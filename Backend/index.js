var express = require('express');
var app = express();
var router = express.Router();
var path = require('path');
var reservation = require('./routes/reservation');
var person = require('./routes/person');
var slot = require('./routes/slots');
var cors = require('cors');
var swaggerJSDoc = require('swagger-jsdoc');
var cookieParser = require('cookie-parser');
var port = process.env.PORT || 3000;

// ############ Define Swaggger API ####################
var swaggerDefinition = {
  info: {
    title: 'Node Swagger API',
    version: '1.0.0',
    description: 'Demonstrating how to describe a RESTful API with Swagger',
  },
  host: 'calm-shore-97363.herokuapp.com',
  basePath: '/',
};

// ############## Options for the Swagger API ###############
var options = {
  // import swaggerDefinitions
  swaggerDefinition: swaggerDefinition,
  // path to the API docs
  apis: ['./routes/*.js'],
};

var options = {
  // import swaggerDefinitions
  swaggerDefinition: swaggerDefinition,
  // path to the API docs
  apis: ['./routes/*.js'],
};

// initialize swagger-jsdoc
var swaggerSpec = swaggerJSDoc(options);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//define the routes
app.use('/reservations', reservation);
app.use('/persons', person);
app.use('/slots', slot);

app.get('/', function (req, res) {
  res.send('Hello World!');
});

// serve swagger
app.get('/swagger.json', function(req, res) {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

//serve the app

app.listen(port, function () {
  console.log('Example app listening on port 3000!');
});