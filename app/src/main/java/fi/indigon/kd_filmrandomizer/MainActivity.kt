package fi.indigon.kd_filmrandomizer

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ListView
import android.widget.Spinner
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.isVisible
import androidx.preference.PreferenceManager
import com.google.android.material.snackbar.Snackbar
import java.util.Locale

val defaultFilmList = mutableListOf<Film>(
    Film("The Shawshank Redemption", 1),
    Film("The Godfather", 7),
    Film("The Dark Knight", 8),
    Film("Pulp Fiction", 7),
    Film("Fight Club", 7),
    Film("Forrest Gump", 1),
    Film("Inception", 6),
    Film("The Matrix", 6),
    Film("Gladiator", 2),
    Film("The Silence of the Lambs", 9),
    Film("Jurassic Park", 6),
    Film("Schindler's List", 2),
    Film("The Lord of the Rings",8),
    Film("Titanic", 8),
    Film("Star Wars", 6),
    Film("Avatar", 2),
    Film("The Avengers", 6),
    Film("The Lion King", 1),
    Film("E.T. the Extra-Terrestrial", 6),
    Film("The Terminator", 6)
)

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
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get the selected language from SharedPreferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val selectedLanguage = sharedPreferences.getString("app_language", "ru") ?: "ru"
        val locale = Locale(selectedLanguage)
        Locale.setDefault(locale)

        setContentView(R.layout.activity_main)

        val listView = findViewById<ListView>(R.id.filmList)
        val filmAdapter = FilmListAdapter(this, FilmList) // Replace with your data source

        val filmAddNewWindow = findViewById<LinearLayout>(R.id.filmAddNewWindow)
        val genreDropdown = findViewById<Spinner>(R.id.genreDropDown)

        // Custom TODO
        //val genreAdapter = GenresListAdapter(this, getGenres(this))

        val genreAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, getGenres(this))
        genreAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)

        filmAddNewWindow.visibility = View.GONE

        initButtons(filmAddNewWindow, genreDropdown, filmAdapter, this)

        genreDropdown.adapter = genreAdapter
        listView.adapter = filmAdapter



        // Show a Snackbar with the selected language
        val snackbarMessage = "Selected Language: $selectedLanguage \nDefault: ${Locale.getDefault()}"

        Snackbar.make(findViewById(R.id.MainLayout), snackbarMessage, Snackbar.LENGTH_LONG).show()
    }

    private fun initButtons(
        filmAddNewWindow: LinearLayout,
        genreDropdown: Spinner,
        filmAdapter: FilmListAdapter,
        mainActivity: MainActivity
    ) {
        // ADD NEW FILM BUTTON
        val buttonAddNewFilm = findViewById<Button>(R.id.buttonAddNew)
        buttonAddNewFilm.setOnClickListener {
            switchAddWindowVisibility(filmAddNewWindow, buttonAddNewFilm)
        }

        // SUBMIT NEW FILM BUTTON
        val titleInput = findViewById<EditText>(R.id.newFilmTitle)
        val buttonSubmitNewFilm = findViewById<Button>(R.id.button_submit_new)
        buttonSubmitNewFilm.setOnClickListener {
            // TODO CHECK IF FILM ALREADY EXISTS

            val title = titleInput.text.toString()
            val genre = genreDropdown.selectedItemId.toInt()

            if (title.isNotEmpty()) {
                FilmList.add(Film(title, genre))

                filmAdapter.notifyDataSetChanged()
                switchAddWindowVisibility(filmAddNewWindow, buttonAddNewFilm)

                titleInput.setText("")
            }
            else {
                Snackbar.make(findViewById(R.id.MainLayout), mainActivity.getString(R.string.empty_title_error), Snackbar.LENGTH_SHORT).show()
            }


        }

        // CANCEL NEW FILM BUTTON
        val buttonCancelNewFilm = findViewById<Button>(R.id.button_cancel_new)
        buttonCancelNewFilm.setOnClickListener {
            switchAddWindowVisibility(filmAddNewWindow, buttonAddNewFilm)
            titleInput.setText("")
        }

        // BUTTON SETTINGS
        val buttonSettings = findViewById<Button>(R.id.buttonSettings)
        buttonSettings.setOnClickListener {
            val intent = Intent(mainActivity, SettingsActivity::class.java)
            this.startActivity(intent)
        }

        // SYNC BUTTON
        val buttonSync = findViewById<Button>(R.id.buttonSync)
    }

    private fun switchAddWindowVisibility(
        filmAddNewWindow: LinearLayout,
        buttonAddNewFilm: Button
    ) {
        filmAddNewWindow.visibility = if (filmAddNewWindow.isVisible) View.GONE else View.VISIBLE
        buttonAddNewFilm.visibility = if (buttonAddNewFilm.isVisible) View.INVISIBLE else View.VISIBLE
    }
}

