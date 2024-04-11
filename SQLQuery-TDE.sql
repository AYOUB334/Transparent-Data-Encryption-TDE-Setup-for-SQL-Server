-- Create master key for encryption
USE Master;
GO

CREATE MASTER KEY ENCRYPTION
BY PASSWORD='12345';
GO

-- Create certificate for TDE (Transparent Data Encryption)
CREATE CERTIFICATE 
TDE_Cert WITH SUBJECT='Database_Encryption';

-- Switch to the desired database
USE Ecole;

-- Create database encryption key
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM=AES_256 ENCRYPTION 
BY SERVER CERTIFICATE TDE_Cert;

-- Enable encryption for the database
ALTER DATABASE Ecole
SET ENCRYPTION ON;

-- Check encryption status for all databases
SELECT is_encrypted, *
FROM sys.databases;

-- Backup the certificate and private key
BACKUP CERTIFICATE TDE_Cert
TO FILE='D:\SQL\TDE_Cert'
WITH PRIVATE KEY
(file='D:\SQL\TDE_CertKey.pvk',
ENCRYPTION BY PASSWORD='1234');

-- Switch back to master database
USE Master;
GO

-- Create master key for decryption
CREATE MASTER KEY ENCRYPTION
BY PASSWORD='1234';

-- Check database encryption status
SELECT db.name, dek.*
FROM sys.dm_database_encryption_keys dek
INNER JOIN sys.databases db ON dek.database_id=db.database_id;

-- Backup the encrypted database
BACKUP DATABASE Ecole TO DISK = 'D:\SQL\Ecole.bak';

-- Drop the certificate and associated database
USE Master;
DROP CERTIFICATE TDE_Cert;
DROP DATABASE Ecole;

-- Restore the certificate and private key
CREATE CERTIFICATE TDE_Cert
FROM FILE='D:\SQL\TDE_Cert'
WITH PRIVATE KEY
(file='D:\SQL\TDE_CertKey.pvk',
DECRYPTION BY PASSWORD='1234');

