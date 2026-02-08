CREATE TABLE kart_racing_unf 
    ( 
		-- Customers
		customer_id INTEGER NOT NULL,
		customer_first_name VARCHAR (50) NOT NULL, 
        customer_last_name VARCHAR (50) NOT NULL, 
        customer_email VARCHAR (50) NOT NULL, 
        customer_updated_at DATE NOT NULL, 
        customer_created_at DATE NOT NULL,

		-- Finalised Booked places
		booked_place_id INTEGER NOT NULL,
        booked_place_booking_date DATE NOT NULL, 
        booked_place_quantity INTEGER NOT NULL,

		-- Bookings
		booking_id INTEGER NOT NULL,
		booking_status VARCHAR (20) NOT NULL, 
        booking_created_at DATE NOT NULL, 
        booking_reserved_until DATE, 

		-- Time Slots
        time_slot_id INTEGER NOT NULL, 
        time_slot_start_time VARCHAR (5) NOT NULL, 
        time_slot_end_time VARCHAR (5) NOT NULL, 
        time_slot_duration_in_minutes INTEGER NOT NULL,

		-- Track Schedules
		schedule_id INTEGER NOT NULL, 
		schedule_day_of_week SMALLINT NOT NULL, 
        schedule_is_open TINYINT(1) NOT NULL, 

		-- Tracks
		track_id INTEGER NOT NULL,
		track_name VARCHAR (50) NOT NULL, 
        track_max_karts INTEGER NOT NULL, 
        track_is_active TINYINT(1) NOT NULL, 
        track_updated_at DATE NOT NULL, 
        track_created_at DATE NOT NULL 
    ) 
;