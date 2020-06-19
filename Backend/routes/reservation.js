var express = require('express');
var router = express.Router();

var db_con = require('../db/db_connection').connection;


/**
 * @swagger
 * definitions:
 *   Reservation:
 *     properties:
 *       id:
 *         type: integer
 *       reservation_key:
 *         type: string
 *       reservation_date:
 *         type: string
 *       person_id:
 *         type: integer
 *       adults:
 *         type: integer
 *       children:
 *         type: integer
 *       adult_names:
 *         type: string
 *       child_names:
 *         type: string
 *       vehicle_type:
 *          type: string
 *       vehicle_number:
 *          type: string
 *       timeslot:
 *          type: string
 *       parking:
 *          type: string
 *       review:
 *          type: number
 *       review_text:
 *          type: string
 *       entry_time:
 *          type: string
 *       exit_time:
 *          type: string
 *         
 */

/**
 * @swagger
 * /reservations:
 *   get:
 *     tags:
 *       - Reservations
 *     summary: Get all reservations
 *     description: Returns all reservation, with the persons that booked it
 *     produces:
 *       - application/json
 *     responses:
 *       200:
 *         description: An array of reservations
 *         schema:
 *           $ref: '#/definitions/Reservation'
 */
// Home page route.
router.get('/', function (req, res) {
  db_con.query("SELECT reservation.*, persons.*, reservation.id FROM reservation INNER JOIN persons ON reservation.person_id=persons.id ORDER BY reservation.id ASC", function (err, results) {
    if (err) {
      return res.status(500)
        .json({
          status: 'failure',
          message: 'There was an error getting this array'
        });
    }
    //console.log("Results -->", results);
    var resultArray = Object.values(JSON.parse(JSON.stringify(results)))
    return res.json(resultArray);
  })
});


/**
 * @swagger
 * /reservations/get_by_date:
 *   get:
 *     tags:
 *       - Reservations
 *     summary: Get all reservations based on the given date
 *     description: Returns all reservation, with the persons that booked it
 *     parameters:
 *       - name: start_date
 *         description: Start Date (YYYY-MM-dd)
 *         in: query
 *         required: true
 *         type: string
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *       - name: end_date
 *         description: End Date (YYYY-MM-dd)
 *         in: query
 *         required: true
 *         type: string
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     produces:
 *       - application/json
 *     responses:
 *       200:
 *         description: An array of reservations
 *         schema:
 *           $ref: '#/definitions/Reservation'
 */
// Home page route.
router.get('/get_by_date', function (req, res) {
  var start_date = req.query.start_date + " 00:00:00";
  var end_date = req.query.end_date + " 23:59:59";
  var query = "SELECT reservation.*, persons.*, reservation.id FROM reservation INNER JOIN persons ON reservation.person_id=persons.id AND reservation_date BETWEEN '" + start_date + "' AND '" + end_date + "' ORDER BY reservation.id ASC;"
  console.log(query);
  db_con.query(query, function (err, results) {
    if (err) {
      return res.status(500)
        .json({
          status: 'failure',
          message: 'There was an error getting this array',
          error: err
        });
    }
    //console.log("Results -->", results);
    var resultArray = Object.values(JSON.parse(JSON.stringify(results)))
    return res.json(resultArray);
  });
});


/**
 * @swagger
 * /reservations/add:
 *   put:
 *     tags:
 *       - Reservations
 *     summary: Creates a new reservation
 *     description: Creates a new reservation
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: Reservation
 *         description: Reservation object
 *         in: body
 *         required: true
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully created
 */
router.put('/add', function (req, res) {
  console.log(req.body);
  if (req.body.reservation_key == null) {
    req.body.reservation_key = generateReservationKey();
  }
  if (req.body.review == undefined) {
    req.body.review = 0;
  }
  if (req.body.person_id == null) {
    return res.status(500).json({
      status: 'failure',
      message: 'person_id must be present'
    });
  }

  if ((req.body.timeslot != "midday") && (req.body.timeslot != "afternoon") && (req.body.timeslot != "evening") && (req.body.timeslot != "late_evening")) {
    return res.status(500).json({
      status: 'failure',
      message: "Error, timeslot must be one of: midday, afternoon, evening or late_evening"
    });
  }


  db_con.query("INSERT INTO reservation(reservation_key, reservation_date, person_id, adults, children, adult_names, child_names, vehicle_type,\
      vehicle_number, timeslot, parking, review, review_text) VALUES (\
      '"+ req.body.reservation_key + "', '" + req.body.reservation_date + "', " + req.body.person_id + ", " + req.body.adults + ", \
      "+ req.body.children + ", '" + req.body.adult_names + "', '" + req.body.child_names + "', '" + req.body.vehicle_type + "', '" + req.body.vehicle_number + "', '" + req.body.timeslot + "', '" + req.body.parking + "', \
      "+ req.body.review + ", '" + req.body.review_text + "');", function (err, results) {

    if (err) {
      return res.status(500)
        .json({
          status: 'failure',
          message: 'There was an error inserting this object',
          error: err
        });
    }
    return res.status(200)
      .json({
        status: 'success',
        message: 'Inserted one reservation',
        reservationKey: req.body.reservation_key
      });
  });
});

