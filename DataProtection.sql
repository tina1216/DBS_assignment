/******************************************

Encryption - Column Level Encryption

******************************************/
CREATE PROCEDURE SelectAllPatients
AS
SELECT * FROM dbo.Patient
GO;
EXEC SelectAllPatients;

-- Patient ============================================
-- Add new columns to hold the encrypted data.
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
GO

-- 3. Update existing records with encrypted data using ENCRYPTBYCERT
-- Create or replace the existing trigger for Patient table
CREATE TRIGGER EncryptPatientData
ON Patient
AFTER INSERT, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN
    -- Iterate through each row in the inserted table
    DECLARE cur CURSOR LOCAL FOR 
        SELECT PID, PPassportNumber, PaymentCardNumber, PaymentCardPinCode 
        FROM inserted;

    OPEN cur;
    DECLARE @PatientID VARCHAR(6), @PassportNumber VARCHAR(50), 
    @PaymentCardNumber VARCHAR(20), @PaymentCardPinCode VARCHAR(50);

    FETCH NEXT FROM cur INTO @PatientID, @PassportNumber, @PaymentCardNumber, @PaymentCardPinCode;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Perform the encryption and update the Patient table
        UPDATE Patient
        SET 
            PassportNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Patient'), @PassportNumber),
            PaymentCardNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Patient'), @PaymentCardNumber),
            PaymentCardPinCode_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Patient'), @PaymentCardPinCode),
            PPassportNumber = 'N/A',
            PaymentCardNumber = 'N/A',
            PaymentCardPinCode = 'N/A' 
        WHERE PID = @PatientID;

        -- Fetch the next row
        FETCH NEXT FROM cur INTO @PatientID, @PassportNumber, @PaymentCardNumber, @PaymentCardPinCode;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

EXEC EncryptPatientData;

-- view
EXEC SelectAllPatients

-- Staff ============================================
GO

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
GO

CREATE TRIGGER EncryptStaffData
ON Staff
AFTER INSERT, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN
    -- Iterate through each row in the inserted table
    DECLARE cur CURSOR LOCAL FOR 
        SELECT StaffID, SPassportNumber
        FROM inserted;

    OPEN cur;
    DECLARE @StaffID VARCHAR(6), @PassportNumber VARCHAR(50);

    FETCH NEXT FROM cur INTO @StaffID, @PassportNumber;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Perform the encryption and update the Staff table
        UPDATE Staff
        SET 
            SPassportNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('Cert_Staff'), @PassportNumber),
            SPassportNumber = 'N/A'
        WHERE StaffID = @StaffID;

        -- Fetch the next row
        FETCH NEXT FROM cur INTO @StaffID, @PassportNumber;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

EXEC EncryptStaffData;

EXEC SelectAllStaff;

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

-- Create or replace the existing trigger for Patient table
GO

CREATE TRIGGER EncryptPatientDataDev
ON Patient
AFTER INSERT, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN
    -- Iterate through each row in the inserted table
    DECLARE cur CURSOR LOCAL FOR 
        SELECT PID, PName, PPhone
        FROM inserted;

    OPEN cur;
    DECLARE @PatientID VARCHAR(6), @Name VARCHAR(100), @Phone VARCHAR(12);

    FETCH NEXT FROM cur INTO @PatientID, @Name, @Phone;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Perform the encryption and update the Patient table
        UPDATE Patient
        SET 
            PName_Encrypted = ENCRYPTBYCERT(CERT_ID('PatientDataCertificate'), @Name),
            PhoneNumber_Encrypted = ENCRYPTBYCERT(CERT_ID('PatientDataCertificate'), @Phone),
            PName = 'N/A',
            PPhone = 'N/A' 
        WHERE PID = @PatientID;

        -- Fetch the next row
        FETCH NEXT FROM cur INTO @PatientID, @Name, @Phone;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

EXEC EncryptPatientDataDev

-- Decrypt

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
GO

CREATE TRIGGER EncryptStaffDataDev
ON Staff
AFTER INSERT, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN

    -- Perform the encryption in a set-based manner
    UPDATE s
    SET 
        SName_Encrypted = ENCRYPTBYCERT(CERT_ID('StaffDataCertificate'), i.SName),
        SPhone_Encrypted = ENCRYPTBYCERT(CERT_ID('StaffDataCertificate'), i.SPhone),
        SystemUserID_Encrypted = ENCRYPTBYCERT(CERT_ID('StaffDataCertificate'), i.SystemUserID),
        SystemUserID = 'N/A', -- Setting default value after encryption
        SName = 'N/A', -- Setting default value after encryption
        SPhone = 'N/A'  -- Setting default value after encryption
    FROM Staff s
    INNER JOIN inserted i ON s.StaffID = i.StaffID;
END;
GO

EXEC EncryptStaffDataDev;

-- Decrypt
-- Create or replace the existing stored procedure for decrypting and updating Staff data
Go

CREATE PROCEDURE DecryptStaffDataDev
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN
    -- Update using a set-based approach with CROSS APPLY
    UPDATE s
    SET 
        SName = ISNULL(ca.DecryptedName, s.SName), -- Preserve original value if decryption returns NULL
        SPhone = ISNULL(ca.DecryptedPhone, s.SPhone),
        SystemUserID = ISNULL(ca.DecryptedSystemUserID, s.SystemUserID)
    FROM Staff s
    CROSS APPLY 
    (
        SELECT 
            CONVERT(VARCHAR(100), DECRYPTBYCERT(CERT_ID('StaffDataCertificate'), s.SName_Encrypted)) AS DecryptedName,
            CONVERT(VARCHAR(12), DECRYPTBYCERT(CERT_ID('StaffDataCertificate'), s.SPhone_Encrypted)) AS DecryptedPhone,
            CONVERT(VARCHAR(12), DECRYPTBYCERT(CERT_ID('StaffDataCertificate'), s.SystemUserID_Encrypted)) AS DecryptedSystemUserID
    ) AS ca
END;
GO

EXEC DecryptStaffDataDev;

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

/************************************

Backup Database

************************************/
-- Create Backup 
-- 1. create a master key if hasn't
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123';
GO

-- 2. create a certificate
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

