INSERT INTO time_slots (start_time, end_time, duration_in_minutes)
	WITH RECURSIVE time_series AS (
		-- base, we first add the first time slot, then we will add 
		-- the UNION ALL acts as a join / concatenation process where it would add the current + new rows
		-- this acts as a normal 'while condition true' loop, where the previous start time + 2 hours is lower than 18:00 hours keep going and add rows
		-- finally, this loop results set will be saved inside the alias 'time_series' temporarily, where in the end selects for the INSERT Operation
		SELECT 
			TIME_FORMAT('09:00:00', '%H:%i') AS start_time,
			TIME_FORMAT('10:30:00', '%H:%i') AS end_time,
			90 AS duration_in_minutes
		
		UNION ALL
		
		-- Recursive case: add 30 minutes to start_time
		SELECT 
			TIME_FORMAT(ADDTIME(CONCAT(end_time, ':00'), '00:30:00'), '%H:%i'),
			TIME_FORMAT(ADDTIME(CONCAT(start_time, ':00'), '02:00:00'), '%H:%i'),
			90
		FROM time_series
		WHERE ADDTIME(CONCAT(start_time, ':00'), '02:00:00') <= '18:00:00'
	)
SELECT * FROM time_series;