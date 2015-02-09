var exec = require('cordova/exec');


module.exports = {

    jazzGoHome : function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goHome', []);
    },
    jazzGoBackground: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goBackground', []);
    },
    jazzShowMessage : function(successCallback, failureCallback, notificationId, options) {
        if (notificationId == '') {
            notificationId = Math.floor(Math.random()*10000000000).toString();
        }
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'showMessage', [notificationId, options]);
    },
    jazzStoreFile : function(successCallback, failureCallback, options) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'storeFile', [options]);
    },
    jazzOpenFile : function(successCallback, failureCallback, options) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'openFile', [options]);
    },
    jazzRetrieveAndShowFile : function(successCallback, failureCallback, options) {
        exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'retrieveAndShowFile', [options]);
    },
    
    /**
     * Immediately cancels any currently running vibration.
     */
    jazzExibirMensagem: function() {
        exec(null, null, "JazzitNotificationPlugin", "exibirMensagem", []);
    }
};

