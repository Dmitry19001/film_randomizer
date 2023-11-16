package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
import java.util.Locale

open class LocalizedActivity : AppCompatActivity() {
    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(updateBaseContextLocale(newBase))
    }

    private fun updateBaseContextLocale(context: Context): Context {
        val sharedPreferences: SharedPreferences =
            PreferenceManager.getDefaultSharedPreferences(context)
        val languageCode =
            sharedPreferences.getString("setting_app_language", Locale.getDefault().language)
                ?: Locale.getDefault().language
        val locale = Locale(languageCode)
        Locale.setDefault(locale)

        val config = context.resources.configuration.apply {
            setLocale(locale)
            setLayoutDirection(locale)
        }

        return context.createConfigurationContext(config)
    }
}