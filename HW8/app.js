var express = require('express');
var app = express();
var port = process.env.PORT || 8081;
var router = express.Router();

app.use(express.static('public')); 

app.use(require('./router/index'));
app.use(require('./router/auto'));
app.use(require('./router/search'));

app.listen(port, function() { console.log('Server running at port:' + port + '/'); });