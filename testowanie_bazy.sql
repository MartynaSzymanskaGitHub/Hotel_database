-- ## Wstawianie danych do tabeli Hotels ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertHotel N'Hotel Paradise', N'USA', N'101 Sunset Blvd', 50, N'Alice Green', N'123456789';
    EXEC sp_InsertHotel N'Grand Royal', N'UK', N'102 High Street', 80, N'John Brown', N'987654321';
    EXEC sp_InsertHotel N'Empty Hotel', N'France', N'104 Rivoli', 1, N'Sophia White', N'789123456';
    EXEC sp_InsertHotel N'Hotel Atlantis', N'Germany', N'105 Oceanview', 120, N'Emma Brown', N'123456780';
END TRY
BEGIN CATCH
    PRINT 'Błąd wstawiania do tabeli Hotels';
    THROW;
END CATCH;

-- Błędne (duplikat nazwy hotelu)
BEGIN TRY
    EXEC sp_InsertHotel N'Hotel Paradise', N'Canada', N'103 Maple Ave', 60, N'David Smith', N'456789123';
END TRY
BEGIN CATCH
    PRINT 'Błąd: duplikat nazwy hotelu!';
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
    PRINT 'Błąd wstawiania do tabeli Rooms';
    THROW;
END CATCH;

-- Błędne (negatywna cena)
BEGIN TRY
    EXEC sp_InsertRoom 1, -50.00, 1, 1, 20.00, N'Single room';
END TRY
BEGIN CATCH
    PRINT 'Błąd: negatywna cena!';
    THROW;
END CATCH;

-- Błędne (liczba łóżek poniżej 1)
BEGIN TRY
    EXEC sp_InsertRoom 1, 120.00, 3, 0, 25.00, N'Small room';
END TRY
BEGIN CATCH
    PRINT 'Błąd: liczba łóżek musi być większa od 0!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Clients ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertClient N'John', N'Doe', N'123456789', N'john.doe@example.com', N'ID12345', N'123 Main St', N'USA', '2000-01-01', N'Male';
    EXEC sp_InsertClient N'Sophia', N'Davis', N'234567891', N'sophia.davis@example.com', N'ID54321', N'234 Elm St', N'USA', '1990-03-15', N'Female';
END TRY
BEGIN CATCH
    PRINT 'Błąd wstawiania do tabeli Clients';
    THROW;
END CATCH;

-- Błędne (niepełnoletni klient)
BEGIN TRY
    EXEC sp_InsertClient N'Jane', N'Smith', N'987654321', N'jane.smith@example.com', N'ID54321', N'456 Another St', N'Canada', '2010-05-15', N'Female';
END TRY
BEGIN CATCH
    PRINT 'Błąd: klient musi być pełnoletni!';
    THROW;
END CATCH;

-- Błędne (nieprawidłowy adres e-mail)
BEGIN TRY
    EXEC sp_InsertClient N'Invalid', N'Email', N'123456789', N'invalid-email', N'ID99999', N'123 Fake St', N'USA', '1990-01-01', N'Male';
END TRY
BEGIN CATCH
    PRINT 'Błąd: nieprawidłowy adres e-mail!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Reservations ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertReservation 1, 1, GETDATE(), '2024-12-25', '2024-12-30', N'Pending', N'No special requirements';
    EXEC sp_InsertReservation 2, 2, GETDATE(), '2024-12-15', '2024-12-20', N'Pending', N'Late arrival';
END TRY
BEGIN CATCH
    PRINT 'Błąd wstawiania do tabeli Reservations';
    THROW;
END CATCH;

-- Błędne (data przyjazdu po dacie wyjazdu)
BEGIN TRY
    EXEC sp_InsertReservation 1, 1, GETDATE(), '2024-12-30', '2024-12-25', N'Pending', N'Late check-in';
END TRY
BEGIN CATCH
    PRINT 'Błąd: data przyjazdu późniejsza niż data wyjazdu!';
    THROW;
END CATCH;

-- Błędne (pokój już zarezerwowany)
BEGIN TRY
    EXEC sp_InsertReservation 2, 1, GETDATE(), '2024-12-27', '2024-12-28', N'Pending', N'Early check-in';
END TRY
BEGIN CATCH
    PRINT 'Błąd: pokój już zarezerwowany w tym okresie!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli Payments ##

-- Poprawne
BEGIN TRY
    EXEC sp_InsertPayment 1, 900.00, GETDATE(), N'Credit Card';
    EXEC sp_InsertPayment 2, 1800.00, GETDATE(), N'Bank Transfer';
END TRY
BEGIN CATCH
    PRINT 'Błąd wstawiania do tabeli Payments';
    THROW;
END CATCH;

-- Błędne (brak kwoty płatności)
BEGIN TRY
    EXEC sp_InsertPayment 1, NULL, GETDATE(), N'Credit Card';
END TRY
BEGIN CATCH
    PRINT 'Błąd: brak kwoty płatności!';
    THROW;
END CATCH;

-- Błędne (brak metody płatności)
BEGIN TRY
    EXEC sp_InsertPayment 1, 500.00, GETDATE(), NULL;
END TRY
BEGIN CATCH
    PRINT 'Błąd: brak metody płatności!';
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
    PRINT 'Błąd wstawiania do tabeli Events';
    THROW;
END CATCH;

-- Błędne (data wydarzenia w przeszłości)
BEGIN TRY
    INSERT INTO [Events] ([event_name], [event_date], [location], [description])
    VALUES
    (N'Past Event', '2020-01-01', N'Old Hall', N'This event is in the past');
END TRY
BEGIN CATCH
    PRINT 'Błąd: wydarzenie w przeszłości!';
    THROW;
END CATCH;

-- ## Wstawianie danych do tabeli EventRegistration ##

-- Poprawne
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES
    (1, 1, GETDATE()),
    (2, 2, GETDATE());
END TRY
BEGIN CATCH
    PRINT 'Błąd wstawiania do tabeli EventRegistration';
    THROW;
END CATCH;

-- Błędne (brak klienta)
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES (3, NULL, GETDATE());
END TRY
BEGIN CATCH
    PRINT 'Błąd: brak klienta!';
    THROW;
END CATCH;

-- Błędne (brak wydarzenia)
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES (NULL, 1, GETDATE());
END TRY
BEGIN CATCH
    PRINT 'Błąd: brak wydarzenia!';
    THROW;
END CATCH;

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

-- Przykładowe zapytanie do odczytania rezerwacji
SELECT r.id_reservation, r.reservation_date, e.name AS employee_name, c.name AS client_name, r.purpose
FROM Reservations r
JOIN Employees e ON r.employee_id = e.id_employee
JOIN Clients c ON r.client_id = c.id_client;

-- Przykładowe zapytanie analityczne
-- Wyświetlenie liczby rezerwacji wykonanych przez każdego pracownika w danym miesiącu
CREATE VIEW EmployeeReservationSummary AS
SELECT 
    e.id_employee, 
    e.name AS employee_name, 
    MONTH(r.reservation_date) AS reservation_month, 
    COUNT(*) AS total_reservations
FROM Reservations r
JOIN Employees e ON r.employee_id = e.id_employee
GROUP BY e.id_employee, e.name, MONTH(r.reservation_date);

-- Zapytanie wykorzystujące widok
SELECT * FROM EmployeeReservationSummary WHERE reservation_month = 1;