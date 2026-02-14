CREATE OR REPLACE VIEW v_track_availability_view AS
    SELECT
        TRK.id AS track_id,
        TRK.name AS track_name,
        TRK.max_karts,
        BKP.booking_date,
        TS.id AS time_slots_id,
        TS.start_time,
        TS.end_time,
        IFNULL(
            SUM(
                CASE
                    WHEN BKN.status IN ('CONFIRMED', 'PENDING')
                    THEN BKP.quantity
                    ELSE 0
                END
            ),
            0
        ) AS booked_karts,
        TRK.max_karts
        - IFNULL(
                SUM(
                    CASE
                        WHEN BKN.status IN ('CONFIRMED', 'PENDING')
                        THEN BKP.quantity
                        ELSE 0
                    END
            ), 0) AS available_karts
    FROM tracks TRK
    JOIN track_schedules SCH
        ON SCH.tracks_id = TRK.id
        AND SCH.is_open = 1
    JOIN time_slots TS
        ON TS.id = SCH.time_slots_id
    LEFT JOIN booked_places BKP
        ON BKP.tracks_id = TRK.id
        AND BKP.time_slots_id = TS.id
    LEFT JOIN bookings BKN
        ON BKN.id = BKP.bookings_id
    WHERE TRK.is_active = 1
    GROUP BY
        TRK.id,
        TRK.name,
        TRK.max_karts,
        BKP.booking_date,
        TS.id,
        TS.start_time,
        TS.end_time;
