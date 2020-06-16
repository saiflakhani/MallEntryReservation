var express = require('express');
var router = express.Router();
var db_con = require('../db/db_connection').connection;
var crypto = require('crypto');


/**
 * @swagger
 * definitions:
 *   Person:
 *     properties:
 *       id:
 *         type: integer
 *       person_name:
 *         type: string
 *       contact:
 *         type: string
 *       location:
 *         type: string
 *       recurring:
 *         type: integer
 *       flagged:
 *         type: integer
 *       password:
 *         type: string
 *       salt:
 *         type: string
 *       hash:
 *         type: string
 *         
 */

/**
 * @swagger
 * /persons:
 *   get:
 *     tags:
 *       - Persons
 *     summary: Get all registered persons
 *     description: Returns all persons
 *     produces:
 *       - application/json
 *     responses:
 *       200:
 *         description: An array of persons
 *         schema:
 *           $ref: '#/definitions/Person'
 */
router.get('/', function (req, res) {
    db_con.query("SELECT * FROM persons;", function (err, results) {
        if (err) {
            return res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an error getting this array'
                });
        }
        //console.log("Results -->", results);
        var resultArray = Object.values(JSON.parse(JSON.stringify(results)))
        res.json(resultArray);
    })
});


/**
 * @swagger
 * /persons/add:
 *   put:
 *     tags:
 *       - Persons
 *     summary: Creates a new reservation
 *     description: Creates a new reservation
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: Person
 *         description: Person object
 *         in: body
 *         required: true
 *         schema:
 *           $ref: '#/definitions/Person'
 *     responses:
 *       200:
 *         description: Successfully created
 *       401:
 *         description: Unauthorized, Password incorrect
 */
router.put('/add', function (req, res) {
    var salt = undefined, hash = undefined;
    if (req.body.recurring == undefined) {
        req.body.recurring = 0;
    }
    if (req.body.flagged == undefined) {
        req.body.flagged = 0;
    }
    if (req.body.contact == undefined) {
        return res.status(500).json({ status: 'Failed', message: 'Contact not defined' });
    }
    if (req.body.password == undefined) {
        return res.status(500).json({ status: 'Failed', message: 'Password not defined' });
    } else {
        var response = setPassword(req.body.password);
        salt = response.salt;
        hash = response.hash;
        console.log("Salt --> " + salt + " Hash --> " + hash);
    }

    db_con.query("SELECT * FROM persons WHERE contact = '" + req.body.contact + "';", function (err, results) {
        if (err) {
            return res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an error getting this object',
                    error: err
                });
        }
        var resultArray = Object.values(JSON.parse(JSON.stringify(results)));
        var found = false;

        if(resultArray[0] != undefined){
            if (checkPassword(req.body.password, resultArray[0].salt, resultArray[0].hash)) {
                found = true;
                //Idiot. Signed up when he should've signed in.
                return res.status(200).json(resultArray[0]);
            }else{
                return res.status(401)
                        .json({
                            status: 'failure',
                            message: 'Password incorrect',
                        });
            }
        }
        if(!found) {
            db_con.query("INSERT INTO persons(person_name, contact, location, recurring, flagged, salt, hash) VALUES('" + req.body.person_name + "', \
                '"+ req.body.contact + "', '" + req.body.location + "', " + req.body.recurring + ", " + req.body.flagged + ", '" + salt + "', '" + hash + "');", function (err, results) {
                if (err) {
                    return res.status(500)
                        .json({
                            status: 'failure',
                            message: 'There was an error inserting this object',
                            error: err
                        });
                }
                db_con.query("SELECT * FROM persons WHERE id = " + results.insertId, function (err, results) {
                    if (err) {
                        return res.status(500)
                            .json({
                                status: 'failure',
                                message: 'There was an error inserting this object',
                                error: err
                            });
                    }
                    return res.status(200).json(results[0]);
                });
            });
        }
    });




});


