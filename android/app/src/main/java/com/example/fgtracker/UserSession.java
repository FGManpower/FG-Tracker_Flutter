package com.example.fgtracker;

import android.content.Context;

public class UserSession {

    private static final String PREF = "walkie";

    public static void saveUserId(Context c, String userId) {
        c.getSharedPreferences(PREF, Context.MODE_PRIVATE)
                .edit()
                .putString("userId", userId)
                .apply();
    }

    public static String getUserId(Context c) {
        return c.getSharedPreferences(PREF, Context.MODE_PRIVATE)
                .getString("userId", null);
    }
}
