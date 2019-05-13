var express = require('express');
var router = express.Router();
var path = require('path');

path = path.resolve(__dirname + '/../public');

router.get("/index.html",function(req,res){
    res.sendFile(path + "/index.html");
});


module.exports = router;