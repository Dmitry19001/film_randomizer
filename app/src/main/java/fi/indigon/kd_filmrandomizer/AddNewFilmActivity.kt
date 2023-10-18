package fi.indigon.kd_filmrandomizer

import android.content.DialogInterface
import android.graphics.Rect
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.appcompat.app.AlertDialog.Builder
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.Collections.sort

class AddNewFilmActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

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
                // You might want to move or resize some UI elements

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

    @OptIn(DelicateCoroutinesApi::class)
    private fun initUI() {
        // SUBMIT NEW FILM BUTTON
        val titleInput = findViewById<EditText>(R.id.newFilmTitle)
        val buttonSubmitNewFilm = findViewById<Button>(R.id.button_submit_new)
        val restClient = RestClient(this);
        val loadingOverlay = findViewById<View>(R.id.loadingOverlay)

        initMultipleGenreChoiceWidget()

        buttonSubmitNewFilm.setOnClickListener {
            // TODO CHECK IF FILM ALREADY EXISTS

            val title = titleInput.text.toString()

            val genres = selectedGenres.mapIndexed{ index, value ->
                if (value) index // If true adding index = genreID to array
                else null }
                .filterNotNull() // Filtering out null values
                .toIntArray()

            if (title.isNotEmpty()) {

                toggleLoadingOverlay(loadingOverlay, true)

                val film = Film(title, genres)

                GlobalScope.launch(Dispatchers.Main) {
                    restClient.postFilmData(film = film, apiAction = ApiAction.ADD) { isDone, responseCode ->
                        if (isDone) {
                            Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.upload_success), Snackbar.LENGTH_SHORT).show()

                            setResult(RESULT_OK)
                            finish()
                        }
                        else if (responseCode == ResponseCode.ALREADY_EXISTS){
                            // ALREADY EXISTS
                            Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.film_already_exists), Snackbar.LENGTH_SHORT).show()
                        }
                        else {
                            // UNABLE TO UPLOAD
                            Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.upload_error), Snackbar.LENGTH_SHORT).show()
                        }
                        toggleLoadingOverlay(loadingOverlay, false)
                    }
                }
            }
            else {
                Snackbar.make(findViewById(R.id.filmAddNewWindow), getString(R.string.empty_title_error), Snackbar.LENGTH_SHORT).show()
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

    private var selectedGenres: BooleanArray = booleanArrayOf()

    private fun initMultipleGenreChoiceWidget() {
        // assign variable
        val textView = findViewById<TextView>(R.id.genresMultiselect)
        val selectedGenresList = arrayListOf<Int>()

        // Getting genres
        val genres = getGenres(this)

        // initialize selected language array
        selectedGenres = BooleanArray(genres.count())

        textView.setOnClickListener { // Initialize alert dialog
            val builder = Builder(this@AddNewFilmActivity)

            // set title
            builder.setTitle(getString(R.string.genres_choose))

            // set dialog non cancelable
            builder.setCancelable(false)
            builder.setMultiChoiceItems(
                genres, selectedGenres
            ) { _, i, b ->
                // check condition
                if (b) {
                    // when checkbox selected
                    // Add position  in lang list
                    selectedGenresList.add(i)
                    // Sort array list
                    sort(selectedGenresList)
                } else {
                    // when checkbox unselected
                    // Remove position from langList
                    selectedGenresList.remove(Integer.valueOf(i))
                }
            }
            builder.setPositiveButton(
                getString(R.string.button_ok)
            ) { _, _ -> // Initialize string builder
                val stringBuilder = StringBuilder()
                // use for loop
                for (j in 0 until selectedGenresList.count()) {
                    // concat array value
                    stringBuilder.append(genres[selectedGenresList[j]])
                    // check condition
                    if (j != (selectedGenresList.count() - 1)) {
                        // When j value  not equal
                        // to lang list size - 1
                        // add comma
                        stringBuilder.append(", ")
                    }
                }
                // set text on textView
                textView.text = stringBuilder.toString()
            }
            builder.setNegativeButton(getString(R.string.button_cancel),
                DialogInterface.OnClickListener { dialogInterface, i -> // dismiss dialog
                    dialogInterface.dismiss()
                })
            builder.setNeutralButton(
                getString(R.string.button_clear_all)
            ) { _, _ ->
                // use for loop
                for (j in 0 until selectedGenres.count()) {
                    // remove all selection
                    selectedGenres[j] = false
                    // clear language list
                    selectedGenresList.clear()
                    // clear text view value
                    textView.text = ""
                }
            }
            // show dialog
            builder.show()
        }
    }

    private fun toggleLoadingOverlay(loadingOverlay: View, state: Boolean) {
        if (state){
            loadingOverlay.visibility = View.VISIBLE

            window.setFlags(
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
        }
        else {
            loadingOverlay.visibility = View.GONE

            window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
        }

    }

}