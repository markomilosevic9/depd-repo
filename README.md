# DEPD internship task

This repository covers the implementation of a test task for a Data Engineer in People Domain internship.

The provided code showcases the design and implementation of a ETL pipeline, including schema setup, mock data generation, and data processing from source tables to a datamart; including incremental loading.

## Documentation

A detailed explanation of the solution design, approach and rationale is provided in [Documentation](https://github.com/markomilosevic9/depd-repo/blob/main/Documentation.pdf) PDF file.


The document includes:
- Data modeling explanation  
- Description of data processing workflow 
- Description of data quality-related approach and considerations
- Analytical queries as requested in the task description

All diagrams included in the documentation are also available in high resolution within the repository (e.g., `picture_1`, `picture_2`, etc.).

## The pipeline
The pipeline logic is placed within few .sql scripts meant to be executed one-by-one:

```bash
└───sql
        schema_init.sql - initializes schemas and tables
        mock_data_insert.sql - handles insertion of initial mock data sample
        etl_source_to_datamart.sql - main pipeline script
        mock_data_incremental_insert.sql - handles insertion of incremental mock data sample
        queries_part_b.sql - contains analytical queries
```
Note that after loading of incremental mock data sample, the re-execution of `etl_source_to_datamart.sql` script is required. 

## Running the pipeline

After cloning the repository or downloading files, you can run the pipeline using Docker. To do so, you can execute following commands in sequence.

From the project root directory:

```bash
docker-compose up -d
```
Then:

```bash
docker exec -i depd-postgres-storage psql -U storage -d ats_data < sql/schema_init.sql
docker exec -i depd-postgres-storage psql -U storage -d ats_data < sql/mock_data_insert.sql
docker exec -i depd-postgres-storage psql -U storage -d ats_data < sql/etl_source_to_datamart.sql
docker exec -i depd-postgres-storage psql -U storage -d ats_data < sql/mock_data_incremental_insert.sql
docker exec -i depd-postgres-storage psql -U storage -d ats_data < sql/etl_source_to_datamart.sql
docker exec -i depd-postgres-storage psql -U storage -d ats_data < sql/queries_part_b.sql

```

These commands create DB schemas and tables, insert initial mock data sample, run the pipeline, insert incremental mock data sample and re-run the pipeline to simulate the incremental loading. 

Also, after launching Docker container, you can connect to PostgreSQL instance via e.g. DBeaver using following parameters:
```
Host: localhost
Port: 5433
DB: ats_data
Username: storage
Password: storage
```

Once connected, you can execute the SQL scripts manually in the same order as described above.

Please note: Docker is used just to simplify environment setup and it is not required. The solution itself can be executed on any PostgreSQL instance, after creation of DB (e.g. ats_data), successful connection and execution of SQL scripts in aforementioned order.


