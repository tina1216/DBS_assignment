/******************************************

Encryption - Column Level Encryption

******************************************/
CREATE PROCEDURE SelectAllPatients
AS
SELECT * FROM dbo.Patient
GO;
EXEC SelectAllPatients;

-- Patient ============================================

ALTER TABLE Patient ADD PassportNumber_Encrypted VARBINARY(MAX);
ALTER TABLE Patient ADD PaymentCardNumber_Encrypted VARBINARY(MAX);
ALTER TABLE Patient ADD PaymentCardPinCode_Encrypted VARBINARY(MAX);

-- Update existing records with encrypted data
---Step 1 - Create Master Key
CREATE master key encryption BY password = 'QwErTy12345!@#$%'
go
SELECT * FROM sys.symmetric_keys
go

---Step 2 - Create a certificate for encryption
CREATE Certificate Cert_Patient
With Subject = 'Cert_For_Patient_Table'
go
select * from sys.certificates

-- 3. Update existing records with encrypted data using ENCRYPTBYCERT
UPDATE Patient
SET 
    PassportNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Patient'), PPassportNumber),
    PaymentCardNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Patient'), PaymentCardNumber), 
    PaymentCardPinCode_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Patient'), PaymentCardPinCode)

-- 4. Test : Decrypting data using DECRYPTBYCERT for demonstration
SELECT 
    PID, 
    CONVERT(VARCHAR(100), DECRYPTBYCERT(CERT_ID('Cert_Patient'), PaymentCardNumber_Encrypted)) AS DecryptedCardNumber, 
    CONVERT(VARCHAR(50), DECRYPTBYCERT(CERT_ID('Cert_Patient'), PassportNumber_Encrypted)) AS DecryptedPassportNumber,
    CONVERT(VARCHAR(50), DECRYPTBYCERT(CERT_ID('Cert_Patient'), PaymentCardPinCode_Encrypted)) AS DecryptedPaymentCardPinCode
FROM Patient
-- WHERE PID = 'P20001' OR PID = 'P20002';

-- 5. Remove previous unencrypted columns
ALTER TABLE Patient DROP COLUMN PPassportNumber;
ALTER TABLE Patient DROP COLUMN PaymentCardNumber;
ALTER TABLE Patient DROP COLUMN PaymentCardPinCode;

EXEC SelectAllPatients

-- Staff ============================================
CREATE PROCEDURE SelectAllStaff
AS
SELECT * FROM dbo.Staff
GO;
EXEC SelectAllStaff;

-- Add new columns to hold the encrypted data.
ALTER TABLE Staff ADD SPassportNumber_Encrypted VARBINARY(MAX);

-- Update existing records with encrypted data
---Step 1 - Create Master Key (if haven't)
CREATE master key encryption BY password = 'QwErTy12345!@#$%'
go
SELECT * FROM sys.symmetric_keys
go

---Step 2 - Create a certificate for encryption
CREATE Certificate Cert_Staff
With Subject = 'Cert_For_Staff_Table'
go
select * from sys.certificates

-- 3. Update existing records with encrypted data using ENCRYPTBYCERT
UPDATE Staff
SET 
    SPassportNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Staff'), SPassportNumber)

-- 4. Test : Decrypting data using DECRYPTBYCERT for demonstration
SELECT 
    StaffID,  
    CONVERT(VARCHAR(50), DECRYPTBYCERT(CERT_ID('Cert_Staff'), SPassportNumber_Encrypted)) AS DecryptedPassportNumber
FROM Staff

-- 5. Remove previous unencrypted columns
ALTER TABLE Staff DROP COLUMN SPassportNumber;

EXEC SelectAllStaff

/****** 
Protect the data before passing a copy of the database to the development team.
(Encrypt-decrypt PName & PPhone)
******/
-- Patient ============================================
ALTER TABLE Patient ADD PName_Encrypted VARBINARY(MAX);
ALTER TABLE Patient ADD PhoneNumber_Encrypted VARBINARY(MAX);

EXEC SelectAllPatients;

-- Master key
-- (already created)

-- Show Certificate
CREATE CERTIFICATE PatientDataCertificate
WITH SUBJECT = 'Patient Data Encryption(name and phone numbers)';
GO
SELECT * FROM sys.certificates

-- Encrypt
UPDATE dbo.Patient
SET 
    PName_Encrypted = ENCRYPTBYCERT(CERT_ID('PatientDataCertificate'), PName),
    PhoneNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('PatientDataCertificate'), PPhone);

EXEC SelectAllPatients;

-- Decrypt
SELECT 
    PID, 
    CONVERT(VARCHAR(100), DECRYPTBYCERT(CERT_ID('PatientDataCertificate'), PName_Encrypted)) AS DecryptedName,
    CONVERT(VARCHAR(12), DECRYPTBYCERT(CERT_ID('PatientDataCertificate'), PhoneNumber_Encrypted)) AS DecryptedPhone
FROM Patient;

-- Delete columns
ALTER TABLE Patient DROP COLUMN PName;
ALTER TABLE Patient DROP COLUMN PPhone;

-- View
EXEC SelectAllPatients;

-- Staff ============================================
ALTER TABLE Staff ADD SName_Encrypted VARBINARY(MAX);
ALTER TABLE Staff ADD SPhone_Encrypted VARBINARY(MAX);
ALTER TABLE Staff ADD SystemUserID_Encrypted VARBINARY(MAX);

EXEC SelectAllStaff;

-- Master key
-- (already created)

-- Show Certificate
CREATE CERTIFICATE StaffDataCertificate
WITH SUBJECT = 'Staff Data Encryption(name and phone numbers)';
GO
SELECT * FROM sys.certificates

