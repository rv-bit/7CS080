SET autocommit = 0; -- Causes for no auto committing in MySQL, shouldn't be used in Oracle

-- Simple update where id is 1, and commit changes
-- If id not found, rollbacks / raises error instantly
START TRANSACTION;
	UPDATE time_slots SET start_time = TIME_FORMAT('08:00:00', '%H:%i')
	WHERE id = 1;
	COMMIT;

	-- We are getting the latest only change
	SELECT * FROM time_slots 
	ORDER BY 1 ASC

-- -- Simple delete where first name is CJ, and commit changes
START TRANSACTION;
	DELETE FROM time_slots WHERE id = 7;
	COMMIT;