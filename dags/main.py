import pandas as pd
from datetime import datetime
from airflow.decorators import dag, task
from airflow.utils.task_group import TaskGroup
from airflow.operators.bash import BashOperator
from airflow.models import Variable


@dag(
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['DE_PROJECT2'],
)
def hr_pipeline():

    with TaskGroup("create_azure_resource", tooltip="Tasks for Terraform operations") as terraform_group:

        # Initialize Terraform
        terraform_init = BashOperator(
            task_id="terraform_init",
            bash_command="terraform -chdir=/usr/local/airflow/include/terraform init"
        )

        # Apply Terraform
        terraform_apply = BashOperator(
            task_id="terraform_apply",
            bash_command="terraform -chdir=/usr/local/airflow/include/terraform apply -auto-approve"
        )

        # Get Storage Access Key and Container Name
        get_access_key_and_container = BashOperator(
            task_id="get_access_key_and_container",
            bash_command="""
            ACCESS_KEY=$(terraform -chdir=/usr/local/airflow/include/terraform output -raw adls_access_key)
            CONTAINER_NAME=$(terraform -chdir=/usr/local/airflow/include/terraform output -raw bronze_container_name)
            airflow variables set ACCESS_KEY $ACCESS_KEY
            airflow variables set CONTAINER_NAME $CONTAINER_NAME
            """,
        )

        # Define dependencies within the TaskGroup
        terraform_init >> terraform_apply >> get_access_key_and_container

    @task()
    def upload_to_bronze_container():
        # Define paths for the local CSV files
        people_data_path = "/usr/local/airflow/include/local/people_data.csv"
        employment_history_path = "/usr/local/airflow/include/local/people_employment_history.csv"

        # Fetch container name and access key from Airflow Variables
        container_name = Variable.get("CONTAINER_NAME")
        storage_account_name = f"{container_name.split('-')[0]}adlsdatapipeline"
        access_key = Variable.get("ACCESS_KEY")

        # Define ADLS paths dynamically
        people_data_adls_path = f"abfs://{container_name}@{storage_account_name}.dfs.core.windows.net/people_data.csv"
        employment_history_adls_path = f"abfs://{container_name}@{storage_account_name}.dfs.core.windows.net/people_employment_history.csv"

        # Use the adlfs library to write the CSV files to ADLS
        storage_options = {"account_key": access_key}

        # Read local files and upload to ADLS
        people_data_df = pd.read_csv(people_data_path)
        employment_history_df = pd.read_csv(employment_history_path)

        people_data_df.to_csv(people_data_adls_path, index=False, storage_options=storage_options)
        employment_history_df.to_csv(employment_history_adls_path, index=False, storage_options=storage_options)

    # Define the task dependencies
    terraform_group >> upload_to_bronze_container()


hr_dag = hr_pipeline()
