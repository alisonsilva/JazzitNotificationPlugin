package br.com.laminarsoft.jazzitnotification;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class NotificationReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		JazzitNotificationPlugin.handleNotificationAction(context, intent);
	}

}
