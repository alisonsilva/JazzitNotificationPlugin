package br.com.laminarsoft.jazzitnotification;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutorService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.CordovaWebView;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.location.LocationManager;
import android.location.Location;
import android.os.Environment;
import android.support.v4.app.NotificationCompat;
import android.support.v4.content.IntentCompat;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

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
    
    private static final String RAIZ_CHAMADA_ANEXO = "http://tjdf199.tjdft.jus.br/jazzforms/servicos/mensagemService/mensagem/anexoMensagemUsuario/";

    private static CordovaWebView webView;
    private static boolean safeToFireEvents = false;
    private static List<EventInfo> pendingEvents = new ArrayList<EventInfo>();
    private NotificationManager notificationManager;
    private ExecutorService executorService;
	
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
            this.cordova.getActivity().moveTaskToBack(true);
			callbackContext.success();
			return true;
        } else if("retrieveAndShowFile".equals(action)) {
        	JSONObject options = args.getJSONObject(0);
        	final String usuario = options.getString("usuario");
        	final String senha = options.getString("senha");
        	final String idMensagem = options.getString("idMensagem");
        	final String nomeArquivo = options.getString("nomeArquivo");
        	final String type = options.getString("type");
        	final Activity cordActivity = cordova.getActivity();
        	
        	Resources resources = cordova.getActivity().getResources();
        	
    		String externalDirectory = Environment.getExternalStorageDirectory().toString();
    		String meuArquivo = externalDirectory + "/jazzit/" + nomeArquivo;
    		File myFolder = new File(meuArquivo);
			if(myFolder.exists()) {
				exibeArquivo(nomeArquivo, type);
			} else if(isOnline()) {
				final ProgressDialog progress = ProgressDialog.show(cordActivity, "Carregando ...", "Carregando anexo", true);
				new Thread(new Runnable() {
					
					@Override
					public void run() {

	                    HttpClient httpclient = new DefaultHttpClient();
			    		String url = RAIZ_CHAMADA_ANEXO + idMensagem + "/" + usuario;
			    		url += "?j_username=" + usuario + "&j_password=" + senha + "&timestamp="+ (new Date()).getTime();
			    		
			    		HttpGet httpGet = new HttpGet(url);
			    		
			    		try {
			    			httpGet.addHeader("Accept", "application/xml");
			    			HttpResponse response = httpclient.execute(httpGet);    			
			    			org.apache.http.HttpEntity entity = response.getEntity();
			    			Serializer serializer = new Persister();
			    			ArquivoVO vo = serializer.read(ArquivoVO.class, entity.getContent());
			    			byte[] conteudo = Base64.decode(vo.arqAnexo, Base64.DEFAULT);
			    			
			    			escreveArquivo(vo.nomeArquivo, conteudo);
			    			exibeArquivo(vo.nomeArquivo, vo.type);
			    		} catch (UnsupportedEncodingException e) {
			    			Log.e(LOG_TAG, "Erro ao alterar encoding (JazzitNotificationPlutin): " + e.getMessage());
			    		} catch (ClientProtocolException e) {			
			    			Log.e(LOG_TAG, "Erro de protocolo (JazzitNotificationPlutin): " + e.getMessage());
			    		} catch (IOException e) {			
			    			Log.e(LOG_TAG, "Erro de IO (JazzitNotificationPlutin): " + e.getMessage());
			    		} catch (Exception e) {    			
			    			Log.e(LOG_TAG, "Erro genérico (JazzitNotificationPlutin): " + e.getMessage());
			    		} finally {
			    			progress.dismiss();
			            }
					}
				}).start();
			} else if(!isOnline()) {
				Toast.makeText(cordActivity, "Não há conexão com a Internet no momento", Toast.LENGTH_LONG).show();
			}
        	
        	callbackContext.success();
        	return true;
        } else if ("storeFile".equals(action)) {
    		JSONObject options = args.getJSONObject(0);    		
            Resources resources = cordova.getActivity().getResources();
            Activity cordActivity = cordova.getActivity();
        	String fileName = options.getString("fileName");
        	String content = options.getString("conteudo");
        	byte[] conteudo = Base64.decode(content, Base64.DEFAULT);
        	
        	escreveArquivo(fileName, conteudo); 
			callbackContext.success();
			return true;        	
        } else if ("openFile".equals(action)) {
    		JSONObject options = args.getJSONObject(0);
            Resources resources = cordova.getActivity().getResources();
        	String fileName = options.getString("fileName");
        	String fileType = options.getString("fileType");
        	
            exibeArquivo(fileName, fileType);
        	
			callbackContext.success();
			return true;        	
        } else if("showMessage".equals(action)) {
        	boolean isInBackground = JazzitNotificationPlugin.isApplicationSentToBackground(cordova.getActivity());
        	if (isInBackground) {
        		String notificationId = args.getString(0);
        		JSONObject options = args.getJSONObject(1);
                Resources resources = cordova.getActivity().getResources();
                
                Bitmap largeIcon = makeBitmap(options.getString("iconUrl"),
                                              resources.getDimensionPixelSize(android.R.dimen.notification_large_icon_width),
                                              resources.getDimensionPixelSize(android.R.dimen.notification_large_icon_height));
                
                int smallIconId = resources.getIdentifier("notification_icon", "drawable", cordova.getActivity().getPackageName());
                if (smallIconId == 0) {
                    smallIconId = resources.getIdentifier("icon", "drawable", cordova.getActivity().getPackageName());
                }
                
                Intent viewIntent = new Intent(cordova.getActivity(), cordova.getActivity().getClass());
                viewIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                PendingIntent viewPendingIntent = PendingIntent.getActivity(cordova.getActivity(), PendingIntent.FLAG_CANCEL_CURRENT, viewIntent, 0);
                NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(cordova.getActivity())
                	.setSmallIcon(smallIconId)
                	.setContentTitle(options.getString("title"))
                	.setContentText(options.getString("message"))
                	.setPriority(5)
                	.setContentIntent(viewPendingIntent)
                	.setAutoCancel(true)
                	.setOngoing(true)
                	.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS);
                notificationBuilder.setOngoing(true);
                
                notificationManager.notify("notif_jazzit".hashCode(), notificationBuilder.build());
        	}
        	callbackContext.success();
			return true;
        }
		Log.e(LOG_TAG, "Called invalid action: "+action);
		return false;  
	}

	private void exibeArquivo(String fileName, String fileType) {
		Activity cordActivity = cordova.getActivity();
		String externalDirectory = Environment.getExternalStorageDirectory().toString();        	
		File file = new File(externalDirectory + "/jazzit/" + fileName);
		Intent target = new Intent(Intent.ACTION_VIEW);
		target.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
		target.setDataAndType(Uri.fromFile(file), fileType);
		Intent intent = Intent.createChooser(target, "Abrir arquivo");
		
		try {
			cordActivity.startActivity(intent);
		} catch (ActivityNotFoundException e) {
			Log.e(LOG_TAG, "Erro abrindo arquivo: " + e.getMessage());
			Toast.makeText(cordActivity, "Não foi possível abrir arquivo: " + e.getMessage(), Toast.LENGTH_LONG).show();
		}
	}
	
	public boolean isOnline() {
	    ConnectivityManager cm = (ConnectivityManager) cordova.getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo netInfo = cm.getActiveNetworkInfo();
	    return netInfo != null && netInfo.isConnectedOrConnecting();
	}	

	private void escreveArquivo(String fileName, byte[] conteudo) {
		String externalDirectory = Environment.getExternalStorageDirectory().toString();
		File myFolder = new File(externalDirectory, "jazzit");
		try {
			myFolder.mkdir();
			File newfile = new File(myFolder, fileName);
			newfile.createNewFile();
			FileOutputStream fous = new FileOutputStream(newfile);
			fous.write(conteudo);
			fous.flush();
			fous.close();
		} catch (FileNotFoundException e) {
			Log.e(LOG_TAG, "Erro criando arquivo: " + e.getMessage()); 
		} catch (IOException e) {
			Log.e(LOG_TAG, "Erro escrevendo arquivo: " + e.getMessage());
		}
	}	
	
	public static boolean isApplicationSentToBackground(final Context context) {
		ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
		List<RunningTaskInfo> tasks = am.getRunningTasks(1);
		if (!tasks.isEmpty()) {
			ComponentName topActivity = tasks.get(0).topActivity;
			if (!topActivity.getPackageName().equals(context.getPackageName())) {
				return true;
			}
		}

		return false;
	}
	
    private Bitmap makeBitmap(String imageUrl, int scaledWidth, int scaledHeight) {
        InputStream largeIconStream;
        try {
            Uri uri = Uri.parse(imageUrl);
            CordovaResourceApi resourceApi = webView.getResourceApi();
            uri = resourceApi.remapUri(uri);
            largeIconStream = resourceApi.openForRead(uri).inputStream;
        } catch (Exception e) {
            Log.e(LOG_TAG, "Failed to open image file " + imageUrl + ": " + e);
            return null;
        }
        Bitmap unscaledBitmap = BitmapFactory.decodeStream(largeIconStream);
        try {
            largeIconStream.close();
        } catch (Exception e) {
            Log.e(LOG_TAG, "Failed to close image file");
        }
        if (scaledWidth != 0 && scaledHeight != 0) {
            return Bitmap.createScaledBitmap(unscaledBitmap, scaledWidth, scaledHeight, false);
        } else {
            return unscaledBitmap;
        }
    }	
	
    public PendingIntent makePendingIntent(String action, String notificationId, int buttonIndex, int flags) {
    	Log.i(LOG_TAG, "making pending intent 1: " + cordova.getActivity() + ", " + cordova.getActivity().getIntent().getComponent());
        return makePendingIntent(cordova.getActivity(), cordova.getActivity().getIntent().getComponent(), action, notificationId, buttonIndex, flags);
    }
    
	public static PendingIntent makePendingIntent(Context context,	ComponentName componentName, String action, String notificationId,
			int buttonIndex, int flags) {
		Intent intent = new Intent(context, NotificationReceiver.class);
		String fullAction = context.getPackageName() + "." + action + "." + notificationId;
		if (buttonIndex >= 0) {
			fullAction += "." + buttonIndex;
		}
		intent.setAction(fullAction);
		Log.i(LOG_TAG, "making pending intent 2: " + componentName + ", " + fullAction);
		intent.putExtra(COMPONENT_NAME_LABEL, componentName);
		return PendingIntent.getBroadcast(context, 0, intent, flags);
	}
	
	public static void handleNotificationAction(Context context, Intent intent) {
        String[] strings = intent.getAction().substring(context.getPackageName().length() + 1).split("\\.", 3);
        Log.i(LOG_TAG, "Str strings: " + strings);
        for(String str : strings) {
        	Log.i(LOG_TAG, "Str : " + str);
        }
        int buttonIndex = strings.length >= 3 ? Integer.parseInt(strings[2]) : -1;
        triggerJavascriptEvent(context, (ComponentName) intent.getExtras().getParcelable(COMPONENT_NAME_LABEL), new EventInfo(strings[0], strings[1], buttonIndex));
    }
    
    private static void triggerJavascriptEventNow(Context context, ComponentName componentName, EventInfo eventInfo) {
        Intent intent = new Intent();
        intent.setComponent(componentName);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        if (NOTIFICATION_CLICKED_ACTION.equals(eventInfo.action)) {
            webView.sendJavascript("chrome.notifications.triggerOnClicked('" + eventInfo.notificationId + "')");
            context.startActivity(intent);
        } else if (NOTIFICATION_CLOSED_ACTION.equals(eventInfo.action)) {
            PendingIntent pendingIntent = makePendingIntent(context, componentName, NOTIFICATION_CLICKED_ACTION, eventInfo.notificationId, -1,
                                                            PendingIntent.FLAG_NO_CREATE);
            if (pendingIntent != null) {
                pendingIntent.cancel();
            }
            webView.sendJavascript("chrome.notifications.triggerOnClosed('" + eventInfo.notificationId + "')");
        } else if (NOTIFICATION_BUTTON_CLICKED_ACTION.equals(eventInfo.action)) {
            webView.sendJavascript("chrome.notifications.triggerOnButtonClicked('" + eventInfo.notificationId + "', " + eventInfo.buttonIndex + ")");
            context.startActivity(intent);
        }
    }

    private static void triggerJavascriptEvent(Context context, ComponentName componentName, EventInfo eventInfo) {
        if (webView == null) {
            // In this case the main activity has been closed and will need to be started up again in order to execute
            // the appropriate event handler.
            Intent intent = IntentCompat.makeMainActivity(componentName);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(NOTIFICATION_ACTION_LABEL, eventInfo.action);
            intent.putExtra(NOTIFICATION_ID_LABEL, eventInfo.notificationId);
            if (eventInfo.buttonIndex >= 0) {
                intent.putExtra(NOTIFICATION_BUTTON_INDEX_LABEL, eventInfo.buttonIndex);
            }
            pendingEvents.add(eventInfo);
            context.startActivity(intent);
            return;
        } else if (!safeToFireEvents) {
            // In this case the activity has been started up but initialization has not completed so the javascript is not
            // yet ready to run event handlers, so queue the event until javascript is ready.
            pendingEvents.add(eventInfo);
            return;
        }
        // This is the "normal" case in which the main activity is still around and ready to execute event handlers
        // in javascript immediately. The activity may not necessarily be in the foreground so we still need to send
        // an intent that brings it to the foreground if the notification or a notification button was clicked.
        Log.i(LOG_TAG, "Triggering javascript event now");
        triggerJavascriptEventNow(context, componentName, eventInfo);
    }

    private boolean doesNotificationExist(String notificationId) {
        return makePendingIntent(NOTIFICATION_CLICKED_ACTION, notificationId, -1, PendingIntent.FLAG_NO_CREATE) != null; 
    }	
}
