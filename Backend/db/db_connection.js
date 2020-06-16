var mysql = require('mysql');

var con = mysql.createConnection({
  host: "muowdopceqgxjn2b.cbetxkdyhwsb.us-east-1.rds.amazonaws.com",
  user: "b03eouybalox0j08",
  password: "h7tcwcb605r4trzb",
  database: "czw4zagmwznak0b0"
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected to database");
});

module.exports = {
    connection: con
}