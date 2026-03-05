SET autocommit = 0; -- Causes for no auto committing in MySQL, shouldn't be used in Oracle

-- INFO Checks available for the booking date, if results returned, no booking available

-- SELECT
--     V.track_id,
--     V.track_name,
--     V.time_slots_id,
--     V.start_time,
--     V.end_time,
--     V.max_karts AS MaxKartsPerBooking,
--     AGG.booking_date,
--     IFNULL(AGG.booked_karts, 0) AS booked_karts,
--     GREATEST(V.max_karts - IFNULL(AGG.booked_karts, 0), 0) AS available_karts
-- FROM v_track_slots V
--     LEFT JOIN (
--         SELECT
--             BKP.tracks_id,
--             BKP.time_slots_id,
--             BK.booking_date,
--             SUM(BKP.quantity) AS booked_karts
--         FROM booked_places BKP
--         INNER JOIN bookings BK
--             ON BK.id = BKP.bookings_id
--             AND BK.booking_date IN ('2026-03-10', '2026-03-12', '2026-03-13')
--             AND BK.status IN ('CONFIRMED', 'PENDING')
--         GROUP BY
--             BKP.tracks_id,
--             BKP.time_slots_id,
--             BK.booking_date
--     ) AGG
--         ON AGG.tracks_id = V.track_id
--         AND AGG.time_slots_id = V.time_slots_id
-- ORDER BY
--     V.track_id,
--     V.start_time;

-- INFO Only update the booking if the status is PENDING and is still in reservation process

-- START TRANSACTION;
-- 	UPDATE bookings BK SET status = 'CONFIRMED' WHERE id = 4 
-- 		AND BK.status = 'PENDING'
-- 		AND reserved_until >= NOW();

-- COMMIT;


-- INFO Only update the booking if the status is CONFIRMED and it is past the booking date, meaning it completed the booking
    -- Also deletes from booked_places, to have kind of a recycle of old data 

-- START TRANSACTION;
--     DELETE BKP
--     FROM booked_places BKP
--         JOIN bookings BK ON BK.id = BKP.bookings_id
--     WHERE BK.status = 'CONFIRMED'
--         AND BK.booking_date < DATE(NOW())
--         AND BK.id = 2;

-- 	UPDATE bookings BK SET status = 'COMPLETED' WHERE id = 2
-- 		AND BK.status = 'CONFIRMED'
-- 		AND BK.booking_date < DATE(NOW());
-- COMMIT;


-- INFO Delete expired booked_places first (child rows must go before parent update to avoid FK constraint violations)

-- START TRANSACTION;
--     DELETE BKP
--     FROM booked_places BKP
--         JOIN bookings BK ON BK.id = BKP.bookings_id
--     WHERE BK.status = 'PENDING'
--         AND BK.reserved_until < NOW();

--     UPDATE bookings BK SET BK.status = 'CANCELLED'
--     WHERE BK.status = 'PENDING' AND BK.reserved_until < NOW();

-- COMMIT;

-- INFO: Update Quantity

-- START TRANSACTION;
-- 	SET @booking_Id = 13;
-- 	SET @new_quantity = 10;
--     SET @track_id = 6;

-- 	UPDATE booked_places BKP
--         JOIN bookings BK ON BK.id = BKP.bookings_id
--         JOIN tracks TRK ON TRK.id = BKP.tracks_id

--         LEFT JOIN
--         (
--             SELECT
--                 BKP2.tracks_id,
--                 BKP2.time_slots_id,
--                 BK2.booking_date,
--                 SUM(BKP2.quantity) booked
--             FROM booked_places BKP2
--                 JOIN bookings BK2 ON BK2.id = BKP2.bookings_id
--             WHERE BK2.status IN ('PENDING', 'CONFIRMED')
--                 AND BK2.id <> @booking_Id
--                 AND BKP2.tracks_id = @track_id
--             GROUP BY BKP2.tracks_id, BKP2.time_slots_id, BK2.booking_date
--         ) used_capacity ON used_capacity.tracks_id = BKP.tracks_id
--             AND used_capacity.time_slots_id = BKP.time_slots_id
--             AND used_capacity.booking_date = BK.booking_date

-- 	SET BKP.quantity = @new_quantity

-- 	WHERE BKP.bookings_id = @booking_Id
-- 		AND BK.status IN ('PENDING', 'CONFIRMED')
--         AND BKP.tracks_id = @track_id
-- 		AND (TRK.max_karts - IFNULL(used_capacity.booked, 0)) >= @new_quantity;

-- COMMIT;