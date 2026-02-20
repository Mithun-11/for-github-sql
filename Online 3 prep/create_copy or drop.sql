DROP TABLE your_table_name;

CREATE TABLE your_new_table_name AS 
SELECT * FROM your_original_table_name;
COMMIT;