-- We are inserting for each day through 1-7, 
-- We are going to take each time_slot and track and we are going to insert schedule
-- So the calculations on this would be 15 tracks * 7 time slots = 105 schedules per day

-- CROSS JOIN - helps with the calculation by combining result set of tracks and time_slots

-- I've added the truncate of all data, it's easier to test when changing query
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE track_schedules;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 1, 1 FROM tracks TR CROSS JOIN time_slots TS;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 2, 1 FROM tracks TR CROSS JOIN time_slots TS;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 3, 1 FROM tracks TR CROSS JOIN time_slots TS;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 4, 1 FROM tracks TR CROSS JOIN time_slots TS;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 5, 1 FROM tracks TR CROSS JOIN time_slots TS;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 6, 1 FROM tracks TR CROSS JOIN time_slots TS;

INSERT INTO track_schedules ( tracks_id, time_slots_id, day_of_week, is_open )
SELECT TR.id, TS.id, 7, 1 FROM tracks TR CROSS JOIN time_slots TS;