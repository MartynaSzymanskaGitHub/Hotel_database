-- ustawienie Recovery Full
ALTER DATABASE HOTELDB SET RECOVERY FULL;
GO

-- Tworzenie loginów dla grup użytkowników
CREATE LOGIN HotelManagerLogin WITH PASSWORD = 'HotelManager123!';
CREATE LOGIN ReceptionistLogin WITH PASSWORD = 'Receptionist123!';
CREATE LOGIN GuestLogin WITH PASSWORD = 'Guest123!';
GO

CREATE USER HotelManagerUser FOR LOGIN HotelManagerLogin;
CREATE USER ReceptionistUser FOR LOGIN ReceptionistLogin;
CREATE USER GuestUser FOR LOGIN GuestLogin;
GO

-- Tworzenie ról
CREATE ROLE HotelManagerRole;
CREATE ROLE ReceptionistRole;
CREATE ROLE GuestRole;
GO

-- Przypisywanie użytkowników do ról
EXEC sp_addrolemember 'HotelManagerRole', 'HotelManagerUser';
EXEC sp_addrolemember 'ReceptionistRole', 'ReceptionistUser';
EXEC sp_addrolemember 'GuestRole', 'GuestUser';
GO

-- HotelManager: pełny dostęp do wszystkich danych
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: dbo TO HotelManagerRole;

-- Receptionist: odczyt i wstawianie danych w kluczowych tabelach
GRANT SELECT, INSERT ON [Clients] TO ReceptionistRole;
GRANT SELECT, INSERT ON [Reservations] TO ReceptionistRole;

-- Guest: tylko odczyt danych ogólnodostępnych
GRANT SELECT ON [Hotels] TO GuestRole;
GRANT SELECT ON [Rooms] TO GuestRole;
GO

-- Backup bazy danych
BACKUP DATABASE hoteldb 
TO DISK = 'C:\studia\backup.bak' 
WITH FORMAT, INIT, NAME = 'Full Backup of HOTELDB 245938 245958';
GO

-- Skrypt do przywracania bazy danych
RESTORE DATABASE tempdb 
FROM DISK = 'C:\studia\backup.bak' 
WITH RECOVERY, REPLACE;
GO


-- Logowanie jako HotelManagerUser
EXECUTE AS USER = 'HotelManagerUser';
-- Test: Pełny dostęp - zakończony powodzeniem
SELECT * FROM [Clients]; 
INSERT INTO [Clients] ([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES ('Test', 'Manager', '987654322', 'manager@test.com', 'ID99999', '123 Manager St', 'USA', '1990-01-01', 'Male');
REVERT;

-- Logowanie jako ReceptionistUser
EXECUTE AS USER = 'ReceptionistUser';
-- Test: Odczyt i wstawianie do kluczowych tabel - zakończenie powodzeniem
SELECT * FROM [Clients]; 
INSERT INTO [Clients] ([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES ('Test', 'Receptionist', '987654321', 'receptionist@test.com', 'ID88888', '456 Reception St', 'UK', '1995-12-25', 'Female');

-- Test: Brak dostępu do usuwania danych - zakończone błędem
DELETE FROM [Clients] WHERE [name] = 'Test'; 
REVERT;

-- Logowanie jako GuestUser
EXECUTE AS USER = 'GuestUser';
-- Test: Tylko odczyt danych publicznych -zakończone powodzeniem
SELECT * FROM [Hotels]; 
SELECT * FROM [Rooms]; 
-- Test: Brak dostępu do wstawiania danych - zakończone błędem
INSERT INTO [Clients] ([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES ('Test', 'Guest', '555555555', 'guest@test.com', 'ID77777', '789 Guest St', 'France', '2000-01-01', 'Male'); 
REVERT;
