Create Database MedicalInfoSystem;
Go

Use MedicalInfoSystem
Go

Create Table Staff(
StaffID varchar(6) primary key,
SName varchar(100) not null,
SPassportNumber varchar(50) not null,
SPhone varchar(20),
SystemUserID varchar(10),
Position varchar(20) Check (Position in ('Doctor','Nurse'))
)

-- ALTER TABLE dbo.Staff
-- ADD SPassportNumber varchar(50) not null CONSTRAINT DF_passport DEFAULT 'default value' WITH VALUES, SName varchar(100) not null CONSTRAINT DF_name DEFAULT 'default value' WITH VALUES ,SPhone varchar(20), SystemUserID varchar(10);

-- ALTER TABLE dbo.Staff
--     DROP CONSTRAINT DF_passport, DF_name;



Create Table Patient(
PID varchar(6) primary key,
PName varchar(100) not null,
PPassportNumber varchar(50) not null,
PPhone varchar(20),
SystemUserID varchar(10),
PaymentCardNumber varchar(20),
PaymentCardPinCode varchar(20)
)

-- ALTER TABLE dbo.Patient
-- ADD PPassportNumber varchar(50) not null CONSTRAINT DF_passport DEFAULT 'default value' WITH VALUES, PPhone varchar(20) null,PaymentCardNumber varchar(20) null, PaymentCardPinCode varchar(20) null;

-- ALTER TABLE dbo.Patient
--     DROP CONSTRAINT DF_passport;

-- ALTER TABLE dbo.Patient
-- ADD PName varchar(100) not null CONSTRAINT DF_name DEFAULT 'default value' WITH VALUES;

-- ALTER TABLE dbo.Patient
--     DROP CONSTRAINT DF_name;



Create Table Medicine(
MID varchar(10) primary key,
MName varchar(50) not null
)

Create Table Prescription(
PresID int identity(1,1) primary key,
PatientID varchar(6) references Patient(PID) ,
DoctorID varchar(6) references Staff(StaffID) ,
PharmacistID varchar(6) references Staff(StaffID) ,
PresDateTime datetime not null
)

Create Table PrescriptionMedicine(
PresID int references Prescription(PresID),
MedID varchar(10) references Medicine(MID),
Primary Key (PresID, MedID)
)