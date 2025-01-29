IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HOTELDB')
BEGIN
    ALTER DATABASE HOTELDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HOTELDB;
END
GO

CREATE DATABASE HOTELDB
COLLATE Polish_CS_AS;
GO

USE HOTELDB;
GO

-- Schematy baz danych
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

CREATE TABLE [Roles] (
    [id_role] INT IDENTITY(1,1) PRIMARY KEY,
    [role_name] NVARCHAR(50) NOT NULL UNIQUE,
    [description] NVARCHAR(200) NULL
);
GO

CREATE TABLE [Employees] (
    [id_employee] INT IDENTITY(1,1) PRIMARY KEY,
    [id_hotel] INT NOT NULL,
    [first_name] NVARCHAR(50) NOT NULL,
    [last_name] NVARCHAR(50) NOT NULL,
    [position] NVARCHAR(50) NOT NULL,
    [salary] DECIMAL(18,2) NOT NULL CHECK ([salary] > 0),
    [contact_number] NVARCHAR(15) NOT NULL UNIQUE,
    [email] NVARCHAR(100) NOT NULL UNIQUE,
    [date_hired] DATE NOT NULL DEFAULT GETDATE(),
    [ModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [role_id] INT NOT NULL,
    FOREIGN KEY ([id_hotel]) REFERENCES [Hotels]([id_hotel]),
    FOREIGN KEY ([role_id]) REFERENCES [Roles]([id_role])
);
GO

CREATE TABLE [SalaryChangeLog] (
    [id_log] INT IDENTITY(1,1) PRIMARY KEY,
    [id_employee] INT NOT NULL,
    [old_salary] DECIMAL(18,2) NOT NULL,
    [new_salary] DECIMAL(18,2) NOT NULL,
    [change_date] DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY ([id_employee]) REFERENCES [Employees]([id_employee])
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

CREATE TABLE [Reviews] (
    [id_review] INT IDENTITY(1,1) PRIMARY KEY,
    [id_client] INT NOT NULL,
    [id_hotel] INT NOT NULL,
    [rating] INT NOT NULL CONSTRAINT DF_Reviews_Rating DEFAULT 0 CHECK ([rating] BETWEEN 1 AND 5),
    [comments] NVARCHAR(500),
    [review_date] DATE NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client]),
    FOREIGN KEY ([id_hotel]) REFERENCES [Hotels]([id_hotel])
);
GO

