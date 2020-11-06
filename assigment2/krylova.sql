
-- 3. Создать юзера и схему(Под админом)
CREATE LOGIN [o_krylova] WITH PASSWORD=N'password';
GO

CREATE SCHEMA krylova_schema;  
GO

CREATE USER olga_k FROM LOGIN o_krylova
WITH DEFAULT_SCHEMA = krylova_schema;
GO

EXECUTE sp_addrolemember db_owner, olga_k;
GO

-- 5. Создать екстернал data source

CREATE DATABASE SCOPED CREDENTIAL AzureStrgCredentialOK
WITH
  IDENTITY = 'bigdatashc01' ,
  SECRET = 'Key' ;
GO

CREATE EXTERNAL DATA SOURCE KrylovaAzureStorage
WITH (
    LOCATION = 'wasbs://container01@bigdatashc01.blob.core.windows.net',
    CREDENTIAL = AzureStrgCredentialOK ,
    TYPE = HADOOP
);
GO

 -- 6. Создать екстернал таблицу для файла  yellow_tripdata_2020-01 на основе екстернал data source

CREATE EXTERNAL FILE FORMAT CSV
WITH (FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS(
        FIELD_TERMINATOR = ',',
        STRING_DELIMITER = '"',
        FIRST_ROW = 2, 
        USE_TYPE_DEFAULT = False
    )
);
GO

CREATE EXTERNAL TABLE yellow_tripdata(
    VendorID int,
    tpep_pickup_datetime datetime,
    tpep_dropoff_datetime datetime,
    passenger_count int,
    trip_distance decimal(9,2),
    RatecodeID int,
    store_and_fwd_flag varchar(1),
    PULocationID int,
    DOLocationID int,
    payment_type int,
    fare_amount decimal(7,2),
    extra decimal(7,2), 
    mta_tax decimal(7,2),
    tip_amount decimal(7,2),
    tolls_amount decimal(7,2),
    improvement_surcharge decimal(7,2),
    total_amount decimal(7,2),
    congestion_surcharge decimal(7,2)
)
WITH (
    LOCATION = '/yellow_tripdata_2020-01.csv',
    DATA_SOURCE = KrylovaAzureStorage,
    FILE_FORMAT = CSV
);
GO

-- 7. Выгрузить данные из external table в таблицу "ВашаСхема".fact_tripdata. 
-- Таблица должна быть Hash-distributed tables

CREATE TABLE krylova_schema.fact_tripdata
WITH  
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = HASH (tpep_pickup_datetime)  
)  
AS SELECT * FROM yellow_tripdata;
GO

-- -- 8. Создать таблицы справочники на основе документа data_dictionary_trip_records_yellow(вручную) 
-- -- Vendor(поля ID, Name) 
-- -- RateCode(поля ID, Name) 
-- -- Payment_type (поля ID, Name) 
-- -- Выбрать правильную схему распределения(distribution) для них


CREATE TABLE krylova_schema.Vendor(
    ID int,
    Name varchar(64)
)
WITH (
    DISTRIBUTION = REPLICATE
);
GO

INSERT INTO krylova_schema.Vendor (ID, Name) VALUES (1, 'Creative Mobile Technologies, LLC');
INSERT INTO krylova_schema.Vendor (ID, Name) VALUES (2, 'VeriFone Inc.');

CREATE TABLE krylova_schema.RateCode(
    ID int,
    Name varchar(64)
)
WITH (
    DISTRIBUTION = REPLICATE
);
GO

INSERT INTO krylova_schema.RateCode (ID, Name) VALUES (1, 'Standard rate');
INSERT INTO krylova_schema.RateCode (ID, Name) VALUES (2, 'JFK');
INSERT INTO krylova_schema.RateCode (ID, Name) VALUES (3, 'Newark');
INSERT INTO krylova_schema.RateCode (ID, Name) VALUES (4, 'Nassau or Westchester');
INSERT INTO krylova_schema.RateCode (ID, Name) VALUES (5, 'Negotiated fare');
INSERT INTO krylova_schema.RateCode (ID, Name) VALUES (6, 'Group ride');

CREATE TABLE krylova_schema.Payment_type(
    ID int,
    Name varchar(64)
)
WITH (
    DISTRIBUTION = REPLICATE
);
GO

INSERT INTO krylova_schema.Payment_type (ID, Name) VALUES (1, ' Credit card');
INSERT INTO krylova_schema.Payment_type (ID, Name) VALUES (2, 'Cash');
INSERT INTO krylova_schema.Payment_type (ID, Name) VALUES (3, 'No charge');
INSERT INTO krylova_schema.Payment_type (ID, Name) VALUES (4, 'Dispute');
INSERT INTO krylova_schema.Payment_type (ID, Name) VALUES (5, 'Unknown');
INSERT INTO krylova_schema.Payment_type (ID, Name) VALUES (6, 'Voided trip');
