use tempdb;

CREATE TABLE [Hotels] (
	[id_hotel] int IDENTITY(1,1) NOT NULL UNIQUE,
	[hotel_name] nvarchar(100) NOT NULL UNIQUE,
	[country] nvarchar(100) NOT NULL,
	[address] int NOT NULL,
	[total_rooms] int NOT NULL,
	[manager_name] nvarchar(100) NOT NULL,
	[contact_number] nvarchar(max) NOT NULL,
	PRIMARY KEY ([id_hotel])
);

CREATE TABLE [Rooms] (
	[id_room] int IDENTITY(1,1) NOT NULL UNIQUE,
	[id_hotel] int NOT NULL,
	[price_per_night] decimal(18,0) NOT NULL,
	[number_of_rooms] int NOT NULL,
	[allow_animals] nvarchar(3) NOT NULL,
	[floor] int NOT NULL,
	[number_of_beds] int NOT NULL,
	[room_size] decimal(18,0) NOT NULL,
	[description] nvarchar(200) NOT NULL,
	PRIMARY KEY ([id_room])
);

CREATE TABLE [Clients] (
	[id_client] int IDENTITY(1,1) NOT NULL UNIQUE,
	[name] nvarchar(50) NOT NULL,
	[last_name] nvarchar(50) NOT NULL,
	[contact_number] int NOT NULL UNIQUE,
	[email] nvarchar(100) NOT NULL,
	[document_number] nvarchar(50) NOT NULL,
	[address] nvarchar(100) NOT NULL,
	[country] nvarchar(100) NOT NULL,
	[date_of_birth] date NOT NULL,
	[gender] nvarchar(10) NOT NULL,
	PRIMARY KEY ([id_client])
);

CREATE TABLE [Reservations] (
	[id_reservation] int IDENTITY(1,1) NOT NULL UNIQUE,
	[id_client] int NOT NULL,
	[reservation_date] date NOT NULL,
	[data_arrival] date NOT NULL,
	[data_department] date NOT NULL,
	[id_room] int NOT NULL,
	[payment_status] nvarchar(200) NOT NULL,
	[special_requents] nvarchar(200) NOT NULL,
	[number_of_people] int NOT NULL,
	[number_animals] int NOT NULL,
	[cancellation_policy] nvarchar(max) NOT NULL,
	[hotel_id] int not null,
	PRIMARY KEY ([id_reservation])
);

CREATE TABLE [Facilities] (
	[id] int IDENTITY(1,1) NOT NULL UNIQUE,
	[room_id] int NOT NULL,
	[number_of_balcons] int NOT NULL,
	[view] nvarchar(100) NOT NULL,
	[allow_smoking] nvarchar(10) NOT NULL,
	[private_bathroom] nvarchar(10) NOT NULL,
	[private_kitchen] nvarchar(30) NOT NULL,
	[gym_access] bit NOT NULL,
	[heating] bit NOT NULL,
	[air_conditioning] bit NOT NULL,
	PRIMARY KEY ([id])
);

CREATE TABLE [Payments] (
	[id_payment] int IDENTITY(1,1) NOT NULL UNIQUE,
	[client_id] int NOT NULL,
	[reservation_id] int NOT NULL,
	[status] nvarchar(100) NOT NULL,
	[payment_date] date,
	[amount] decimal(18,0) NOT NULL,
	[currency] nvarchar(50) NOT NULL,
	[is_refunded] bit NOT NULL,
	[refund_date] date,
	PRIMARY KEY ([id_payment])
);

CREATE TABLE [Events] (
	[id_event] int IDENTITY(1,1) NOT NULL UNIQUE,
	[hotel_id] int NOT NULL,
	[event_name] nvarchar(100) NOT NULL,
	[event_description] nvarchar(400) NOT NULL,
	[start_date] date NOT NULL,
	[end_date] date NOT NULL,
	[max_number_of_guests] int NOT NULL,
	[organizer_name] nvarchar(100) NOT NULL,
	[status] nvarchar(100) NOT NULL,
	PRIMARY KEY ([id_event])
);

CREATE TABLE [EventRegistration] (
	[id_registration] int IDENTITY(1,1) NOT NULL UNIQUE,
	[event_id] int NOT NULL,
	[client_id] int NOT NULL,
	[number_of_people] int NOT NULL,
	[registration_date] date NOT NULL,
	[status] nvarchar(100) NOT NULL,
	PRIMARY KEY ([id_registration])
);


ALTER TABLE [Rooms] ADD CONSTRAINT [Rooms_fk] FOREIGN KEY ([id_hotel]) REFERENCES [Hotels]([id_hotel]);
ALTER TABLE [Reservations] ADD CONSTRAINT [Reservations_Client_FK] FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client]);

