

-- Cell-level encryption example

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
