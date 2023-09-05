package fi.indigon.kd_filmrandomizer

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ListView
import android.widget.Spinner
import androidx.core.view.isVisible
import com.google.android.material.floatingactionbutton.FloatingActionButton

val filmTitles = arrayOf(
    "The Shawshank Redemption",
    "The Godfather",
    "The Dark Knight",
    "Pulp Fiction",
    "Fight Club",
    "Forrest Gump",
    "Inception",
    "The Matrix",
    "Gladiator",
    "The Silence of the Lambs",
    "Jurassic Park",
    "Schindler's List",
    "The Lord of the Rings",
    "Titanic",
    "Star Wars",
    "Avatar",
    "The Avengers",
    "The Lion King",
    "E.T. the Extra-Terrestrial",
    "The Terminator"
)

val defaultFilmList = filmTitles.map{title -> Film(title)}.toMutableList()

val FilmList = mutableListOf<Film>()



class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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

        val buttonAddNewFilm = findViewById<FloatingActionButton>(R.id.buttonAddNew)
        buttonAddNewFilm.setOnClickListener {
            switchAddWindowVisibility(filmAddNewWindow, buttonAddNewFilm)
        }


        val buttonSubmitNewFilm = findViewById<Button>(R.id.button_submit_new)
        val buttonCancelNewFilm = findViewById<Button>(R.id.button_cancel_new)

        buttonSubmitNewFilm.setOnClickListener {
            // TODO CHECK IF FILM ALREADY EXISTS
            val title = findViewById<EditText>(R.id.newFilmTitle).text.toString()
            val genre = genreDropdown.selectedItemId.toInt()

            if (title.isNotEmpty()){
                FilmList.add( Film(title, genre) )

                filmAdapter.notifyDataSetChanged()
                switchAddWindowVisibility(filmAddNewWindow, buttonAddNewFilm)
            }


        }

        buttonCancelNewFilm.setOnClickListener {
            switchAddWindowVisibility(filmAddNewWindow, buttonAddNewFilm)
        }

        genreDropdown.adapter = genreAdapter
        listView.adapter = filmAdapter
    }

    private fun switchAddWindowVisibility(
        filmAddNewWindow: LinearLayout,
        buttonAddNewFilm: FloatingActionButton
    ) {
        filmAddNewWindow.visibility = if (filmAddNewWindow.isVisible) View.GONE else View.VISIBLE
        buttonAddNewFilm.visibility = if (buttonAddNewFilm.isVisible) View.INVISIBLE else View.VISIBLE
    }
}

