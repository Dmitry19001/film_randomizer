package fi.indigon.kd_filmrandomizer

import android.os.Build
import android.os.Bundle
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.TextView
import androidx.lifecycle.lifecycleScope
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class EditFilmActivity : LocalizedActivity() {
    private lateinit var loadingDialog: LoadingDialog
    private var sheetURL = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sheetURL = PreferenceUtils.getGoogleSheetUrl(this)

        loadingDialog = LoadingDialog(this)

        setContentView(R.layout.activity_edit_film)

        val film = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra("EXTRA_FILM", Film::class.java)
        } else {
            intent.getParcelableExtra<Film>("EXTRA_FILM")
        }

        if (film != null) {
            initUI(film)
        }
        else {
            Snackbar.make(
                findViewById(R.id.filmEditWindow),
                "Nothing works here!",
                Snackbar.LENGTH_SHORT
            ).show()
        }
    }

    private fun initUI(film: Film) {
        // RESTClient
        val restClient = RestClient(this, sheetURL)

        // Other
        val filmTitle = findViewById<EditText>(R.id.filmTitle)
        filmTitle.setText(film.title)

        val genresMultiselect = findViewById<TextView>(R.id.genresMultiselect)
        val multipleGenreChoiceWidget = MultipleGenreChoiceWidget(this, genresMultiselect, film.genres)


        // Checkbox
        val isWatchedCheckBox = findViewById<CheckBox>(R.id.isWatchedCheckBox)
        isWatchedCheckBox.isChecked = film.isWatched

        // Buttons
        val buttonSubmit = findViewById<Button>(R.id.button_submit)
        val buttonCancel = findViewById<Button>(R.id.button_cancel)

        buttonSubmit.setOnClickListener {
            sendData(film.id, filmTitle, multipleGenreChoiceWidget, isWatchedCheckBox, restClient)
        }

        buttonCancel.setOnClickListener {
            setResult(RESULT_CANCELED)
            finish()
        }
    }

    private fun sendData(
        filmId: Int,
        filmTitle: EditText,
        multipleGenreChoiceWidget: MultipleGenreChoiceWidget,
        isWatchedCheckBox: CheckBox,
        restClient: RestClient
    ) {
        val title = filmTitle.text.toString()

        val genresIDs = multipleGenreChoiceWidget.getSelectedGenres().mapIndexed { index, value ->
            if (value) index
            else null
        }.filterNotNull().toIntArray()

        val genres = FilmUtils.intArrayToGenresList(genresIDs)

        if (title.isNotEmpty() && genres.isNotEmpty()) {
            loadingDialog.show()

            val film = Film(title, genres, isWatchedCheckBox.isChecked, filmId)

            lifecycleScope.launch {
                val (isDone, responseCode) = restClient.postFilmData(
                    film = film,
                    apiAction = APIAction.EDIT
                )

                if (isDone) {
                    Snackbar.make(
                        findViewById(R.id.filmAddNewWindow),
                        getString(R.string.upload_success),
                        Snackbar.LENGTH_SHORT
                    ).show()
                    setResult(RESULT_OK)
                    finish()
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
