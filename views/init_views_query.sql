CREATE OR REPLACE VIEW v_track_availability_view ( track_id, track_name, max_karts, booking_date, time_slots_id, start_time, end_time, booked_karts, available_karts) AS
    SELECT
        TRK.id AS track_id,
        TRK.name AS track_name,
        TRK.max_karts,
        CAPTR.booking_date,
        TS.id AS time_slots_id,
        TS.start_time,
        TS.end_time,
        COALESCE(CAPTR.booked_karts, 0) AS booked_karts,
        GREATEST(TRK.max_karts - COALESCE(CAPTR.booked_karts, 0), 0) AS available_karts
    FROM tracks TRK
        JOIN track_schedules SCH ON SCH.tracks_id = TRK.id AND SCH.is_open = 1
        JOIN time_slots TS ON TS.id = SCH.time_slots_id

        LEFT JOIN (
            SELECT
                BKP.tracks_id,
                BKP.time_slots_id,
                BK.booking_date,
                SUM(BKP.quantity) AS booked_karts
            FROM booked_places BKP
                JOIN bookings BK ON BK.id = BKP.bookings_id
            WHERE BK.status IN ('CONFIRMED', 'PENDING')
            GROUP BY
                BKP.tracks_id,
                BKP.time_slots_id,
                BK.booking_date
        ) CAPTR ON CAPTR.tracks_id = TRK.id AND CAPTR.time_slots_id = TS.id

    WHERE TRK.is_active = 1;

CREATE OR REPLACE VIEW v_track_slots AS
SELECT
    TRK.id AS track_id,
    TRK.name AS track_name,
    TRK.max_karts,
    TS.id AS time_slots_id,
    TS.start_time,
    TS.end_time
FROM tracks TRK
JOIN track_schedules SCH
    ON SCH.tracks_id = TRK.id
    AND SCH.is_open = 1
JOIN time_slots TS
    ON TS.id = SCH.time_slots_id
WHERE TRK.is_active = 1;