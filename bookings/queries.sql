SET autocommit = 0; -- Causes for no auto committing in MySQL, shouldn't be used in Oracle

-- Checks available for the booking date, if results returned, no booking available
-- SELECT *
-- FROM v_track_availability_view
-- WHERE booking_date = '2026-02-10'
-- ORDER BY track_name, start_time;

-- INFO Only update the booking if the status is PENDING and is still in reservation process

-- START TRANSACTION;
-- 	UPDATE bookings BK SET status = 'CONFIRMED' WHERE id = 4 
-- 		AND BK.status IN ('PENDING')
-- 		AND reserved_until >= NOW();

-- 	COMMIT;


-- INFO: Update Quantity

START TRANSACTION;
	SET @booking_Id = 1;
	SET @new_quantity = 10;

	UPDATE booked_places BKP

	JOIN bookings BK ON BK.id = BKP.bookings_id
	JOIN tracks TRK ON TRK.id = BKP.tracks_id

	LEFT JOIN
	(
		SELECT
			BKP2.tracks_id,
			BKP2.time_slots_id,
			BK2.booking_date,
			SUM(BKP2.quantity) booked
		FROM booked_places BKP2
			JOIN bookings BK2 ON BK2.id = BKP2.bookings_id
		WHERE BK2.status IN ('PENDING', 'CONFIRMED')
			AND BK2.id <> @booking_Id
		GROUP BY BKP2.tracks_id, BKP2.time_slots_id, BK2.booking_date
	) cap ON cap.tracks_id = BKP.tracks_id
		AND cap.time_slots_id = BKP.time_slots_id
	    AND cap.booking_date = BK.booking_date

	SET BKP.quantity = @new_quantity

	WHERE BKP.bookings_id = @booking_Id
		AND BK.status IN ('PENDING')
		AND (TRK.max_karts - IFNULL(cap.booked, 0)) >= @new_quantity;

	COMMIT;