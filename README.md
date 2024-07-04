# tw_real_estate

This is a side project to collect Taiwan real estate transaction data through ELT pipeline. It composed of following elements:

1. Web crawler of transaction data from the following websites to GCP cloud storgage
    + https://plvr.land.moi.gov.tw/DownloadOpenData
2. Extract and Load Tools.
    + Meltano or Python from Cloud Storage to Bigquery
3. Orchestration with kestra or dagster.
4. Transformation with dbt
5. Visualization with PBI.
