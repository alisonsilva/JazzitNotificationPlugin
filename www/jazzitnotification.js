var jazzitnotification = {

    goHome: function(successCallback, failureCallback) {
        cordova.exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goHome', []);
    },
    goBackground: function(successCallback, failureCallback) {
        cordova.exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goBackground', []);
    },
    showMessage : function(successCallback, failureCallback, notificationId, options) {
        if (notificationId == '') {
            notificationId = Math.floor(Math.random()*10000000000).toString();
        }
        cordova.exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'showMessage', [notificationId, options]);
    }
};

module.exports = jazzitnotification;