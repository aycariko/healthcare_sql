ALTER TABLE appointment
ADD CONSTRAINT fk_DoctorName
FOREIGN KEY (DoctorName)
REFERENCES doctor(DoctorName)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE INDEX idx_HospitalName ON hospital(hospital_name);
-- HospitalName sütunu için foreign key kısıtlaması ekleme
ALTER TABLE appointment
ADD CONSTRAINT fk_HospitalName
FOREIGN KEY (HospitalName)
REFERENCES hospital(hospital_name)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Specialization sütunu için foreign key kısıtlaması ekleme
ALTER TABLE appointment
ADD CONSTRAINT fk_Specialization
FOREIGN KEY (Specialization)
REFERENCES doctor(Specialization)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Address sütunu için foreign key kısıtlaması ekleme
ALTER TABLE appointment
ADD CONSTRAINT fk_Address
FOREIGN KEY (Address)
REFERENCES hospital(address)
ON DELETE CASCADE
ON UPDATE CASCADE;
ALTER TABLE hospital ADD INDEX (contact_info);

-- ContactInfo sütunu için foreign key kısıtlaması ekleme
ALTER TABLE appointment
ADD CONSTRAINT fk_ContactInfo
FOREIGN KEY (ContactInfo)
REFERENCES hospital(contact_info)
ON DELETE CASCADE
ON UPDATE CASCADE;



CREATE VIEW Doctor_Patient_Info AS
SELECT 
-- -- doctor kendsine ait patientlarını görüyor 
    d.Doctor_id, 
    -- d.doctor_name, 
    p.Id, 
    p.Name AS Name, 
    p.Age AS Age, 
    p.Gender AS patient_gender, 
    mr.Record_Id, 
    mr.Diseases, 
    mr.Drugs, 
    a.Patient_Id,
    a.event_date_time AS appointment_date_time
   
FROM 
    DOCTOR d
JOIN 
    APPOINTMENT a ON d.Doctor_id = a.Doctor_id
JOIN 
    PATIENT p ON a.Patient_id = p.Id
JOIN 
    MEDICAL_RECORD mr ON mr.Patient_id = p.Id AND mr.Doctor_id = d.Doctor_id
WHERE 
    d.Doctor_id IN ('34567890123','25369841236','23456789012','15963247569','14725836925','12345678929','12345678911','12345678910','11234567892');  -- Add more IDs as needed
 
    
SELECT * FROM Doctor_Patient_Info;
    

CREATE VIEW Patient_Medical_Records AS
SELECT 
    p.Id AS patient_id, 
    p.Name AS patient_name, 
    p.Age AS patient_age,
    p.Gender AS patient_gender,
    mr.Record_Id AS record_id, 
    mr.Diseases AS disease, 
    mr.Drugs AS drugs, 
    mr.Date_of_Examination AS date_of_examination, 
    d.F_name AS doctor_name,
    d.Specialization AS specialization
FROM 
    PATIENT p
JOIN 
    MEDICAL_RECORD mr ON p.Id = mr.Patient_Id
JOIN
    appointment a ON a.event_date_time = mr.Date_of_Examination 
LEFT JOIN 
    DOCTOR d ON mr.Doctor_id = d.Doctor_id
WHERE 
    p.Id IN ('12345678901','12345678902','12345678903','12345678904','12345678905','12345678906','12345678907','12345678908');
  -- @patient_id hastanın ID'si için bir yer tutucudu
    
    
CREATE VIEW Patient_Appointments AS
SELECT 

-- create an appointment kendine geliyor geçmişte oluşturduğu appointmentları görcek yani her şeyi
    p.Id AS patient_id, 
    p.Name AS patient_name, 
    a.Patient_Id AS appointment_id, 
    a.event_date_time AS appointment_date_time,
    
    d.F_name AS doctor_name,
    d.Specialization AS specialization,
    h.hospital_name AS hospital_name
    
FROM 
    PATIENT p
JOIN 
    APPOINTMENT a ON p.Id = a.Patient_Id
LEFT JOIN 
    DOCTOR d ON a.Doctor_id = d.Doctor_id
LEFT JOIN
    HOSPITAL h ON a.HospitalName = h.hospital_name
WHERE 
	p.Id IN ('12345678901','12345678902','12345678903','12345678904','12345678905','12345678906','12345678907','12345678908');  -- @patient_id hastanın ID'si için bir yer tutucudur
    
CREATE VIEW Hospital_Overview AS
SELECT 
-- kendine ait doktorun her şeyini görcek 
-- patienti görcekd
-- appointment list 
    h.hospital_id,
    h.hospital_name,
    h.address AS hospital_address,
    d.Doctor_id,
    d.F_name,
    d.Specialization,
    p.Id, 
    p.Name AS patient_name,
    a.event_date_time AS appointment_date_time
	
