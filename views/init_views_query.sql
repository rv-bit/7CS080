CREATE OR REPLACE VIEW v_track_availability_view ( 
    track_id, 
    track_name, 
    time_slots_id, 
    start_time, 
    end_time, 
    max_karts, 
    booking_date, 
    booked_karts,
    available_karts
) AS
    SELECT
        V.track_id AS track_id,
        V.track_name AS track_name,
        V.time_slots_id,
        V.start_time,
        V.end_time,
        V.max_karts AS MaxKartsPerBooking,
        AGG.booking_date,
        IFNULL(AGG.booked_karts, 0) AS booked_karts,
        GREATEST(V.max_karts - IFNULL(AGG.booked_karts, 0), 0) AS available_karts
    FROM v_track_slots V
        LEFT JOIN (
            SELECT
                BKP.tracks_id,
                BKP.time_slots_id,
                BK.booking_date,
                SUM(BKP.quantity) AS booked_karts
            FROM booked_places BKP
            INNER JOIN bookings BK
                ON BK.id = BKP.bookings_id
                AND BK.status IN ('CONFIRMED', 'PENDING')
            GROUP BY
                BKP.tracks_id,
                BKP.time_slots_id,
                BK.booking_date
        ) AGG
            ON AGG.tracks_id = V.track_id
            AND AGG.time_slots_id = V.time_slots_id
    ORDER BY
        V.track_id,
        V.start_time;

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