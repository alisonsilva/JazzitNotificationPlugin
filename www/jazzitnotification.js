var jazzitnotification = {

    goHome: function(successCallback, failureCallback) {
        cordova.exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goHome', []);
    },
    goBackground: function(successCallback, failureCallback) {
        cordova.exec(successCallback, failureCallback, 'JazzitNotificationPlugin', 'goBackground', []);
    }
};

module.exports = jazzitnotification;