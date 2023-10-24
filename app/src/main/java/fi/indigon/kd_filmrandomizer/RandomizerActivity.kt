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

//        val carouselRecyclerView = findViewById<RecyclerView>(R.id.carousel_recycler_view)
//        carouselRecyclerView.setLayoutManager(CarouselLayoutManager())

        initUI()

        //Toast.makeText(this, "NE RABOTAET POKA!!!", Toast.LENGTH_SHORT).show()
    }

    private fun initUI() {
        val genresMultiChoice = findViewById<TextView>(R.id.genresMultiselect)
        val buttonRandomize = findViewById<Button>(R.id.buttonRandomize)

        val multipleGenreChoiceWidget = MultipleGenreChoiceWidget(this, genresMultiChoice)

        buttonRandomize.setOnClickListener {
            // getting chosen genres for filtering
            val genres = multipleGenreChoiceWidget.getSelectedGenres().mapIndexed{ index, value ->
                if (value) index // If true adding index = genreID to array
                else null }
                .filterNotNull() // Filtering out null values
                .toIntArray()

            val filmList = mutableListOf<Film>()

            if (genres.isNotEmpty()) {
                for (film in FilmList) {
                    // Finding any same genre
                    val containsGenres = film.genres.any{ genre ->
                        genres.any { chosenGenre ->
                            genre == chosenGenre
                        }
                    }

                    if (containsGenres) {
                        filmList.add(film) // Adding to new list
                    }
                }
            }
            else {
                filmList.addAll(FilmList) // No sorting
            }

            Snackbar.make(findViewById(R.id.randomizerLayout), "${FilmList.count() - filmList.count()} was filtered out of ${FilmList.count()} films", Snackbar.LENGTH_SHORT).show()

            if (filmList.isEmpty()) {
                Snackbar.make(findViewById(R.id.randomizerLayout), "No films to get random from", Snackbar.LENGTH_SHORT).show()
                return@setOnClickListener
            }


            val random = Random(generateRandomSeed())
            val randomIndex = random.nextInt(0, filmList.count())

            showOkDialog(this, getString(R.string.random_result_title), filmList[randomIndex].title)
        }
    }

    private fun showOkDialog(context: Context, title: String, message: String) {
        val builder = AlertDialog.Builder(context)
        builder.setTitle(title)
        builder.setMessage(message)

        // Add an "OK" button
        builder.setPositiveButton("OK") { dialog, _ ->
            dialog.dismiss()
        }

        val dialog = builder.create()
        dialog.show()
    }
    private fun generateRandomSeed(): Long {
        val currentTimeMillis = System.currentTimeMillis()
        val seconds = (currentTimeMillis / 1000) % 60
        val hours = (currentTimeMillis / (1000 * 60 * 60)) % 24

        // Concatenate the values and return

        return "$currentTimeMillis$seconds$hours".toLong()
    }

}

