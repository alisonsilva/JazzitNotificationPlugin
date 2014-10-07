package br.com.laminarsoft.jazzitnotification;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

@SuppressWarnings("all")
public class JazzitNotificationPlugin extends CordovaPlugin{

    private static final String LOG_TAG = "JazzitNotification";
    private static final String NOTIFICATION_ID_LABEL = "notificationId";
    private static final String NOTIFICATION_ACTION_LABEL = "notificationAction";
    private static final String NOTIFICATION_BUTTON_INDEX_LABEL = "notificationButtonIndex";
    private static final String COMPONENT_NAME_LABEL = "componentName";
    private static final String NOTIFICATION_CLICKED_ACTION = "NOTIFICATION_CLICKED";
    private static final String NOTIFICATION_CLOSED_ACTION = "NOTIFICATION_CLOSED";
    private static final String NOTIFICATION_BUTTON_CLICKED_ACTION = "NOTIFICATION_BUTTON_CLICKED";

    private static CordovaWebView webView;
    private static boolean safeToFireEvents = false;
    private static List<EventInfo> pendingEvents = new ArrayList<EventInfo>();
    private NotificationManager notificationManager;
    private ExecutorService executorService;
    
    private CordovaInterface cordova;	
	
    private static class EventInfo {
        public String action;
        public String notificationId;
        public int buttonIndex;
        
        public EventInfo(String action, String notificationId, int buttonIndex) {
            this.action = action;
            this.notificationId = notificationId;
            this.buttonIndex = buttonIndex;
        }
    }    
    
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
        safeToFireEvents = false;
        this.cordova = cordova;
        notificationManager = (NotificationManager) cordova.getActivity().getSystemService(Context.NOTIFICATION_SERVICE);
        if (JazzitNotificationPlugin.webView == null &&
            NOTIFICATION_CLOSED_ACTION.equals(cordova.getActivity().getIntent().getStringExtra(NOTIFICATION_ACTION_LABEL))) {
            // In this case we are starting up the activity again in response to a notification being closed. We do not
            // want to interrupt the user by bringing the activity to the foreground in this case so move it to the
            // background.
            cordova.getActivity().moveTaskToBack(true);
        }
        JazzitNotificationPlugin.webView = webView;
        executorService = cordova.getThreadPool();        
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if ("goHome".equals(action)) {
			try {				
				Intent i = new Intent(Intent.ACTION_MAIN);
                i.addCategory(Intent.CATEGORY_HOME);
                this.cordova.getActivity().startActivity(i);
				
			} catch (Exception e) {
				Log.e(LOG_TAG, "Exception occurred: ".concat(e.getMessage()));
				return false;
			}
			callbackContext.success();
			return true;
		} else if("goBackground".equals(action)) {
            cordova.getActivity().moveTaskToBack(true);
        }
		Log.e(LOG_TAG, "Called invalid action: "+action);
		return false;  
	}	
	
}
