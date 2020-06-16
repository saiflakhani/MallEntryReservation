var express = require('express');
var moment = require('moment');
var router = express.Router();
var db_con = require('../db/db_connection').connection;
var INITIAL_SLOTS = 200;
var TIME_SLOTS = ['midday', 'afternoon', 'evening', 'late_evening'];
var async_query_day_count = 0; // variable to keep track of async function inside query;


/**
 * @swagger
 * definitions:
 *   Slot:
 *     properties:
 *       midday:
 *         type: integer
 *       afternoon:
 *         type: integer
 *       evening:
 *         type: integer
 *       late_evening:
 *         type: integer
 *         
 */


/**
 * @swagger
 * /slots/get_week:
 *   get:
 *     tags:
 *       - Slots
 *     summary: Get all available slots for the coming week, starting with today, array[0]
 *     description: Get all available slots for the coming week
 *     produces:
 *       - application/json
 *     responses:
 *       200:
 *         description: An array of slots
 *         schema:
 *           $ref: '#/definitions/Slot'
 */
router.get("/get_week", function (req, res) {
    // array to return
    var response = [];
    //first initialise the slots for a particular day
    var midday = INITIAL_SLOTS, afternoon = INITIAL_SLOTS, evening = INITIAL_SLOTS, late_evening = INITIAL_SLOTS;
    var today = new Date();
    var async_query_day_count = 0;
    for (var dayCount = 0; dayCount < 7; dayCount++) {
        //get the current date
        
        var ms = new Date().getTime() + (86400000 * dayCount);
        var nextDay = new Date(ms);

        var beginDate = new Date(nextDay.setHours(0, 0, 0, 0));
        var endDate = new Date(nextDay.setHours(23,59,59,999));

        var begin = moment(beginDate).format().slice(0, 19).replace('T', ' ');
        var end = moment(endDate).format().slice(0, 19).replace('T', ' ');
        
        
        

        var db_query = "SELECT timeslot FROM reservation WHERE reservation_date BETWEEN '" + begin + "' AND '" + end + "';";
        //console.log(db_query);
        db_con.query(db_query, function (err, results) {
            midday = INITIAL_SLOTS, afternoon = INITIAL_SLOTS, evening = INITIAL_SLOTS, late_evening = INITIAL_SLOTS;
            if (err) {
                res.status(500)
                    .json({
                        status: 'failure',
                        message: 'There was an error getting this slots list',
                        error: err
                    });
            }
            var daySlots = new Object();
            results.forEach(element => {
                switch(element['timeslot']){
                    case 'midday': midday = midday - 1;
                    break;
                    case 'afternoon': afternoon = afternoon - 1;
                    break;
                    case 'evening': evening = evening - 1;
                    break;
                    case 'late_evening': late_evening -= 1;
                    break;
                }
            });

            var ms = new Date().getTime() + (86400000 * async_query_day_count++);
            daySlots.date = moment(new Date(ms)).format();
            daySlots.midday = midday;
            daySlots.afternoon = afternoon;
            daySlots.evening = evening;
            daySlots.late_evening = late_evening;
            response.push(daySlots);
            if(response.length == 7){
                res.status(200).json(response);
            }
        });
    }
});


function addDays(date, days) {
    var result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
}


// Asynchronous function to get count of timeslot from database
function getCountOfTimeslot(begin, end, timeslot, callback) {
    var db_query = "SELECT COUNT(timeslot) FROM reservation WHERE reservation_date BETWEEN '" + begin + "' AND '" + end + "' AND timeslot = '" + TIME_SLOTS[timeslot] + "';";
    var countOfTimeslot = 0;
    console.log(db_query);
    db_con.query(db_query, function (err, results) {
        if (err) {
            res.status(500)
                .json({
                    status: 'failure',
                    message: 'There was an error getting this slots list',
                    error: err
                });
        }
        countOfTimeslot = results[0]['COUNT(timeslot)'];
        console.log("Count >> "+countOfTimeslot);
        return callback(countOfTimeslot);
    });
}

module.exports = router;