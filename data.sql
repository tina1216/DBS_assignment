--Use DBSLab;
Use MedicalInfoSystem;
Go

-- Inserting data into Staff Table
INSERT INTO Staff (StaffID, SName, SPassportNumber, SPhone, SystemUserID, Position) VALUES 
('S10001', 'Dr. Emma Brown', 'AB123456', '123-456-7890', 'U10001', 'Doctor'),
('S10002', 'Nurse John Doe', 'CD654321', '987-654-3210', 'U10002', 'Nurse'),
('S10003', 'Dr. Alice Smith', 'EF987654', '456-789-0123', 'U10003', 'Doctor');

-- Inserting data into Patient Table
INSERT INTO Patient (PID, PName, PPassportNumber, PPhone, SystemUserID, PaymentCardNumber, PaymentCardPinCode) VALUES 
('P20001', 'James Wilson', 'GH123789', '321-654-9870', 'U20001', '1111222233334444', '1234'),
('P20002', 'Sophia Johnson', 'IJ456321', '654-321-0987', 'U20002', '5555666677778888', '5678');

-- Inserting data into Medicine Table
INSERT INTO Medicine (MID, MName) VALUES 
('M3001', 'Paracetamol'),
('M3002', 'Ibuprofen'),
('M3003', 'Amoxicillin');

-- Inserting data into Prescription Table
INSERT INTO Prescription (PatientID, DoctorID, PharmacistID, PresDateTime) VALUES 
('P20001', 'S10001', 'S10002', '2023-12-10 10:00:00'),
('P20002', 'S10003', 'S10002', '2023-12-10 11:00:00');

-- Inserting data into PrescriptionMedicine Table
INSERT INTO PrescriptionMedicine (PresID, MedID) VALUES 
(1, 'M3001'),
(1, 'M3002'),
(2, 'M3003');