package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import androidx.preference.PreferenceManager
import java.util.Locale


object PreferenceUtils {
    fun updateAppLanguage(languageCode: String, context: Context) {
        val locale = Locale(languageCode)

        val appContext = context.applicationContext

        val resources = appContext.resources
        val configuration = resources.configuration

        // For API 24 and above, we can use setLocale directly
        configuration.setLocale(locale)
        Locale.setDefault(locale)

        // Save the selected language preference
        val sharedPreferences: SharedPreferences =
            PreferenceManager.getDefaultSharedPreferences(appContext)
        val editor = sharedPreferences.edit()
        editor.putString("app_language", languageCode)
        editor.apply()

        // Restart the app to apply the new language
        val intent = Intent(appContext, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
        appContext.startActivity(intent)
    }

    fun getAppVersion(context: Context): String {
        return try {
            val packageInfo: PackageInfo =
                context.packageManager.getPackageInfo(context.packageName, 0)

            packageInfo.versionName
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
            "0.0"
        }

    }

}