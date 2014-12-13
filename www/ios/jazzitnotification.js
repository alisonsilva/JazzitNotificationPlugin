var exec = require('cordova/exec');

/**
 * Constructor
 */
function LSJAsset() {}


LSJAsset.prototype.goHome = function(successCallback, failureCallback) {
	exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goHome', []);
}

LSJAsset.prototype.goBackground = function(successCallback, failureCallback) {
	exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goBackground', []);
}

LSJAsset.prototype.showMessage = function(successCallback, failureCallback, notificationId, options) {
        if (notificationId == '') {
            notificationId = Math.floor(Math.random()*10000000000).toString();
        }
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'showMessage', [notificationId, options]);
}

LSJAsset.prototype.storeFile : function(successCallback, failureCallback, options) {
	exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'storeFile', [options]);
}


LSJAsset.prototype.openFile = function(successCallback, failureCallback, options) {	
	exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'openFile', [options]);
}

LJSAsset.prototype.retrieveAndShowFile = function(successCallback, failureCallback, options) {
 exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'retrieveAndShowFile', [options]);
}
	

var jazzitnotification = new LJSAsset();
module.exports = jazzitnotification;