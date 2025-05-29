-- DELETE QUERIES ------------------------------------------------------------------------------------------------------

-- #############################
-- DELETE bird
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteBird;

DELIMITER //
CREATE PROCEDURE sp_DeleteBird(IN b_id INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both birds table and 
        --      intersection table to prevent a data anamoly


        DELETE bird_sightings FROM bird_sightings
        LEFT JOIN sighting_birds ON bird_sightings.sighting_id = sighting_birds.sighting_id
        LEFT JOIN birds ON sighting_birds.bird_id = birds.bird_id
        WHERE birds.bird_id = b_id;

        DELETE FROM sighting_birds WHERE bird_id = b_id;
        DELETE FROM birds WHERE bird_id = b_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in birds for id: ', b_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE birder
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteBirder;

DELIMITER //
CREATE PROCEDURE sp_DeleteBirder(IN bder_id INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both birds table and 
        --      intersection table to prevent a data anamoly

        DELETE bird_sightings FROM bird_sightings
        LEFT JOIN sighting_birds ON bird_sightings.sighting_id = sighting_birds.sighting_id
        LEFT JOIN birds ON sighting_birds.bird_id = birds.bird_id
        LEFT JOIN sighting_birders ON bird_sightings.sighting_id = sighting_birders.sighting_id
        LEFT JOIN birders ON sighting_birders.birder_id = birders.birder_id
        WHERE birders.birder_id = bder_id;
        
        DELETE FROM sighting_birders WHERE birder_id = bder_id;
        DELETE FROM birders WHERE birder_id = bder_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in birders for id: ', bder_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE location
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteLocation;

DELIMITER //
CREATE PROCEDURE sp_DeleteLocation(IN l_id INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both birds table and 
        --      intersection table to prevent a data anamoly

        
        DELETE FROM bird_sightings WHERE location_id = l_id;
        DELETE FROM locations WHERE location_id = l_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in locations for id: ', l_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE sightings
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteSighting;

DELIMITER //
CREATE PROCEDURE sp_DeleteSighting(IN s_id INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both birds table and 
        -- intersection table to prevent a data anamoly

        DELETE FROM sighting_birds WHERE sighting_id = s_id;
        DELETE FROM sighting_birders WHERE sighting_id = s_id;
        DELETE FROM bird_sightings WHERE sighting_id = s_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in bird_sightings for id: ', s_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- RESET QUERY ------------------------------------------------------------------------------------------------------

-- #############################
-- RESET database
-- #############################

DROP PROCEDURE IF EXISTS sp_ResetDatabase;

DELIMITER //
CREATE PROCEDURE sp_ResetDatabase()
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        set error_message = 'Reset failed.';
        SIGNAL SQLSTATE '40004' SET MESSAGE_TEXT = error_message;
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;


    END;
    -- Regenerate DB with tables and sample data. Code drom DDL.sql

    SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id int(11) NOT NULL AUTO_INCREMENT,
    order_name varchar(45) NOT NULL UNIQUE,
    PRIMARY KEY (order_id)
);

INSERT INTO orders (
    order_name
)
VALUES 
(
    'Pelecaniformes'
),
(
    'Passeriformes'
),
(
    'Accipitriformes'
);

DROP TABLE IF EXISTS families;
CREATE TABLE families (
    family_id int(11) NOT NULL AUTO_INCREMENT,
    family_name varchar(45) NOT NULL UNIQUE,
    PRIMARY KEY (family_id)
);

INSERT INTO families (
    family_name
)
VALUES 
(
    'Ardeidae'
),
(
    'Threskiornithidae'
),
(
    'Icteridae'
),
(
    'Accipitridae'
);

DROP TABLE IF EXISTS species;
CREATE TABLE species (
    species_id int(11) NOT NULL AUTO_INCREMENT,
    order_id int(11) NOT NULL,
    family_id int(11) NOT NULL,
    species_name varchar(45) NOT NULL UNIQUE,
    PRIMARY KEY (species_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (family_id) REFERENCES families(family_id) ON DELETE CASCADE
);

INSERT INTO species (
    order_id,
    family_id,
    species_name
)
VALUES 
(
    (select order_id from orders where order_name = 'Pelecaniformes'),
    (select family_id from families where family_name = 'Ardeidae'),
    'Ardea herodias'
),
(
    (select order_id from orders where order_name ='Pelecaniformes'),
    (select family_id from families where family_name = 'Threskiornithidae'),
    'Platalea leucorodia'
),
(
    (select order_id from orders where order_name ='Passeriformes'),
    (select family_id from families where family_name = 'Icteridae'),
    'Agelaius phoeniceus'
),
(
    (select order_id from orders where order_name ='Passeriformes'),
    (select family_id from families where family_name = 'Icteridae'),
    'Fringilla pecoris'
),
(
    (select order_id from orders where order_name ='Accipitriformes'),
    (select family_id from families where family_name = 'Accipitridae'),
    'Buteo jamaicensis'
);

DROP TABLE IF EXISTS birds;
CREATE TABLE birds (
    bird_id int(11) NOT NULL AUTO_INCREMENT,
    species_id int(11) NOT NULL,
    common_name varchar(45) NOT NULL UNIQUE,
    PRIMARY KEY (bird_id),
    FOREIGN KEY (species_id) REFERENCES species(species_id) ON DELETE CASCADE
);

INSERT INTO birds (
    common_name,
    species_id
)
VALUES 
(
    'Great blue heron',
    (select species_id from species where species_name = 'Ardea herodias')
),
(
    'Eurasian spoonbill',
    (select species_id from species where species_name = 'Platalea leucorodia')
),
(
    'Red-winged blackbird',
    (select species_id from species where species_name = 'Agelaius phoeniceus')
),
(
    'Cowbird',
    (select species_id from species where species_name = 'Fringilla pecoris')
),
(
    'Red-tailed hawk',
    (select species_id from species where species_name = 'Buteo jamaicensis')
);

DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
    location_id int(11) NOT NULL AUTO_INCREMENT,
    location_name varchar(45) NOT NULL UNIQUE,
    is_public tinyint NOT NULL DEFAULT 1,
    longitude decimal(10,6),
    latitude decimal(10,6),
    PRIMARY KEY (location_id)
);

INSERT INTO locations (
    location_name,
    longitude,
    latitude,
    is_public
)
VALUES 
(
    'Pearl Park',
    44.904650, 
    -93.269675,
    1

),
(
    'Wood Lake',
    44.879479, 
    -93.289225,
    1

),
(
    'Andrew''s Backyard',
    44.904590, 
    -93.259956,
    0

);

DROP TABLE IF EXISTS bird_sightings;
CREATE TABLE bird_sightings (
    sighting_id int(11) NOT NULL AUTO_INCREMENT,
    location_id int(11) NOT NULL,
    sighting_datetime datetime NOT NULL,
    note varchar(1028),
    PRIMARY KEY (sighting_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE,
    UNIQUE(sighting_datetime, location_id)
);

INSERT INTO bird_sightings (
    location_id,
    sighting_datetime,
    note
)
VALUES 
(
    (select location_id from locations where location_name = 'Andrew''s Backyard'),
    '2025-04-12 11:15:00',
    'A beautiful Red-tailed hawk in flight'
),
(
    (select location_id from locations where location_name = 'Wood Lake'),
    '2025-04-29 13:15:00',
    'We spotted a Great blue heron fishing in the lake.'
),
(
    (select location_id from locations where location_name = 'Pearl Park'),
    '2025-04-15 18:15:00',
    ''
);

DROP TABLE IF EXISTS sighting_birds;
CREATE TABLE sighting_birds (
    bird_id int(11) NOT NULL,
    sighting_id int(11) NOT NULL,
    PRIMARY KEY (bird_id, sighting_id),
    FOREIGN KEY (bird_id) REFERENCES birds(bird_id) ON DELETE CASCADE,
    FOREIGN KEY (sighting_id) REFERENCES bird_sightings(sighting_id) ON DELETE CASCADE,
    UNIQUE(sighting_id, bird_id)
);

INSERT INTO sighting_birds (
    bird_id,
    sighting_id
)
VALUES 
(
    (select bird_id from birds where common_name = 'Red-tailed hawk'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-12 11:15:00')
),
(
    (select bird_id from birds where common_name = 'Great blue heron'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-29 13:15:00')
),
(
    (select bird_id from birds where common_name = 'Cowbird'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-15 18:15:00')
);

DROP TABLE IF EXISTS birders;
CREATE TABLE birders (
    birder_id int(11) NOT NULL AUTO_INCREMENT,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    email varchar(45) NOT NULL,
    member_since date NOT NULL,
    is_active tinyint DEFAULT 1,
    PRIMARY KEY (birder_id),
    UNIQUE (first_name,last_name)
);

INSERT INTO birders (
    first_name,
    last_name,
    email,
    member_since
)
VALUES 
(
    'Andrew',
    'Mathena',
    'mathenaa@ife.org',
    '2025-01-01'
),
(
    'Christian',
    'Bromley',
    'bromleyc@ife.org',
    '2025-02-01'
),
(
    'George',
    'Birdington',
    'birdingtong@ife.org',
    '2025-01-11'
);

DROP TABLE IF EXISTS sighting_birders;
CREATE TABLE sighting_birders (
    birder_id int(11) NOT NULL,
    sighting_id int(11) NOT NULL,
    PRIMARY KEY (birder_id, sighting_id),
    FOREIGN KEY (birder_id) REFERENCES birders(birder_id) ON DELETE CASCADE,
    FOREIGN KEY (sighting_id) REFERENCES bird_sightings(sighting_id) ON DELETE CASCADE,
    UNIQUE(sighting_id, birder_id)
);

INSERT INTO sighting_birders (
    birder_id,
    sighting_id
)
VALUES 
(
    (select birder_id from birders where email = 'mathenaa@ife.org'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-12 11:15:00')
),
(
    (select birder_id from birders where email = 'bromleyc@ife.org'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-29 13:15:00')
),
(
    (select birder_id from birders where email = 'mathenaa@ife.org'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-29 13:15:00')
),
(
    (select birder_id from birders where email = 'birdingtong@ife.org'),
    (select sighting_id from bird_sightings where sighting_datetime = '2025-04-15 18:15:00')
);

SET FOREIGN_KEY_CHECKS=1;
COMMIT;

END //
DELIMITER ;