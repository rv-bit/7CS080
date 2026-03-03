-- INFO 
--	 ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`7cs080`.`bookings`, CONSTRAINT `bookings_customers_FK` FOREIGN KEY (`customers_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE)
--	 Happens when id removed and cannot find child / customer id, this error can happen to anything that is within the referential integrity
--	 	Can happen on @track_Id, @time_slot_Id etc.

-- INFO - The main query which looks to see active tracks and will try and book on a particular day and time
--		If there is a track block in track_blocks, it will not return the max_karts which automatically will not allow the booking 
START TRANSACTION;
	-- Setting some default, these would have to come from an actual application, 	
	SET @customer_Id = 3;
	SET @track_Id = 2;
	SET @time_slot_Id = 1;
	SET @quantity = 5;
	SET @booking_date = '2026-03-05';

	SELECT 1
	FROM track_schedules
	WHERE tracks_id = @track_Id
		AND time_slots_id = @time_slot_Id
		AND is_open = 1
	FOR UPDATE;

	SELECT 1
	FROM track_blocks
	WHERE tracks_id = @track_Id
		AND block_date = @booking_date
		AND time_slots_id = @time_slot_Id
	FOR UPDATE;

	-- Prevent race conditions by locking the track row
	-- It will only return the max_karts if the track isn't blocked on that date and time slot
    SET @max_karts = 0;

	SELECT TRK.max_karts INTO @max_karts 
	FROM tracks TRK
		LEFT JOIN track_blocks TRKB ON TRKB.tracks_id = TRK.id
			AND TRKB.block_date = @booking_date
			AND TRKB.time_slots_id = @time_slot_Id
	WHERE TRK.id = @track_Id
		AND TRK.is_active = 1
		AND TRKB.tracks_id IS NULL
	FOR UPDATE;

	-- Calculate used capacity for the slot and lock relevant rows
	SELECT IFNULL(SUM(BKP.quantity), 0) INTO @used_capacity
	FROM booked_places BKP
		JOIN bookings BK ON BK.id = BKP.bookings_id
	WHERE BKP.tracks_id = @track_Id
		AND BK.booking_date = @booking_date
		AND BKP.time_slots_id = @time_slot_Id
		AND (BK.status = 'CONFIRMED' OR (BK.status = 'PENDING' AND BK.reserved_until > NOW()))
	FOR UPDATE;

	SET @reserved_until = DATE_ADD(SYSDATE(), INTERVAL 10 MINUTE);
	SET @remaining_capacity = @max_karts - @used_capacity;

	-- Checks if there is currently a booking already created, with the same date, time slot and grabs the customer id
		-- if yes we will block the insert of the same rows again, we also have a UNIQUE constraint just in case
	SET @already_created_booking = NULL;
	SELECT BK.customers_id INTO @already_created_booking
	FROM booked_places BKP
		JOIN bookings BK ON BK.id = BKP.bookings_id
			AND BK.customers_id = @customer_Id
			AND BK.booking_date = @booking_date
			AND BK.status IN ('CONFIRMED', 'PENDING')
	WHERE BKP.time_slots_id = @time_slot_Id
	LIMIT 1;

	SET @booking_id = 0;

	-- Only insert if enough capacity
	-- Use DUAL as given there is no reference to table, we can use methods from Oracle https://stackoverflow.com/a/33378903
	-- Checks if the customer already has booking for that, and if he does we can update or insert only new record into booked_places
	INSERT INTO bookings (status, created_at, reserved_until, booking_date, customers_id)
	SELECT 'PENDING', SYSDATE(), @reserved_until, @booking_date, @customer_Id
	FROM DUAL
	WHERE @remaining_capacity >= @quantity
		AND @already_created_booking IS NULL; 

	SET @booking_id = LAST_INSERT_ID();

	-- Checks if the customer already has booking for that, and if he does we can update or insert only new record into this
	-- Checks if the first insert was created, and if yes then add into this too
	-- In a real world scenario if the user has many different tracks, we can insert multiple values, 
		-- But in order to do that, we will have to get various @max_karts depending on the different tracks
	INSERT INTO booked_places (bookings_id, tracks_id, time_slots_id, quantity)
	SELECT @booking_id, @track_Id, @time_slot_Id, @quantity
	FROM DUAL
	WHERE @remaining_capacity >= @quantity
		AND @already_created_booking IS NULL 
		AND @booking_id > 0; 

	COMMIT;