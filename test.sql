/******************************************

Encryption - Column Level Encryption

AND

Protect the data before passing a copy of the database to the development team.
(Encrypt-decrypt PName & PPhone)

******************************************/
-- Patient ============================================
-- 1. display Patient table
CREATE PROCEDURE SelectAllPatients
AS
SELECT * FROM dbo.Patient
GO;

EXEC SelectAllPatients;

-- 2. display the master key
SELECT * FROM sys.symmetric_keys
GO

-- 3. display the certificate 
SELECT * FROM sys.certificates
GO

-- 4. view result
EXEC SelectAllPatients;
GO;

-- Staff ============================================
-- 1. display Patient table
CREATE PROCEDURE SelectAllStaff
AS
SELECT * FROM dbo.Staff
GO;

EXEC SelectAllStaff;

-- 2. display the master key
SELECT * FROM sys.symmetric_keys
GO

-- 3. display the certificate 
SELECT * FROM sys.certificates
GO

-- 4. view result
EXEC SelectAllStaff;


/******************************************

Encryption - Transparent Data Encryption (TDE)

******************************************/
--- 1. display the master key
SELECT * FROM sys.symmetric_keys
GO

-- 2. display the certificate 
SELECT * FROM sys.certificates
GO
Select thumbprint From sys.certificates where name = 'MedicalInfoSystem_DB_Cert'
GO

-- Copy the database and certificate backup files to another location
--- 1. display the master key
SELECT * FROM sys.symmetric_keys
GO

-- 2. display the certificate 
SELECT * FROM sys.certificates
GO

-- 3. check if the backup data is restored
SELECT 
   rs.destination_database_name, 
   rs.restore_date, 
   bs.backup_start_date, 
   bs.backup_finish_date, 
   bs.database_name as source_database_name, 
   bmf.physical_device_name as backup_file_used_for_restore
FROM msdb.dbo.restorehistory rs
INNER JOIN msdb.dbo.backupset bs ON rs.backup_set_id = bs.backup_set_id
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id 
ORDER BY rs.restore_date DESC;