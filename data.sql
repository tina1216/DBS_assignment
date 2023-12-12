--Use DBSLab;
Use MedicalInfoSystem;
Go

-- Inserting data into Staff Table
INSERT INTO Staff (StaffID, SName, SPassportNumber, SPhone, SystemUserID, Position) VALUES 
('S10001', 'Dr. Emma Brown', 'AB123456', '123-456-7890', 'U10001', 'Doctor'),
('S10002', 'Nurse John Doe', 'CD654321', '987-654-3210', 'U10002', 'Nurse'),
('S10003', 'Dr. Alice Smith', 'EF987654', '456-789-0123', 'U10003', 'Doctor'),
('S10004', 'Nurse Olivia Johnson', 'GH213546', '210-987-6543', 'U10004', 'Nurse'),
('S10005', 'Dr. William Martinez', 'IJ321654', '789-012-3456', 'U10005', 'Doctor'),
('S10006', 'Nurse Amelia Brown', 'KL456789', '321-654-9870', 'U10006', 'Nurse'),
('S10007', 'Dr. Lucas Garcia', 'MN654321', '654-321-0987', 'U10007', 'Doctor'),
('S10008', 'Dr. Mia Perez', 'OP789012', '123-987-6543', 'U10008', 'Doctor');

INSERT INTO Staff (StaffID, SName, SPassportNumber, SPhone, SystemUserID, Position) VALUES 
('S10009', 'Nurse Ethan Lee', 'QR321987', '987-123-4567', 'U10009', 'Nurse');

-- Inserting data into Patient Table
INSERT INTO Patient (PID, PName, PPassportNumber, PPhone, SystemUserID, PaymentCardNumber, PaymentCardPinCode) VALUES 
('P20001', 'James Wilson', 'GH123789', '321-654-9870', 'U20001', '1111222233334444', '1234'),
('P20002', 'Sophia Johnson', 'IJ456321', '654-321-0987', 'U20002', '5555666677778888', '5678'),
('P20003', 'Oliver Smith', 'XY987654', '987-654-3210', 'U20003', '9999000011112222', '9101'),
('P20004', 'Emma Martinez', 'AB213546', '210-987-6543', 'U20004', '4444333322221111', '3412'),
('P20005', 'Liam Brown', 'CD654789', '123-456-7890', 'U20005', '6666777788889999', '7856'),
('P20006', 'Isabella Garcia', 'EF321654', '789-012-3456', 'U20006', '2222333344445555', '4321'),
('P20007', 'Ethan Wilson', 'XX123456', '111-222-3333', 'U20007', '1234567890123456', '0000'),
('P20008', 'Ava Johnson', 'YY654321', '444-555-6666', 'U20008', '6543210987654321', '1111');

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