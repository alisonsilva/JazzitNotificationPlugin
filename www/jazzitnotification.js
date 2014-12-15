var exec = require('cordova/exec');


module.exports = {

    goHome : function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goHome', []);
    },
    goBackground: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goBackground', []);
    },
    showMessage : function(successCallback, failureCallback, notificationId, options) {
        if (notificationId == '') {
            notificationId = Math.floor(Math.random()*10000000000).toString();
        }
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'showMessage', [notificationId, options]);
    },
    storeFile : function(successCallback, failureCallback, options) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'storeFile', [options]);
    },
    openFile : function(successCallback, failureCallback, options) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'openFile', [options]);
    },
    retrieveAndShowFile : function(successCallback, failureCallback, options) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'retrieveAndShowFile', [options]);
    },
    
    /**
     * Immediately cancels any currently running vibration.
     */
    exibirMensagem: function() {
        exec(null, null, "JazzitTest", "exibirMensagem", []);
    }
};