-- Encrypt
UPDATE dbo.Staff
SET 
    SName_Encrypted = ENCRYPTBYCERT(CERT_ID('StaffDataCertificate'), SName),
    SPhone_Encrypted = ENCRYPTBYCERT(CERT_ID('StaffDataCertificate'), SPhone),
    SystemUserID_Encrypted = ENCRYPTBYCERT(CERT_ID('StaffDataCertificate'), SystemUserID);

EXEC SelectAllStaff;

-- Decrypt
SELECT 
    StaffID, 
    CONVERT(VARCHAR(100), DECRYPTBYCERT(CERT_ID('StaffDataCertificate'), SName_Encrypted)) AS DecryptedName,
    CONVERT(VARCHAR(12), DECRYPTBYCERT(CERT_ID('StaffDataCertificate'), SPhone_Encrypted)) AS DecryptedPhone,
    CONVERT(VARCHAR(12), DECRYPTBYCERT(CERT_ID('StaffDataCertificate'), SystemUserID_Encrypted)) AS DecryptedSystemUserID
FROM Staff;

-- Delete columns
ALTER TABLE Staff DROP COLUMN SName;
ALTER TABLE Staff DROP COLUMN SPhone;
ALTER TABLE Staff DROP COLUMN SystemUserID;

-- View
EXEC SelectAllStaff;


/******************************************

Encryption - Transparent Data Encryption (TDE)

******************************************/
-- a master key (Create one if havent)

-- 1.2 Create a certificate protected by the master key
CREATE CERTIFICATE MedicalInfoSystem WITH SUBJECT = 'TDE Certificate for Medical Info System';
GO

-- 1.3 Switch to your database and create a database encryption key
USE MedicalInfoSystem;
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MedicalInfoSystem;
GO

-- 1.4 Enable encryption on the database
ALTER DATABASE MedicalInfoSystem
SET ENCRYPTION ON;
GO

-- To off,
ALTER DATABASE MedicalInfoSystem
SET ENCRYPTION OFF;
GO

-- 2.1 Backup the encrypted database
USE master;
GO
BACKUP DATABASE MedicalInfoSystem
TO DISK = '/var/opt/mssql/data/MedicalInfoSystem.bak';  -- path for MAC OS
GO

/*****************************

encrypt a column of data by using symmetric encryption ??

*****************************/




/************************************

Backup Database

************************************/
-- Create Backup 
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123';
GO

CREATE CERTIFICATE MedicalInfoSystem_DB_Cert  
   WITH SUBJECT = 'MedicalInfoSystem_DB_Cert';  
GO
Select thumbprint From sys.certificates where name = 'MedicalInfoSystem_DB_Cert'

BACKUP CERTIFICATE MedicalInfoSystem_DB_Cert 
TO FILE = '/var/opt/mssql/data/MedicalInfoSystem_DB_Cert.cert'
WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/data/MedicalInfoSystem_DB_Cert.key', 
    ENCRYPTION BY PASSWORD = 'QWEqwe!@#123'
);
Go

-- Restore data from backup
Use master
Go
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'MyBackUpPassword$$12345'
Create CERTIFICATE MedicalInfoSystem_DB_Cert
From FILE = '/var/opt/mssql/data/MedicalInfoSystem_DB_Cert.cert'
WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/data/MedicalInfoSystem_DB_Cert.key', 
    DECRYPTION BY PASSWORD = 'QWEqwe!@#123'
);

Use master
Go
BACKUP DATABASE MedicalInfoSystem_Anonymise
TO DISK = '/var/opt/mssql/data/MedicalInfoSystem.bak' 
WITH  
    FORMAT, INIT,
    COMPRESSION,  
    ENCRYPTION   
    (  
    ALGORITHM = AES_256,  
    SERVER CERTIFICATE = MedicalInfoSystem_DB_Cert  
    )
GO

-- Copy the database and certificate backup files to another location 
-- accessible by the other instance
-- perform permission management so that the backup file, certificate 
-- and private key is accessible by the new instance account

--Another Server/Instance - run in the new server
USE MASTER
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123';
GO

--Recreate the Certificate From The File
USE MASTER
GO
Create CERTIFICATE MedicalInfoSystem_cert
From FILE = '/var/opt/mssql/data/MedicalInfoSystem_DB_Cert.cert'
WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/data/MedicalInfoSystem_DB_Cert.key', 
    DECRYPTION BY PASSWORD = 'QWEqwe!@#123'
);

RESTORE DATABASE MedicalInfoSystem_Anonymise 
FROM DISK = '/var/opt/mssql/data/MedicalInfoSystem.bak'
WITH MOVE 'MedicalInfoSystem_Anonymise' TO '/var/opt/mssql/data/MedicalInfoSystem_Anonymise.mdf',
MOVE 'MedicalInfoSystem_Anonymise_Log' TO '/var/opt/mssql/data/MedicalInfoSystem_Anonymise_Log.ldf'
Select * from sys.certificates



/******************************************

Note

******************************************/
/** 
drop master key, private key and certificate
 **/
-- USE MedicalInfoSystem;
-- GO
-- ALTER DATABASE MedicalInfoSystem
-- SET ENCRYPTION OFF;
-- GO

-- USE MedicalInfoSystem;
-- GO
-- DROP DATABASE ENCRYPTION KEY;
-- GO

-- USE master;
-- GO
-- DROP CERTIFICATE MedicalInfoSystem;
-- GO

-- USE master;
-- GO
-- DROP MASTER KEY;
-- GO

-- -- Suspend TDE Scan to pause TDE enablement
-- USE master
-- GO
-- ALTER DATABASE MedicalInfoSystem
-- SET ENCRYPTION SUSPEND;
-- GO