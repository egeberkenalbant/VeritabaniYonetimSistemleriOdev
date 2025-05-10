CREATE DATABASE KilitlemeVeEszamanlilik;

SELECT 
    L.request_session_id AS SessionID,
    L.request_mode AS LockType,
    L.resource_type AS ResourceType,
    L.resource_database_id AS DatabaseID,
    DB_NAME(L.resource_database_id) AS DatabaseName,
    S.login_name AS UserName
FROM 
    sys.dm_tran_locks L
JOIN 
    sys.dm_exec_sessions S ON L.request_session_id = S.session_id;

SELECT 
    L.request_session_id AS SessionID,
    L.resource_type AS ResourceType,
    L.resource_database_id AS DatabaseID,
    DB_NAME(L.resource_database_id) AS DatabaseName,
    L.request_mode AS LockMode,
    L.request_status AS LockStatus
FROM 
    sys.dm_tran_locks L
ORDER BY 
    L.request_session_id;

SELECT 
    L.request_session_id AS SessionID,
    T.name AS TableName,
    L.request_mode AS LockMode
FROM 
    sys.dm_tran_locks L
JOIN 
    sys.tables T ON L.resource_associated_entity_id = T.object_id
WHERE 
    T.name = 'YourTableName';

SELECT 
    blocking_session_id AS BlockingSession,
    session_id AS BlockedSession
FROM 
    sys.dm_exec_requests
WHERE 
    blocking_session_id <> 0;

DBCC TRACEON(1222, -1);

USE KilitlemeVeEszamanlilik;

CREATE TABLE Musteriler (
    MusteriID INT PRIMARY KEY,
    AdSoyad NVARCHAR(100),
    Durum NVARCHAR(50)
);

INSERT INTO Musteriler VALUES
(1, 'Ali Yýlmaz', 'Aktif'),
(2, 'Ayþe Demir', 'Pasif');

BEGIN TRANSACTION;

UPDATE Musteriler WITH (UPDLOCK)
SET Durum = 'Aktif'
WHERE MusteriID = 2;

COMMIT TRANSACTION;
BEGIN TRANSACTION;

SELECT * FROM Musteriler WITH (TABLOCK)
WHERE Durum = 'Pasif';

COMMIT TRANSACTION;

BEGIN TRANSACTION;

SELECT * FROM Musteriler WITH (NOLOCK)
WHERE Durum = 'Pasif';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

UPDATE Musteriler
SET Durum = 'Aktif'
WHERE Durum = 'Pasif';

COMMIT TRANSACTION;

CREATE LOGIN testkullanici WITH PASSWORD = '1234567890*+%&!?-';

USE KilitlemeVeEszamanlilik;
CREATE USER testkullanici FOR LOGIN testkullanici;

GRANT SELECT, INSERT, UPDATE, DELETE ON Musteriler TO testkullanici;
