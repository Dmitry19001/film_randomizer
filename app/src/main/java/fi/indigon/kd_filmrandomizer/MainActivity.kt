package fi.indigon.kd_filmrandomizer

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.ListView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : LocalizedActivity() {
    //class MainActivity : ComponentActivity(){
    private lateinit var filmActivity: ActivityResultLauncher<Intent>
    private lateinit var loadingDialog: LoadingDialog

    private val filmList = mutableListOf<Film>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        //region TODO COMPOSE MIGRATION
        // TODO FULL MIGRATE TO COMPOSE NEEDS PARTIAL REWRITE OF CODE
        //        setContent {
        //            MainLayout()
        //        }
        //endregion

        val filmAdapter = FilmListAdapter(this, filmList) // Replace with your data source

        loadingDialog = LoadingDialog(this)

        // On addNewFilm or editFilm activity close
        filmActivity =
            registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { _ ->
                // Requesting new data
                requestFilms(filmAdapter)

                // Clearing singleton data
                DataHolder.clearData()
            }

        setupFilmAdapterCallbacks(filmAdapter)

        // Initializing ListView and its Adapter
        val listView = findViewById<ListView>(R.id.filmList)

        // Requesting data
        requestFilms(filmAdapter)

        // Initializing buttons
        initButtons(filmAdapter)

        listView.adapter = filmAdapter
    }

    private fun setupFilmAdapterCallbacks(filmAdapter: FilmListAdapter) {
        filmAdapter.setOnFilmDeleteListener { film ->
            val restClient = RestClient(this)

            loadingDialog.show()

            lifecycleScope.launch(Dispatchers.Main) {
                val (isDone, responseCode) = restClient.postFilmData(film, APIAction.DELETE)
                if (isDone) {
                    println("SUCCESS TO DELETE $film")
                    requestFilms(filmAdapter)
                } else {
                    println("ERROR TO DELETE $responseCode $film")
                }
            }
        }

        filmAdapter.setOnFilmEditListener { film, watchedOnly ->
            if (watchedOnly) {
                // Loading dialog
                loadingDialog.show()

                // Marking film watched
                film.markWatched()

                // Sending data
                val restClient = RestClient(this)
                lifecycleScope.launch(Dispatchers.Main) {
                    val (isDone, responseCode) = restClient.postFilmData(film, APIAction.EDIT)

                    // TODO handle response
                    loadingDialog.dismiss()
                }

                requestFilms(filmAdapter)

                return@setOnFilmEditListener
            }

            val intent = Intent(this, EditFilmActivity::class.java)
            intent.putExtra("EXTRA_FILM", film)
            filmActivity.launch(intent)
        }
    }

    private fun requestFilms(filmAdapter: FilmListAdapter) {
        loadingDialog.show()

        val restClient = RestClient(this)

        lifecycleScope.launch(Dispatchers.Main) {
            restClient.getFilmsData { json ->
                // Process the JSON data here
                if (json == null) {
                    loadingDialog.dismiss()
                    return@getFilmsData
                }

                filmList.clear()
                filmList.addAll(FilmUtils.jsonToFilms(json))

                filmAdapter.notifyDataSetChanged()
                loadingDialog.dismiss()
            }
        }
    }

    private fun initButtons(filmAdapter: FilmListAdapter) {
        // ADD NEW FILM BUTTON
        val buttonAddNewFilm = findViewById<Button>(R.id.buttonAddNew)
        buttonAddNewFilm.setOnClickListener {
            val intent = Intent(this, AddNewFilmActivity::class.java)
            filmActivity.launch(intent)
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
            requestFilms(filmAdapter)
        }

        // RANDOMIZER BUTTON
        val buttonRandom = findViewById<Button>(R.id.buttonRandom)
        buttonRandom.setOnClickListener {
            // Setting up singleton data before opening new activity
            DataHolder.setFilmArray(filmList.toTypedArray())

            val intent = Intent(this, RandomizerActivity::class.java)
            this.startActivity(intent)
        }
    }
}