FROM 
    HOSPITAL h
JOIN 
    DOCTOR d ON h.hospital_id = d.hospital_id
JOIN 
    APPOINTMENT a ON d.doctor_id = a.doctor_id
JOIN 
    PATIENT p ON a.patient_id = p.Id
WHERE 
    h.hospital_id IN ('21098765432','23456789012','32198765432','34219872654');  -- @hospital_id is a placeholder for the hospital's ID
    
    
DELIMITER $$

CREATE TRIGGER AfterMedicalRecordInsert
AFTER INSERT ON MEDICAL_RECORD
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (record_id, action_type, action_timestamp)
    VALUES (NEW.record_id, 'Insert', NOW());
END$$

DELIMITER $$



CREATE TABLE Audit_Log (
    record_id INT NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    action_timestamp DATETIME NOT NULL
);

DELIMITER $$
CREATE TRIGGER AfterAppointmentInsert
AFTER INSERT ON APPOINTMENT
FOR EACH ROW
BEGIN
    INSERT INTO Notification (patient_id, message, date_sent)
    VALUES (NEW.patient_id, CONCAT('Appointment Confirmed for ', NEW.event_date_time), NOW());
END$$

DELIMITER $$

CREATE TABLE Notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    date_sent DATETIME NOT NULL
);




DELIMITER $$

CREATE TRIGGER AfterDoctorInsert
AFTER INSERT ON DOCTOR
FOR EACH ROW
BEGIN
    INSERT INTO Notification (doctor_id, message, date_sent)
    VALUES (NEW.doctor_id, CONCAT('Welcome to ', (SELECT hospital_name FROM HOSPITAL WHERE hospital_id = NEW.hospital_id)), NOW());
END$$

DELIMITER $$


DELIMITER $$

CREATE TRIGGER AfterDoctorDelete
AFTER DELETE ON DOCTOR
FOR EACH ROW
BEGIN
    INSERT INTO Notification (doctor_id, message, date_sent)
    VALUES (OLD.doctor_id, CONCAT('Farewell from ', (SELECT hospital_name FROM HOSPITAL WHERE hospital_id = OLD.hospital_id)), NOW());
END$$

DELIMITER $$



CREATE TABLE patient (
    Id CHAR(11) PRIMARY KEY,
    Age INT,
    Gender CHAR(1),
    Name VARCHAR(50),
    Notes VARCHAR(300)
);

CREATE TABLE appointment (
    DoctorRoom VARCHAR(5),
    Doctor_id BIGINT,
    ContactInfo VARCHAR(150),
    HospitalName VARCHAR(50),
    Specialization VARCHAR(30),
    Adress VARCHAR(100),
    Patient_Id CHAR(11),
    Time INT,
    Date CHAR(10),
    PRIMARY KEY (Doctor_id, Patient_Id, Date, Time),
    FOREIGN KEY (Doctor_id) REFERENCES doctor(Doctor_id),
    FOREIGN KEY (Patient_Id) REFERENCES patient(Id),
    FOREIGN KEY (ContactInfo) REFERENCES hospital(contact_info),
    FOREIGN KEY (HospitalName) REFERENCES hospital(hospital_name),
    FOREIGN KEY (DoctorRoom) REFERENCES doctor(Room),
    FOREIGN KEY (Specialization) REFERENCES doctor(Specialization),
    FOREIGN KEY (Adress) REFERENCES hospital(address)
);
CREATE TABLE medical_record (
    Record_Id BIGINT PRIMARY KEY,
    Patient_Id CHAR(11),
    Doctor_id BIGINT,
    Date_of_Examination DATE,
    Drugs VARCHAR(255),
    Diseases VARCHAR(255),
    FOREIGN KEY (Patient_Id) REFERENCES patient(Id),
    FOREIGN KEY (Doctor_id) REFERENCES doctor(Doctor_id)
);
    
    CREATE TABLE doctor (
    Doctor_id BIGINT PRIMARY KEY,
    F_name VARCHAR(50),
    M_name VARCHAR(50),
    L_name VARCHAR(50),
    Gender CHAR(6),
    Age INT,
    Room VARCHAR(5),
    Qualification VARCHAR(30),
    Specialization VARCHAR(30)
);

CREATE TABLE hospital (
    hospital_id CHAR(11) PRIMARY KEY,
    hospital_name VARCHAR(50),
    address VARCHAR(100),
    contact_info VARCHAR(150)
);
