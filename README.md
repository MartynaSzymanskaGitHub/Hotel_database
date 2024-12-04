# Hotel Management Database

## Authors
This project was created by:
- [Martyna Szymańska](https://github.com/MartynaSzymanskaGitHub)
- [Kamil](https://github.com/elzyr)

## Purpose
The goal of this project is to design and implement a well-structured hotel management database that provides easy access and usability for hotel employees. It facilitates the management of reservations, guest information, and hotel-related operations.

### Key Features
- Simplified access to reservation and client data.
- Tools for employees to easily manage and check guest reservations.
- Management of events and their registrations.
- Tracking hotel room details and facilities.

---

## Table Structure

### Hotels
Stores details about individual hotels.

- **`id_hotel`** (int): Unique identifier for the hotel (Primary Key).
- **`hotel_name`** (nvarchar(100)): Name of the hotel (must be unique).
- **`country`** (nvarchar(100)): Country where the hotel is located.
- **`address`** (int): Address of the hotel.
- **`total_rooms`** (int): Total number of rooms in the hotel.
- **`manager_name`** (nvarchar(100)): Name of the hotel manager.
- **`contact_number`** (nvarchar(max)): Contact number for the hotel.

---

### Rooms
Stores details about rooms in the hotel.

- **`id_room`** (int): Unique identifier for the room (Primary Key).
- **`id_hotel`** (int): Identifier of the hotel where the room is located.
- **`price_per_night`** (decimal): Price per night for the room.
- **`number_of_rooms`** (int): Number of identical rooms of this type.
- **`allow_animals`** (nvarchar(3)): Indicates if animals are allowed (e.g., "Yes").
- **`floor`** (int): Floor where the room is located.
- **`number_of_beds`** (int): Number of beds in the room.
- **`room_size`** (decimal): Size of the room in square meters.
- **`description`** (nvarchar(200)): Description of the room.

---

### Clients
Stores details about hotel clients.

- **`id_client`** (int): Unique identifier for the client (Primary Key).
- **`name`** (nvarchar(50)): First name of the client.
- **`last_name`** (nvarchar(50)): Last name of the client.
- **`contact_number`** (int): Contact number of the client (must be unique).
- **`email`** (nvarchar(100)): Email address of the client.
- **`document_number`** (nvarchar(50)): Identification document number of the client.
- **`address`** (nvarchar(100)): Address of the client.
- **`country`** (nvarchar(100)): Country of the client.
- **`date_of_birth`** (date): Client's date of birth.
- **`gender`** (nvarchar(10)): Gender of the client.
- **`room_number`** (int): Room number assigned to the client.

---

### Reservations
Tracks reservations made by clients.

- **`id_reservation`** (int): Unique identifier for the reservation (Primary Key).
- **`id_client`** (int): Client associated with the reservation.
- **`reservation_date`** (date): Date the reservation was made.
- **`data_arrival`** (date): Date of arrival.
- **`data_department`** (date): Date of departure.
- **`id_room`** (int): Identifier of the reserved room.
- **`payment_status`** (nvarchar(200)): Status of payment (e.g., "Paid", "Pending").
- **`special_requests`** (nvarchar(200)): Additional requests from the client.
- **`number_of_people`** (int): Number of people staying in the reservation.
- **`number_animals`** (int): Number of animals accompanying the client.
- **`cancellation_policy`** (nvarchar(max)): Details of the reservation's cancellation policy.

---

### Facilities
Details about room facilities.

- **`id`** (int): Unique identifier for the facility (Primary Key).
- **`room_id`** (int): Identifier of the room associated with the facility.
- **`number_of_balcons`** (int): Number of balconies in the room.
- **`view`** (nvarchar(100)): Type of view (e.g., "Sea View").
- **`allow_smoking`** (nvarchar(10)): Indicates if smoking is allowed in the room.
- **`private_bathroom`** (nvarchar(10)): Indicates if the room has a private bathroom.
- **`private_kitchen`** (nvarchar(30)): Indicates if the room has a private kitchen.
- **`gym_access`** (bit): Indicates if gym access is available.
- **`heating`** (bit): Indicates if heating is available.
- **`air_conditioning`** (bit): Indicates if air conditioning is available.

---

### Payments
Tracks payment details for reservations.

- **`id_payment`** (int): Unique identifier for the payment (Primary Key).
- **`client_id`** (int): Client associated with the payment.
- **`room_id`** (int): Room associated with the payment.
- **`reservation_id`** (int): Reservation associated with the payment.
- **`status`** (nvarchar(100)): Status of the payment (e.g., "Completed").
- **`payment_date`** (date): Date the payment was made.
- **`amount`** (decimal): Amount paid.
- **`currency`** (nvarchar(50)): Currency used for the payment.
- **`is_refunded`** (bit): Indicates if the payment was refunded.
- **`refund_date`** (date): Date of refund (if applicable).

---

### Events
Tracks events organized at hotels.

- **`id_event`** (int): Unique identifier for the event (Primary Key).
- **`hotel_id`** (int): Identifier of the hotel hosting the event.
- **`event_name`** (nvarchar(100)): Name of the event.
- **`event_description`** (nvarchar(400)): Description of the event.
- **`start_date`** (date): Start date of the event.
- **`end_date`** (date): End date of the event.
- **`max_number_of_guests`** (int): Maximum number of guests for the event.
- **`organizer_name`** (nvarchar(100)): Name of the event organizer.
- **`status`** (nvarchar(100)): Status of the event (e.g., "Scheduled").

---

### EventRegistration
Tracks registrations for events.

- **`id_registration`** (int): Unique identifier for the registration (Primary Key).
- **`event_id`** (int): Event associated with the registration.
- **`client_id`** (int): Client associated with the registration.
- **`number_of_people`** (int): Number of people registered (including the client).
- **`registration_date`** (date): Date of registration.
- **`status`** (nvarchar(100)): Status of the registration (e.g., "Confirmed").

---
