-- Wstawianie danych do tabeli Hotels (z przykładowym błędem dla duplikatu)
INSERT INTO [Hotels] 
([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
VALUES 
('Hotel Paradise', 'USA', '101 Sunset Blvd', 50, 'Alice Green', '123456789'),
('Grand Royal', 'UK', '102 High Street', 80, 'John Brown', '987654321'),
('Empty Hotel', 'France', '104 Rivoli', 1, 'Sophia White', '789123456'),
('Hotel Atlantis', 'Germany', '105 Oceanview', 120, 'Emma Brown', '123456780');

-- Błąd: duplikat nazwy hotelu
INSERT INTO [Hotels] 
([hotel_name], [country], [address], [total_rooms], [manager_name], [contact_number])
VALUES 
('Hotel Paradise', 'Canada', '103 Maple Ave', 60, 'David Smith', '456789123');

-- Wstawianie danych do tabeli Rooms (z przykładowymi błędami)
INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, 150.00, 2, 2, 30.00, 'Deluxe room with balcony'),
(1, 180.00, 3, 1, 20.00, 'Single room with city view'),
(2, 300.00, 5, 3, 55.00, 'Family suite with kitchenette');

-- Błąd: negatywna cena
INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, -50.00, 1, 1, 20.00, 'Single room');

-- Błąd: liczba łóżek poniżej 1
INSERT INTO [Rooms] 
([id_hotel], [price_per_night], [floor], [number_of_beds], [room_size], [description])
VALUES 
(1, 120.00, 3, 0, 25.00, 'Small room');

