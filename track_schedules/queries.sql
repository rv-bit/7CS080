SET autocommit = 0; -- Causes for no auto committing in MySQL, shouldn't be used in Oracle

-- Simple update where id is 12, and commit changes
-- If id not found, rollbacks / raises error instantly
START TRANSACTION;
	UPDATE track_schedules SET is_open = false
	WHERE id = 12;
	COMMIT;

	-- We are getting the latest only change
	SELECT * FROM track_schedules 
	ORDER BY 1 ASC

-- -- Simple delete where id is 12, and commit changes
START TRANSACTION;
	DELETE FROM track_schedules WHERE id = 12;
	COMMIT;