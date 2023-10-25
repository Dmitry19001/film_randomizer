package fi.indigon.kd_filmrandomizer

import android.app.AlertDialog
import android.content.Context
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.activity.ComponentActivity
import com.google.android.material.snackbar.Snackbar
import kotlin.random.Random

class RandomizerActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_randomizer)

        initUI()
    }

    private fun initUI() {
        val genresMultiChoice = findViewById<TextView>(R.id.genresMultiselect)
        val buttonRandomize = findViewById<Button>(R.id.buttonRandomize)

        val multipleGenreChoiceWidget = MultipleGenreChoiceWidget(this, genresMultiChoice)

        buttonRandomize.setOnClickListener {
            // getting chosen genres for filtering
            val genreIds = multipleGenreChoiceWidget.getSelectedGenres().mapIndexed{ index, value ->
                if (value) index // If true adding index = genreID to array
                else null }
                .filterNotNull() // Filtering out null values
                .toIntArray()

            val filmList = if (genreIds.isNotEmpty()) {
                FilmList.filter { film ->
                    // Finding any same genre
                    film.genres.any{ genre ->
                        genreIds.any { chosenGenre ->
                            genre.id == chosenGenre
                        }
                    }
                }
            }
            else {
                FilmList // No sorting
            }

            Snackbar.make(findViewById(R.id.randomizerLayout), "${FilmList.count() - filmList.count()} was filtered out of ${FilmList.count()} films", Snackbar.LENGTH_SHORT).show()

            if (filmList.isEmpty()) {
                Snackbar.make(findViewById(R.id.randomizerLayout), "No films to get random from", Snackbar.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            val randomIndex = Random.nextInt(0, filmList.count())

            showOkDialog(this, getString(R.string.random_result_title), filmList[randomIndex].title)
        }
    }

    private fun showOkDialog(context: Context, title: String, message: String) {
        AlertDialog.Builder(context)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
            .show()
    }
}

