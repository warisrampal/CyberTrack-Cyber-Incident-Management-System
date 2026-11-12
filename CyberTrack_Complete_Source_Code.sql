/*
CYBERTRACK — COMPLETE MYSQL SOURCE CODE
BCA Cybersecurity | RDBMS Project
Recommended: MySQL 8.0.31+ | InnoDB

RUNNING:
1. Open this file in MySQL Workbench.
2. Execute from top to bottom.
3. This script does not DROP the database or existing tables.
4. Sample rows use explicit IDs and INSERT IGNORE to reduce duplicate-key
   errors when the seed section is rerun. Existing rows are not overwritten.
5. INTERSECT and EXCEPT require MySQL 8.0.31+.
6. The invalid constraint tests at the end are commented out intentionally.
All sample people, incidents, evidence names and hashes are fictional.
This is an academic incident-record database, not a live detection system.
*/

-- PART 1 — DDL: CREATE AND SELECT DATABASE
CREATE DATABASE IF NOT EXISTS CyberTrack;
USE CyberTrack;
SELECT DATABASE() AS selected_database;
SELECT VERSION() AS mysql_version;

-- PART 2 — DDL: TABLES AND CONSTRAINTS
-- Primary keys identify rows; foreign keys enforce relationships;
-- UNIQUE, NOT NULL and CHECK constraints validate stored data.

CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    designation VARCHAR(100),
    department VARCHAR(100),
    user_role VARCHAR(50) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_active CHECK (is_active IN (0,1))
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Incident_Types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Severity (
    severity_id INT AUTO_INCREMENT PRIMARY KEY,
    severity_name VARCHAR(50) NOT NULL UNIQUE,
    priority_score INT NOT NULL UNIQUE,
    response_target_hours INT NOT NULL,
    CONSTRAINT chk_priority_score CHECK (priority_score BETWEEN 1 AND 4),
    CONSTRAINT chk_response_hours CHECK (response_target_hours > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Incidents (
    incident_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    type_id INT NOT NULL,
    severity_id INT NOT NULL,
    reported_by INT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Open',
    incident_date DATETIME NOT NULL,
    resolved_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incident_type FOREIGN KEY (type_id) REFERENCES Incident_Types(type_id),
    CONSTRAINT fk_incident_severity FOREIGN KEY (severity_id) REFERENCES Severity(severity_id),
    CONSTRAINT fk_incident_reporter FOREIGN KEY (reported_by) REFERENCES Users(user_id),
    CONSTRAINT chk_incident_status CHECK (status IN
      ('Open','In Progress','Under Review','Resolved','Closed')),
    CONSTRAINT chk_incident_dates CHECK
      (resolved_date IS NULL OR resolved_date >= incident_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Investigations (
    investigation_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT NOT NULL,
    investigator_id INT NOT NULL,
    investigation_notes TEXT NOT NULL,
    investigation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolution TEXT,
    CONSTRAINT fk_investigation_incident FOREIGN KEY (incident_id) REFERENCES Incidents(incident_id),
    CONSTRAINT fk_investigation_user FOREIGN KEY (investigator_id) REFERENCES Users(user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Evidence (
    evidence_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT NOT NULL,
    collected_by INT NOT NULL,
    evidence_type VARCHAR(100) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_hash VARCHAR(128),
    file_size_kb DECIMAL(12,2),
    description TEXT,
    collected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evidence_incident FOREIGN KEY (incident_id) REFERENCES Incidents(incident_id),
    CONSTRAINT fk_evidence_collector FOREIGN KEY (collected_by) REFERENCES Users(user_id),
    CONSTRAINT chk_evidence_size CHECK (file_size_kb IS NULL OR file_size_kb >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Incident_Status_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT NOT NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by INT NOT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    CONSTRAINT fk_history_incident FOREIGN KEY (incident_id) REFERENCES Incidents(incident_id),
    CONSTRAINT fk_history_user FOREIGN KEY (changed_by) REFERENCES Users(user_id),
    CONSTRAINT chk_history_new_status CHECK (new_status IN
      ('Open','In Progress','Under Review','Resolved','Closed')),
    CONSTRAINT chk_history_old_status CHECK (old_status IS NULL OR old_status IN
      ('Open','In Progress','Under Review','Resolved','Closed'))
) ENGINE=InnoDB;

-- PART 3 — DML: FICTIONAL SAMPLE DATA
-- INSERT IGNORE avoids duplicate-key errors on reruns; it does not update rows.

INSERT IGNORE INTO Users
(user_id,full_name,email,designation,department,user_role,is_active) VALUES
(1,'Aarav Sharma','aarav@example.com','Security Analyst','SOC','Analyst',1),
(2,'Riya Verma','riya@example.com','Incident Responder','SOC','Analyst',1),
(3,'Kabir Singh','kabir@example.com','Network Engineer','IT','Engineer',1),
(4,'Mehak Kaur','mehak@example.com','Security Administrator','IT Security','Admin',1),
(5,'Arjun Mehta','arjun@example.com','Database Administrator','Database','Admin',1),
(6,'Simran Gill','simran@example.com','Security Manager','SOC','Manager',1),
(7,'Dev Patel','dev@example.com','Employee','Finance','Reporter',1),
(8,'Ananya Roy','ananya@example.com','Employee','HR','Reporter',1),
(9,'Ishaan Malhotra','ishaan@example.com','Forensic Analyst','SOC','Analyst',1),
(10,'Navya Kapoor','navya@example.com','IT Support','IT','Support',1);

INSERT IGNORE INTO Incident_Types(type_id,type_name,description) VALUES
(1,'Phishing','Suspicious messages or attempts to obtain sensitive information.'),
(2,'Malware','Malicious software detected on a device or system.'),
(3,'Ransomware','Incident involving ransomware indicators.'),
(4,'Data Breach','Possible unauthorized exposure of information.'),
(5,'DDoS Attack','Distributed denial-of-service activity.'),
(6,'SQL Injection','Suspicious or potentially malicious SQL input.'),
(7,'Unauthorized Access','Access without appropriate authorization.'),
(8,'Insider Threat','Potential security risk involving an internal account or user.');

INSERT IGNORE INTO Severity(severity_id,severity_name,priority_score,response_target_hours) VALUES
(1,'Low',1,72),(2,'Medium',2,48),(3,'High',3,24),(4,'Critical',4,4);

INSERT IGNORE INTO Incidents
(incident_id,title,description,type_id,severity_id,reported_by,status,incident_date,resolved_date) VALUES
(1,'Suspicious Email Received','Employee reported an unexpected email.',1,2,7,'Resolved','2026-10-01 09:00:00','2026-10-02 11:00:00'),
(2,'Malware Detected on Workstation','Endpoint alert requires investigation.',2,3,8,'In Progress','2026-10-02 10:30:00',NULL),
(3,'Ransomware Alert','Fictional ransomware alert for academic testing.',3,4,7,'Under Review','2026-10-03 08:15:00',NULL),
(4,'Unauthorized Database Access','Unexpected database access was reported.',7,3,8,'Open','2026-10-04 12:00:00',NULL),
(5,'Possible Customer Data Exposure','Possible exposure requires verification.',4,4,6,'In Progress','2026-10-05 14:20:00',NULL),
(6,'Network Service Disruption','Network service availability was affected.',5,3,4,'Resolved','2026-10-06 16:00:00','2026-10-07 09:30:00'),
(7,'Suspicious SQL Input Activity','Unusual input was recorded in an application.',6,3,5,'Under Review','2026-10-07 11:45:00',NULL),
(8,'Repeated Login Failures','Multiple unsuccessful login attempts were reported.',7,2,7,'Closed','2026-10-08 07:30:00','2026-10-08 13:00:00'),
(9,'Unusual Employee Account Activity','Account activity requires review.',8,2,8,'Open','2026-10-09 15:10:00',NULL),
(10,'Suspicious File Download','A file download was flagged for review.',2,1,7,'Resolved','2026-10-10 10:00:00','2026-10-10 16:00:00'),
(11,'Critical Server Access Alert','A critical access alert requires investigation.',7,4,6,'In Progress','2026-10-11 18:20:00',NULL),
(12,'Suspicious Email Attachment','An email attachment was reported as suspicious.',1,2,8,'Open','2026-10-12 09:40:00',NULL);

INSERT IGNORE INTO Investigations
(investigation_id,incident_id,investigator_id,investigation_notes,investigation_date,resolution) VALUES
(1,1,1,'Reviewed sender details and message headers.','2026-10-01 10:00:00','Message classified as suspicious.'),
(2,2,2,'Reviewed endpoint alert and collected event details.','2026-10-02 11:00:00',NULL),
(3,3,9,'Reviewed fictional alert indicators.','2026-10-03 09:00:00',NULL),
(4,4,5,'Reviewed database access records.','2026-10-04 13:00:00',NULL),
(5,5,6,'Started review of possible data exposure.','2026-10-05 15:00:00',NULL),
(6,6,3,'Reviewed network availability logs.','2026-10-06 17:00:00','Service restored.'),
(7,7,5,'Reviewed application input records.','2026-10-07 12:30:00',NULL),
(8,8,1,'Reviewed authentication event records.','2026-10-08 08:30:00','Activity reviewed and case closed.'),
(9,9,2,'Reviewed account activity with relevant team.','2026-10-09 16:00:00',NULL),
(10,10,9,'Reviewed file metadata.','2026-10-10 11:00:00','No further action recorded.'),
(11,11,6,'Started review of critical server access alert.','2026-10-11 19:00:00',NULL),
(12,1,2,'Completed secondary review.','2026-10-02 09:00:00','Review completed.'),
(13,2,9,'Collected additional endpoint observations.','2026-10-03 10:00:00',NULL),
(14,5,1,'Reviewed reported exposure details.','2026-10-06 10:00:00',NULL),
(15,7,5,'Added follow-up investigation notes.','2026-10-08 10:00:00',NULL);

INSERT IGNORE INTO Evidence
(evidence_id,incident_id,collected_by,evidence_type,file_name,file_hash,file_size_kb,description,collected_at) VALUES
(1,1,1,'Email Header','suspicious_email_header.txt','a1b2c3d4e5f60123456789abcdef0123',24.50,'Fictional email header sample.','2026-10-01 10:15:00'),
(2,2,2,'Log File','endpoint_events.log','b1c2d3e4f5a60123456789abcdef0123',512.00,'Fictional endpoint event log.','2026-10-02 11:20:00'),
(3,3,9,'Alert Record','ransomware_alert.json','c1d2e3f4a5b60123456789abcdef0123',18.75,'Fictional alert export.','2026-10-03 09:20:00'),
(4,4,5,'Database Log','db_access.log','d1e2f3a4b5c60123456789abcdef0123',256.00,'Fictional database log sample.','2026-10-04 13:20:00'),
(5,5,6,'Report','exposure_review.pdf','e1f2a3b4c5d60123456789abcdef0123',1024.00,'Fictional review report.','2026-10-05 15:20:00'),
(6,6,3,'Network Log','network_events.log','f1a2b3c4d5e60123456789abcdef0123',768.00,'Fictional network event log.','2026-10-06 17:20:00'),
(7,7,5,'Application Log','application_input.log','0123456789abcdef0123456789abcdef',128.00,'Fictional application log.','2026-10-07 12:45:00'),
(8,8,1,'Authentication Log','login_attempts.log','1123456789abcdef0123456789abcdef',64.00,'Fictional authentication log.','2026-10-08 08:45:00'),
(9,9,2,'Audit Log','account_audit.log','2123456789abcdef0123456789abcdef',96.00,'Fictional account audit log.','2026-10-09 16:20:00'),
(10,10,9,'File Metadata','download_metadata.txt','3123456789abcdef0123456789abcdef',12.00,'Fictional file metadata.','2026-10-10 11:20:00'),
(11,11,6,'Server Log','server_access.log','4123456789abcdef0123456789abcdef',384.00,'Fictional server access log.','2026-10-11 19:20:00'),
(12,12,1,'Email Attachment','attachment_details.txt','5123456789abcdef0123456789abcdef',32.00,'Fictional attachment details.','2026-10-12 10:00:00');

INSERT IGNORE INTO Incident_Status_History
(history_id,incident_id,old_status,new_status,changed_by,changed_at,remarks) VALUES
(1,1,NULL,'Open',7,'2026-10-01 09:00:00','Incident reported.'),
(2,1,'Open','In Progress',1,'2026-10-01 10:00:00','Review started.'),
(3,1,'In Progress','Resolved',1,'2026-10-02 11:00:00','Review completed.'),
(4,2,NULL,'Open',8,'2026-10-02 10:30:00','Incident reported.'),
(5,2,'Open','In Progress',2,'2026-10-02 11:00:00','Investigation started.'),
(6,3,NULL,'Open',7,'2026-10-03 08:15:00','Alert recorded.'),
(7,3,'Open','Under Review',9,'2026-10-03 09:00:00','Alert reviewed.'),
(8,4,NULL,'Open',8,'2026-10-04 12:00:00','Incident reported.'),
(9,5,NULL,'Open',6,'2026-10-05 14:20:00','Incident reported.'),
(10,5,'Open','In Progress',6,'2026-10-05 15:00:00','Review started.'),
(11,6,NULL,'Open',4,'2026-10-06 16:00:00','Incident reported.'),
(12,6,'Open','Resolved',3,'2026-10-07 09:30:00','Service restored.'),
(13,7,NULL,'Open',5,'2026-10-07 11:45:00','Incident reported.'),
(14,7,'Open','Under Review',5,'2026-10-07 12:30:00','Review started.'),
(15,8,NULL,'Open',7,'2026-10-08 07:30:00','Incident reported.'),
(16,8,'Open','Closed',1,'2026-10-08 13:00:00','Case closed.'),
(17,9,NULL,'Open',8,'2026-10-09 15:10:00','Incident reported.'),
(18,10,NULL,'Open',7,'2026-10-10 10:00:00','Incident reported.'),
(19,10,'Open','Resolved',9,'2026-10-10 16:00:00','Review completed.'),
(20,11,NULL,'Open',6,'2026-10-11 18:20:00','Incident reported.'),
(21,11,'Open','In Progress',6,'2026-10-11 19:00:00','Review started.'),
(22,12,NULL,'Open',8,'2026-10-12 09:40:00','Incident reported.'),
(23,2,'In Progress','Under Review',9,'2026-10-13 10:00:00','Additional review started.'),
(24,5,'In Progress','Under Review',1,'2026-10-13 11:00:00','Additional review started.'),
(25,7,'Under Review','Under Review',5,'2026-10-13 12:00:00','Review note recorded.');

-- PART 4 — DQL: RETRIEVAL AND FILTERING
SELECT * FROM Users;
SELECT * FROM Incident_Types;
SELECT * FROM Severity;
SELECT * FROM Incidents;
SELECT * FROM Investigations;
SELECT * FROM Evidence;
SELECT * FROM Incident_Status_History;
SELECT incident_id,title,status FROM Incidents;
SELECT * FROM Incidents WHERE status='Open';
SELECT * FROM Incidents WHERE severity_id>=3;
SELECT * FROM Incidents WHERE incident_date>='2026-10-05';
SELECT * FROM Incidents WHERE title LIKE '%Email%';
SELECT * FROM Incidents ORDER BY incident_date DESC LIMIT 5;

-- PART 5 — DML: INSERT / UPDATE / DELETE
-- Demonstration INSERT is guarded so reruns do not add duplicate title rows.
INSERT INTO Incidents(title,description,type_id,severity_id,reported_by,status,incident_date)
SELECT 'CyberTrack Demonstration Incident','Fictional demonstration record.',7,2,7,'Open',NOW()
WHERE NOT EXISTS (SELECT 1 FROM Incidents WHERE title='CyberTrack Demonstration Incident');
-- Optional UPDATE template; run separately if desired:
-- UPDATE Incidents SET status='In Progress' WHERE incident_id=12;
-- Optional DELETE template; only delete a test row with no child records:
-- DELETE FROM Incidents WHERE title='CyberTrack Demonstration Incident';

-- PART 6 — JOINS
SELECT I.incident_id,I.title,U.full_name AS reported_by,S.severity_name,I.status
FROM Incidents I
JOIN Users U ON I.reported_by=U.user_id
JOIN Severity S ON I.severity_id=S.severity_id;

SELECT I.incident_id,I.title,T.type_name
FROM Incidents I JOIN Incident_Types T ON I.type_id=T.type_id;

SELECT INV.investigation_id,I.title,U.full_name AS investigator,INV.investigation_notes
FROM Investigations INV
JOIN Incidents I ON INV.incident_id=I.incident_id
JOIN Users U ON INV.investigator_id=U.user_id;

SELECT E.evidence_id,I.title,E.file_name,U.full_name AS collected_by
FROM Evidence E
JOIN Incidents I ON E.incident_id=I.incident_id
JOIN Users U ON E.collected_by=U.user_id;

SELECT I.incident_id,I.title,INV.investigation_id
FROM Incidents I LEFT JOIN Investigations INV ON I.incident_id=INV.incident_id;

SELECT I.*
FROM Incidents I LEFT JOIN Investigations INV ON I.incident_id=INV.incident_id
WHERE INV.investigation_id IS NULL;

-- PART 7 — AGGREGATION, GROUP BY AND HAVING
SELECT COUNT(*) AS total_incidents FROM Incidents;
SELECT COUNT(*) AS open_incidents FROM Incidents WHERE status='Open';

SELECT status,COUNT(*) AS total FROM Incidents GROUP BY status;

SELECT S.severity_name,COUNT(I.incident_id) AS total_incidents
FROM Incidents I JOIN Severity S ON I.severity_id=S.severity_id
GROUP BY S.severity_name,S.priority_score ORDER BY S.priority_score;

SELECT T.type_name,COUNT(I.incident_id) AS total_incidents
FROM Incident_Types T LEFT JOIN Incidents I ON T.type_id=I.type_id
GROUP BY T.type_id,T.type_name;

SELECT U.full_name,COUNT(INV.investigation_id) AS total_investigations
FROM Users U JOIN Investigations INV ON U.user_id=INV.investigator_id
GROUP BY U.user_id,U.full_name;

SELECT SUM(file_size_kb) AS total_evidence_size_kb FROM Evidence;
SELECT AVG(file_size_kb) AS average_evidence_size_kb FROM Evidence;
SELECT MIN(file_size_kb) AS smallest_file_kb,MAX(file_size_kb) AS largest_file_kb FROM Evidence;

SELECT T.type_name,COUNT(I.incident_id) AS total_incidents
FROM Incident_Types T JOIN Incidents I ON T.type_id=I.type_id
GROUP BY T.type_id,T.type_name HAVING COUNT(I.incident_id)>1;

SELECT COUNT(*) AS total_incidents,
SUM(status='Open') AS open_incidents,
SUM(status='In Progress') AS in_progress,
SUM(status='Resolved') AS resolved_incidents,
SUM(status='Closed') AS closed_incidents
FROM Incidents;

-- PART 8 — ADVANCED RETRIEVAL: SUBQUERIES
SELECT * FROM Incidents
WHERE severity_id=(SELECT severity_id FROM Severity WHERE severity_name='Critical');

SELECT * FROM Incidents
WHERE reported_by=(SELECT user_id FROM Users WHERE full_name='Aarav Sharma');

SELECT I.incident_id,I.title,S.severity_name,S.priority_score
FROM Incidents I JOIN Severity S ON I.severity_id=S.severity_id
WHERE S.priority_score>(SELECT AVG(priority_score) FROM Severity);

SELECT evidence_id,file_name,file_size_kb FROM Evidence
WHERE file_size_kb>(SELECT AVG(file_size_kb) FROM Evidence);

SELECT * FROM Users
WHERE user_id IN (SELECT DISTINCT reported_by FROM Incidents);

SELECT * FROM Incidents I
WHERE EXISTS (SELECT 1 FROM Evidence E WHERE E.incident_id=I.incident_id);

SELECT * FROM Incidents I
WHERE NOT EXISTS (SELECT 1 FROM Investigations INV WHERE INV.incident_id=I.incident_id);

SELECT * FROM Users U
WHERE NOT EXISTS (SELECT 1 FROM Incidents I WHERE I.reported_by=U.user_id);

SELECT U.full_name,
(SELECT COUNT(*) FROM Investigations INV WHERE INV.investigator_id=U.user_id) AS total_investigations
FROM Users U;

-- PART 9 — DATABASE OBJECTS: VIEWS
-- Views are reusable virtual tables based on SELECT statements.
CREATE OR REPLACE VIEW vw_incident_details AS
SELECT I.incident_id,I.title,I.description,T.type_name AS incident_type,
S.severity_name,U.full_name AS reported_by,I.status,I.incident_date,I.resolved_date
FROM Incidents I
JOIN Incident_Types T ON I.type_id=T.type_id
JOIN Severity S ON I.severity_id=S.severity_id
JOIN Users U ON I.reported_by=U.user_id;

CREATE OR REPLACE VIEW vw_open_incidents AS
SELECT I.incident_id,I.title,T.type_name AS incident_type,S.severity_name,
U.full_name AS reported_by,I.incident_date
FROM Incidents I
JOIN Incident_Types T ON I.type_id=T.type_id
JOIN Severity S ON I.severity_id=S.severity_id
JOIN Users U ON I.reported_by=U.user_id
WHERE I.status='Open';

CREATE OR REPLACE VIEW vw_investigation_summary AS
SELECT INV.investigation_id,I.incident_id,I.title AS incident_title,
U.full_name AS investigator,INV.investigation_notes,INV.investigation_date,INV.resolution
FROM Investigations INV
JOIN Incidents I ON INV.incident_id=I.incident_id
JOIN Users U ON INV.investigator_id=U.user_id;

CREATE OR REPLACE VIEW vw_evidence_report AS
SELECT E.evidence_id,I.incident_id,I.title AS incident_title,E.evidence_type,
E.file_name,E.file_hash,E.file_size_kb,U.full_name AS collected_by,E.collected_at
FROM Evidence E
JOIN Incidents I ON E.incident_id=I.incident_id
JOIN Users U ON E.collected_by=U.user_id;

CREATE OR REPLACE VIEW vw_incident_type_summary AS
SELECT T.type_id,T.type_name,COUNT(I.incident_id) AS total_incidents
FROM Incident_Types T LEFT JOIN Incidents I ON T.type_id=I.type_id
GROUP BY T.type_id,T.type_name;

SELECT * FROM vw_incident_details;
SELECT * FROM vw_open_incidents;
SELECT * FROM vw_investigation_summary;
SELECT * FROM vw_evidence_report;
SELECT * FROM vw_incident_type_summary;
SELECT * FROM vw_incident_details WHERE severity_name='Critical' ORDER BY incident_date DESC;

-- PART 10 — DATABASE OBJECTS: INDEXES
-- The email UNIQUE constraint already creates an index; do not add a duplicate.
-- Conditional DDL checks INFORMATION_SCHEMA before creating each index.
SET @idx_sql=IF((SELECT COUNT(*) FROM information_schema.statistics
 WHERE table_schema=DATABASE() AND table_name='Incidents'
 AND index_name='idx_incident_status')=0,
 'CREATE INDEX idx_incident_status ON Incidents(status)',
 'SELECT ''idx_incident_status already exists''');
PREPARE idx_stmt FROM @idx_sql; EXECUTE idx_stmt; DEALLOCATE PREPARE idx_stmt;

SET @idx_sql=IF((SELECT COUNT(*) FROM information_schema.statistics
 WHERE table_schema=DATABASE() AND table_name='Incidents'
 AND index_name='idx_incident_severity_status')=0,
 'CREATE INDEX idx_incident_severity_status ON Incidents(severity_id,status)',
 'SELECT ''idx_incident_severity_status already exists''');
PREPARE idx_stmt FROM @idx_sql; EXECUTE idx_stmt; DEALLOCATE PREPARE idx_stmt;

SHOW INDEX FROM Incidents;

-- PART 11 — TRANSACTIONS / TCL
-- COMMIT saves a transaction; ROLLBACK cancels uncommitted changes;
-- SAVEPOINT permits a partial rollback. InnoDB supports transactions.
START TRANSACTION;
UPDATE Incidents SET status='Under Review' WHERE incident_id=12;
SELECT incident_id,status FROM Incidents WHERE incident_id=12;
ROLLBACK;
SELECT incident_id,status FROM Incidents WHERE incident_id=12;

START TRANSACTION;
INSERT INTO Incident_Types(type_name,description)
VALUES('Transaction Demo A','Temporary transaction demonstration row.');
SAVEPOINT sp_after_first_insert;
INSERT INTO Incident_Types(type_name,description)
VALUES('Transaction Demo B','Temporary row to be rolled back.');
ROLLBACK TO SAVEPOINT sp_after_first_insert;
COMMIT;
SELECT * FROM Incident_Types WHERE type_name IN ('Transaction Demo A','Transaction Demo B');
DELETE FROM Incident_Types WHERE type_name='Transaction Demo A';

START TRANSACTION;
INSERT INTO Incident_Types(type_name,description)
VALUES('Commit Demo Type','Temporary row demonstrating COMMIT.');
COMMIT;
SELECT * FROM Incident_Types WHERE type_name='Commit Demo Type';
DELETE FROM Incident_Types WHERE type_name='Commit Demo Type';

-- PART 12 — ANALYSIS AND PERFORMANCE
-- EXPLAIN shows the optimizer's plan; EXPLAIN ANALYZE runs the SELECT and
-- reports actual execution details (MySQL 8.0.18+).
EXPLAIN SELECT * FROM Incidents WHERE status='Open';

EXPLAIN
SELECT I.title,U.full_name,S.severity_name
FROM Incidents I
JOIN Users U ON I.reported_by=U.user_id
JOIN Severity S ON I.severity_id=S.severity_id;

EXPLAIN ANALYZE SELECT * FROM Incidents WHERE status='Open';

SHOW TABLE STATUS;
SELECT TABLE_NAME,ENGINE,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH
FROM information_schema.TABLES WHERE TABLE_SCHEMA='CyberTrack';

-- PART 13 — PROGRAMMABILITY: PROCEDURES, FUNCTIONS AND TRIGGER
-- Procedures are invoked with CALL. Functions return values.
-- Triggers automatically run when the specified table event occurs.
-- DELIMITER lets compound routine definitions contain semicolons.
DROP PROCEDURE IF EXISTS GetAllIncidents;
DROP PROCEDURE IF EXISTS GetIncidentsByStatus;
DROP FUNCTION IF EXISTS GetTotalIncidents;
DROP FUNCTION IF EXISTS GetOpenIncidents;
DROP TRIGGER IF EXISTS trg_incident_status_update;

DELIMITER //

CREATE PROCEDURE GetAllIncidents()
BEGIN
  SELECT * FROM Incidents;
END //

CREATE PROCEDURE GetIncidentsByStatus(IN p_status VARCHAR(30))
BEGIN
  SELECT * FROM Incidents WHERE status=p_status;
END //

CREATE FUNCTION GetTotalIncidents()
RETURNS INT
READS SQL DATA
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM Incidents;
  RETURN total;
END //

CREATE FUNCTION GetOpenIncidents()
RETURNS INT
READS SQL DATA
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM Incidents WHERE status='Open';
  RETURN total;
END //

CREATE TRIGGER trg_incident_status_update
AFTER UPDATE ON Incidents
FOR EACH ROW
BEGIN
  IF NOT (OLD.status <=> NEW.status) THEN
    INSERT INTO Incident_Status_History
      (incident_id,old_status,new_status,changed_by,remarks)
    VALUES
      (NEW.incident_id,OLD.status,NEW.status,NEW.reported_by,
       'Status automatically recorded by database trigger.');
  END IF;
END //

DELIMITER ;

CALL GetAllIncidents();
CALL GetIncidentsByStatus('Open');
CALL GetIncidentsByStatus('Resolved');
SELECT GetTotalIncidents() AS total_incidents;
SELECT GetOpenIncidents() AS open_incidents;

-- Trigger demonstration: if incident 12 is Open, change it and automatically
-- record the transition. This is a real update and is intentionally retained.
UPDATE Incidents SET status='Under Review'
WHERE incident_id=12 AND status='Open';

SELECT * FROM Incident_Status_History
WHERE incident_id=12 ORDER BY changed_at DESC,history_id DESC;

-- PART 14 — SET OPERATIONS
-- UNION removes duplicates; UNION ALL retains duplicates.
-- INTERSECT and EXCEPT require MySQL 8.0.31+.
SELECT full_name AS person_name FROM Users WHERE user_id<=5
UNION
SELECT full_name AS person_name FROM Users WHERE user_id>=5;

SELECT full_name AS person_name FROM Users WHERE user_id<=5
UNION ALL
SELECT full_name AS person_name FROM Users WHERE user_id>=5;

-- MySQL 8.0.31+
SELECT user_id FROM Users
INTERSECT
SELECT reported_by FROM Incidents;

-- MySQL 8.0.31+
SELECT user_id FROM Users
EXCEPT
SELECT reported_by FROM Incidents;

-- PART 15 — FINAL VERIFICATION
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type='VIEW';
SHOW PROCEDURE STATUS WHERE Db='CyberTrack';
SHOW FUNCTION STATUS WHERE Db='CyberTrack';
SHOW TRIGGERS FROM CyberTrack;
SHOW INDEX FROM Incidents;

SELECT TABLE_NAME,ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='CyberTrack'
ORDER BY TABLE_NAME;

SELECT 'Users' AS table_name,COUNT(*) AS record_count FROM Users
UNION ALL SELECT 'Incident_Types',COUNT(*) FROM Incident_Types
UNION ALL SELECT 'Severity',COUNT(*) FROM Severity
UNION ALL SELECT 'Incidents',COUNT(*) FROM Incidents
UNION ALL SELECT 'Investigations',COUNT(*) FROM Investigations
UNION ALL SELECT 'Evidence',COUNT(*) FROM Evidence
UNION ALL SELECT 'Incident_Status_History',COUNT(*) FROM Incident_Status_History;

-- PART 16 — OPTIONAL NEGATIVE TESTS
-- Run these one at a time to see the expected constraint errors.
-- Duplicate email: expected UNIQUE constraint error.
-- INSERT INTO Users(full_name,email,user_role)
-- VALUES('Duplicate Email Test','aarav@example.com','User');

-- Invalid type_id: expected FOREIGN KEY constraint error.
-- INSERT INTO Incidents(title,type_id,severity_id,reported_by,status,incident_date)
-- VALUES('Invalid FK Test',999,1,1,'Open',NOW());

-- Invalid status: expected CHECK constraint error.
-- INSERT INTO Incidents(title,type_id,severity_id,reported_by,status,incident_date)
-- VALUES('Invalid Status Test',1,1,1,'Pending',NOW());

-- END OF CYBERTRACK SOURCE CODE
