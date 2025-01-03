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
GO

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
GO

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
GO

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
    CONSTRAINT chk_departure_date CHECK ([departure_date] > [arrival_date])
);
GO

CREATE TABLE [Facilities] (
    [id_facility] INT IDENTITY(1,1) PRIMARY KEY,
    [id_room] INT NOT NULL,
    [facility_name] NVARCHAR(100) NOT NULL,
    [facility_description] NVARCHAR(200),
    FOREIGN KEY ([id_room]) REFERENCES [Rooms]([id_room])
);
GO

CREATE TABLE [Payments] (
    [id_payment] INT IDENTITY(1,1) PRIMARY KEY,
    [id_reservation] INT NOT NULL,
    [amount] DECIMAL(18,2) NOT NULL CHECK ([amount] > 0),
    [payment_date] DATE NOT NULL,
    [payment_method] NVARCHAR(50) NOT NULL,
    FOREIGN KEY ([id_reservation]) REFERENCES [Reservations]([id_reservation])
);
GO

CREATE TABLE [Events] (
    [id_event] INT IDENTITY(1,1) PRIMARY KEY,
    [event_name] NVARCHAR(100) NOT NULL,
    [event_date] DATE NOT NULL,
    [location] NVARCHAR(200) NOT NULL,
    [description] NVARCHAR(200)
);
GO

CREATE TABLE [EventRegistration] (
    [id_registration] INT IDENTITY(1,1) PRIMARY KEY,
    [id_event] INT NOT NULL,
    [id_client] INT NOT NULL,
    [registration_date] DATE NOT NULL,
    FOREIGN KEY ([id_event]) REFERENCES [Events]([id_event]),
    FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client])
);
GO

-- Step 3: Indexing
CREATE NONCLUSTERED INDEX idx_fk_id_hotel ON [Rooms] ([id_hotel]);
CREATE NONCLUSTERED INDEX idx_fk_id_client ON [Reservations] ([id_client]);
CREATE NONCLUSTERED INDEX idx_fk_id_room ON [Facilities] ([id_room]);
CREATE NONCLUSTERED INDEX idx_fk_id_reservation ON [Payments] ([id_reservation]);
GO

-- Step 4: Triggers
CREATE TRIGGER trg_UpdateModifiedDate ON [Hotels]
AFTER UPDATE
AS
BEGIN
    UPDATE [Hotels]
    SET [ModifiedDate] = GETDATE()
    WHERE [id_hotel] IN (SELECT DISTINCT [id_hotel] FROM Inserted);
END;
GO

