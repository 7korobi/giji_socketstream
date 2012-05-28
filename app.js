// My SocketStream app

var http = require('http')
  , ss = require('socketstream');

// Define a single-page client
ss.client.define('trpg', {
  view: 'trpg.jade',
  code: ['app'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/trpg', function(req, res){
  res.serveClient('trpg');
})

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

redis_db = {host: 'utage.sytes.net', port: 6379, db: 3}
ss.session.store.use(    "redis", redis_db);
ss.publish.transport.use('redis', redis_db);

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env == 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

// Start SocketStream
ss.start(server);