-- Wstawianie danych do tabeli Clients
INSERT INTO [Clients] 
([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES 
('John', 'Doe', '123456789', 'john.doe@example.com', 'ID12345', '123 Main St', 'USA', '2000-01-01', 'Male'),
('Sophia', 'Davis', '234567891', 'sophia.davis@example.com', 'ID54321', '234 Elm St', 'USA', '1990-03-15', 'Female');

-- Błąd: niepełnoletni klient
INSERT INTO [Clients] 
([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES 
('Jane', 'Smith', '987654321', 'jane.smith@example.com', 'ID54321', '456 Another St', 'Canada', '2010-05-15', 'Female');

-- Błąd: nieprawidłowy adres e-mail
INSERT INTO [Clients] 
([name], [last_name], [contact_number], [email], [document_number], [address], [country], [date_of_birth], [gender])
VALUES 
('Invalid', 'Email', '123456789', 'invalid-email', 'ID99999', '123 Fake St', 'USA', '1990-01-01', 'Male');

-- Wstawianie danych do tabeli Reservations (z przykładowymi błędami)
INSERT INTO [Reservations] 
([id_client], [id_room], [reservation_date], [arrival_date], [departure_date], [payment_status], [special_requests])
VALUES 
(1, 1, GETDATE(), '2024-12-25', '2024-12-30', 'Pending', 'No special requirements'),
(2, 2, GETDATE(), '2024-12-15', '2024-12-20', 'Confirmed', 'Late arrival');

-- Błąd: data przyjazdu po dacie wyjazdu
INSERT INTO [Reservations] 
([id_client], [id_room], [reservation_date], [arrival_date], [departure_date], [payment_status], [special_requests])
VALUES 
(1, 1, GETDATE(), '2024-12-30', '2024-12-25', 'Pending', 'Late check-in');

-- Błąd: pokój już zarezerwowany
INSERT INTO [Reservations] 
([id_client], [id_room], [reservation_date], [arrival_date], [departure_date], [payment_status], [special_requests])
VALUES 
(2, 1, GETDATE(), '2024-12-27', '2024-12-28', 'Pending', 'Early check-in');

-- Przykładowe zapytania walidacyjne i testowe
SELECT * FROM [Clients] WHERE DATEDIFF(YEAR, [date_of_birth], GETDATE()) < 18;
SELECT * FROM [Rooms] WHERE [price_per_night] <= 0;
SELECT * FROM [Reservations] WHERE [arrival_date] >= [departure_date];

-- Wstawianie danych do tabeli Payments
INSERT INTO [Payments]
([id_reservation], [amount], [payment_date], [payment_method])
VALUES
(1, 900.00, GETDATE(), 'Credit Card'),
(2, 1800.00, GETDATE(), 'Bank Transfer'),
(3, 2100.00, GETDATE(), 'Cash');

-- Błąd: brak kwoty
INSERT INTO [Payments]
([id_reservation], [amount], [payment_date], [payment_method])
VALUES
(1, NULL, GETDATE(), 'Credit Card'); -- Powinno zakończyć się błędem

-- Błąd: brak metody płatności
INSERT INTO [Payments]
([id_reservation], [amount], [payment_date], [payment_method])
VALUES
(1, 500.00, GETDATE(), NULL); -- Powinno zakończyć się błędem

-- Wstawianie danych do tabeli Events
INSERT INTO [Events]
([event_name], [event_date], [location], [description])
VALUES
('Christmas Gala', '2024-12-24', 'Main Ballroom', 'A grand Christmas celebration'),
('Corporate Retreat', '2024-12-15', 'Conference Room', 'A retreat for corporate teams'),
('New Year Party', '2024-12-31', 'Rooftop Terrace', 'Celebrate the New Year with us!');

-- Błąd: data wydarzenia w przeszłości
INSERT INTO [Events]
([event_name], [event_date], [location], [description])
VALUES
('Past Event', '2020-01-01', 'Old Hall', 'This event is in the past'); -- Powinno zakończyć się błędem

-- Wstawianie danych do tabeli EventRegistration
INSERT INTO [EventRegistration]
([id_event], [id_client], [registration_date])
VALUES
(1, 1, GETDATE()),
(2, 2, GETDATE());

-- Błąd: brak klienta
INSERT INTO [EventRegistration]
([id_event], [id_client], [registration_date])
VALUES
(3, NULL, GETDATE()); -- Powinno zakończyć się błędem

-- Błąd: brak wydarzenia
INSERT INTO [EventRegistration]
([id_event], [id_client], [registration_date])
VALUES
(NULL, 1, GETDATE()); -- Powinno zakończyć się błędem


-- #6 Testowanie widoku AvailableRooms
-- Sprawdzenie dostępnych pokoi - powinno zwrócić pokoje, które nie są zarezerwowane w danym okresie
SELECT r.*
FROM [Rooms] r
LEFT JOIN [Reservations] res
  ON r.[id_room] = res.[id_room]
  AND res.[arrival_date] <= GETDATE()
  AND res.[departure_date] >= GETDATE()
WHERE res.[id_reservation] IS NULL;

-- Sprawdzenie poprawności wieku klientów (wszyscy klienci muszą być pełnoletni)
SELECT *
FROM [Clients]
WHERE DATEDIFF(YEAR, [date_of_birth], GETDATE()) < 18;

-- Sprawdzenie poprawności adresów e-mail
SELECT *
FROM [Clients]
WHERE [email] NOT LIKE '%_@__%.__%';

-- Sprawdzenie poprawności dat w rezerwacjach (data przyjazdu nie może być późniejsza niż data wyjazdu)
SELECT *
FROM [Reservations]
WHERE [arrival_date] >= [departure_date];

-- Sprawdzenie, czy pokój został podwójnie zarezerwowany na ten sam okres
SELECT r1.*
FROM [Reservations] r1
JOIN [Reservations] r2
  ON r1.[id_room] = r2.[id_room]
 AND r1.[id_reservation] <> r2.[id_reservation]
 AND r1.[arrival_date] < r2.[departure_date]
 AND r1.[departure_date] > r2.[arrival_date];

-- Sprawdzenie, czy istnieją pokoje przypisane do nieistniejących hoteli
SELECT *
FROM [Rooms]
WHERE [id_hotel] NOT IN (SELECT [id_hotel] FROM [Hotels]);

-- Sprawdzenie, czy istnieją udogodnienia przypisane do nieistniejących pokoi
SELECT *
FROM [Facilities]
WHERE [id_room] NOT IN (SELECT [id_room] FROM [Rooms]);

-- Sprawdzenie, czy istnieją płatności przypisane do nieistniejących rezerwacji
SELECT *
FROM [Payments]
WHERE [id_reservation] NOT IN (SELECT [id_reservation] FROM [Reservations]);

-- Sprawdzenie, czy istnieją rejestracje na wydarzenia przypisane do nieistniejących klientów lub wydarzeń
SELECT *
FROM [EventRegistration]
WHERE [id_event] NOT IN (SELECT [id_event] FROM [Events])
   OR [id_client] NOT IN (SELECT [id_client] FROM [Clients]);

-- Sprawdzenie, czy w tabeli Events są błędne daty (data wydarzenia nie może być w przeszłości)
SELECT *
FROM [Events]
WHERE [event_date] < GETDATE();

-- Liczba rezerwacji w danym dniu
SELECT [arrival_date], COUNT(*) AS [NumberOfReservations]
FROM [Reservations]
GROUP BY [arrival_date]
ORDER BY [arrival_date];

-- Liczba rezerwacji przypisana do każdego klienta
SELECT c.[name], c.[last_name], COUNT(r.[id_reservation]) AS [NumberOfReservations]
FROM [Clients] c
LEFT JOIN [Reservations] r
  ON c.[id_client] = r.[id_client]
GROUP BY c.[name], c.[last_name]
ORDER BY [NumberOfReservations] DESC;

-- Liczba wydarzeń zarejestrowanych w hotelach
SELECT h.[hotel_name], COUNT(e.[id_event]) AS [NumberOfEvents]
FROM [Hotels] h
LEFT JOIN [Events] e
  ON h.[id_hotel] = e.[id_event]
GROUP BY h.[hotel_name]
ORDER BY [NumberOfEvents] DESC;
