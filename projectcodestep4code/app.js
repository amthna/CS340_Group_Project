// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 5689;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/birds', async function (req, res) {
    try {
        // Create and execute our queries
        // In query1, we use a JOIN clause to display the names of the homeworlds
        const query1 = `SELECT birds.bird_id, birds.common_name, species.species_name, families.family_name, orders.order_name FROM birds
        LEFT JOIN species ON birds.species_id = species.species_id
        LEFT JOIN families ON species.family_id = families.family_id
        LEFT JOIN orders ON species.order_id = orders.order_id;
        `;
        const [birds] = await db.query(query1);

        // Render the birds.hbs file, and also send the renderer
        //  an object that contains our birds information
        res.render('birds', { birds: birds});
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/birders', async function (req, res) {
    try {
        // Create and execute our queries
        // In query1, we use a JOIN clause to display the names of the homeworlds
        const query1 = `SELECT birder_id, first_name, last_name, email, is_active FROM birders;
        `;
        const [birders] = await db.query(query1);

        // Render the birders.hbs file, and also send the renderer
        //  an object that contains our birds information
        res.render('birders', { birders: birders });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/locations', async function (req, res) {
    try {
        // Create and execute our queries
        // In query1, we use a JOIN clause to display the names of the homeworlds
        const query1 = `SELECT location_id, location_name, is_public, longitude, latitude FROM locations;
        `;
        const [locations] = await db.query(query1);

        // Render the birders.hbs file, and also send the renderer
        //  an object that contains our birds information
        res.render('locations', { locations: locations });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/sightings', async function (req, res) {
    try {
        // Create and execute our queries
        // In query1, we use a JOIN clause to display the names of the homeworlds
        const query1 = `SELECT bird_sightings.sighting_id, locations.location_id, birds.bird_id, sighting_birders.sighting_id, birders.birder_id,
        locations.location_name, birders.first_name, birders.last_name, 
        birds.common_name, bird_sightings.sighting_datetime, bird_sightings.note 
        FROM bird_sightings

        LEFT JOIN locations ON bird_sightings.location_id = locations.location_id
        LEFT JOIN sighting_birds ON bird_sightings.sighting_id = sighting_birds.sighting_id
        LEFT JOIN birds ON sighting_birds.bird_id = birds.bird_id
        LEFT JOIN sighting_birders ON bird_sightings.sighting_id = sighting_birders.sighting_id
        LEFT JOIN birders ON sighting_birders.birder_id = birders.birder_id

        ;`;
        const query2 = `SELECT location_name FROM locations;`
        const query3 = `SELECT first_name, last_name FROM birders;`
        const query4 = `SELECT common_name FROM birds;`

        const [sightings] = await db.query(query1);
        const [locations] = await db.query(query2);
        const [birders] = await db.query(query3);
        const [birds] = await db.query(query4);

        // Render the birders.hbs file, and also send the renderer
        //  an object that contains our birds information
        res.render('sightings', { sightings: sightings, locations: locations, birders: birders, birds: birds });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// DELETE Routes

app.post('/birds/delete', async function (req, res) {

    try {
        // Create and execute our queries
        let data = req.body;

        const query1 = `CALL sp_DeleteBird(?);`;
        await db.query(query1, data.delete_bird_id);

        console.log(`DELETE birds. ID: ${data.delete_bird_id} ` +
            `Name: ${data.delete_common_name}`);
        res.redirect('/birds');      

    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/birders/delete', async function (req, res) {

    try {
        // Create and execute our queries
        let data = req.body;

        const query1 = `CALL sp_DeleteBirder(?);`;
        await db.query(query1, data.delete_birder_id);

        console.log(`DELETE birder. ID: ${data.delete_birder_id} ` +
            `Name: ${data.delete_birder_name}`);
            
            res.redirect('/birders');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/locations/delete', async function (req, res) {

    try {
        // Create and execute our queries
        let data = req.body;

        const query1 = `CALL sp_DeleteLocation(?);`;
        await db.query(query1, data.delete_location_id);

        console.log(`DELETE location. ID: ${data.delete_location_id} ` +
            `Name: ${data.delete_location_name}`);
            
            res.redirect('/locations');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/sightings/delete', async function (req, res) {

    try {
        // Create and execute our queries
        let data = req.body;

        const query1 = `CALL sp_DeleteSighting(?);`;
        await db.query(query1, data.delete_sighting_id);

        console.log(`DELETE sighting. ID: ${data.delete_sighting_id}`)
            
      res.redirect('/sightings');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// RESET

app.post('/reset', async function (req, res) {

    try {
        // Create and execute our queries
        const query1 = `CALL sp_ResetDatabase();`;
        await db.query(query1);

        console.log(`Reset database.`);
        res.redirect('/');    

    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});