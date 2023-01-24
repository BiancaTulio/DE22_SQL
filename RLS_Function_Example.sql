
-- Example of RLS function creation and activation
USE T618
GO

-- create a few users, the Manager is gonna have access to everything, while the Sellers will see only their own sales
CREATE USER Manager WITHOUT LOGIN;
CREATE USER Sales1 WITHOUT LOGIN;
CREATE USER Sales2 WITHOUT LOGIN;
GO


-- create an example table
CREATE TABLE Sales
(
OrderID int,
SalesRep sysname,		  --nvarchar(128)
Product varchar(10),
Qty int
)
GO


-- add values to the table
INSERT INTO Sales VALUES
(1, 'Sales1', 'Valve', 5),
(2, 'Sales1', 'Wheel', 2),
(3, 'Sales1', 'Valve', 4),
(4, 'Sales2', 'Bracket', 2),
(5, 'Sales2', 'Wheel', 5),
(6, 'Sales2', 'Seat', 5); 

SELECT * FROM Sales;


-- grant permission to the users
GRANT SELECT ON Sales TO Manager;
GRANT SELECT ON Sales TO Sales1;
GRANT SELECT ON Sales TO Sales2;
GO


-- create a Schema only for security, that the users are not gonna have access to
CREATE SCHEMA [Security] AUTHORIZATION dbo
GO


-- Not needed in the code right now, just an example of how to change the user and get it's name
SELECT USER_NAME();
EXECUTE AS USER = 'Sales1';
SELECT USER_NAME();
REVERT;

EXECUTE AS USER = 'Manager';
SELECT USER_NAME();
REVERT; 
GO


-- create the function
CREATE FUNCTION 
	[Security].fn_securitypredicate(@SalesRep AS sysname)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN 
	SELECT 1 AS fn_securitypredicate_result			 -- give permission to see the row
	WHERE @SalesRep = USER_NAME()					 -- if the column for SalesRep matches the name of the user
	OR USER_NAME() = 'Manager';						 -- or if the user is the Manager
GO


-- activate the function
CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE [Security].fn_securitypredicate(SalesRep)		  -- concerns only SELECT
ON dbo.Sales
WITH (STATE = ON);


-- try with the different users
EXECUTE AS USER = 'Sales1';
SELECT * FROM Sales;
REVERT;

EXECUTE AS USER = 'Sales2';
SELECT * FROM Sales;
REVERT;

EXECUTE AS USER = 'Manager';
SELECT * FROM Sales;
REVERT;


