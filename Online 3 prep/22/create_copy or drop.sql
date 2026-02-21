DROP TABLE your_table_name;

CREATE TABLE your_new_table_name AS 
SELECT * FROM your_original_table_name;
COMMIT;

CREATE TABLE your_table_name (
    column1_name DATA_TYPE,
    column2_name DATA_TYPE,
    column3_name DATA_TYPE,
    created_at  DATE DEFAULT SYSDATE
);


-- for inserting into table
 INSERT INTO JOB_RANK(JOB_ID,RANK)
        VALUES (r.j_id,v_rank);