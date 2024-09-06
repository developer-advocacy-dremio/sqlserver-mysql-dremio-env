-- Create a Users table in the MySQL database
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(100),
    Email VARCHAR(100)
);

-- Insert some sample data into the Users table
INSERT INTO Users (UserName, Email)
VALUES ('John Doe', 'john.doe@example.com'),
       ('Jane Smith', 'jane.smith@example.com'),
       ('Bob Johnson', 'bob.johnson@example.com');

-- Create a Transactions table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionDate DATE,
    Amount DECIMAL(10, 2),
    UserID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Insert some sample transactions into the Transactions table
INSERT INTO Transactions (TransactionDate, Amount, UserID)
VALUES ('2024-09-01', 500.00, 1),
       ('2024-09-02', 200.00, 2),
       ('2024-09-03', 300.50, 3);