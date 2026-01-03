CREATE TABLE projects (
    -- 1. Column Definitions (Name, Type, Default)
    project_id      NUMBER(6),
    project_name    VARCHAR2(50) NOT NULL, -- NOT NULL stays here typically
    manager_id      NUMBER(6),
    start_date      DATE DEFAULT SYSDATE,
    budget          NUMBER(10, 2) DEFAULT 0,
    status          VARCHAR2(20),

    -- 2. Constraints Section (The Rules)
    
    -- Primary Key
    CONSTRAINT pk_projects 
        PRIMARY KEY (project_id),

    -- Foreign Key (Explicitly linking the column to the other table)
    CONSTRAINT fk_projects_manager 
        FOREIGN KEY (manager_id) 
        REFERENCES employees(employee_id),

    -- Check Constraint
    CONSTRAINT chk_project_status 
        CHECK (status IN ('Planned', 'Active', 'Closed'))
);