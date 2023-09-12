package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.preference.PreferenceManager
import java.util.Locale

fun updateAppLanguage(languageCode: String, context: Context) {
    val locale = Locale(languageCode)

    val appContext = context.applicationContext

    val resources = appContext.resources
    val configuration = resources.configuration

    // For API 24 and above, we can use setLocale directly
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
        configuration.setLocale(locale)
        Locale.setDefault(locale)
    } else {
        // For older versions, use the deprecated locale-related methods
        configuration.locale = locale
    }

    // Update the app's resources
    val displayMetrics = resources.displayMetrics
    val context = appContext.createConfigurationContext(configuration)
    val updatedResources = context.resources

    // Save the selected language preference
    val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(appContext)
    val editor = sharedPreferences.edit()
    editor.putString("app_language", languageCode)
    editor.apply()

    // Restart the app to apply the new language
    val intent = Intent(appContext, MainActivity::class.java)
    intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    appContext.startActivity(intent)
}