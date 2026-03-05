-- INFO 
--	 ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`7cs080`.`bookings`, CONSTRAINT `bookings_customers_FK` FOREIGN KEY (`customers_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE)
--	 Happens when id removed and cannot find child / customer id, this error can happen to anything that is within the referential integrity
--	 	Can happen on @track_Id, @time_slot_Id etc.

-- INFO - The main query which looks to see active tracks and will try and book on a particular day and time
--		If there is a track block in track_blocks, it will not return the max_karts which automatically will not allow the booking 

START TRANSACTION;
	-- Setting some default, these would have to come from an actual application, 	
    SET @customer_id = 3;
    SET @booking_date = '2026-03-12';
    SET @reserved_until = DATE_ADD(SYSDATE(), INTERVAL 10 MINUTE);

    -- This would be a count of record which can be counted within the application layer and sent as params
    -- Since this would automatically get the length from the array of various tracks etc, it will always match the request which is good
    SET @request_count = 2;
    
    -- Prevent race conditions by locking the track row
    -- Locks in ascending ID order to avoid deadlocks with concurrent transactions.
    -- The application supplies the IN list from the same track_ids it uses below, again sent as params
    SELECT id FROM tracks WHERE id IN (5, 6) FOR UPDATE;

    -- Creates a CTE https://dev.mysql.com/doc/refman/8.4/en/with.html , sub queries where validation can happen with all data
    -- The 'booking_requests' will serve as the main table / result set of the tracks, time slots and quantity selected within the booking session
    WITH booking_requests AS (
        SELECT 5 AS track_id, 1 AS slot_id, 5 AS quantity
        UNION ALL
        SELECT 6 AS track_id, 2 AS slot_id, 3 AS quantity 
    ),
    used_capacity AS (
        -- Checks the currently used capacity based on the already booked_place for the same booking_date where either CONFIRMED or PENDING
        SELECT BKP.tracks_id, BKP.time_slots_id, SUM(BKP.quantity) AS used_cap
        FROM booked_places BKP
            JOIN bookings BK ON BK.id = BKP.bookings_id
                AND BK.booking_date = @booking_date
                AND (
                    BK.status = 'CONFIRMED'
                    OR (BK.status = 'PENDING' AND BK.reserved_until > NOW())
                )
        GROUP BY BKP.tracks_id, BKP.time_slots_id
    ),
    validated AS (
        -- Makes sure that track is active, schedule is open, no block exists, capacity sufficient
        -- Based on the selected tracks, time slots and quantity from sub query 'booking_request'
        -- Returns the result set of all logically TRUE conditions from above
        SELECT DISTINCT BR.track_id, BR.slot_id, BR.quantity
        FROM booking_requests BR
            JOIN tracks TRK ON TRK.id = BR.track_id AND TRK.is_active = 1
            JOIN track_schedules TS ON TS.tracks_id  = BR.track_id AND TS.time_slots_id = BR.slot_id AND TS.is_open = 1

            LEFT JOIN track_blocks TRKB ON TRKB.tracks_id = BR.track_id
                AND TRKB.block_date = @booking_date
                AND TRKB.time_slots_id = BR.slot_id

            LEFT JOIN used_capacity UC ON UC.tracks_id = BR.track_id AND UC.time_slots_id = BR.slot_id
        WHERE 
            TRKB.tracks_id IS NULL
            AND (TRK.max_karts - IFNULL(UC.used_cap, 0)) >= BR.quantity
    ),
    dup_check AS (
        -- Checks if there is currently a booking already created, with the same date, time slot and grabs the customer id
		    -- if yes we will block the insert of the same rows again, we also have a UNIQUE constraint just in case
        SELECT COUNT(*) AS already_created_booking
        FROM booking_requests BR
            JOIN booked_places BKP ON BKP.tracks_id = BR.track_id AND BKP.time_slots_id = BR.slot_id
            JOIN bookings BK ON BK.id = BKP.bookings_id
                AND BK.customers_id = @customer_id
                AND BK.booking_date = @booking_date
                AND BK.status IN ('CONFIRMED', 'PENDING')
    )

    -- Pretty self explanatory, it selects from the 2 sub queries the data and sets it into variables
    SELECT 
        (SELECT COUNT(*) FROM validated), 
        (SELECT already_created_booking FROM dup_check) 
        INTO 
        @valid_count, 
        @already_created_booking;

    -- If the @valid_count != @request_count then this would fail and automatically it will stop the insertion of booked_places
    -- Makes sure that if one from list is not valid, it will automatically fail due to logical condition

    -- Only insert if enough capacity
	-- Use DUAL as given there is no reference to table, we can use methods from Oracle https://stackoverflow.com/a/33378903
	-- Checks if the customer already has booking for that, and if he does we can update or insert only new record into booked_places
    INSERT INTO bookings (status, created_at, reserved_until, booking_date, customers_id)
    SELECT 'PENDING', SYSDATE(), @reserved_until, @booking_date, @customer_id
    FROM DUAL
    WHERE @valid_count = @request_count AND @already_created_booking = 0;
    
    -- Sets the booking_id of the 'bookings' created, if NULL the next INSERT will not take place
    SET @booking_id = LAST_INSERT_ID();

    -- Checks if the customer already has booking for that, and if he does we can update or insert only new record into this
	-- Checks if the first insert was created, and if yes then add into this too
        -- If the user has multiple tracks within the same booking session, it will add all at once
    INSERT INTO booked_places (bookings_id, tracks_id, time_slots_id, quantity)
    WITH booking_requests AS (
        SELECT 5 AS track_id, 1 AS slot_id, 5 AS quantity
        UNION ALL
        SELECT 6 AS track_id, 2 AS slot_id, 3 AS quantity
    )
    SELECT @booking_id, BR.track_id, BR.slot_id, BR.quantity
    FROM booking_requests BR
    WHERE @booking_id > 0 AND @already_created_booking = 0;

COMMIT;