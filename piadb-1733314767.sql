-- Step 1: Database Creation and Setup
CREATE DATABASE HOTELDB;
ALTER DATABASE HOTELDB COLLATE Polish_CS_AS;
USE HOTELDB;
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
    [departure_date] DATE NOT NULL,
    [payment_status] NVARCHAR(50) NOT NULL CHECK ([payment_status] IN ('Paid', 'Pending', 'Cancelled')),
    [special_requests] NVARCHAR(200),
    FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client]),
    FOREIGN KEY ([id_room]) REFERENCES [Rooms]([id_room]),
    CONSTRAINT chk_departure_date CHECK ([departure_date] > [arrival_date]) -- Przeniesiono ograniczenie CHECK na poziom tabeli
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
go;

-- Step 3: Triggers for ModifiedDate Updates

CREATE TRIGGER trg_UpdateModifiedDate ON [Hotels]
AFTER UPDATE AS
BEGIN
	UPDATE [Hotels]
	SET [ModifiedDate] = GETDATE()
	WHERE [id_hotel] IN (SELECT DISTINCT [id_hotel] FROM Inserted);
END;
GO;

CREATE TRIGGER trg_UpdateTotalRooms ON [Rooms]
AFTER INSERT, DELETE
AS
BEGIN
    -- Aktualizacja po dodaniu pokoju
    IF EXISTS (SELECT * FROM Inserted)
    BEGIN
        UPDATE h
        SET [total_rooms] = (
            SELECT COUNT(*)
            FROM [Rooms]
            WHERE [id_hotel] = i.[id_hotel]
        )
        FROM [Hotels] h
        JOIN Inserted i ON h.[id_hotel] = i.[id_hotel];
    END

    -- Aktualizacja po usuniêciu pokoju
    IF EXISTS (SELECT * FROM Deleted)
    BEGIN
        UPDATE h
        SET [total_rooms] = (
            SELECT COUNT(*)
            FROM [Rooms]
            WHERE [id_hotel] = d.[id_hotel]
        )
        FROM [Hotels] h
        JOIN Deleted d ON h.[id_hotel] = d.[id_hotel];
    END
END;
GO

CREATE TRIGGER trg_CheckRoomAvailability ON [Reservations]
INSTEAD OF INSERT
AS
BEGIN
    -- SprawdŸ, czy istnieje nak³adaj¹ca siê rezerwacja, która nie jest anulowana
    IF EXISTS (
        SELECT 1
        FROM [Reservations] r
        JOIN Inserted i ON r.[id_room] = i.[id_room]
        WHERE i.[arrival_date] < r.[departure_date]
          AND i.[departure_date] > r.[arrival_date]
          AND r.[payment_status] != 'Cancelled'
    )
    BEGIN
        -- Jeœli nak³adaj¹ca siê rezerwacja istnieje, zg³oœ b³¹d
        RAISERROR('Pokój jest ju¿ zarezerwowany w podanym terminie.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Jeœli nie ma konfliktu, wstaw dane
        INSERT INTO [Reservations] ([id_client], [id_room], [reservation_date], [arrival_date], [departure_date], [payment_status], [special_requests])
        SELECT [id_client], [id_room], [reservation_date], [arrival_date], [departure_date], [payment_status], [special_requests]
        FROM Inserted;
    END
END;
GO


CREATE TRIGGER trg_UpdatePaymentStatus ON [Payments]
AFTER INSERT
AS
BEGIN
    UPDATE [Reservations]
    SET [payment_status] = 'Paid'
    WHERE [id_reservation] IN (SELECT [id_reservation] FROM Inserted);
END;
GO



-- Step 4: Indexing
CREATE NONCLUSTERED INDEX idx_fk_id_hotel ON [Rooms] ([id_hotel]);
CREATE NONCLUSTERED INDEX idx_fk_id_client ON [Reservations] ([id_client]);
CREATE NONCLUSTERED INDEX idx_fk_id_room ON [Facilities] ([id_room]);
CREATE NONCLUSTERED INDEX idx_fk_id_reservation ON [Payments] ([id_reservation]);

-- Step 5: Stored Procedures for Data Manipulation
go;
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
go;
CREATE PROCEDURE sp_InsertClient
    @name NVARCHAR(50),
    @last_name NVARCHAR(50),
    @contact_number NVARCHAR(15),
    @email NVARCHAR(100),
    @document_number NVARCHAR(50),
    @address NVARCHAR(200),
    @country NVARCHAR(100),
    @date_of_birth DATE,
    @gender NVARCHAR(10)
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Clients] ([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
        VALUES (@name, @last_name, @contact_number, @email, @document_number, @address, @country, @date_of_birth, @gender);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure for Rooms Table
CREATE PROCEDURE sp_InsertRoom
    @id_hotel INT,
    @price_per_night DECIMAL(18,2),
    @floor INT,
    @number_of_beds INT,
    @room_size DECIMAL(18,2),
    @description NVARCHAR(200)
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Rooms] ([id_hotel], [price_per_night], [floor], [number_of_beds], [room_size], [description])
        VALUES (@id_hotel, @price_per_night, @floor, @number_of_beds, @room_size, @description);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure for Reservations Table
CREATE PROCEDURE sp_InsertReservation
    @id_client INT,
    @id_room INT,
    @reservation_date DATE,
    @arrival_date DATE,
    @departure_date DATE,
    @payment_status NVARCHAR(50),
    @special_requests NVARCHAR(200)
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Reservations] ([id_client], [id_room], [reservation_date], [arrival_date], [departure_date], [payment_status], [special_requests])
        VALUES (@id_client, @id_room, @reservation_date, @arrival_date, @departure_date, @payment_status, @special_requests);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure for Payments Table
CREATE PROCEDURE sp_InsertPayment
    @id_reservation INT,
    @amount DECIMAL(18,2),
    @payment_date DATE,
    @payment_method NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Payments] ([id_reservation], [amount], [payment_date], [payment_method])
        VALUES (@id_reservation, @amount, @payment_date, @payment_method);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
