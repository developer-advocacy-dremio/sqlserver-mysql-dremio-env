# Docker Compose Setup for Dremio, MinIO, Nessie, SQL Server, and MySQL

This Docker Compose configuration sets up a local environment for Dremio, MinIO (object storage), Nessie (data versioning), SQL Server, and MySQL. Each service is configured to run in a Docker container and linked via a custom Docker network.

## Services Overview

### 1. **Dremio**
   - **Image**: `dremio/dremio-oss:latest`
   - **Container Name**: `dremio`
   - **Ports**:
     - `9047:9047`: Dremio web UI
     - `31010:31010`: Dremio JDBC/ODBC communication
     - `32010:32010`: Arrow Flight protocol
     - `45678:45678`: Dremio internal communication
   - **Environment Variables**:
     - `DREMIO_JAVA_SERVER_EXTRA_OPTS`: Configures Dremio to use a custom distribution path for additional data.
   - **Depends On**: MinIO, Nessie, SQL Server, and MySQL. Dremio will not start until these services are running.
   - **Network**: `sql-mysql-dremio`

### 2. **MinIO (Object Storage)**
   - **Image**: `minio/minio`
   - **Container Name**: `minio`
   - **Environment Variables**:
     - `MINIO_ROOT_USER`: Sets the MinIO admin username to `admin`.
     - `MINIO_ROOT_PASSWORD`: Sets the MinIO admin password to `password`.
   - **Command**: Starts the MinIO server and creates two buckets: `datalake` and `datalakehouse` using the MinIO client (`mc`).
   - **Ports**:
     - `9000:9000`: MinIO S3-compatible API endpoint.
     - `9001:9001`: MinIO console (web UI).
   - **Healthcheck**:
     - Checks the MinIO health endpoint (`/minio/health/live`) every 30 seconds to ensure the service is running.
   - **Network**: `sql-mysql-dremio`

### 3. **Nessie (Data Versioning)**
   - **Image**: `projectnessie/nessie`
   - **Container Name**: `nessie`
   - **Environment Variables**:
     - `QUARKUS_PROFILE`: Sets the profile to `sqlserver`, as Nessie is using SQL Server as its metadata storage.
     - `QUARKUS_DATASOURCE_JDBC_URL`: Connects to SQL Server at `sqlserver:1433`, and uses the `nessie` database.
     - `QUARKUS_DATASOURCE_USERNAME`: SQL Server user `SA`.
     - `QUARKUS_DATASOURCE_PASSWORD`: Password for the `SA` user (`YourStrong!Passw0rd`).
   - **Ports**:
     - `19120:19120`: Nessie REST API endpoint.
   - **Depends On**: SQL Server.
   - **Network**: `sql-mysql-dremio`

### 4. **SQL Server (Relational Database)**
   - **Image**: `mcr.microsoft.com/mssql/server:2019-latest`
   - **Container Name**: `sqlserver`
   - **Environment Variables**:
     - `ACCEPT_EULA`: Accepts the Microsoft SQL Server EULA (`Y`).
     - `SA_PASSWORD`: Sets the SQL Server `SA` password to `YourStrong!Passw0rd`.
   - **Ports**:
     - `1433:1433`: Exposes the default SQL Server port.
   - **Volumes**:
     - Mounts the `./seed/sqlserver` directory to `/var/opt/mssql/seed` to include the seed SQL files.
   - **Command**:
     - Starts SQL Server, waits 30 seconds for the service to be ready, and runs the seed SQL file (`init.sql`) to initialize the database with pre-defined tables and data.
   - **Network**: `sql-mysql-dremio`

### 5. **MySQL (Relational Database)**
   - **Image**: `mysql:8.0`
   - **Container Name**: `mysql`
   - **Environment Variables**:
     - `MYSQL_ROOT_PASSWORD`: Sets the MySQL root password to `rootpassword`.
     - `MYSQL_DATABASE`: Creates a database called `mydatabase`.
     - `MYSQL_USER`: Creates a user `user`.
     - `MYSQL_PASSWORD`: Sets the password for the MySQL user `user` to `password`.
   - **Ports**:
     - `3307:3306`: Maps the default MySQL port (3306) to 3307 on the host machine.
   - **Volumes**:
     - Mounts the `./seed/mysql` directory to `/docker-entrypoint-initdb.d/` for automatic execution of SQL seed files during container initialization.
   - **Network**: `sql-mysql-dremio`

## Networks

- **sql-mysql-dremio**: A custom Docker bridge network that links all services (Dremio, MinIO, Nessie, SQL Server, and MySQL) for inter-service communication.

## Seed Data

- **SQL Server Seed**: The `./seed/sqlserver/init.sql` file is executed when the SQL Server container starts. This SQL file creates tables (e.g., `Customers`, `Orders`) and inserts sample data.
- **MySQL Seed**: Any `.sql` files placed in `./seed/mysql` will be executed when the MySQL container starts, allowing you to initialize the database with pre-defined tables and data.

## How to Run the Docker Compose

1. **Ensure Docker and Docker Compose are installed**.
2. Save the `docker-compose.yml` file and place any seed files in the `./seed/sqlserver` and `./seed/mysql` directories.
3. Run the following command to start all services:

```bash
docker-compose up -d
```

**Access the services:**
- **Dremio:** http://localhost:9047
- **MinIO:** http://localhost:9001
- **Nessie API:** http://localhost:19120
- **SQL Server:** Accessible on localhost:1433
- **MySQL:** Accessible on localhost:3307

## Stopping and Cleaning Up
To stop the services, run:

```bash
docker-compose down
```
To stop and remove all data volumes (clean slate), run:

