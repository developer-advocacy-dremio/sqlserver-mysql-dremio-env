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
   - **Hostname**: Enter `localhost` (or `mysql` if referencing the Docker container name).
   - **Port**: Enter `3306` (the default MySQL port).
   - **Database**: Enter `mydatabase` (the default database name defined in the Docker Compose file).
   - **Username**: Enter `user` (the user defined in the Docker Compose file).
   - **Password**: Enter `password` (as set in the Docker Compose file).

5. **Click Save**: Once you’ve filled in the necessary details, click **Save**. Dremio will now be connected to MySQL, and you can query data stored in MySQL from Dremio.

---

## 3. Connecting to MinIO (Object Storage)

MinIO configuration remains the same as in the original setup. Follow the same steps to connect it to Dremio as an S3-compatible source.

---

## Summary

- **SQL Server**: Use `localhost:1433` with `SA` as the username and `YourStrong!Passw0rd` as the password.
- **MySQL**: Use `localhost:3306` with `user` as the username and `password` as the password.
- **MinIO**: Use the `http://localhost:9000` endpoint with `admin/password`.

These sources can now be queried, transformed, and joined within Dremio using SQL queries.

