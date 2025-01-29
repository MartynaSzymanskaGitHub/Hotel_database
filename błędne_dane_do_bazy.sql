-------------------------------------------------------------------------------
-- Duplikat nazwy hotelu
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertHotel 
         @hotel_name = N'Hotel Paradise', 
         @country = N'Canada', 
         @address = N'103 Maple Ave', 
         @total_rooms = 60, 
         @manager_name = N'David Smith', 
         @contact_number = N'456789123';
END TRY
BEGIN CATCH
    PRINT 'Error: Given hotel name already exists in the database!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Negatywna cena - niepoprawna
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertRoom 
         @id_hotel = 1, 
         @price_per_night = -50.00, 
         @floor = 1, 
         @number_of_beds = 1, 
         @room_size = 20.00, 
         @description = N'Single room';
END TRY
BEGIN CATCH
    PRINT 'Error: Invalid price (negative value)!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Liczba ³ó¿ek <= 0 (np. 0) - niepoprawna
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertRoom 
         @id_hotel = 1, 
         @price_per_night = 120.00, 
         @floor = 3, 
         @number_of_beds = 0, 
         @room_size = 25.00, 
         @description = N'Small room';
END TRY
BEGIN CATCH
    PRINT 'Error: Number of beds must be positive!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Niepe³noletni klient (zak³adaj¹c, ¿e w procedurze jest ograniczenie np. >=18 lat)
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertClient_toBase 
         @name = N'Jacek', 
         @last_name = N'Piastowski', 
         @contact_number = N'987654321', 
         @email = N'j.piast@example.com', 
         @document_number = N'ID54321', 
         @address = N'Piotrkowska 12', 
         @country = N'Poland', 
         @date_of_birth = '2010-05-15', 
         @gender = N'Male';
END TRY
BEGIN CATCH
    PRINT 'Error: Client is underage!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Nieprawid³owy adres e-mail
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertClient_toBase 
         @name = N'Invalid', 
         @last_name = N'Email', 
         @contact_number = N'123456789', 
         @email = N'invalid-email',
         @document_number = N'ID99999',
         @address = N'123 blad', 
         @country = N'USA', 
         @date_of_birth = '1990-01-01', 
         @gender = N'Male';
END TRY
BEGIN CATCH
    PRINT 'Error: Invalid e-mail address format!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Nieprawid³owa p³eæ (np. 'Unknown' zamiast 'Male', 'Female', 'Other')
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertClient_toBase 
         @name = N'Hanna', 
         @last_name = N'Malik', 
         @contact_number = N'987654300', 
         @email = N'h.malik@example.com', 
         @document_number = N'ID54321', 
         @address = N'456 Another St', 
         @country = N'Canada', 
         @date_of_birth = '2000-05-15', 
         @gender = N'Unknown';
END TRY
BEGIN CATCH
    PRINT 'Error: Invalid data! Gender must be Male, Female or Other!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Rezerwacja pokoju, który ju¿ jest zajêty w tym samym terminie
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertReservation 
         @id_client = 2, 
         @id_room = 1, 
         @reservation_date = '2024-12-20', 
         @arrival_date = '2024-12-27', 
         @departure_date = '2024-12-28', 
         @payment_status = N'Pending', 
         @special_requests = N'Early check-in';
END TRY
BEGIN CATCH
    PRINT 'Error: Room is already reserved for this time range!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Brak kwoty p³atnoœci (NULL)
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertPayment 
         @id_reservation = 1, 
         @amount = NULL, 
         @payment_date = '2024-12-15', 
         @payment_method = N'Credit Card';
END TRY
BEGIN CATCH
    PRINT 'Error: Missing payment amount!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Brak metody p³atnoœci (NULL)
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC sp_InsertPayment 
         @id_reservation = 1, 
         @amount = 500.00, 
         @payment_date = '2024-12-15', 
         @payment_method = NULL;
END TRY
BEGIN CATCH
    PRINT 'Error: Missing payment method!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Rejestracja w tabeli [EventRegistration] bez id_client
-------------------------------------------------------------------------------
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES (3, NULL, '2024-12-11');
END TRY
BEGIN CATCH
    PRINT 'Error: Missing client data for event registration!';
    THROW;
END CATCH;
GO


-------------------------------------------------------------------------------
-- Rejestracja w tabeli [EventRegistration] bez id_event
-------------------------------------------------------------------------------
BEGIN TRY
    INSERT INTO [EventRegistration] ([id_event], [id_client], [registration_date])
    VALUES (NULL, 1, '2024-12-11');
END TRY
BEGIN CATCH
    PRINT 'Error: Invalid event (ID is NULL)!';
    THROW;
END CATCH;
GO