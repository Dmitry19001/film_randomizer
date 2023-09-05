package fi.indigon.kd_filmrandomizer

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.ListView

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

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val listView = findViewById<ListView>(R.id.filmList)
        val adapter = FilmListAdapter(this, defaultFilmList) // Replace with your data source
        listView.adapter = adapter
    }
}

