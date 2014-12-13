var exec = require('cordova/exec');



var jazzitnotification = function() {

	this.goHome = function(successCallback, failureCallback) {
		exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goHome', []);
	};
	
	this.goBackground = function(successCallback, failureCallback) {
		exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goBackground', []);
	};
	
	this.showMessage = function(successCallback, failureCallback, notificationId, options) {
	  if (notificationId == '') {
	      notificationId = Math.floor(Math.random()*10000000000).toString();
	  }
	  exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'showMessage', [notificationId, options]);
	};
	
	this.storeFile : function(successCallback, failureCallback, options) {
		exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'storeFile', [options]);
	};
	
	
	this.openFile = function(successCallback, failureCallback, options) {
		
		exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'openFile', [options]);
	};
	
	this.retrieveAndShowFile = function(successCallback, failureCallback, options) {
	  exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'retrieveAndShowFile', [options]);
	};
	
};

module.exports = jazzitnotification;