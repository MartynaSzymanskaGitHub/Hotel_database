-- Step 1: Database Creation and Setup
USE tempdb;
GO

-- Step 2: Table Definitions with Normalization and Constraints
CREATE TABLE [Hotels] (
	[id_hotel] INT IDENTITY(1,1) PRIMARY KEY,
	[hotel_name] NVARCHAR(100) NOT NULL UNIQUE,
	[country] NVARCHAR(100) NOT NULL,
	[address] NVARCHAR(200) NOT NULL,
	[total_rooms] INT NOT NULL CHECK ([total_rooms] > 0),
	[manager_name] NVARCHAR(100) NOT NULL,
	[contact_number] NVARCHAR(15) NOT NULL,
	[ModifiedDate] DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE [Rooms] (
	[id_room] INT IDENTITY(1,1) PRIMARY KEY,
	[id_hotel] INT NOT NULL,
	[price_per_night] DECIMAL(18,2) NOT NULL CHECK ([price_per_night] > 0),
	[floor] INT NOT NULL,
	[number_of_beds] INT NOT NULL CHECK ([number_of_beds] > 0),
	[room_size] DECIMAL(18,2) NOT NULL CHECK ([room_size] > 0),
	[description] NVARCHAR(200),
	[ModifiedDate] DATETIME2 DEFAULT GETDATE(),
	FOREIGN KEY ([id_hotel]) REFERENCES [Hotels]([id_hotel])
);

CREATE TABLE [Clients] (
	[id_client] INT IDENTITY(1,1) PRIMARY KEY,
	[name] NVARCHAR(50) NOT NULL,
	[last_name] NVARCHAR(50) NOT NULL,
	[contact_number] NVARCHAR(15) NOT NULL UNIQUE,
	[email] NVARCHAR(100) NOT NULL,
	[document_number] NVARCHAR(50) NOT NULL UNIQUE,
	[address] NVARCHAR(200),
	[country] NVARCHAR(100) NOT NULL,
	[date_of_birth] DATE NOT NULL,
	[gender] NVARCHAR(10) CHECK ([gender] IN ('Male', 'Female', 'Other'))
);

CREATE TABLE [Reservations] (
	[id_reservation] INT IDENTITY(1,1) PRIMARY KEY,
	[id_client] INT NOT NULL,
	[id_room] INT NOT NULL,
	[reservation_date] DATE NOT NULL,
	[arrival_date] DATE NOT NULL,
	[departure_date] DATE NOT NULL CHECK ([departure_date] > [arrival_date]),
	[payment_status] NVARCHAR(50) NOT NULL CHECK ([payment_status] IN ('Paid', 'Pending', 'Cancelled')),
	[special_requests] NVARCHAR(200),
	FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client]),
	FOREIGN KEY ([id_room]) REFERENCES [Rooms]([id_room])
);

CREATE TABLE [Facilities] (
	[id_facility] INT IDENTITY(1,1) PRIMARY KEY,
	[id_room] INT NOT NULL,
	[facility_name] NVARCHAR(100) NOT NULL,
	[facility_description] NVARCHAR(200),
	FOREIGN KEY ([id_room]) REFERENCES [Rooms]([id_room])
);

CREATE TABLE [Payments] (
	[id_payment] INT IDENTITY(1,1) PRIMARY KEY,
	[id_reservation] INT NOT NULL,
	[amount] DECIMAL(18,2) NOT NULL CHECK ([amount] > 0),
	[payment_date] DATE NOT NULL,
	[payment_method] NVARCHAR(50) NOT NULL,
	FOREIGN KEY ([id_reservation]) REFERENCES [Reservations]([id_reservation])
);

CREATE TABLE [Events] (
	[id_event] INT IDENTITY(1,1) PRIMARY KEY,
	[event_name] NVARCHAR(100) NOT NULL,
	[event_date] DATE NOT NULL,
	[location] NVARCHAR(200) NOT NULL,
	[description] NVARCHAR(200)
);

CREATE TABLE [EventRegistration] (
	[id_registration] INT IDENTITY(1,1) PRIMARY KEY,
	[id_event] INT NOT NULL,
	[id_client] INT NOT NULL,
	[registration_date] DATE NOT NULL,
	FOREIGN KEY ([id_event]) REFERENCES [Events]([id_event]),
	FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client])
);

-- Step 3: Triggers for ModifiedDate Updates
CREATE TRIGGER trg_UpdateModifiedDate ON [Hotels]
AFTER UPDATE AS
BEGIN
	UPDATE [Hotels]
	SET [ModifiedDate] = GETDATE()
	WHERE [id_hotel] IN (SELECT DISTINCT [id_hotel] FROM Inserted);
END;

-- Step 4: Indexing
CREATE NONCLUSTERED INDEX idx_fk_id_hotel ON [Rooms] ([id_hotel]);
CREATE NONCLUSTERED INDEX idx_fk_id_client ON [Reservations] ([id_client]);
CREATE NONCLUSTERED INDEX idx_fk_id_room ON [Facilities] ([id_room]);
CREATE NONCLUSTERED INDEX idx_fk_id_reservation ON [Payments] ([id_reservation]);

-- Step 5: Stored Procedures for Data Manipulation
CREATE PROCEDURE sp_InsertHotel
	@hotel_name NVARCHAR(100),
	@country NVARCHAR(100),
	@address NVARCHAR(200),
	@total_rooms INT,
	@manager_name NVARCHAR(100),
	@contact_number NVARCHAR(15)
AS
BEGIN
	BEGIN TRY
		INSERT INTO [Hotels] ([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
		VALUES (@hotel_name, @country, @address, @total_rooms, @manager_name, @contact_number);
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END;

-- Step 6: User Roles and Permissions
CREATE LOGIN HotelManager WITH PASSWORD = 'SecurePass123!';
CREATE USER HotelManagerUser FOR LOGIN HotelManager;
ALTER ROLE db_datareader ADD MEMBER HotelManagerUser;
ALTER ROLE db_datawriter ADD MEMBER HotelManagerUser;

-- Step 7: Backup
BACKUP DATABASE tempdb TO DISK = 'C:\Backup\HotelDB_Full.bak' WITH FORMAT;

-- Additional steps: Sample queries, analytics, and Power BI integration can be added later.
