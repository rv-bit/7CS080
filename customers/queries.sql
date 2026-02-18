SET autocommit = 0; -- Causes for no auto committing in MySQL, shouldn't be used in Oracle

-- Simple update where first name is Emma, and commit changes
START TRANSACTION;
	UPDATE customers SET first_name = "CJ", updated_at = CURRENT_TIMESTAMP
	WHERE first_name = "Emma";
	COMMIT;

	-- We are getting the latest only change
	SELECT * FROM customers 
	ORDER BY updated_at DESC
	LIMIT 1;

-- Simple delete where first name is CJ, and commit changes
START TRANSACTION;
	DELETE FROM customers WHERE first_name = "CJ";
	COMMIT;