/**
 * @swagger
 * /reservations/entry_exit:
 *   post:
 *     tags:
 *       - Reservations
 *     summary: Creates an entry or exit for the given reservation key
 *     description: Creates an entry or exit for the given reservation key 
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: Reservation
 *         description: Reservation object
 *         in: body
 *         required: true
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully entered or exited
 */
router.post('/entry_exit', function (req, res) {
  if (req.body.reservation_key == undefined) {
    return res.status(500).json({
      status: 'failure',
      message: 'Reservation Key not present'
    });
  }

  var reservationKey = req.body.reservation_key;

  var query = "SELECT entry_time, exit_time FROM reservation WHERE reservation_key = '" + reservationKey + "';";
  db_con.query(query, function (err, results) {
    if (err) {
      return res.status(500)
        .json({
          status: 'failure',
          message: 'There was an error getting this array',
          error: err
        });
    }
    //console.log("Results -->", results);
    var resultArray = Object.values(JSON.parse(JSON.stringify(results)))
    if (resultArray != undefined && resultArray[0] != undefined) {
      var currentDate = new Date().toISOString().slice(0, 19).replace('T', ' ');
      
      if (resultArray[0].entry_time == undefined) {
        var columnToUpdate = "entry_time";
      }else if(resultArray[0].exit_time == undefined){
        var columnToUpdate = "exit_time";
      }else{
        return res.status(500).json({
          status: 'failure',
          message: 'This reservation is already used'
        });
      }
      db_con.query("UPDATE reservation SET " + columnToUpdate +" = '" + currentDate + "' WHERE reservation_key = '" + reservationKey + "';", function (err, results) {
        if (err) {
          return res.status(500)
            .json({
              status: 'failure',
              message: 'There was an error getting this array',
              error: err
            });
        }
        return res.status(200).json(
          {
            status: 'success',
            message: 'Updated one element',
            type: columnToUpdate
          }
        );
      });
    }
  });

});




/**
 * @swagger
 * /reservations/{id}:
 *   get:
 *     tags:
 *       - Reservations
 *     summary: Gets a reservation with the given ID
 *     description: Gets a reservation with the given ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: id
 *         description: Reservation ID
 *         in: path
 *         required: true
 *         type: integer
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully created
 */
router.get("/:id", function (req, res) {
  var reservationID = req.params.id;
  db_con.query("SELECT reservation.*, persons.*, reservation.id FROM reservation INNER JOIN persons ON reservation.person_id=persons.id WHERE reservation.id = " + reservationID, function (err, results) {
    if (err) {
      res.status(500)
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
 * /reservations/update:
 *   post:
 *     tags:
 *       - Reservations
 *     summary: Updates the reservation with the given ID, and the given body
 *     description: Updates the reservation with the given ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: Reservation
 *         description: Reservation object
 *         in: body
 *         required: true
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully updated
 */
router.post('/update', function (req, res) {
  console.log("Updating entry --> " + JSON.stringify(req.body));

});



/**
 * @swagger
 * /reservations/my_reservations/{personId}:
 *   get:
 *     tags:
 *       - Reservations
 *     summary: Gets all reservations for the given person ID
 *     description: Gets all reservations for the given person ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: personId
 *         description: Person ID
 *         in: path
 *         required: true
 *         type: integer
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully created
 */
router.get("/my_reservations/:personId", function (req, res) {
  var personId = req.params.personId;
  db_con.query("SELECT reservation.*, persons.*, reservation.id FROM reservation INNER JOIN persons ON reservation.person_id=persons.id WHERE reservation.person_id = " + personId, function (err, results) {
    if (err) {
      res.status(500)
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
 * /reservations/{id}:
 *   delete:
 *     tags:
 *       - Reservations
 *     summary: Deletes (hard) a reservation with the given ID
 *     description: Deletes a reservation with the given ID
 *     produces:
 *       - application/json
 *     parameters:
 *       - name: id
 *         description: Reservation ID
 *         in: path
 *         required: true
 *         type: integer
 *         schema:
 *           $ref: '#/definitions/Reservation'
 *     responses:
 *       200:
 *         description: Successfully created
 */
router.delete("/:id", function (req, res) {
  var reservationID = req.params.id;
  db_con.query("DELETE FROM reservation WHERE id=" + reservationID, function (err, results) {
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




// ####### Utility function to generate reservation key ##########
function generateReservationKey() {
  var result = '';
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  var charactersLength = characters.length;
  for (var i = 0; i < 6; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

module.exports = router;