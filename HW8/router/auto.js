var express = require('express');
var router = express.Router();
var path = require('path');
path = path.resolve(__dirname);

router.post("/location",function(req,res){
    
    const http = require('http');
    var input = req.query.zip;
    
    http.get('http://api.geonames.org/postalCodeSearchJSON?postalcode_startsWith='+input+'&username=XXXXXX&country=US&maxRows=5', (resp) => {
    let data = '';

    // A chunk of data has been recieved.
    resp.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received. Print out the result.
    resp.on('end', () => {
        var zips = [];
        JSON.parse(data).postalCodes.forEach(function(item) {
            zips.push(item.postalCode);
        });
        console.log
        res.send(zips);
    });
})
    .on("error", (err) => {
        console.log("Error: " + err.message);
    });
});


module.exports = router;