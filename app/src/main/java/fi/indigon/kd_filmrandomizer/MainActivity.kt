package fi.indigon.kd_filmrandomizer

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.ListView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.preference.PreferenceManager
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Locale

val FilmList = mutableListOf<Film>()


//class MainActivity : ComponentActivity(){
class MainActivity : AppCompatActivity(){

    private lateinit var loadingDialog: LoadingDialog
    private var sheetURL = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sheetURL = PreferenceUtils.getGoogleSheetUrl(this)
        loadLocalization()

        setContentView(R.layout.activity_main)

// TODO FULL MIGRATE TO COMPOSE NEEDS PARTIAL REWRITE OF CODE
//        setContent {
//            MainLayout()
//        }

        val filmAdapter = FilmListAdapter(this, FilmList) // Replace with your data source

        loadingDialog = LoadingDialog(this)

        // On addNewFilm activity close
        addNewFilmActivity = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { _ ->
            // Requesting new data
            requestFilms(filmAdapter)
        }

        setupFilmAdapterCallbacks(filmAdapter)

        // Initializing ListView and its Adapter
        val listView = findViewById<ListView>(R.id.filmList)

        if (sheetURL.isNotEmpty()) {
            requestFilms(filmAdapter)
        }
        else {
            loadingDialog.dismiss()
            Snackbar.make(findViewById(R.id.MainLayout), getString(R.string.error_undefined_sheetUrl), Snackbar.LENGTH_SHORT)
                .show()
        }
        // Initializing buttons
        initButtons()

        listView.adapter = filmAdapter
    }

    private fun setupFilmAdapterCallbacks(filmAdapter: FilmListAdapter) {
        filmAdapter.setOnFilmDeleteListener { film ->
            val restClient = RestClient(this, sheetURL)

            loadingDialog.show()

            lifecycleScope.launch(Dispatchers.Main) {
                val (isDone, responseCode) = restClient.postFilmData(film, APIAction.DELETE)
                if (isDone) {
                    println("SUCCESS TO DELETE $film")
                    reloadMainActivity()
                } else {
                    println("ERROR TO DELETE $responseCode $film")
                }
            }
        }

        filmAdapter.setOnFilmEditListener { film, watchedOnly ->
            if (watchedOnly){
                // Loading dialog
                loadingDialog.show()

                // Marking film watched
                film.markWatched()

                // Sending data
                val restClient = RestClient(this, sheetURL)
                lifecycleScope.launch(Dispatchers.Main) {
                    val (isDone, responseCode) = restClient.postFilmData(film, APIAction.EDIT)

                    // TODO handle response
                    loadingDialog.dismiss()
                }

                requestFilms(filmAdapter)

                return@setOnFilmEditListener
            }

            val intent = Intent(this, EditFilmActivity::class.java)
            startActivity(intent)
        }
    }

    private fun reloadMainActivity() {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
        startActivity(intent)
        finish()
    }


    private fun requestFilms(filmAdapter: FilmListAdapter) {
        loadingDialog.show()

        val restClient = RestClient(this, sheetURL)

        lifecycleScope.launch(Dispatchers.Main) {
            restClient.getFilmsData { json ->
                // Process the JSON data here
                if (json == null){
                    loadingDialog.dismiss()
                    return@getFilmsData
                }

                FilmList.clear()
                FilmList.addAll(FilmUtils.jsonToFilms(json))

                filmAdapter.notifyDataSetChanged()
                loadingDialog.dismiss()
            }
        }
    }

    private fun loadLocalization() {
        // Get the selected language from SharedPreferences
        val sharedPreferences: SharedPreferences =
            PreferenceManager.getDefaultSharedPreferences(this)
        val selectedLanguage = sharedPreferences.getString("setting_app_language", "ru") ?: "ru"
        val locale = Locale(selectedLanguage)
        Locale.setDefault(locale)
    }

    private lateinit var addNewFilmActivity: ActivityResultLauncher<Intent>

    private fun initButtons() {
        // ADD NEW FILM BUTTON
        val buttonAddNewFilm = findViewById<Button>(R.id.buttonAddNew)
        buttonAddNewFilm.setOnClickListener {
            val intent = Intent(this, AddNewFilmActivity::class.java)
            addNewFilmActivity.launch(intent)
        }

        // BUTTON SETTINGS
        val buttonSettings = findViewById<Button>(R.id.buttonSettings)
        buttonSettings.setOnClickListener {
            val intent = Intent(this, SettingsActivity::class.java)
            this.startActivity(intent)
        }

        // SYNC BUTTON
        val buttonSync = findViewById<Button>(R.id.buttonSync)
        buttonSync.setOnClickListener {
            reloadMainActivity()
        }

        // RANDOMIZER BUTTON
        val buttonRandom = findViewById<Button>(R.id.buttonRandom)
        buttonRandom.setOnClickListener {
            val intent = Intent(this, RandomizerActivity::class.java)
            this.startActivity(intent)
        }
    }
}
