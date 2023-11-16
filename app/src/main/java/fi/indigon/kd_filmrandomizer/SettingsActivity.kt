package fi.indigon.kd_filmrandomizer

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.EditTextPreference
import androidx.preference.ListPreference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SwitchPreference

class SettingsActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)
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

            initLanguageSetting()

            initAppVersion()

            initWatchedFilterSetting()
        }

        private fun initWatchedFilterSetting() {
            val watchedFilterPreference = findPreference<SwitchPreference>("setting_watched_filter")

            watchedFilterPreference?.let { preference ->
                preference.setOnPreferenceChangeListener { _, newValue ->
                    // Ensure the new value is of type Boolean
                    if (newValue is Boolean) {
                        DataHolder.setFilterWatchedSetting(newValue)
                        true // Return true to update the state of the Preference with the new value.
                    } else {
                        false // Return false if the new value is not of the correct type.
                    }
                }
            }
        }

        private fun initAppVersion() {
            val currentVersion = PreferenceUtils.getAppVersion(requireContext())
            val versionPreference = findPreference<EditTextPreference>("app_version")

            // ENABLING DEV_MODE PREFERENCE
            if (currentVersion.contains("_DEBUG")){
                val devModePreference = findPreference<SwitchPreference>("setting_dev_mode")
                devModePreference?.let {
                    it.isVisible = true
                }
            }

            versionPreference?.let {
                it.title = currentVersion
            }
        }

        private fun initLanguageSetting() {
            val languagePreference = findPreference<ListPreference>("setting_app_language")

            languagePreference?.let {
                it.summary = it.value

                it.setOnPreferenceChangeListener { _, newValue ->
                    val selectedLanguage = newValue.toString()
                    it.summary = selectedLanguage

                    PreferenceUtils.updateAppLanguage(selectedLanguage, requireContext())
                    true
                }
            }
        }

    }
}