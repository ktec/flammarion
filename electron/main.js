// Generated by CoffeeScript 1.9.0
(function() {
  var BrowserWindow, app;

  app = require('app');

  BrowserWindow = require('browser-window');

  require('crash-reporter').start();

  app.on('ready', function() {
    var main_window;
    main_window = new BrowserWindow({
      width: 800,
      height: 600,
      "node-integration": false
    });
    main_window.loadUrl("http://localhost:4567");
    return main_window.openDevTools();
  });

}).call(this);