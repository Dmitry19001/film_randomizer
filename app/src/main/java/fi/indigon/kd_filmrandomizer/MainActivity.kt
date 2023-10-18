package fi.indigon.kd_filmrandomizer

import FilmListAdapter
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ListView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.Locale

//0 genre_comedy,
//1 genre_drama,
//2 genre_action,
//3 genre_documentary,
//4 genre_musical,
//5 genre_romance,
//6 genre_science_fiction,
//7 genre_crime,
//8 genre_fantasy
//9 genre_thriller

val FilmList = mutableListOf<Film>()

class MainActivity : AppCompatActivity() {

    @OptIn(DelicateCoroutinesApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        loadLocalization()
        setContentView(R.layout.activity_main)

        val filmAdapter = FilmListAdapter(this, FilmList) // Replace with your data source
        val loadingOverlay = findViewById<FrameLayout>(R.id.loadingOverlay)

        toggleLoadingOverlay(loadingOverlay, true)

        // On add activity close
        addNewFilmActivity = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { _ ->
            // Reloading main activity to get new film list
            reloadMainActivity()
        }

        filmAdapter.setOnFilmDeleteListener { film ->
            val restClient = RestClient(this);

            toggleLoadingOverlay(loadingOverlay, true)

            GlobalScope.launch(Dispatchers.Main) {

                restClient.postFilmData(film, ApiAction.DELETE) { isSuccess, responseCode ->
                    if (isSuccess) {
                        println("SUCCESS TO DELETE $film")
                        reloadMainActivity()
                    } else {
                        println("ERROR TO DELETE $responseCode $film")
                    }
                }
            }
        }

        // Initializing ListView and its Adapter
        val listView = findViewById<ListView>(R.id.filmList)

        val restClient = RestClient(this);
        GlobalScope.launch(Dispatchers.Main) {
            requestFilms(restClient, filmAdapter, loadingOverlay)
        }

        // Initializing buttons
        initButtons()

        listView.adapter = filmAdapter
    }

    private fun reloadMainActivity() {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
        startActivity(intent)
        finish()
    }

    private fun toggleLoadingOverlay(loadingOverlay: View, state: Boolean) {
        if (state){
            loadingOverlay.visibility = View.VISIBLE

            window.setFlags(
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
        }
        else {
            loadingOverlay.visibility = View.GONE

            window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        }

    }


    private suspend fun requestFilms(restClient: RestClient, filmAdapter: FilmListAdapter, loadingOverlay : View) {
        restClient.getFilmsData { data ->
            // Process the JSON data here
            if (data == null){
                return@getFilmsData
            }

            FilmList.clear()
            FilmList.addAll(jsonToFilms(data))

            filmAdapter.notifyDataSetChanged()
            toggleLoadingOverlay(loadingOverlay, false)
        }
    }

    private fun loadLocalization() {
        // Get the selected language from SharedPreferences
        val sharedPreferences: SharedPreferences =
            PreferenceManager.getDefaultSharedPreferences(this)
        val selectedLanguage = sharedPreferences.getString("app_language", "ru") ?: "ru"
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
    }
}
