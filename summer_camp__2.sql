Create DATABASE summer_camp;
use summer_camp;
-- -------TASK 1  CREATING TABLE 

-- Creating tables
CREATE TABLE Campers (
    CamperID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    MiddleName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    DateOfBirth DATE,
    Gender VARCHAR(10),
    PersonalPhone VARCHAR(20) UNIQUE
);

select * from campers;

select * from camps;



select * from CampRegistrations;

CREATE TABLE Camps (
    CampID INT PRIMARY KEY,
    CampTitle VARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Capacity INT,
    Price DECIMAL(10, 2)
);

CREATE TABLE CampRegistrations (
    RegistrationID INT PRIMARY KEY,
    CamperID INT,
    CampID INT,
    RegistrationDate DATE,
    FOREIGN KEY (CamperID) REFERENCES Campers(CamperID),
    FOREIGN KEY (CampID) REFERENCES Camps(CampID)
);

-- data insertion to table 

-- task 2 ----------------------------------------------------------------
-- Stored procedure to populate the Campers table with 5000 random entries


DROP PROCEDURE IF EXISTS PopulateCampers;

DELIMITER $$

CREATE PROCEDURE PopulateCampers()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE gender_val VARCHAR(10);
    DECLARE dob_val DATE;
    DECLARE v_current_date DATE;
    DECLARE birth_year INT;
    DECLARE birth_month INT;
    DECLARE birth_day INT;
    DECLARE rand_num DOUBLE;
    DECLARE first_index INT;
    DECLARE first_val VARCHAR(50);
    DECLARE middle_index INT;
    DECLARE middle_val VARCHAR(10);

    -- Set current date for age calculation
    SET v_current_date = '2025-09-16';

    -- Clear child and parent tables safely
    DELETE FROM CampRegistrations WHERE CamperID > 0;
    DELETE FROM Campers WHERE CamperID > 0;

    WHILE i <= 5000 DO
        -- Determine gender (65% Female, 35% Male)
        IF RAND() <= 0.65 THEN
            SET gender_val = 'Female';
        ELSE
            SET gender_val = 'Male';
        END IF;

        -- Determine age distribution
        SET rand_num = RAND();
        IF rand_num <= 0.18 THEN
            SET birth_year = YEAR(v_current_date) - FLOOR(RAND() * 6) - 7;
        ELSEIF rand_num <= 0.45 THEN
            SET birth_year = YEAR(v_current_date) - FLOOR(RAND() * 2) - 13;
        ELSEIF rand_num <= 0.65 THEN
            SET birth_year = YEAR(v_current_date) - FLOOR(RAND() * 3) - 15;
        ELSE
            SET birth_year = YEAR(v_current_date) - FLOOR(RAND() * 5) - 15;
        END IF;

        SET birth_month = FLOOR(RAND() * 12) + 1;
        SET birth_day = FLOOR(RAND() * 28) + 1;

        -- Generate valid date
        SET dob_val = STR_TO_DATE(CONCAT(birth_year, '-', birth_month, '-', birth_day), '%Y-%m-%d');

        -- Pick random FirstName (including Lakshmi)
        SET first_index = FLOOR(RAND() * 11) + 1; -- 11 options
        CASE first_index
            WHEN 1 THEN SET first_val = 'Liam';
            WHEN 2 THEN SET first_val = 'Emma';
            WHEN 3 THEN SET first_val = 'Noah';
            WHEN 4 THEN SET first_val = 'Olivia';
            WHEN 5 THEN SET first_val = 'Aiden';
            WHEN 6 THEN SET first_val = 'Sophia';
            WHEN 7 THEN SET first_val = 'Ethan';
            WHEN 8 THEN SET first_val = 'Isabella';
            WHEN 9 THEN SET first_val = 'Lucas';
            WHEN 10 THEN SET first_val = 'Mia';
            WHEN 11 THEN SET first_val = 'Lakshmi';
        END CASE;

        -- Pick simple MiddleName (single letters or short)
        SET middle_index = FLOOR(RAND() * 5) + 1;
        CASE middle_index
            WHEN 1 THEN SET middle_val = 'A';
            WHEN 2 THEN SET middle_val = 'B';
            WHEN 3 THEN SET middle_val = 'C';
            WHEN 4 THEN SET middle_val = 'M';
            WHEN 5 THEN SET middle_val = 'J';
        END CASE;

        -- Insert camper record
        INSERT INTO Campers 
            (CamperID, FirstName, MiddleName, LastName, Email, DateOfBirth, Gender, PersonalPhone)
        VALUES (
            i,
            first_val,
            middle_val,
            'Test',
            CONCAT(LOWER(first_val), i, '@test.com'),
            dob_val,
            gender_val,
            CONCAT('555-01', LPAD(i, 4, '0'))
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Call the procedure
CALL PopulateCampers();

INSERT INTO camps (CampID, CampTitle, StartDate, EndDate, Capacity, Price) VALUES
(1, 'Tech Explorers Camp', '2022-07-15', '2022-07-29', 50, 450.00),
(2, 'Art & Design Workshop', '2023-06-10', '2023-06-20', 30, 300.00),
(3, 'Young Leader Academy', '2024-08-01', '2024-08-15', 40, 550.00),
(4, 'Robotics Summer Camp', '2025-07-05', '2025-07-19', 60, 600.00);

INSERT INTO CampRegistrations (RegistrationID, CamperID, CampID, RegistrationDate)
VALUES
(1, 1, 1, '2023-06-02'),
(2, 1, 3, '2024-05-06'),
(3, 2, 2, '2023-07-12'),
(4, 2, 4, '2024-08-03'),
(5, 6, 1, '2023-06-15'),
(6, 6, 2, '2023-07-20'),
(7, 6, 3, '2024-05-08');

-- ----------------------------------------------------------------------------------



-- task 3 ---=query 1 - TO find how many times teenager Lakshmi visited camp in last 3 years-


SELECT COUNT(*) AS Lakshmi_Teen_Visits
FROM Campers c
JOIN CampRegistrations r ON c.CamperID = r.CamperID
WHERE c.FirstName = 'Lakshmi'
  AND (YEAR(CURDATE()) - YEAR(c.DateOfBirth)) BETWEEN 13 AND 19
  AND r.RegistrationDate >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR);


-- Task 3 ---------------------------------
-- query 4----write a query that can output data in a format so that following chart can be drawn as the number the chart are indicative as Gen X, Millanials ,GenZ, Gen alpha


WITH GenerationCounts AS (
    SELECT
        CASE
            WHEN YEAR(DateOfBirth) BETWEEN 1965 AND 1980 THEN 'Gen X'
            WHEN YEAR(DateOfBirth) BETWEEN 1981 AND 1996 THEN 'Millennials'
            WHEN YEAR(DateOfBirth) BETWEEN 1997 AND 2012 THEN 'Gen Z'
            WHEN YEAR(DateOfBirth) >= 2013 AND YEAR(DateOfBirth) <= YEAR(CURDATE()) THEN 'Gen Alpha'
            ELSE 'Other'
        END AS Generation,
        Gender,
        COUNT(*) AS CamperCount
    FROM Campers
    GROUP BY Generation, Gender
)
SELECT
    Generation,
    Gender,
    CamperCount,
    CAST(CamperCount * 100.0 / SUM(CamperCount) OVER (PARTITION BY Generation) AS DECIMAL(5,2)) AS Percentage
FROM GenerationCounts
WHERE Generation IN ('Gen X', 'Millennials', 'Gen Z', 'Gen Alpha')
ORDER BY Generation, Gender DESC;
