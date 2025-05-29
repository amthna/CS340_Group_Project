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