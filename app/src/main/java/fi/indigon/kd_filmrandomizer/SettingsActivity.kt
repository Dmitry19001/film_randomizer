package fi.indigon.kd_filmrandomizer

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.ListPreference
import androidx.preference.PreferenceFragmentCompat

class SettingsActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.settings_activity)
        if (savedInstanceState == null) {
            supportFragmentManager
                .beginTransaction()
                .replace(R.id.settings, SettingsFragment())
                .commit()
        }
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
    }

    class SettingsFragment : PreferenceFragmentCompat() {
        override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
            setPreferencesFromResource(R.xml.root_preferences, rootKey)

            val languagePreference = findPreference<ListPreference>("app_language")

            languagePreference?.let {
                it.summary = it.value

                it.setOnPreferenceChangeListener { _, newValue ->
                    val selectedLanguage = newValue.toString()
                    it.summary = selectedLanguage

                    updateAppLanguage(selectedLanguage, requireContext())
                    true
                }
            }
        }

    }
}