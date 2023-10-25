package fi.indigon.kd_filmrandomizer

import android.graphics.Rect
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.lifecycle.lifecycleScope
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class AddNewFilmActivity : ComponentActivity() {

    private var sheetURL = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sheetURL = PreferenceUtils.getGoogleSheetUrl(this)

        setContentView(R.layout.add_new_film_activity)

        // making current view adjustable to keyboard
        makeAdjustableView()

        initUI()
    }

    private fun makeAdjustableView() {
        val rootView = findViewById<View>(R.id.filmAddNewWindow)
        val initialRootLayoutParams = rootView.layoutParams // Store the initial layout params

        rootView.viewTreeObserver.addOnGlobalLayoutListener {
            val rect = Rect()
            rootView.getWindowVisibleDisplayFrame(rect)
            val screenHeight = rootView.height
            val keypadHeight = screenHeight - rect.bottom

            // You can define a threshold to determine when the keyboard is visible
            val threshold = screenHeight / 3

            if (keypadHeight > threshold) {
                // Keyboard is visible; adjust your UI here

                // Calculate the new height for the root view
                val newHeight = screenHeight - keypadHeight

                // Create new LayoutParams with the adjusted height
                initialRootLayoutParams.height = newHeight

                // Apply the new LayoutParams to the root view
                rootView.layoutParams = initialRootLayoutParams
            } else {
                // Keyboard is hidden; reset your UI here

                // Restore the initial LayoutParams when the keyboard is hidden
                rootView.layoutParams = initialRootLayoutParams
            }
        }
    }

    private fun initUI() {
        // SUBMIT NEW FILM BUTTON
        val titleInput = findViewById<EditText>(R.id.newFilmTitle)
        val buttonSubmitNewFilm = findViewById<Button>(R.id.button_submit_new)
        val restClient = RestClient(this, sheetURL)
        val loadingOverlay = findViewById<View>(R.id.loadingOverlay)

        val multipleChoice = findViewById<TextView>(R.id.genresMultiselect)

        val multipleGenreChoiceWidget = MultipleGenreChoiceWidget(this, multipleChoice)

        buttonSubmitNewFilm.setOnClickListener {
            val title = titleInput.text.toString()

            val genresIDs = multipleGenreChoiceWidget.getSelectedGenres().mapIndexed { index, value ->
                if (value) index
                else null
            }.filterNotNull().toIntArray()

            val genres = FilmUtils.intArrayToGenresList(genresIDs)

            if (title.isNotEmpty() && genres.isNotEmpty()) {
                toggleLoadingOverlay(loadingOverlay, true)

                val film = Film(title, genres)

                lifecycleScope.launch {
                    val (isDone, responseCode) = restClient.postFilmData(film = film, apiAction = APIAction.ADD)

                    if (isDone) {
                        Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.upload_success), Snackbar.LENGTH_SHORT).show()
                        setResult(RESULT_OK)
                        finish()
                    } else if (responseCode == ResponseCode.ALREADY_EXISTS) {
                        // ALREADY EXISTS
                        Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.film_already_exists), Snackbar.LENGTH_SHORT).show()
                    } else {
                        // UNABLE TO UPLOAD
                        Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.upload_error), Snackbar.LENGTH_SHORT).show()
                    }
                    toggleLoadingOverlay(loadingOverlay, false)
                }
            } else {
                if (title.isEmpty()) Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.empty_title_error), Snackbar.LENGTH_SHORT).show()
                if (genres.isEmpty()) Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.error_empty_genre), Snackbar.LENGTH_SHORT).show()
            }
        }

        // CANCEL NEW FILM BUTTON
        val buttonCancelNewFilm = findViewById<Button>(R.id.button_cancel_new)
        buttonCancelNewFilm.setOnClickListener {
            // Closing activity
            setResult(RESULT_CANCELED)
            finish()
        }
    }

    private fun toggleLoadingOverlay(loadingOverlay: View, state: Boolean) {
        if (state) {
            loadingOverlay.visibility = View.VISIBLE
            window.setFlags(
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
            )
        } else {
            loadingOverlay.visibility = View.GONE
            window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        }
    }
}
