-- uzupe³nianie bazy danych
USE tempdb;

INSERT INTO [Hotels] 
([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
VALUES 
('Hotel Paradise', 'USA', 101, 50, 'Alice Green', '123456789'),
('Grand Royal', 'UK', 102, 80, 'John Brown', '987654321');

INSERT INTO [Hotels] 
([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
VALUES 
('Empty Hotel', 'France', 104, 1, 'Sophia White', '789123456');

INSERT INTO [Hotels] 
([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
VALUES 
('Hotel Atlantis', 'Germany', 105, 120, 'Emma Brown', '123456780');

-- Hotel z t¹ sam¹ nazw¹ ( zakoñczenie niepowodzeniem )
INSERT INTO [Hotels] 
([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
VALUES 
('Hotel Paradise', 'Canada', 103, 60, 'David Smith', '456789123'); 

-- #2 Dodawanie pokoi
-- Poprawne dane - operacja powinna siê powieœæ
INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [number_of_rooms], [allow_animals], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, 150.00, 5, 'Yes', 2, 2, 30.00, 'Deluxe room with balcony'); -- Ma siê udaæ

INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [number_of_rooms], [allow_animals], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, 180.00, 1, 'Yes', 3, 1, 20.00, 'Single room with city view'),
(2, 300.00, 1, 'No', 5, 3, 55.00, 'Family suite with kitchenette'),
(1, 250.00, 2, 'Yes', 4, 2, 40.00, 'Double room with ocean view'),
(2, 350.00, 2, 'No', 6, 4, 70.00, 'Penthouse with private pool'),
(2, 250.00, 3, 'Yes', 4, 2, 40.00, 'Double room with ocean view'),
(3, 150.00, 1, 'Yes', 2, 2, 35.00, 'Standard double room'),
(3, 150.00, 2, 'Yes', 2, 2, 25.00, 'Standard double room'),
(3, 150.00, 3, 'Yes', 2, 2, 40.00, 'Standard double room')



-- Negatywna cena za noc - operacja powinna zakoñczyæ siê b³êdem
INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [number_of_rooms], [allow_animals], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, -50.00, 2, 'No', 1, 1, 20.00, 'Single room'); -- Ma siê nie udaæ

-- Liczba ³ó¿ek poni¿ej 1 - operacja powinna zakoñczyæ siê b³êdem
INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [number_of_rooms], [allow_animals], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, 120.00, 3, 'No', 1, 0, 25.00, 'Small room'); -- Ma siê nie udaæ


-- Poprawne dane - operacja powinna siê powieœæ
INSERT INTO [Clients] 
([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES 
('John', 'Doe', 123456789, 'john.doe@example.com', 'ID12345', '123 Main St', 'USA', '2000-01-01', 'Male'); -- Ma siê udaæ

INSERT INTO [Clients] 
([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES 
('Sophia', 'Davis', 234567891, 'sophia.davis@example.com', 'ID54321', '234 Elm St', 'USA', '1990-03-15', 'Female'),
('James', 'Wilson', 345678912, 'james.wilson@example.com', 'ID67890', '456 Oak St', 'Canada', '1985-07-20', 'Male'),
('Mia', 'Johnson', 456789123, 'mia.johnson@example.com', 'ID78901', '567 Pine St', 'UK', '1995-12-25', 'Female'),
('Noah', 'Martinez', 567891234, 'noah.martinez@example.com', 'ID89012', '678 Birch St', 'Germany', '1988-09-10', 'Male');


-- Niepe³noletni klient - operacja powinna zakoñczyæ siê b³êdem
INSERT INTO [Clients] 
([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES 
('Jane', 'Smith', 987654321, 'jane.smith@example.com', 'ID54321', '456 Another St', 'Canada', '2010-05-15', 'Female'); -- Ma siê nie udaæ

-- Klient z niepoprawnym adresem e-mail
INSERT INTO [Clients] ([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES ('Invalid', 'Email', 123456789, 'invalid-email', 'ID99999', '123 Fake St', 'USA', '1990-01-01', 'Male'); -- Ma siê nie udaæ



-- #3 Dodawanie rezerwacji
-- Poprawna rezerwacja - operacja powinna siê powieœæ
INSERT INTO [Reservations]
([id_client], [reservation_date], [data_arrival], [data_department], [id_room], [payment_status], [special_requents], [number_of_people], [number_animals], [cancellation_policy],[hotel_id])
VALUES 
(1, GETDATE(), '2024-12-25', '2024-12-30', 1, 'Pending', 'No special requirements', 2, 0, '24-hour notice',1); -- Ma siê udaæ

INSERT INTO [Reservations]
([id_client], [reservation_date], [data_arrival], [data_department], [id_room], [payment_status], [special_requents], [number_of_people], [number_animals], [cancellation_policy],[hotel_id])
VALUES 
(2, GETDATE(), '2024-12-15', '2024-12-20', 2, 'Confirmed', 'Late arrival', 2, 0, 'Non-refundable',1),
(3, GETDATE(), '2024-12-22', '2024-12-28', 3, 'Pending', 'No special requests', 3, 0, '24-hour notice',2),
(4, GETDATE(), '2024-12-29', '2025-01-03', 5, 'Confirmed', 'Early check-in', 4, 1, 'Flexible',2);

Select * from clients
Select * from rooms

-- Rezerwacja z dat¹ przyjazdu po dacie wyjazdu - operacja powinna zakoñczyæ siê b³êdem
INSERT INTO [Reservations]
([id_client], [reservation_date], [data_arrival], [data_department], [id_room], [payment_status], [special_requents], [number_of_people], [number_animals], [cancellation_policy],[hotel_id])
VALUES 
(1, GETDATE(), '2024-12-30', '2024-12-25', 1, 'Pending', 'Late check-in', 1, 0, 'Flexible',1); -- Ma siê nie udaæ

-- Rezerwacja pokoju ju¿ zajêtego w danym okresie - operacja powinna zakoñczyæ siê b³êdem
INSERT INTO [Reservations]
([id_client], [reservation_date], [data_arrival], [data_department], [id_room], [payment_status], [special_requents], [number_of_people], [number_animals], [cancellation_policy],[hotel_id])
VALUES 
(2, GETDATE(), '2024-12-27', '2024-12-28', 1, 'Pending', 'Early check-in', 1, 0, 'Non-refundable',1); -- Ma siê nie udaæ


INSERT INTO [Payments]
([client_id], [reservation_id], [status], [payment_date], [amount], [currency], [is_refunded], [refund_date])
VALUES 
(2, 1, 'Paid', GETDATE(), 900.00, 'USD', 0, NULL),
(3, 2, 'Pending', NULL, 1800.00, 'USD', 0, NULL),
(4, 3, 'Paid', GETDATE(), 2100.00, 'EUR', 0, NULL);

INSERT INTO [EventRegistration]
([event_id], [client_id], [number_of_people], [registration_date], [status])
VALUES 
(1, 2, 2, GETDATE(), 'Confirmed'),
(2, 3, 1, GETDATE(), 'Pending'),
(3, 4, 4, GETDATE(), 'Confirmed');


INSERT INTO [Events]
([hotel_id], [event_name], [event_description], [start_date], [end_date], [max_number_of_guests], [organizer_name], [status])
VALUES 
(1, 'Christmas Gala', 'A grand Christmas celebration for guests', '2024-12-24', '2024-12-25', 150, 'Alice Green', 'Scheduled'),
(2, 'Corporate Retreat', 'A retreat for corporate teams', '2024-12-15', '2024-12-17', 50, 'Liam Smith', 'Scheduled'),
(3, 'New Year Party', 'Ring in the New Year with us!', '2024-12-31', '2025-01-01', 200, 'Emma Brown', 'Scheduled');


-- Wydarzenie z b³êdnymi datami
INSERT INTO [Events] ([hotel_id], [event_name], [event_description], [start_date], [end_date], [max_number_of_guests], [organizer_name], [status])
VALUES (1, 'Invalid Event', 'Test invalid dates', '2024-12-25', '2024-12-20', 50, 'Invalid Organizer', 'Scheduled'); -- Ma siê nie udaæ


-- #4 Testowanie wyzwalacza na zmianê statusu rezerwacji
-- Zmiana statusu rezerwacji na "Cancelled" - operacja powinna siê powieœæ
UPDATE [Reservations]
SET [payment_status] = 'Cancelled'
WHERE [id_reservation] = 2; -- Ma siê udaæ


-- #5 Dodawanie p³atnoœci
-- Poprawna p³atnoœæ - operacja powinna siê powieœæ
INSERT INTO [Payments]
([client_id], [reservation_id], [status], [payment_date], [amount], [currency], [is_refunded], [refund_date])
VALUES 
(1, 1, 'Paid', GETDATE(), 500.00, 'USD', 0, NULL); -- Ma siê udaæ

-- P³atnoœæ z nieprawid³ow¹ walut¹ (NULL) - operacja powinna zakoñczyæ siê b³êdem
INSERT INTO [Payments]
([client_id], [reservation_id], [status], [payment_date], [amount], [currency], [is_refunded], [refund_date])
VALUES 
(1, 1,'Paid', GETDATE(), 500.00, NULL, 0, NULL); -- Ma siê nie udaæ




-- #6 Testowanie widoku AvailableRooms
-- Sprawdzenie dostêpnych pokoi - powinno zwróciæ dostêpne pokoje
SELECT * FROM AvailableRooms; -- Ma zwróciæ pokoje, które nie s¹ zarezerwowane


SELECT *
FROM [Hotels]

-- sprawdzenie poprawnosci wieku klientow
SELECT * 
FROM [Clients]
WHERE DATEDIFF(YEAR, [date_of_birth], GETDATE()) < 18;


SELECT * 
FROM [Clients]
WHERE [email] NOT LIKE '%_@__%.__%';


SELECT * 
FROM [Reservations]
WHERE [data_arrival] >= [data_department];

-- Sprawdzenie, czy pokój zosta³ podwójnie zarezerwowany na ten sam okres:
SELECT r1.*
FROM [Reservations] r1
JOIN [Reservations] r2
  ON r1.[id_room] = r2.[id_room]
 AND r1.[id_reservation] <> r2.[id_reservation]
 AND r1.[data_arrival] < r2.[data_department]
 AND r1.[data_department] > r2.[data_arrival];


 --Sprawdzenie wszystkich wierszy w tabelach z kluczami obcymi, które nie maj¹ dopasowanych kluczy g³ównych:

 SELECT *
FROM [Rooms]
WHERE [id_hotel] NOT IN (SELECT [id_hotel] FROM [Hotels]);

SELECT *
FROM [Facilities]
WHERE [room_id] NOT IN (SELECT [id_room] FROM [Rooms]);

SELECT *
FROM [Payments]
WHERE [reservation_id] NOT IN (SELECT [id_reservation] FROM [Reservations]);


-- ilosc prezerwacji
SELECT [data_arrival], COUNT(*) AS [NumberOfReservations]
FROM Reservations
GROUP BY [data_arrival]
ORDER BY [data_arrival];


SELECT c.[name], c.[last_name], COUNT(r.[id_reservation]) AS [NumberOfReservations]
FROM Clients c
JOIN Reservations r ON c.[id_client] = r.[id_client]
GROUP BY c.[name], c.[last_name]
ORDER BY [NumberOfReservations] DESC;

