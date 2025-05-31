-- Resetear la base de datos
DROP DATABASE IF EXISTS snow;

-- Crear base de datos snow si no existe
CREATE DATABASE IF NOT EXISTS snow;

-- Usar la base de datos para nuestro estudio
USE snow;

-- Drop table para evitar que los registros se creen multiples veces
DROP TABLE IF EXISTS JobTitle; 				-- 1
DROP TABLE IF EXISTS QualPercent; 			-- 2
DROP TABLE IF EXISTS Entity; 				-- 3
DROP TABLE IF EXISTS Employee; 				-- 4 
DROP TABLE IF EXISTS HireTermDates; 		-- 5
DROP TABLE IF EXISTS City; 					-- 6
DROP TABLE IF EXISTS WorkType; 				-- 7
DROP TABLE IF EXISTS ProjectList; 			-- 8
DROP TABLE IF EXISTS Hours; 				-- 9
DROP TABLE IF EXISTS Wages; 				-- 10
DROP TABLE IF EXISTS Tasks; 				-- 11
DROP TABLE IF EXISTS Stakeholder; 			-- 12
DROP TABLE IF EXISTS log_employee_nuevo; 	-- 13
DROP TABLE IF EXISTS log_wage_modify; 		-- 14
DROP TABLE IF EXISTS log_task_update; 		-- 15

-- ------------------------------------------------- Creación de tablas --------------------------------------------------------

-- Crear la tabla JobTitle
-- Tabla dimensional donde se guardan los datos de puestos de trabajo por empleado
CREATE TABLE IF NOT EXISTS JobTitle (
    JobCode INT PRIMARY KEY,
    JobDescription VARCHAR(255) UNIQUE
) AUTO_INCREMENT=1000;

-- Crear la tabla QualPercent
-- Tabla de hecho que contiene la calificación técnica en porcentaje de cada puesto de trabajo
CREATE TABLE IF NOT EXISTS QualPercent (
    JobCode INT,
    TechnicalQual DECIMAL (3,2),
    -- Definición de FK
	FOREIGN KEY (JobCode) REFERENCES JobTitle(JobCode)
);

-- Crear la tabla Entity
-- Tabla de hecho que contiene la información de cada entidad
CREATE TABLE IF NOT EXISTS Entity (
    EntityID INT PRIMARY KEY,
    EntityName VARCHAR(255) NOT NULL,
    IndustryType VARCHAR(100),
    Country VARCHAR(100),
    TaxID VARCHAR(50)
);

-- Crear la tabla de Empleados
-- Tabla dimensional donde se guardan los datos de ingreso al sistema de los empleados
CREATE TABLE IF NOT EXISTS Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeName VARCHAR(70),
    JobCode INT,
    EntityID INT,
    Email VARCHAR(100),
    -- Definición de FK:
	FOREIGN KEY (JobCode) REFERENCES JobTitle(JobCode),
    FOREIGN KEY (EntityID) REFERENCES Entity(EntityID)
);

