DROP EXTERNAL TABLE yellow_tripdata;
DROP EXTERNAL DATA SOURCE KrylovaAzureStorage;
DROP DATABASE SCOPED CREDENTIAL AzureStrgCredentialOK;
DROP EXTERNAL FILE FORMAT CSV;

DROP TABLE krylova_schema.fact_tripdata;
DROP TABLE krylova_schema.Vendor;
DROP TABLE krylova_schema.RateCode;
DROP TABLE krylova_schema.Payment_type;
