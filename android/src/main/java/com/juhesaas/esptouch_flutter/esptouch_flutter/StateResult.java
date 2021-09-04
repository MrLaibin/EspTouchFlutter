package com.juhesaas.esptouch_flutter.esptouch_flutter;

import java.net.InetAddress;

public class StateResult {
    public CharSequence message = null;

    public boolean permissionGranted = false;

    public boolean locationRequirement = false;

    public boolean wifiConnected = false;
    public boolean is5G = false;
    public InetAddress address = null;
    public String ssid = null;
    public byte[] ssidBytes = null;
    public String bssid = null;
}