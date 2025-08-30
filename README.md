# HR Data Pipeline with Azure Databricks and DBT

This project aims to implement dbt on Azure Databricks to build an end-to-end HR data pipeline on the Azure platform. The pipeline involves provisioning infrastructure, processing raw data with Azure Databricks, applying dbt transformations, and visualizing insights in Power BI.

## Architecture

![Pipeline Flow](/images/pipeline_architecture.png "Project Architecture")

This project leverages Azure services such as Azure Databricks, Azure Storage, Synapse Studio, and Key Vault to build an end-to-end HR data pipeline. Airflow orchestrates infrastructure provisioning using Terraform and facilitates the upload of local HR data into the bronze container in Azure Storage.

## Project Flow

1. **Run Airflow DAGs**:  
   Execute Airflow DAGs to:
    - Create Azure resources (Resource Group, Storage Account, etc.).
    - Upload the raw HR data into the bronze container

        ![](/images/1.airflow_dag.png "")

2. **Verify Azure Resource Group**:
    - Check the Azure Resource Group to confirm the resources are successfully created.

        ![](/images/2.azure_resource.png "")

3. **Check Azure Storage**:  
    - Ensure the required storage containers (bronze, silver, and gold) are created successfully

        ![](/images/3.azure_containers.png "")

4. **Verify Bronze Container**:  
    - Open the bronze container to confirm the raw HR data has been uploaded correctly.

        ![](/images/4.container_bronze.png "")

5. **Secure Access Key with Azure Key Vault**:  
    - Use Azure Key Vault to securely store the Storage Account key and other sensitive credentials

        ![](/images/5.azure_keyvault.png "")

6. **Create Azure Databricks Workspace**:  
    - Open Azure Databricks and create a new workspace for data processing and analytics


7. **Create Secret Scope in Databricks**: 
    - Set up a Secret Scope to securely access the Azure Storage Account from Databricks

        ![](/images/7.databricks_secretscope.png "")

8. **Mount Storage Containers in Databricks**: 
    - Create a Databricks Notebook to mount the bronze, silver, and gold storage containers

        ![](/images/8.databricks_nb_1.png "")

9. **Create Database and Tables in Databricks**: 
    - Create another Databricks Notebook to set up a database and tables in the catalog for the raw HR data

        ![](/images/9.databricks_nb_2.png "")

10. **Connect Databricks to dbt**: 
    - Configure databricks-cli and generate an access token to integrate Databricks with dbt


11. **Define dbt Sources**: 
    - Create a sources.yml file in dbt to specify the database and schema for your source tables

        ![](/images/11.dbt_sources.png "")

12. **Snapshot Raw Data**: 
    - Use dbt to create snapshots of the raw data and store them in the silver container

        ![](/images/12.dbt_snapshots.png "")

    - Confirm the snapshot has been stored correctly in the silver container

        ![](/images/12.container_silver.png "")

13. **Create Analytical Models**: 
    - Use dbt to create models for reports and analytics, storing the results in the gold container

        ![](/images/13.dbt_models.png "")

    - Confirm the models has been stored correctly in the gold container

        ![](/images/13.container_gold.png "")

14. **Run dbt Tests**: 
    - Implement and run dbt tests to validate data quality in the gold container

        ![](/images/14.dbt_test.png "")

15. **Verify Data in Catalog Explorer**: 
    - Use the Databricks Catalog Explorer to confirm the data is organized and accessible

        ![](/images/15.databricks_catalog.png "")
    
16. **Set Up Synapse Studio**: 
    - Open Azure Synapse Studio and create a Lake Database
    - Use Synapse Serverless to connect tables from the gold container into a star schema

        ![](/images/17.azure_synapse.png "")

17. **Integrate with Power BI**: 
    - Open Power BI Desktop and load the star schema data from Synapse Serverless

        ![](/images/18.powerbi_load.png "")

    - Build dashboards for reporting

        ![](/images/19.powerbi_apps.gif "")

18. **Host dbt Docs on Azure Static Web Apps (Optional)**: 
    - Deploy the dbt docs site to an Azure Static Web App to host it for free

        ![](/images/20.azure_webapp_2.png "")

19. **Explore dbt Docs**: 
    - Use the dbt docs site to explore models, sources, and transformations in detail

        ![](/images/21.dbt_docs.png "")

20. **Analyze Lineage Graph**: 
    - Open the dbt Lineage Graph to visualize dependencies between raw data, snapshots, and marts tables

        ![](/images/22.dbt_lineage.png "")

## Additional Notes

- Terraform does not provision:
  - Azure Linked Services.
  - Azure Databricks clusters and notebooks

- These configurations must be set up manually before running the pipeline.

## Prerequisites

1. **Azure Subscription**: 
    - Ensure you have an active Azure subscription with Owner or Contributor access to provision the required resources.
2. **Airflow Environment**: 
    - Install and configure Airflow locally or using Astronomer. If using Astronomer, ensure the Astronomer CLI is installed.
3. **Azure CLI**:
    - Install Azure CLI to authenticate with Azure for Terraform provisioning.
4. **Terraform**: 
    - Install Terraform (v1.5 or later) and set up the configuration files for Azure resource provisioning.
5. **Databricks CLI**: 
    - Install and configure Databricks CLI with an access token to interact with Databricks resources.
   