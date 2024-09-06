-- Create a Customers table in the Nessie database
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100),
    Email NVARCHAR(100)
);

-- Insert some sample data into the Customers table
INSERT INTO Customers (CustomerName, Email)
VALUES ('John Doe', 'john.doe@example.com'),
       ('Jane Smith', 'jane.smith@example.com'),
       ('Alice Johnson', 'alice.johnson@example.com');

-- Create an Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderDate DATE,
    Amount DECIMAL(10, 2),
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Insert some sample orders into the Orders table
INSERT INTO Orders (OrderDate, Amount, CustomerID)
VALUES ('2024-09-01', 250.00, 1),
       ('2024-09-02', 150.50, 2),
       ('2024-09-03', 320.75, 3);