CREATE TRIGGER trg_UpdateTotalRooms ON [Rooms]
AFTER INSERT, DELETE
AS
BEGIN
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
    IF EXISTS (
        SELECT 1
        FROM [Reservations] r
        JOIN Inserted i ON r.[id_room] = i.[id_room]
        WHERE i.[arrival_date] < r.[departure_date]
          AND i.[departure_date] > r.[arrival_date]
          AND r.[payment_status] != 'Cancelled'
    )
    BEGIN
        RAISERROR('Pok�j jest ju� zarezerwowany w podanym terminie.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
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

-- Step 5: Stored Procedures
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
    END CATCH;
END;
GO

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
    END CATCH;
END;
GO

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
    END CATCH;
END;
GO

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
    END CATCH;
END;
GO

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
    END CATCH;
END;
GO;

-- ## Wstawianie danych do tabeli Hotels ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertHotel N'Hotel Paradise', N'USA', N'101 Sunset Blvd', 50, N'Alice Green', N'123456789';
    EXEC sp_InsertHotel N'Grand Royal', N'UK', N'102 High Street', 80, N'John Brown', N'987654321';
    EXEC sp_InsertHotel N'Empty Hotel', N'France', N'104 Rivoli', 1, N'Sophia White', N'789123456';
    EXEC sp_InsertHotel N'Hotel Atlantis', N'Germany', N'105 Oceanview', 120, N'Emma Brown', N'123456780';
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli Hotels';
    THROW;
END CATCH;

-- B��dne (duplikat nazwy hotelu)
BEGIN TRY
    EXEC sp_InsertHotel N'Hotel Paradise', N'Canada', N'103 Maple Ave', 60, N'David Smith', N'456789123';
END TRY
BEGIN CATCH
    PRINT 'B��d: duplikat nazwy hotelu!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Rooms ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertRoom 1, 150.00, 2, 2, 30.00, N'Deluxe room with balcony';
    EXEC sp_InsertRoom 1, 180.00, 3, 1, 20.00, N'Single room with city view';
    EXEC sp_InsertRoom 2, 300.00, 5, 3, 55.00, N'Family suite with kitchenette';
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli Rooms';
    THROW;
END CATCH;

-- B��dne (negatywna cena)
BEGIN TRY
    EXEC sp_InsertRoom 1, -50.00, 1, 1, 20.00, N'Single room';
END TRY
BEGIN CATCH
    PRINT 'B��d: negatywna cena!';
    THROW;
END CATCH;

-- B��dne (liczba ��ek poni�ej 1)
BEGIN TRY
    EXEC sp_InsertRoom 1, 120.00, 3, 0, 25.00, N'Small room';
END TRY
BEGIN CATCH
    PRINT 'B��d: liczba ��ek musi by� wi�ksza od 0!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Clients ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertClient N'John', N'Doe', N'123456789', N'john.doe@example.com', N'ID12345', N'123 Main St', N'USA', '2000-01-01', N'Male';
    EXEC sp_InsertClient N'Sophia', N'Davis', N'234567891', N'sophia.davis@example.com', N'ID54321', N'234 Elm St', N'USA', '1990-03-15', N'Female';
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli Clients';
    THROW;
END CATCH;

-- B��dne (niepe�noletni klient)
BEGIN TRY
    EXEC sp_InsertClient N'Jane', N'Smith', N'987654321', N'jane.smith@example.com', N'ID54321', N'456 Another St', N'Canada', '2010-05-15', N'Female';
END TRY
BEGIN CATCH
    PRINT 'B��d: klient musi by� pe�noletni!';
    THROW;
END CATCH;

-- B��dne (nieprawid�owy adres e-mail)
BEGIN TRY
    EXEC sp_InsertClient N'Invalid', N'Email', N'123456789', N'invalid-email', N'ID99999', N'123 Fake St', N'USA', '1990-01-01', N'Male';
END TRY
BEGIN CATCH
    PRINT 'B��d: nieprawid�owy adres e-mail!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Reservations ##

-- Poprawne
BEGIN TRY
    -- Wstawienie pierwszej rezerwacji
    EXEC sp_InsertReservation 
        @id_client = 1, 
        @id_room = 1, 
        @reservation_date = '2025-01-01', -- U�ycie konkretnej daty zamiast GETDATE()
        @arrival_date = '2024-12-25', 
        @departure_date = '2024-12-30', 
        @payment_status = N'Pending', 
        @special_requests = N'No special requirements';

    -- Wstawienie drugiej rezerwacji
    EXEC sp_InsertReservation 
        @id_client = 2, 
        @id_room = 2, 
        @reservation_date = '2025-01-02', -- U�ycie konkretnej daty zamiast GETDATE()
        @arrival_date = '2024-12-15', 
        @departure_date = '2024-12-20', 
        @payment_status = N'Pending', 
        @special_requests = N'Late arrival';
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli Reservations';
    THROW;
END CATCH;


-- B��dne (pok�j ju� zarezerwowany)
BEGIN TRY
    EXEC sp_InsertReservation 2, 1, '2024-12-20', '2024-12-27', '2024-12-28', N'Pending', N'Early check-in';
END TRY
BEGIN CATCH
    PRINT 'B��d: pok�j ju� zarezerwowany w tym okresie!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Payments ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertPayment 1, 900.00, '2024-12-15', N'Credit Card';
    EXEC sp_InsertPayment 2, 1800.00, '2024-12-20', N'Bank Transfer';
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli Payments';
    THROW;
END CATCH;

-- B��dne (brak kwoty p�atno�ci)
BEGIN TRY
    EXEC sp_InsertPayment 1, NULL, '2024-12-15', N'Credit Card';
END TRY
BEGIN CATCH
    PRINT 'B��d: brak kwoty p�atno�ci!';
    THROW;
END CATCH;

-- B��dne (brak metody p�atno�ci)
BEGIN TRY
    EXEC sp_InsertPayment 1, 500.00, '2024-12-15', NULL;
END TRY
BEGIN CATCH
    PRINT 'B��d: brak metody p�atno�ci!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Events ##

-- Poprawne
BEGIN TRY
    INSERT INTO [Events] ([event_name], [event_date], [location], [description])
    VALUES
    (N'Christmas Gala', '2024-12-24', N'Main Ballroom', N'A grand Christmas celebration'),
    (N'Corporate Retreat', '2024-12-15', N'Conference Room', N'A retreat for corporate teams'),
    (N'New Year Party', '2024-12-31', N'Rooftop Terrace', N'Celebrate the New Year with us!');
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli Events';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli EventRegistration ##

-- Poprawne
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES
    (1, 1, '2024-12-10'),
    (2, 2, '2024-12-11');
END TRY
BEGIN CATCH
    PRINT 'B��d wstawiania do tabeli EventRegistration';
    THROW;
END CATCH;

-- B��dne (brak klienta)
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES (3, NULL, '2024-12-11');
END TRY
BEGIN CATCH
    PRINT 'B��d: brak klienta!';
    THROW;
END CATCH;

-- B��dne (brak wydarzenia)
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES (NULL, 1, '2024-12-11');
END TRY
BEGIN CATCH
    PRINT 'B��d: brak wydarzenia!';
    THROW;
END CATCH;

-- #6 Testowanie widoku AvailableRooms
-- Sprawdzenie dost�pnych pokoi - powinno zwr�ci� pokoje, kt�re nie s� zarezerwowane w danym okresie
SELECT r.*
FROM [Rooms] r
LEFT JOIN [Reservations] res
  ON r.[id_room] = res.[id_room]
  AND res.[arrival_date] <= '2024-12-10'
  AND res.[departure_date] >= '2024-12-10'
WHERE res.[id_reservation] IS NULL;

-- Liczba rezerwacji w danym dniu
SELECT [arrival_date], COUNT(*) AS [NumberOfReservations]
FROM [Reservations]
GROUP BY [arrival_date]
ORDER BY [arrival_date];

-- Liczba rezerwacji przypisana do ka�dego klienta
SELECT c.[name], c.[last_name], COUNT(r.[id_reservation]) AS [NumberOfReservations]
FROM [Clients] c
LEFT JOIN [Reservations] r
  ON c.[id_client] = r.[id_client]
GROUP BY c.[name], c.[last_name]
ORDER BY [NumberOfReservations] DESC;

-- Liczba wydarze� zarejestrowanych w hotelach
SELECT h.[hotel_name], COUNT(e.[id_event]) AS [NumberOfEvents]
FROM [Hotels] h
LEFT JOIN [Events] e
  ON h.[id_hotel] = e.[id_event]
GROUP BY h.[hotel_name]
ORDER BY [NumberOfEvents] DESC;

-- Przyk�adowe zapytanie do odczytania rezerwacji
SELECT 
    r.id_reservation, 
    r.reservation_date, 
    c.name AS client_name, 
    c.last_name AS client_last_name, 
    r.arrival_date, 
    r.departure_date, 
    r.payment_status, 
    r.special_requests
FROM Reservations r
JOIN Clients c ON r.id_client = c.id_client;

-- Przyk�adowe zapytanie analityczne
-- Wy�wietlenie liczby rezerwacji wykonanych przez ka�dego pracownika w danym miesi�cu
-- Widok pokazuj�cy liczb� rezerwacji w ka�dym pokoju w hotelu
go;
CREATE VIEW RoomReservationSummary AS
SELECT 
    h.hotel_name, 
    r.id_room, 
    COUNT(res.id_reservation) AS total_reservations
FROM Hotels h
JOIN Rooms r ON h.id_hotel = r.id_hotel
LEFT JOIN Reservations res ON r.id_room = res.id_room
GROUP BY h.hotel_name, r.id_room;
go;

-- Zapytanie wykorzystuj�ce widok do wy�wietlenia liczby rezerwacji w hotelach
SELECT * 
FROM RoomReservationSummary
WHERE total_reservations > 0
ORDER BY total_reservations DESC;