```bash
docker-compose down -v
```

# Connecting SQL Server and MySQL to Dremio from the Dremio Web UI

## 1. Connecting to SQL Server

SQL Server is a relational database, and Dremio supports it natively. Here's how to add SQL Server as a data source:

### Steps:

1. **Log in to Dremio**: Open your browser and go to `http://localhost:9047`. Log in with your Dremio credentials.

2. **Navigate to Sources**:
   - Click on the **Sources** tab in the left-hand sidebar.

3. **Add SQL Server as a Source**:
   - Click **+ Source** in the upper-right corner.
   - Select **SQL Server** from the list of available source types.

4. **Configure SQL Server Source**:
   - **Name**: Give your SQL Server source a name (e.g., `sqlserver_data`).
   - **Hostname**: Enter `localhost` (or `sqlserver` if referencing the Docker container name).
   - **Port**: Enter `1433` (the default SQL Server port).
   - **Database**: Enter `nessie` (the database name for Nessie, or any other relevant database).
   - **Username**: Enter `SA` (the default SQL Server admin user).
   - **Password**: Enter `YourStrong!Passw0rd` (as set in the Docker Compose file).

5. **Click Save**: After filling in the details, click **Save**. You can now query data stored in SQL Server from Dremio.

---

## 2. Connecting to MySQL

MySQL is another relational database supported natively by Dremio.

### Steps:

1. **Log in to Dremio**: If you're not already logged in, go to `http://localhost:9047` and log in.

2. **Navigate to Sources**:
   - Click on the **Sources** tab in the left-hand sidebar.

3. **Add MySQL as a Source**:
   - Click **+ Source** in the upper-right corner.
   - Select **MySQL** from the list of available source types.

4. **Configure MySQL Source**:
   - **Name**: Give your MySQL source a name (e.g., `mysql_data`).
   - **Hostname**: Enter `mysql` (or `mysql` if referencing the Docker container name).
   - **Port**: Enter `3306` (the default MySQL port).
   - **Database**: Enter `mydatabase` (the default database name defined in the Docker Compose file).
   - **Username**: Enter `user` (the user defined in the Docker Compose file).
   - **Password**: Enter `password` (as set in the Docker Compose file).

5. **Click Save**: Once you’ve filled in the necessary details, click **Save**. Dremio will now be connected to MySQL, and you can query data stored in MySQL from Dremio.

---

## 3. Connecting to MinIO (Object Storage)

MinIO provides S3-compatible object storage, and you can add it as an external source in Dremio.

### Steps:

1. **Log in to Dremio**: If you're not already logged in, go to `http://localhost:9047` and log in.

2. **Navigate to Sources**:
   - Click on the **Sources** tab in the left-hand sidebar.

3. **Add MinIO as a Source**:
   - Click **+ Source** in the upper-right corner.
   - Select **Amazon S3** from the list of available source types. MinIO is S3-compatible, so use this option.

4. **Configure MinIO Source**:
   - **Name**: Give your MinIO source a name (e.g., `minio`).
   - **Access Key**: Enter `admin` (as per your Docker Compose environment variables).
   - **Secret Key**: Enter `password` (as per your Docker Compose environment variables).
   - **External Bucket Name**: Specify the bucket you want to access. For example, `datalake`.
   - **Root Path**: Leave blank if accessing the whole bucket, or provide a specific path.
   - **Encryption**: Set this to `None` for unencrypted data. (since your operating in this demo environment)
   - **Enable Compatibility with AWS S3**: Check this option since MinIO is S3-compatible.
   - **Connection Properties**: set the following connection properties:
        - `fs.s3a.path.style.access` to true
        - `fs.s3a.endpoint` to the endpoint of MinIO (minio:9000)

5. **Click Save**: Once the configuration is set, click **Save**. You will now be able to browse and query data stored in MinIO directly from Dremio.

## 4. Connecting to Nessie

Nessie is a version control system for your data lake and can be connected to Dremio using the built-in Nessie support.

### Steps:

1. **Log in to Dremio**: Open your browser and go to `http://localhost:9047`. Log in with your Dremio credentials.
   
2. **Navigate to Sources**:
   - On the Dremio Web UI, click on the **Sources** tab in the left-hand sidebar.
   
3. **Add Nessie as a Source**:
   - Click **+ Source** in the upper-right corner.
   - Select **Nessie** from the list of available source types.

4. **Configure Nessie Source**:
   - **Name**: Give your Nessie source a name (e.g., `nessie`).
   - **Nessie REST API URL**: Enter `http://nessie:19120` (the API URL exposed by the Nessie container, based on the `container_name` defined in the `docker-compose.yml` file).
   - **Authentication**: Choose `None`

5. **Configure Nessie Storage**:
    - set the warehouse address to the name of the bucket in MinIO (datalakehouse)
    - access key and secret key are the same as the ones used to access MinIO defined  in the docker-compose.yml file. (admin/password)
    - set the following custom parameters:
        - `fs.s3a.path.style.access` to true
        - `fs.s3a.endpoint` to the endpoint of MinIO (minio:9000)
        - `dremio.s3.compat` to true
    
6. **Click Save**: Once the configuration is set, click **Save**. Dremio will now be connected to Nessie, and you will be able to read and write versioned data using Iceberg tables managed by Nessie.
---

## Summary

- **SQL Server**: Use `localhost:1433` with `SA` as the username and `YourStrong!Passw0rd` as the password.
- **MySQL**: Use `localhost:3306` with `user` as the username and `password` as the password.
- **MinIO**: Use the `http://localhost:9000` endpoint with `admin/password`.

These sources can now be queried, transformed, and joined within Dremio using SQL queries.