ALTER TABLE [Reservations] ADD CONSTRAINT [Reservations_Hotel_FK] FOREIGN KEY ([hotel_id]) REFERENCES [Hotels]([id_hotel]);
ALTER TABLE [Reservations] ADD CONSTRAINT [Reservations_Room_FK] FOREIGN KEY ([id_room]) REFERENCES [Rooms]([id_room]);
ALTER TABLE [Facilities] ADD CONSTRAINT [Facilities_Room_FK] FOREIGN KEY ([room_id]) REFERENCES [Rooms]([id_room]);
ALTER TABLE [Payments] ADD CONSTRAINT [Payments_Client_FK] FOREIGN KEY ([client_id]) REFERENCES [Clients]([id_client]);

ALTER TABLE [Payments] ADD CONSTRAINT [Payments_Reservation_FK] FOREIGN KEY ([reservation_id]) REFERENCES [Reservations]([id_reservation]);
ALTER TABLE [Events] ADD CONSTRAINT [Events_Hotel_FK] FOREIGN KEY ([hotel_id]) REFERENCES [Hotels]([id_hotel]);
ALTER TABLE [EventRegistration] ADD CONSTRAINT [EventRegistration_Event_FK] FOREIGN KEY ([event_id]) REFERENCES [Events]([id_event]);

ALTER TABLE [EventRegistration] ADD CONSTRAINT [EventRegistration_fk2] FOREIGN KEY ([client_id]) REFERENCES [Clients]([id_client]);

-- klient rezerwujacy musi byc pe³noletni
ALTER TABLE [Clients] ADD CONSTRAINT [CK_Clients_Adult] CHECK (DATEDIFF(YEAR, [date_of_birth], GETDATE()) >= 18);
-- sprawdzenie poprawnosci plci
ALTER TABLE [Clients] ADD CONSTRAINT [CK_Clients_Gender] CHECK ([gender] IN ('Male', 'Female', 'Other'));

-- sprawdzenie poprawnosci pokoi
ALTER TABLE [Rooms] ADD CONSTRAINT [CK_Rooms_Price] CHECK ([price_per_night] > 0);
ALTER TABLE [Rooms] ADD CONSTRAINT [CK_Rooms_Beds] CHECK ([number_of_beds] >= 1);

-- sprawdzenie czy data wyjazdu < data przyjazdu
ALTER TABLE [Reservations] ADD CONSTRAINT [CK_Reservations_Dates] CHECK ([data_arrival] < [data_department]);

ALTER TABLE [Events] ADD CONSTRAINT [CK_Events_Dates] CHECK ([start_date] < [end_date]);

ALTER TABLE [Clients] ADD CONSTRAINT [CK_Clients_Email] CHECK ([email] LIKE '%_@__%.__%');





GO
CREATE TRIGGER trg_UpdateReservationStatus
ON [Reservations]
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE [payment_status] = 'Cancelled')
    BEGIN
        UPDATE [Reservations]
        SET [payment_status] = 'Cancelled'
        WHERE [id_reservation] IN (SELECT [id_reservation] FROM inserted);
    END
END;
GO

-- dodanie wartoœci defaultowych
ALTER TABLE [Facilities]
ADD CONSTRAINT [DF_Facilities_Heating] DEFAULT 0 FOR [heating],
             CONSTRAINT [DF_Facilities_AC] DEFAULT 0 FOR [air_conditioning];
GO

-- tworzenie indexow
CREATE NONCLUSTERED INDEX idx_FK_Reservations_Client ON [Reservations] ([id_client]);
CREATE NONCLUSTERED INDEX idx_FK_Reservations_Room ON [Reservations] ([id_room]);
CREATE NONCLUSTERED INDEX idx_FK_Payments_Reservation ON [Payments] ([reservation_id]);
GO

-- sprawdzenie czy pokoj zarezerwowany
CREATE PROCEDURE AddReservation
    @id_client INT,
    @id_room INT,
    @reservation_date DATE,
    @data_arrival DATE,
    @data_department DATE,
    @number_of_people INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
            SELECT 1 FROM Reservations
            WHERE [id_room] = @id_room
              AND [data_arrival] < @data_department
              AND [data_department] > @data_arrival
        )
        BEGIN
            THROW 50001, 'Room already reserved for this period.', 1;
        END
        INSERT INTO Reservations ([id_client], [id_room], [reservation_date], [data_arrival], [data_department], [number_of_people])
        VALUES (@id_client, @id_room, @reservation_date, @data_arrival, @data_department, @number_of_people);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- widok na wolne pokoje
CREATE VIEW AvailableRooms AS
SELECT r.[id_room], r.[price_per_night], r.[number_of_beds], h.[hotel_name]
FROM [Rooms] r
LEFT JOIN [Reservations] res ON r.[id_room] = res.[id_room]
LEFT JOIN [Hotels] h ON r.[id_hotel] = h.[id_hotel]
WHERE res.[id_reservation] IS NULL OR res.[data_department] < GETDATE();
GO


