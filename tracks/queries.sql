SET autocommit = 0; -- Causes for no auto committing in MySQL, shouldn't be used in Oracle

-- Simple update where id is 3, and commit changes
-- If id not found, rollbacks / raises error instantly
-- START TRANSACTION;
-- 	UPDATE tracks SET is_active = false, updated_at = CURRENT_TIMESTAMP
-- 	WHERE id = 2;
-- 	COMMIT;

-- 	-- We are getting the latest only change
-- 	SELECT * FROM tracks 
-- 	ORDER BY 1 ASC;

-- -- Simple delete where id is 3, and commit changes
-- START TRANSACTION;
-- 	DELETE FROM tracks WHERE id = 3;
-- 	COMMIT;

-- Info Inserts track_blocks - this would be used for admins / business to block specific track and give a reason on why
-- 	This will also get blocked when trying to book
-- 	Will only update the tracks table if the track id is active, if not we shall not update

-- START TRANSACTION;
-- 	SET @track_Id = 2;
-- 	SET @time_slot_Id = 1;
-- 	SET @blocked_date = '2026-03-06';

-- 	SET @reason = 'This is a test reason, it could be because of other purpose';

-- 	INSERT INTO track_blocks (block_date, reason, created_at, tracks_id, time_slots_id)
-- 	VALUES (@blocked_date, @reason, SYSDATE(), @track_Id, @time_slot_Id);

-- 	UPDATE tracks SET is_active = false, updated_at = CURRENT_TIMESTAMP
-- 	WHERE id = @track_Id AND is_active = true;

-- 	COMMIT;