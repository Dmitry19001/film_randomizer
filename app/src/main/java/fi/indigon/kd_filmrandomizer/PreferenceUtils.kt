package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.util.Log
import androidx.preference.PreferenceManager

object PreferenceUtils {
    private const val PREF_KEY_SHEET_URL = "setting_sheet_url"

    fun getGoogleSheetUrl(context: Context): String {
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
        val url = sharedPreferences.getString(PREF_KEY_SHEET_URL, "") ?: ""
        if (url.isNotEmpty()) {
            Log.d("PreferenceUtils", "URL FOUND: $url")
        } else {
            Log.d("PreferenceUtils", "No URL found in SharedPreferences.")
        }
        return url
    }
}