var express = require('express');
var router = express.Router();
var request = require('request');
var cdn_url = process.env.CDN_URL

var api_url = process.env.API_HOST + '/api/status';

/* GET home page. */
router.get('/', function(req, res, next) {
    request({
            method: 'GET',
            url: api_url,
            json: true
        },
        function(error, response, body) {
            if (error || response.statusCode !== 200) {
                return res.status(500).send('error running request to ' + api_url + ' error: ' + error);
            } else {
                res.render('index', {
                    title: '3tier App',
                    request_uuid: body[0].request_uuid,
                    time: body[0].time,
                    cdn: cdn_url
                });
            }
        }
    );
});

router.get('/status', function(req, res, next) {
    return res.status(200).send('success');
});

module.exports = router;