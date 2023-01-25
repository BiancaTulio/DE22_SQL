

-- Cell-level encryption with asymmetric and symmetric keys example
USE T618
GO

-- Creates a database master key encrypted by password $Str0nGPa$$w0rd
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$tr0nGPa$$w0rd'
GO

-- Creates an asymmetric key encrypted by password '$e1ectPa$$w0rd'
CREATE ASYMMETRIC KEY MyAsymmetricKey
WITH ALGORITHM = RSA_2048 ENCRYPTION BY PASSWORD = '$e1ectPa$$w0rd'
GO

-- Creates an symmetric key encrypted by asymmetric key
CREATE SYMMETRIC KEY MySymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY ASYMMETRIC KEY MyAsymmetricKey
GO

-- Create a test table
CREATE TABLE CreditCard (
	[Name] [varchar](256)
	,[CreditCardNumber] [varchar](16)
	,[EncryptedCreditCardNumber] [varbinary](max)
	)
GO

-- Insert data into the test table
INSERT INTO CreditCard (
	[Name]
	,[CreditCardNumber]
	)
VALUES 
	('Joey Dantoni','9876123456782378'),
	('Bob Jones','1234567898765432')
GO

-- Opening the symmetric key
OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY ASYMMETRIC KEY MyAsymmetricKey
WITH PASSWORD = '$e1ectPa$$w0rd'
GO

-- Update the test table to encrypt the column with credit card numbers
UPDATE CreditCard
SET [EncryptedCreditCardNumber] = ENCRYPTBYKEY(KEY_GUID('MySymmetricKey'), CreditCardNumber)
GO

-- At this point the data is encrypted
SELECT *
FROM [CreditCard]
GO

-- But the key is still open, close the key to prevent decryption
CLOSE SYMMETRIC KEY MySymmetricKey

-- Try decrypting the data, it's not possible and you get a NULL value
SELECT 
	[name], 
	convert(VARCHAR(10), decryptbykey(EncryptedCreditCardNumber)) AS CCNumber 
FROM 
	CreditCard;

-- If the key is opened again, then the data can be decrypted again
OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY ASYMMETRIC KEY MyAsymmetricKey
WITH PASSWORD = '$e1ectPa$$w0rd' 

-- And new records can be inserted and encrypted at the same time
-- If new values are added while the key is closed, they're not gonna be encrypted unless an update is done with the key open
INSERT INTO CreditCard 
	(name, 
	CreditCardNumber,
	EncryptedCreditCardNumber)
VALUES 
	('Drew Brees','7896541234', 
	EncryptByKey(Key_GUID('mySymmetricKey'),'7896541234'));

-- Close the key again, otherwise the data can be decrypted again
CLOSE SYMMETRIC KEY MySymmetricKey


--------------------------------------------------------------------


-- Cell-level encryption with certificate example
USE	BikeStores_Staging
GO

-- First create the master key that's going to be used to encrypt the certificate
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'P455w0rd' 

-- To check the key you created
SELECT 
	[name], 
	algorithm_desc 
FROM 
	sys.symmetric_keys

-- Create the certificate
CREATE CERTIFICATE EncryptionCert 
WITH SUBJECT = 'Certificate for column level encryption'

-- To check the certificate you created (notice that the certificate was created using the master key)
SELECT 
	[name], 
	pvt_key_encryption_type_desc
FROM 
	sys.certificates

-- Now create a symmetric key using the certificate
CREATE SYMMETRIC KEY EncryptionKey 
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE EncryptionCert

-- Checking the symmetric keys again, should have two of them
SELECT 
	[name], 
	algorithm_desc 
FROM 
	sys.symmetric_keys

-- Now create the table with the data to be encrypted. All fields that are going to be enrypted must be of datatype VARBINARY(MAX)
CREATE TABLE 
	Logins(
		ID INT IDENTITY (1,1),
		StaffID INT,
		Fullname VARCHAR(25),
		Username VARCHAR(25),
		[Password] VARBINARY(MAX))

-- Open the key using the certificate
OPEN SYMMETRIC KEY EncryptionKey 
DECRYPTION BY CERTIFICATE EncryptionCert

-- Insert data into the table, using the key to encrypt the sensitive information
INSERT INTO 
	Logins (StaffID, Fullname, Username, [Password])
VALUES
	(1, 'Fabiola Jackson', 'FAJA', ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),'Password123')), 
	(2, 'Mireya Copeland', 'MICO', ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),'Password123')),
	(3, 'Genna Serrano', 'GESE', ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),'Password456'))

-- Close the key
CLOSE SYMMETRIC KEY EncryptionKey

-- See how the encrypted data looks like in the table. The two first rows had the same value but got different cyphers
SELECT * FROM Logins

-- To decrypt the data, open the key again by decrypting it with the certificate
OPEN SYMMETRIC KEY EncryptionKey 
DECRYPTION BY CERTIFICATE EncryptionCert
 
-- But just selecting the data isn't enough to see it
SELECT * FROM Logins
 
-- DECRYPTBYKEY returns a VARBINARY datatype, so in order to see the data it needs to be cast to it's native datatype
SELECT
	ID,
	StaffID,
	Fullname,
	Username,
	CAST(DECRYPTBYKEY([Password]) AS varchar) AS 'Password'
FROM
	Logins

-- Don't forget to close the key again
CLOSE SYMMETRIC KEY EncryptionKey

