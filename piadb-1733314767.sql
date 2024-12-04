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
	[room_number] int NOT NULL,
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
	[room_id] int NOT NULL,
	[reservation_id] int NOT NULL,
	[status] nvarchar(100) NOT NULL,
	[payment_date] date,
	[amount] decimal(18,0) NOT NULL,
	[currency] nvarchar(50) NOT NULL,
	[is_refunded] bit NOT NULL,
	[refund_date] date NOT NULL,
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


ALTER TABLE [Rooms] ADD CONSTRAINT [Rooms_fk1] FOREIGN KEY ([id_hotel]) REFERENCES [Hotels]([id_hotel]);
ALTER TABLE [Clients] ADD CONSTRAINT [Clients_fk10] FOREIGN KEY ([room_number]) REFERENCES [Rooms]([id_room]);
ALTER TABLE [Reservations] ADD CONSTRAINT [Reservations_fk1] FOREIGN KEY ([id_client]) REFERENCES [Clients]([id_client]);

ALTER TABLE [Reservations] ADD CONSTRAINT [Reservations_fk5] FOREIGN KEY ([id_room]) REFERENCES [Rooms]([id_room]);
ALTER TABLE [Facilities] ADD CONSTRAINT [Facilities_fk1] FOREIGN KEY ([room_id]) REFERENCES [Rooms]([id_room]);
ALTER TABLE [Payments] ADD CONSTRAINT [Payments_fk1] FOREIGN KEY ([client_id]) REFERENCES [Clients]([id_client]);

ALTER TABLE [Payments] ADD CONSTRAINT [Payments_fk2] FOREIGN KEY ([room_id]) REFERENCES [Rooms]([id_room]);

ALTER TABLE [Payments] ADD CONSTRAINT [Payments_fk3] FOREIGN KEY ([reservation_id]) REFERENCES [Reservations]([id_reservation]);
ALTER TABLE [Events] ADD CONSTRAINT [Events_fk1] FOREIGN KEY ([hotel_id]) REFERENCES [Hotels]([id_hotel]);
ALTER TABLE [EventRegistration] ADD CONSTRAINT [EventRegistration_fk1] FOREIGN KEY ([event_id]) REFERENCES [Events]([id_event]);

ALTER TABLE [EventRegistration] ADD CONSTRAINT [EventRegistration_fk2] FOREIGN KEY ([client_id]) REFERENCES [Clients]([id_client]);