/**
 * @swagger
 * /persons/{id}:
 *   get:
 *     tags:
 *       - Persons
 *     summary: Gets a person with the given ID
 *     description: Gets a person with the given ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: id
 *         description: Person ID
 *         in: path
 *         required: true
 *         type: integer
 *         schema:
 *           $ref: '#/definitions/Person'
 *     responses:
 *       200:
 *         description: Successfully retrieved
 */
router.get("/:id", function (req, res) {
    var personId = req.params.id;
    db_con.query("SELECT * FROM persons WHERE id = " + personId, function (err, results) {
        if (err) {
            return res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an error getting this object',
                    error: err
                });
        }
        var resultArray = Object.values(JSON.parse(JSON.stringify(results)))

        res.status(200).json(resultArray);
    })
});


/**
 * @swagger
 * /persons/get_person_from_contact:
 *   post:
 *     tags:
 *       - Persons
 *     summary: Gets a person with the given contact number and password
 *     description: Gets a person with the given contact and password
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: Person
 *         description: Person object
 *         in: body
 *         required: true
 *         schema:
 *           $ref: '#/definitions/Person'
 *     responses:
 *       200:
 *         description: Successfully retrieved
 *       401:
 *         description: Unauthorized, Password incorrect
 */
router.post("/get_person_from_contact", function (req, res) {
    var contact = req.body.contact;
    var password = req.body.password;
    if (req.body.password == undefined) {
        return res.status(500).json({ status: 'Failed', message: 'Password not defined' });
    }
    if (req.body.contact == undefined) {
        return res.status(500).json({ status: 'Failed', message: 'Contact not defined' });
    }
    db_con.query("SELECT * FROM persons WHERE contact = '" + contact + "';", function (err, results) {
        if (err) {
            return res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an error getting this object',
                    error: err
                });
        }
        var resultArray = Object.values(JSON.parse(JSON.stringify(results)))
        var elementReturn = undefined;


        if(resultArray[0]!=undefined){
            if (checkPassword(password, resultArray[0].salt, resultArray[0].hash)) {
                elementReturn = resultArray[0];
            }else{
                return res.status(401)
                .json({
                    status: 'failure',
                    message: 'Password incorrect',
                });
            }
        }
        
        if (elementReturn != undefined) {
            return res.status(200).json(resultArray);
        } else {
            return res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an error getting this object',
                    error: err
                });
        }

    })
});














/**
 * @swagger
 * /persons/update:
 *   post:
 *     tags:
 *       - Persons
 *     summary: Updates the person with the given ID, and the given body
 *     description: Updates the person with the given ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: Person
 *         description: Person object
 *         in: body
 *         required: true
 *         schema:
 *           $ref: '#/definitions/Person'
 *     responses:
 *       200:
 *         description: Successfully updated
 */
router.post('/update', function (req, res) {
    console.log("Updating entry --> " + JSON.stringify(req.body));

});


/**
 * @swagger
 * /persons/{id}:
 *   delete:
 *     tags:
 *       - Persons
 *     summary: Deletes (hard) a person with the given ID
 *     description: Deletes a person with the given ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: id
 *         description: Person ID
 *         in: path
 *         required: true
 *         type: integer
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully deleted
 */
router.delete("/:id", function (req, res) {
    var personId = req.params.id;
    db_con.query("DELETE FROM persons WHERE id=" + personId, function (err, results) {
        if (err) {
            res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an deleting getting this reservation',
                    error: err
                });
        }
        var resultArray = Object.values(JSON.parse(JSON.stringify(results)))
        res.json(resultArray);
    })
});

function setPassword(password) {
    // Creating a unique salt for a particular user 
    var salt = crypto.randomBytes(16).toString('hex');
    // Hashing user's salt and password with 1000 iterations, 
    //64 length and sha512 digest 
    var hash = crypto.pbkdf2Sync(password, salt, 1000, 64, `sha512`).toString(`hex`);
    return ({ salt: salt, hash: hash });
};

function checkPassword(password, salt, hash) {
    var hashLocal = crypto.pbkdf2Sync(password,
        salt, 1000, 64, `sha512`).toString(`hex`);
    console.log("Generated Hash --> " + hashLocal + " provided hash --> " + hash);
    return hashLocal == hash;
};

module.exports = router;