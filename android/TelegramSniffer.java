package org.telegram;

import android.content.Context;
import android.util.Log;
import android.util.Pair;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.telegram.tgnet.TLObject;
import org.telegram.tgnet.TLRPC;

import java.lang.reflect.Field;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Random;

/*
 how to use:
 1- add implementation 'org.java-websocket:Java-WebSocket:1.5.1' to build.gradle
 2- copy TelegramRequestSniffer.java to your project
 3- edit serverUrl if you want to use on real device
 4- edit clientId and add a random or unique id like ali-alavi
 5- select serverUrl or emulatorUrl in getEndPoint() function
 6- call TelegramRequestSniffer.init() inside ApplicationLoader.postInitApplication() function in telegram source code.
 7- also for destroy connection inside onTerminate function of ApplicationLoader call disconnectWebSocket() function
 8- use methods logTLRPCObject where you need.
     - inside MessagesController.java -> processUpdates()
     - inside ConnectionManager.java -> sendRequestInternal()
 9- use method logRemoteMessage inside FirebaseMessagingService -> onMessageReceived()
*/

public class TelegramRequestSniffer {

    private static final String TAG = "TelegramRequestSniffer";
    private static WebSocketClient webSocketClient;

    // TODO: Replace with your actual server URL
    // For emulator: ws://10.0.2.2:3000/ws
    // For real device: ws://YOUR_COMPUTER_IP:3000/ws
    // For production: wss://your-server.com/ws
    private static String serverUrl = "ws://10.0.2.2:3000/ws";

    // TODO: Set a unique client identifier for this device
    private static String clientId = "my-device-id";

    private static Context _context;
    private static TelegramRequestSniffer singleInstance = null;

    public static HashMap<String, String> maps = null;

    public static Random random = new Random();

    private static String getEndPoint() {
        return serverUrl;
    }

    public static TelegramRequestSniffer init(Context context) {
        // To ensure only one instance is created
        if (singleInstance == null) {
            maps = new HashMap<>();
            for (Class<?> targetClass : TLRPC.class.getDeclaredClasses()) {
                maps.put(targetClass.getName(), targetClass.getName());
            }
            singleInstance = new TelegramRequestSniffer();
            _context = context;
            connectWebSocket(getEndPoint());
        }
        return singleInstance;
    }

    public static void logTLRPCObject(final TLObject object, final String type, final int requestToken) {

        if (singleInstance == null) {
            throw new NullPointerException("TelegramRequestSniffer Not Init");
        }
        if (object != null) {
            String search = maps.get(object.getClass().getName());
            if (search != null) {
                ArrayList<Pair<String, String>> extraData = new ArrayList<>();
                extraData.add(new Pair("CLIENTID", clientId));
                extraData.add(new Pair("TYPE", type.toUpperCase()));
                extraData.add(new Pair("TOKEN", requestToken));
                extraData.add(new Pair("TIME", getCurrentTime()));
                extraData.add(new Pair("UUID", System.currentTimeMillis()+"_"+random.nextInt(9000) + 1000));
                JSONObject jsonObject = classToJsonObject(object, extraData);
                deliverLog(jsonObject.toString());
            } else {
                Log.i(TAG, "can not found class!");
            }
        }
    }

    private static void deliverLog(String json) {
        sendMessage(json);
    }

    private static JSONObject classToJsonObject(TLObject object, ArrayList<Pair<String, String>> extraData) {
        JSONObject jsonObject = new JSONObject();
        try {
            // add extra values like type and token
            if (extraData != null) {
                for (Pair<String, String> data : extraData) {
                    jsonObject.put(data.first, data.second);
                }
            }
            // add class name
            jsonObject.put("CLASS_NAME", object.getClass().getSimpleName());
            // add fields
            Field[] fields = object.getClass().getFields();
            for (Field field : fields) {
                field.setAccessible(true);
                String name = field.getName();
                try {
                    Object value = field.get(object);
                    if (value != null) {
                        String search = maps.get(value.getClass().getName());
                        boolean isTlrpc = search != null;
                        if (isTlrpc) {
                            TLObject valueObject = (TLObject) value;
                            JSONObject childObject = classToJsonObject(valueObject, null);
                            jsonObject.put(name, childObject);
                        } else {
                            if (name.equals("constructor")) {
                                String hex = Integer.toHexString((Integer) value);
                                jsonObject.put(name, hex);
                            } else {
                                // its may be array
                                if (value instanceof ArrayList && ((ArrayList<?>) value).size() > 0) {
                                    JSONArray jsonArray = new JSONArray();
                                    for (Object item : (ArrayList<?>) value) {
                                        boolean isTlObject = maps.get(item.getClass().getName()) != null;
                                        if (isTlObject) {
                                            TLObject go = (TLObject) item;
                                            JSONObject childObject = classToJsonObject(go, null);
                                            jsonArray.put(childObject);
                                        } else {
                                            jsonArray.put(item.toString());
                                        }
                                    }
                                    jsonObject.put(name, jsonArray);
                                } else {
                                    // it may be an object
                                    jsonObject.put(name, value);
                                }
                            }
                        }
                    }


                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        return jsonObject;

    }

    private static void connectWebSocket(String serverUrl) {

        if (webSocketClient != null && webSocketClient.isOpen()) {
            Log.d(TAG, "WebSocket is already connected");
            return;
        }

        URI uri;
        try {
            uri = new URI(serverUrl);
        } catch (URISyntaxException e) {
            e.printStackTrace();
            return;
        }

        webSocketClient = new WebSocketClient(uri) {
            @Override
            public void onOpen(ServerHandshake handshake) {
                Log.d(TAG, "WebSocket connection opened");
            }

            @Override
            public void onMessage(String message) {
                Log.d(TAG, "Received message: " + message);
            }

            @Override
            public void onClose(int code, String reason, boolean remote) {
                Log.d(TAG, "WebSocket connection closed");

                // Reconnect if the connection is lost
                if (remote) {
                    connectWebSocket(serverUrl);
                }
            }

            @Override
            public void onError(Exception ex) {
                Log.e(TAG, "WebSocket error: " + ex.getMessage());
            }
        };

        webSocketClient.connect();
    }

    public static void sendMessage(String message) {
        if (webSocketClient != null && webSocketClient.isOpen()) {
            webSocketClient.send(message);
        } else {
            Log.e(TAG, "WebSocket is not connected");
        }
    }

    public static void disconnectWebSocket() {
        if (webSocketClient != null) {
            Log.d(TAG, "disconnectWebSocket");
            webSocketClient.close();
        }
    }

    public static String getCurrentTime() {
        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String currentDateTime = sdf.format(calendar.getTime());
        return currentDateTime;
    }

}

/*
inside ConnectionManager add TelegramRequestSniffer.logTlRPCObject at first and also hande answer like :

Utilities.stageQueue.postRunnable(() -> {
        if (onComplete != null) {
->            TelegramRequestSniffer.logTLRPCObject(finalResponse, "RESPONSE", requestToken);
->            if (finalError!=null){
->                TelegramRequestSniffer.logTLRPCObject(finalError, "ERROR", requestToken);
->            }
            onComplete.run(finalResponse, finalError);
        } else if (onCompleteTimestamp != null) {
            onCompleteTimestamp.run(finalResponse, finalError, timestamp);
        }
        if (finalResponse != null) {
            finalResponse.freeResources();
        }
    });
 */
