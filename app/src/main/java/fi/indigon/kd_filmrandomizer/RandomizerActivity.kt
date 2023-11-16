package fi.indigon.kd_filmrandomizer

import android.app.AlertDialog
import android.content.Context
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.lifecycle.lifecycleScope
import com.google.android.material.snackbar.Snackbar
import fi.indigon.kd_filmrandomizer.DataHolder.FilmArray
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.random.Random

class RandomizerActivity : LocalizedActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_randomizer)

        // Checking if FilmArray not defined
        if (FilmArray == null) {
            AlertDialog.Builder(this)
                .setTitle("Warning")
                .setMessage("Film list is empty, Activity will be closed!")
                .setPositiveButton(this.getString(R.string.button_ok)) { dialog, _ ->
                    dialog.dismiss()
                }
                .show()

            // if not defined closing activity
            finish()
        }

        initUI()
    }

    private fun initUI() {
        val genresMultiChoice = findViewById<TextView>(R.id.genresMultiselect)
        val buttonRandomize = findViewById<Button>(R.id.buttonRandomize)

        val multipleGenreChoiceWidget = MultipleGenreChoiceWidget(this, genresMultiChoice)

        buttonRandomize.setOnClickListener {
            // getting chosen genres for filtering
            val genreIds =
                multipleGenreChoiceWidget.getSelectedGenres().mapIndexed { index, value ->
                    if (value) index // If true adding index = genreID to array
                    else null
                }
                    .filterNotNull() // Filtering out null values
                    .toIntArray()

            val filmList = if (genreIds.isNotEmpty()) {
                FilmArray!!.filter { film ->
                    // Finding any same genre
                    film.genres.any { genre ->
                        genreIds.any { chosenGenre ->
                            genre.id == chosenGenre
                        }
                    }
                }
            } else {
                FilmArray!!.toMutableList() // No sorting
            }

            Snackbar.make(
                findViewById(R.id.randomizerLayout),
                "${FilmArray!!.count() - filmList.count()} was filtered out of ${FilmArray!!.count()} films",
                Snackbar.LENGTH_SHORT
            ).show()

            if (filmList.isEmpty()) {
                Snackbar.make(
                    findViewById(R.id.randomizerLayout),
                    "No films to get random from",
                    Snackbar.LENGTH_SHORT
                ).show()
                return@setOnClickListener
            }

            val randomIndex = Random.nextInt(0, filmList.count())

            showAskDialog(
                this,
                "${getString(R.string.random_result_title)}\n${getString(R.string.question_mark_watched)}",
                filmList[randomIndex].title,
                positiveAction = {
                    sendChanges(filmList, randomIndex)
                }
            )

        }
    }

    private fun sendChanges(
        filmList: List<Film>,
        randomIndex: Int
    ) {
        // Show loading dialog
        val loadingDialog = LoadingDialog(this)
        loadingDialog.show()

        // Setting up client
        val restClient = RestClient(this)

        lifecycleScope.launch(Dispatchers.Main) {
            // Marking film as watched
            filmList[randomIndex].markWatched()

            // Sending changes and getting response
            val (isDone, responseCode) = restClient.postFilmData(
                filmList[randomIndex],
                APIAction.EDIT
            )

            // GOOD
            if (isDone) {
                Snackbar.make(
                    findViewById(R.id.MainLayout),
                    getString(R.string.upload_success),
                    Snackbar.LENGTH_SHORT
                )
                    .show()
            } else { // OH shit, not good
                Snackbar.make(
                    findViewById(R.id.MainLayout),
                    "${getString(R.string.error_upload_changes)} $responseCode",
                    Snackbar.LENGTH_SHORT
                )
                    .show()
            }
        }
        loadingDialog.dismiss()
    }

    private fun showAskDialog(
        context: Context,
        title: String,
        message: String,
        positiveAction: () -> Unit
    ) {
        AlertDialog.Builder(context)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton(context.getString(R.string.yes)) { dialog, _ ->
                positiveAction.invoke()
                dialog.dismiss()
            }
            .setNegativeButton(context.getString(R.string.no)) { dialog, _ ->
                dialog.cancel()
            }
            .show()
    }
}

