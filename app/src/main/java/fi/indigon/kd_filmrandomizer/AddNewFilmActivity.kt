package fi.indigon.kd_filmrandomizer

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.lifecycle.lifecycleScope
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class AddNewFilmActivity : LocalizedActivity() {

    private lateinit var loadingDialog: LoadingDialog
    private var sheetURL = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sheetURL = PreferenceUtils.getGoogleSheetUrl(this)

        loadingDialog = LoadingDialog(this)

        setContentView(R.layout.activity_add_new_film)

        initUI()
    }

    private fun initUI() {
        val titleInput = findViewById<EditText>(R.id.filmTitle)
        val buttonSubmitNewFilm = findViewById<Button>(R.id.button_submit_new)
        val restClient = RestClient(this, sheetURL)

        val multipleChoice = findViewById<TextView>(R.id.genresMultiselect)

        val multipleGenreChoiceWidget = MultipleGenreChoiceWidget(this, multipleChoice)

        // SUBMIT NEW FILM BUTTON
        buttonSubmitNewFilm.setOnClickListener {
            sendData(titleInput, multipleGenreChoiceWidget, restClient)
        }

        // CANCEL NEW FILM BUTTON
        val buttonCancelNewFilm = findViewById<Button>(R.id.button_cancel)
        buttonCancelNewFilm.setOnClickListener {
            // Closing activity
            setResult(RESULT_CANCELED)
            finish()
        }
    }

    private fun sendData(
        titleInput: EditText,
        multipleGenreChoiceWidget: MultipleGenreChoiceWidget,
        restClient: RestClient
    ) {
        val title = titleInput.text.toString()

        val genresIDs = multipleGenreChoiceWidget.getSelectedGenres().mapIndexed { index, value ->
            if (value) index
            else null
        }.filterNotNull().toIntArray()

        val genres = FilmUtils.intArrayToGenresList(genresIDs)

        if (title.isNotEmpty() && genres.isNotEmpty()) {
            loadingDialog.show()

            val film = Film(title, genres)

            lifecycleScope.launch {
                val (isDone, responseCode) = restClient.postFilmData(
                    film = film,
                    apiAction = APIAction.ADD
                )

                if (isDone) {
                    Snackbar.make(
                        findViewById(R.id.filmAddNewWindow),
                        getString(R.string.upload_success),
                        Snackbar.LENGTH_SHORT
                    ).show()
                    setResult(RESULT_OK)
                    finish()
                } else if (responseCode == ResponseCode.ALREADY_EXISTS) {
                    // ALREADY EXISTS
                    Snackbar.make(
                        findViewById(R.id.filmAddNewWindow),
                        getString(R.string.film_already_exists),
                        Snackbar.LENGTH_SHORT
                    ).show()
                } else {
                    // UNABLE TO UPLOAD
                    Snackbar.make(
                        findViewById(R.id.filmAddNewWindow),
                        getString(R.string.upload_error),
                        Snackbar.LENGTH_SHORT
                    ).show()
                }
                loadingDialog.dismiss()
            }
        } else {
            if (title.isEmpty()) Snackbar.make(
                findViewById(R.id.filmAddNewWindow),
                getString(R.string.empty_title_error),
                Snackbar.LENGTH_SHORT
            ).show()
            if (genres.isEmpty()) Snackbar.make(
                findViewById(R.id.filmAddNewWindow),
                getString(R.string.error_empty_genre),
                Snackbar.LENGTH_SHORT
            ).show()
        }
    }
}