-- Crear las tablas relacionadas a RRHH (Tablas de hecho con información de los empleados)
-- Tabla HireTermDates para almacenar las fechas de contratación y terminación
CREATE TABLE IF NOT EXISTS HireTermDates (
    EmployeeID INT,
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    PRIMARY KEY (EmployeeID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Tabla City para almacenar la ciudad
CREATE TABLE IF NOT EXISTS City (
    EmployeeID INT,
    City VARCHAR(20),
    PRIMARY KEY (EmployeeID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Tabla WorkType para almacenar el tipo de trabajo
CREATE TABLE IF NOT EXISTS WorkType (
    EmployeeID INT,
    WorkType VARCHAR(20) DEFAULT "Híbrido",
    PRIMARY KEY (EmployeeID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Crear Tabla ProjectList
-- Tabla dimensional donde se guardan los proyectos
CREATE TABLE IF NOT EXISTS ProjectList (
	ProjectNumber INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR (255)
    );


-- Crear la tabla Hours
-- Tabla de hecho donde ese registran las horas pasadas por empleado en cada proyecto
CREATE TABLE IF NOT EXISTS Hours (
    EmployeeID INT,
    ProjectID INT,
    HoursWorked INT,
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES ProjectList(ProjectNumber)
);


-- Crear la tabla Wages
-- Tabla de hecho donde se guardan los salarios por proyecto y empleados que lo realizan
CREATE TABLE IF NOT EXISTS Wages (
    EmployeeID INT PRIMARY KEY NOT NULL,
    Wage DECIMAL(12,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);


-- Crear la tabla Task
-- Tabla dimensional que registra las tareas asociadas a un proyecto
CREATE TABLE IF NOT EXISTS Tasks (
    TaskID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectNumber INT,
    TaskName VARCHAR(255),
    Description TEXT,
    Status ENUM('Pending', 'In Progress', 'Completed') NOT NULL,
    DueDate DATE,
    AssignedTo INT,
    -- Definición de las FK
    FOREIGN KEY (ProjectNumber) REFERENCES ProjectList(ProjectNumber),
    FOREIGN KEY (AssignedTo) REFERENCES Employee(EmployeeID)
);

-- Crear la tabla Stakeholders
-- Tabla dimensional que contiene los datos de los Stakeholders
CREATE TABLE IF NOT EXISTS Stakeholders (
    StakeholderID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectNumber INT,
    Name VARCHAR(255),
    Type ENUM('Investor', 'Client', 'Government', 'Internal'),
    ContactInfo VARCHAR(255),
    FOREIGN KEY (ProjectNumber) REFERENCES ProjectList(ProjectNumber)
);

-- ----------------------------------------------- Creación de Tablas para Triggers -----------------------------------------------
-- 1. Tabla para registrar cada vez que se agrega un empleado nuevo a la tabla Employee
CREATE TABLE log_employee_nuevo (
	time_stamp	TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
	employee_id INT NOT NULL,
    employee_name VARCHAR (70),
    comment VARCHAR (100),
    added_by VARCHAR (50)
);

-- 2. Tabla para registrar cada vez que se modifique un salario
CREATE TABLE log_wage_modify (
	time_stamp	TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
    employee_id INT NOT NULL,
	old_wages DECIMAL(12,2),
    updated_wages DECIMAL(12,2)
);

-- 3. Tabla para registrar cada vez que el status de una tarea cambia
CREATE TABLE log_task_update (
	time_stamp	TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
    task_id INT NOT NULL,
    assigned_to INT NOT NULL,
    status_update ENUM('Pending', 'In Progress', 'Completed') NOT NULL
);

-- Fin de la creación de tablas

-- ------------------------------------------ Creación de Triggers ----------------------------------------------------------------
-- 1. Registrar cada vez que se agrega un empleado nuevo a la tabla Employee
-- Crear un trigger que registre las inserciones de datos
DROP TRIGGER IF EXISTS log_trigger_employees;

DELIMITER //

CREATE TRIGGER log_trigger_employees
	AFTER INSERT ON employee
    FOR EACH ROW 
	BEGIN
		INSERT INTO log_employee_nuevo
		VALUES
			(DEFAULT, NEW.EmployeeID, NEW.EmployeeName, "Empleado nuevo. Creación por insert", CURRENT_USER()); 
    END //

DELIMITER ;

INSERT INTO Employee (EmployeeName, JobCode, EntityID, Email) VALUES
('Michael Scofield', 1017, 122, 'michael.scofield@snow.co'),
('Lincoln Burrows', 1004, 123, 'lincoln.burrows@snow.co'),
('Sara Tancredi', 1018, 124, 'sara.tancredi@snow.co'),
('Fernando Sucre', 1006, 122, 'fernando.sucre@snow.co'),
('Theodore Bagwell', 1012, 125, 'theodore.bagwell@snow.co'),
('Paul Kellerman', 1005, 126, 'paul.kellerman@snow.co'),
('Veronica Donovan', 1016, 124, 'veronica.donovan@snow.co'),
('Brad Bellick', 1001, 123, 'brad.bellick@snow.co'),
('Alexander Mahone', 1009, 122, 'alexander.mahone@snow.co'),
('Benjamin Miles', 1003, 125, 'benjamin.miles@snow.co'),
('Charles Westmoreland', 1010, 126, 'charles.westmoreland@snow.co'),
('John Abruzzi', 1014, 123, 'john.abruzzi@snow.co'),
('Henry Pope', 1019, 122, 'henry.pope@snow.co'),
('David Apolskis', 1008, 124, 'david.apolskis@snow.co'),
('James Whistler', 1002, 125, 'james.whistler@snow.co'),
('Sophia Lugo', 1020, 123, 'sophia.lugo@snow.co'),
('LJ Burrows', 1013, 126, 'lj.burrows@snow.co'),
('Gretchen Morgan', 1011, 124, 'gretchen.morgan@snow.co'),
('Donald Self', 1015, 125, 'donald.self@snow.co'),
('Christina Scofield', 1018, 122, 'christina.scofield@snow.co');

SELECT * FROM log_employee_nuevo;

-- 2. Trigger para mostrar cuando se actualice la tabla wages
DROP TRIGGER IF EXISTS tg_wage_modification;

DELIMITER //

CREATE TRIGGER tg_wage_modification
	AFTER UPDATE ON wages
    FOR EACH ROW 
	BEGIN
		INSERT INTO log_wage_modify (employee_id, old_wages, updated_wages)
		VALUES
			(OLD.employeeid, OLD.wage, NEW.wage);
    END //

DELIMITER ;

-- Probar el trigger modificando un salario
SELECT * FROM snow.wages WHERE EmployeeID = 30;

UPDATE snow.wages
SET wage = 150600.00
WHERE EmployeeID = 30;

SELECT * FROM log_wage_modify;

-- 3. Trigger que indique cada vez que el status de una tarea cambia
DROP TRIGGER IF EXISTS tg_task_update;

DELIMITER //

CREATE TRIGGER tg_task_update
	AFTER UPDATE ON Tasks
    FOR EACH ROW 
	BEGIN
		INSERT INTO log_task_update (task_id, assigned_to, status_update)
		VALUES
			(OLD.taskid, OLD.assignedto, NEW.status);
    END //

DELIMITER ;

-- Probar el trigger actualizando una tarea
SELECT * FROM tasks;

UPDATE tasks VALUE
SET Status = 'Completed'
WHERE TaskID = 1;

SELECT * FROM log_task_update;

-- ----------------------------------------------- Creación de Vistas ------------------------------------------------------------- 
-- Vistas requeridas en el mail:
-- 1. ¿Qué empleados no tienen un Entity ID? ¿Cuántos son?
DROP VIEW IF EXISTS VW_no_entity_id;

CREATE VIEW VW_no_entity_id AS
	SELECT * FROM Employee
    WHERE EntityID IS NULL;
    
SELECT * FROM VW_no_entity_id;

SELECT COUNT(1) AS count_no_entityid FROM VW_no_entity_id;

-- 2. ¿Cuántos miembros de la familia Simpson trabajan en nuestra plantilla?
DROP VIEW IF EXISTS vw_simpson_family;

CREATE VIEW vw_simpson_family AS
	SELECT COUNT(1) AS simpsons FROM Employee
    WHERE EmployeeName LIKE '% Simpson';
    
SELECT * FROM vw_simpson_family;

-- 3. Necesitamos un reporte de los ingenieros y que % representan del total de nuestra plantilla
DROP VIEW IF EXISTS vw_ingenieros;

CREATE VIEW vw_ingenieros AS
SELECT 
    jobtitle.jobdescription AS engineer,
    COUNT(employee.EmployeeID) AS total_engineers,
    (SELECT COUNT(employee.EmployeeID) 
     FROM employee 
     JOIN jobtitle ON employee.JobCode = jobtitle.JobCode 
     WHERE JobDescription LIKE '%Ingeniero%') AS total_all_engineers,
    COUNT(employee.EmployeeID) / 
    (SELECT COUNT(employee.EmployeeID) 
     FROM employee 
     JOIN jobtitle ON employee.JobCode = jobtitle.JobCode 
     WHERE JobDescription LIKE '%Ingeniero%') AS percentage_of_total
FROM 
    employee
JOIN 
    jobtitle ON employee.JobCode = jobtitle.JobCode
WHERE 
    JobDescription LIKE '%Ingeniero%'
GROUP BY 
    jobtitle.JobDescription;
    
SELECT * FROM vw_ingenieros;

-- 4. ¿Cuántos carpinteros hay actualmente trabajando? Quisiera ver que cantidad hay de cada tipo de carpintero
DROP VIEW IF EXISTS vw_carpinteros;

CREATE VIEW vw_carpinteros AS
	SELECT jobtitle.jobdescription AS carpinteros, COUNT(employee.EmployeeID) AS total_carpinteros
	FROM employee 
	JOIN jobtitle ON employee.JobCode = jobtitle.JobCode 
	WHERE JobDescription LIKE '%Carpintero%'
    GROUP BY JobDescription;
    
SELECT * FROM vw_carpinteros;

-- 5. Tipos de industria
DROP VIEW IF EXISTS vw_tipos_industria;

CREATE VIEW vw_tipos_industria AS
	SELECT entity.IndustryType AS Industry
	FROM entity 
    GROUP BY entity.IndustryType;
    
SELECT * FROM vw_tipos_industria;

-- ¿Cuántos tipos de industria hay?
SELECT COUNT(DISTINCT entity.IndustryType) AS industry_type_count
FROM entity;

-- ---------------------------------------- Creación de Stored Procedures --------------------------------------------------------
-- 1. Mostrar los empleados con dos condiciones: QualPercent = 0 y Wages > 300,000
DROP PROCEDURE IF EXISTS sp_qual0_300000wage;

DELIMITER //

CREATE PROCEDURE sp_qual0_300000wage ()
BEGIN
    -- Mensaje informativo
    SELECT 'Con este procedimiento consultarás aquellos empleados que no están calificados y tienen salarios mayores a 300,000' AS Info;

    -- Selección de empleados
    SELECT e.EmployeeID, q.TechnicalQual, w.Wage
    FROM snow.Employee e
    JOIN snow.QualPercent q ON e.JobCode = q.JobCode
    JOIN snow.Wages w ON e.EmployeeID = w.EmployeeID
	WHERE w.Wage > 300000 AND q.TechnicalQual = 0
    ORDER BY e.EmployeeID
;
END//

DELIMITER ;

CALL sp_qual0_300000wage();

-- 2. Consultar los datos de una lista de entidades específica, usando el Entity ID
DROP PROCEDURE IF EXISTS sp_entities_by_list;

DELIMITER //

CREATE PROCEDURE sp_entities_by_list (IN EntityIDs VARCHAR(255))
	BEGIN
		SET @query = CONCAT('SELECT * FROM Entity WHERE EntityID IN (', EntityIDs, ')');
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END//
    
DELIMITER ;

SELECT * FROM Entity;

-- Consultar 3 entidades
CALL sp_entities_by_list('14,15,17');

-- --------------------------------------------- Creación de Funciones ------------------------------------------------------------
-- 1. Función para calcular el total de salario calificado
DROP FUNCTION IF EXISTS f_total_qualified_wages;

DELIMITER //

CREATE FUNCTION f_total_qualified_wages() 
RETURNS DECIMAL(20,2) 
DETERMINISTIC
BEGIN
    DECLARE total_qualified_wages DECIMAL(20,2);

    SELECT SUM(q.TechnicalQual * w.Wage) INTO total_qualified_wages
    FROM snow.Employee e
    JOIN snow.QualPercent q ON e.JobCode = q.JobCode
    JOIN snow.Wages w ON e.EmployeeID = w.EmployeeID;

    RETURN total_qualified_wages;
END //

DELIMITER ;

SELECT f_total_qualified_wages();

-- 2. Función para consultar el empleado más antiguo
DROP FUNCTION IF EXISTS f_first_hired;

DELIMITER //

CREATE FUNCTION f_first_hired() 
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE first_hired VARCHAR(100);

    SELECT EmployeeName INTO first_hired
    FROM snow.Employee e
    JOIN snow.HireTermDates h ON e.EmployeeID = h.EmployeeID
    ORDER BY h.HireDate ASC
    LIMIT 1;

    RETURN first_hired;
END //

DELIMITER ;

SELECT f_first_hired();

SELECT *
	FROM snow.Employee e
	JOIN snow.HireTermDates h ON e.EmployeeID = h.EmployeeID
    ORDER BY h.HireDate ASC
;