CREATE TABLE [Events] (
    [id_event] INT IDENTITY(1,1) PRIMARY KEY,
    [event_name] NVARCHAR(100) NOT NULL,
    [event_date] DATE NOT NULL,
    [location] NVARCHAR(200) NOT NULL,
    [description] NVARCHAR(200),
    [id_hotel] INT NOT NULL,
    FOREIGN KEY ([id_hotel]) REFERENCES [Hotels]([id_hotel])
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

-- 3. Indexowanie
CREATE NONCLUSTERED INDEX idx_fk_id_hotel ON [Rooms] ([id_hotel]);
CREATE NONCLUSTERED INDEX idx_fk_id_client ON [Reservations] ([id_client]);
CREATE NONCLUSTERED INDEX idx_fk_id_room ON [Facilities] ([id_room]);
CREATE NONCLUSTERED INDEX idx_fk_id_reservation ON [Payments] ([id_reservation]);
CREATE NONCLUSTERED INDEX idx_fk_id_hotel_events ON [Events] ([id_hotel]);
CREATE NONCLUSTERED INDEX idx_fk_id_hotel_employees ON [Employees] ([id_hotel]);
CREATE NONCLUSTERED INDEX idx_fk_role_id_employees ON [Employees] ([role_id]);
CREATE NONCLUSTERED INDEX idx_fk_id_client_reviews ON [Reviews] ([id_client]);
CREATE NONCLUSTERED INDEX idx_fk_id_hotel_reviews ON [Reviews] ([id_hotel]);
GO

--  Tworzenie triggerow
CREATE TRIGGER trg_UpdateModifiedDate ON [Hotels]
AFTER UPDATE
AS
BEGIN
    UPDATE [Hotels]
    SET [ModifiedDate] = GETDATE()
    WHERE [id_hotel] IN (SELECT DISTINCT [id_hotel] FROM Inserted);
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Employees ON [Employees]
AFTER UPDATE
AS
BEGIN
    UPDATE [Employees]
    SET [ModifiedDate] = GETDATE()
    WHERE [id_employee] IN (SELECT DISTINCT [id_employee] FROM Inserted);
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

CREATE TRIGGER trg_LogSalaryChanges ON [Employees]
AFTER UPDATE
AS
BEGIN
    IF UPDATE([salary])
    BEGIN
        INSERT INTO [SalaryChangeLog] ([id_employee], [old_salary], [new_salary])
        SELECT 
            d.[id_employee],
            d.[salary],
            i.[salary]
        FROM Deleted d
        JOIN Inserted i ON d.[id_employee] = i.[id_employee]
        WHERE d.[salary] <> i.[salary];
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
        RAISERROR('Room is already reserved in given time.', 16, 1);
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



-- Tworzenie procedur
CREATE OR ALTER PROCEDURE sp_InsertClient_toBase
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
        IF @email NOT LIKE '%_@__%.__%'
        BEGIN
            RAISERROR('Invalid email address format!', 16, 1);
            RETURN;
        END
        IF @contact_number NOT LIKE '%[0-9]%' OR LEN(@contact_number) < 9 OR LEN(@contact_number) > 15
        BEGIN
            RAISERROR('Invalid phone number format!', 16, 1);
            RETURN;
        END
		IF @gender NOT IN ('Male', 'Female', 'Other')
        BEGIN
            RAISERROR('Invalid gender value! Allowed values: Male, Female, Other.', 16, 1);
            RETURN;
        END

        INSERT INTO [Clients] ([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
        VALUES (@name, @last_name, @contact_number, @email, @document_number, @address, @country, @date_of_birth, @gender);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertRole
    @role_name NVARCHAR(50),
    @description NVARCHAR(200) = NULL
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Roles] ([role_name], [description])
        VALUES (@role_name, @description);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE sp_InsertEmployee
    @id_hotel INT,
    @first_name NVARCHAR(50),
    @last_name NVARCHAR(50),
    @position NVARCHAR(50),
    @salary DECIMAL(18,2),
    @contact_number NVARCHAR(15),
    @email NVARCHAR(100),
    @date_hired DATE,
    @role_id INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Employees] (
            [id_hotel], [first_name], [last_name], [position], [salary],
            [contact_number], [email], [date_hired], [role_id]
        )
        VALUES (
            @id_hotel, @first_name, @last_name, @position, @salary,
            @contact_number, @email, @date_hired, @role_id
        );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertReview
    @id_client INT,
    @id_hotel INT,
    @rating INT,
    @comments NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        -- Sprawdzenie poprawnoœci oceny
        IF @rating < 1 OR @rating > 5
        BEGIN
            RAISERROR('Rating must be between 1 and 5.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie istnienia klienta
        IF NOT EXISTS (SELECT 1 FROM [Clients] WHERE [id_client] = @id_client)
        BEGIN
            RAISERROR('Client does not exist.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie istnienia hotelu
        IF NOT EXISTS (SELECT 1 FROM [Hotels] WHERE [id_hotel] = @id_hotel)
        BEGIN
            RAISERROR('Hotel does not exist.', 16, 1);
            RETURN;
        END

        INSERT INTO [Reviews] ([id_client], [id_hotel], [rating], [comments])
        VALUES (@id_client, @id_hotel, @rating, @comments);
    END TRY
    BEGIN CATCH
        -- Wyœwietlenie b³êdu
        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @id_employee INT,
    @id_hotel INT = NULL,
    @first_name NVARCHAR(50) = NULL,
    @last_name NVARCHAR(50) = NULL,
    @position NVARCHAR(50) = NULL,
    @salary DECIMAL(18,2) = NULL,
    @contact_number NVARCHAR(15) = NULL,
    @email NVARCHAR(100) = NULL,
    @date_hired DATE = NULL,
    @role_id INT = NULL
AS
BEGIN
    BEGIN TRY
        UPDATE [Employees]
        SET 
            [id_hotel] = COALESCE(@id_hotel, [id_hotel]),
            [first_name] = COALESCE(@first_name, [first_name]),
            [last_name] = COALESCE(@last_name, [last_name]),
            [position] = COALESCE(@position, [position]),
            [salary] = COALESCE(@salary, [salary]),
            [contact_number] = COALESCE(@contact_number, [contact_number]),
            [email] = COALESCE(@email, [email]),
            [date_hired] = COALESCE(@date_hired, [date_hired]),
            [role_id] = COALESCE(@role_id, [role_id])
        WHERE [id_employee] = @id_employee;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_DeleteEmployee
    @id_employee INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM [Employees]
        WHERE [id_employee] = @id_employee;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


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
GO

CREATE PROCEDURE sp_InsertEvent
    @event_name NVARCHAR(100),
    @event_date DATE,
    @location NVARCHAR(200),
    @description NVARCHAR(200),
    @id_hotel INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO [Events] ([event_name], [event_date], [location], [description], [id_hotel])
        VALUES (@event_name, @event_date, @location, @description, @id_hotel);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- widok recenzji hoteli
CREATE OR ALTER VIEW AverageHotelRatings AS
SELECT 
    h.hotel_name,
    AVG(CAST(r.rating AS FLOAT)) AS average_rating
FROM 
    Hotels h
LEFT JOIN 
    Reviews r ON h.id_hotel = r.id_hotel
GROUP BY 
    h.hotel_name;
GO



--  Wstawianie przykladowych danych

-- wstawianie hoteli
BEGIN TRY
    EXEC sp_InsertHotel N'Hotel Paradise', N'PL', N'Radwanska 102', 50, N'Kamil Winczewski', N'123456789';
    EXEC sp_InsertHotel N'Grand Royal', N'UK', N'London street 2', 80, N'Martyna Szymanska', N'987654321';
    EXEC sp_InsertHotel N'Empty Hotel', N'France', N'Ravioli 104', 1, N'Maria Curie', N'789123456';
    EXEC sp_InsertHotel N'Hotel Berlin', N'Germany', N'Heise strase 2', 120, N'John French', N'123456780';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data to Hotel';
    THROW;
END CATCH;

-- wstawianie pokoi
BEGIN TRY
    EXEC sp_InsertRoom 1, 150.00, 2, 2, 30.00, N'Deluxe room with balcony';
    EXEC sp_InsertRoom 1, 180.00, 3, 1, 20.00, N'Single room with city view';
    EXEC sp_InsertRoom 2, 300.00, 5, 3, 55.00, N'Family suite with kitchen';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data to Rooms';
    THROW;
END CATCH;


-- Wstawianie przyk³¹dowych klientow
BEGIN TRY
    EXEC sp_InsertClient_toBase N'Marek', N'Cebula', N'123456789', N'm.cebula@example.com', N'ID12345', N'Nowa 15', N'Poland', '2000-01-01', N'Male';
    EXEC sp_InsertClient_toBase N'Zosia', N'Burek', N'234567891', N'zosia.bulp@example.com', N'ID54321', N'Stara 1', N'Poland', '1990-03-15', N'Female';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data to Clients';
    THROW;
END CATCH;

-- wstawianie rezerwacji
BEGIN TRY
    EXEC sp_InsertReservation 
        @id_client = 1, 
        @id_room = 1, 
        @reservation_date = '2025-01-01',
        @arrival_date = '2024-12-25', 
        @departure_date = '2024-12-30', 
        @payment_status = N'Pending', 
        @special_requests = N'No special requirements';

    EXEC sp_InsertReservation 
        @id_client = 2, 
        @id_room = 2, 
        @reservation_date = '2025-01-02', 
        @arrival_date = '2024-12-15', 
        @departure_date = '2024-12-20', 
        @payment_status = N'Pending', 
        @special_requests = N'Late arrival';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data to Reservations';
    THROW;
END CATCH;

-- wstawianie platnosci
BEGIN TRY
    EXEC sp_InsertPayment 1, 900.00, '2024-12-15', N'Credit Card';
    EXEC sp_InsertPayment 2, 1800.00, '2024-12-20', N'Bank Transfer';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data to Payments';
    THROW;
END CATCH;

-- wstawianie eventu
BEGIN TRY
    INSERT INTO [Events] ([event_name], [event_date], [location], [description],[id_hotel])
    VALUES
    (N'Christmas Gala', '2024-12-24', N'Main Ballroom', N'Christmas celebration', 1),
    (N'Corporate Retreat', '2024-12-15', N'Conference Room', N'Spotkanie przy herbacie', 2),
    (N'New Year Party', '2024-12-31', N'Rooftop Terrace', N'Impreza nowego roku!', 1);
END TRY
BEGIN CATCH
    PRINT 'Error: inserting data to Events';
    THROW;
END CATCH;

-- wstawianie rezerwacji eventu 
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES
    (1, 1, '2024-12-10'),
    (2, 2, '2024-12-11');
END TRY
BEGIN CATCH
    PRINT 'Error: inserting data to EventRegistration';
    THROW;
END CATCH;

-- wstawianie rol pracownikow
BEGIN TRY
    EXEC sp_InsertRole @role_name = N'Receptionist', @description = N'Handles front desk operations';
    EXEC sp_InsertRole @role_name = N'Housekeeper', @description = N'Responsible for cleaning rooms';
    EXEC sp_InsertRole @role_name = N'Manager', @description = N'Oversees hotel operations';
    EXEC sp_InsertRole @role_name = N'Chef', @description = N'In charge of the kitchen and meal preparations';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data into Roles';
    THROW;
END CATCH;
GO

-- dodawanie pracowników
BEGIN TRY
    EXEC sp_InsertEmployee 
        @id_hotel = 1,
        @first_name = N'Anna',
        @last_name = N'Lewandowska',
        @position = N'Receptionist',
        @salary = 2500.00,
        @contact_number = N'555123456',
        @email = N'anna.nowak@hotelparadise.com',
        @date_hired = '2023-06-15',
        @role_id = 1; -- recepcja
    
    EXEC sp_InsertEmployee 
        @id_hotel = 1,
        @first_name = N'Piotr',
        @last_name = N'Nowak',
        @position = N'Housekeeper',
        @salary = 2200.00,
        @contact_number = N'555654321',
        @email = N'piotr.kowalski@hotelparadise.com',
        @date_hired = '2022-04-10',
        @role_id = 2; -- sprzataczka
    
    EXEC sp_InsertEmployee 
        @id_hotel = 2,
        @first_name = N'El¿bieta',
        @last_name = N'Szymanska',
        @position = N'Manager',
        @salary = 4500.00,
        @contact_number = N'555987654',
        @email = N'elzbieta.szymanska@grandroyal.com',
        @date_hired = '2020-01-20',
        @role_id = 3; -- menager
    
    EXEC sp_InsertEmployee 
        @id_hotel = 3,
        @first_name = N'Marcin',
        @last_name = N'Lewandowski',
        @position = N'Chef',
        @salary = 4000.00,
        @contact_number = N'555456789',
        @email = N'marcin.lewandowski@emptyhotel.com',
        @date_hired = '2023-09-05',
        @role_id = 4;--chef
END TRY
BEGIN CATCH
    PRINT 'Error inserting data into Employees';
    THROW;
END CATCH;
GO

-- dodanie recenzji
BEGIN TRY
    EXEC sp_InsertReview 
        @id_client = 1, 
        @id_hotel = 1, 
        @rating = 5, 
        @comments = N'Excellent service and comfortable rooms!';
    
    EXEC sp_InsertReview 
        @id_client = 2, 
        @id_hotel = 2, 
        @rating = 4, 
        @comments = N'Great location but the room was a bit small.';

	EXEC sp_InsertReview 
        @id_client = 2, 
        @id_hotel = 3, 
        @rating = 5, 
        @comments = N'Great location but the room was a bit small.';
	
	EXEC sp_InsertReview 
        @id_client = 2, 
        @id_hotel = 4, 
        @rating = 3, 
        @comments = N'Great location but the room was a bit small.';
END TRY
BEGIN CATCH
    PRINT 'Error inserting data into Reviews';
    THROW;
END CATCH;
GO

-- dodanie smiany wynagrodzenia pracownika
BEGIN TRY
    EXEC sp_UpdateEmployee 
        @id_employee = 1, 
        @salary = 2600.00;
END TRY
BEGIN CATCH
    PRINT 'Error updating employee salary';
    THROW;
END CATCH;
GO

-- sprawdzenie zmian w pensjach
SELECT * FROM [SalaryChangeLog];
GO


-- zwraca pokoje, ktore nie sa zarezerwowane w podanym czasie
SELECT r.*
FROM [Rooms] r
LEFT JOIN [Reservations] res
  ON r.[id_room] = res.[id_room]
  AND res.[arrival_date] <= '2024-12-10'
  AND res.[departure_date] >= '2024-12-10'
WHERE res.[id_reservation] IS NULL;

-- rezerwacje w danym dniu
SELECT [arrival_date], COUNT(*) AS [NumberOfReservations]
FROM [Reservations]
GROUP BY [arrival_date]
ORDER BY [arrival_date];

--liczba rezerwacji klientow
SELECT c.[name], c.[last_name], COUNT(r.[id_reservation]) AS [NumberOfReservations]
FROM [Clients] c
LEFT JOIN [Reservations] r
  ON c.[id_client] = r.[id_client]
GROUP BY c.[name], c.[last_name]
ORDER BY [NumberOfReservations] DESC;

-- odczytanie rezerwacji
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


-- widok liczby rezerwacji w kazdym pokoju w hotelu
go
CREATE VIEW RoomReservationSummary AS
SELECT 
    h.hotel_name, 
    r.id_room, 
    COUNT(res.id_reservation) AS total_reservations
FROM Hotels h
JOIN Rooms r ON h.id_hotel = r.id_hotel
LEFT JOIN Reservations res ON r.id_room = res.id_room
GROUP BY h.hotel_name, r.id_room;
go

-- zapytanie wykorzystujuce widok do wyswietlenia liczby rezerwacji w hotelach
SELECT * 
FROM RoomReservationSummary
WHERE total_reservations > 0
ORDER BY total_reservations DESC;


--liczba uczestnikow kazdego wydarzenia:
SELECT e.event_name, COUNT(er.id_registration) AS total_participants
FROM Events e
LEFT JOIN EventRegistration er ON e.id_event = er.id_event
GROUP BY e.event_name
ORDER BY total_participants DESC;


-- pokazanie œrednich ocen hoteli
SELECT * from AverageHotelRatings;