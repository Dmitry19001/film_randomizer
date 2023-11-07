package fi.indigon.kd_filmrandomizer

import android.graphics.Rect
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.TextView
import androidx.activity.ComponentActivity
import com.google.android.material.snackbar.Snackbar

class EditFilmActivity : ComponentActivity() {
    private lateinit var loadingDialog: LoadingDialog
    private var sheetURL = ""
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sheetURL = PreferenceUtils.getGoogleSheetUrl(this)

        loadingDialog = LoadingDialog(this)

        setContentView(R.layout.edit_film_activity)

        // making current view adjustable to keyboard
        makeAdjustableView()

        initUI()

        Snackbar.make(
            findViewById(R.id.filmEditWindow),
            "Nothing works here!",
            Snackbar.LENGTH_SHORT
        ).show()
    }

    private fun initUI() {
        // Other
        val filmTitle = findViewById<EditText>(R.id.filmTitle)
        val genresMultiselect = findViewById<TextView>(R.id.genresMultiselect)

        // Checkbox
        val isWatchedCheckBox = findViewById<CheckBox>(R.id.isWatchedCheckBox)

        // Buttons
        val buttonSubmit = findViewById<Button>(R.id.button_submit)
        val buttonCancel = findViewById<Button>(R.id.button_cancel)

        buttonSubmit.setOnClickListener {
            finish()
        }

        buttonCancel.setOnClickListener {
            finish()
        }
    }

    private fun makeAdjustableView() {
        val rootView = findViewById<View>(R.id.filmEditWindow)
        val initialRootLayoutParams = rootView.layoutParams // Store the initial layout params

        rootView.viewTreeObserver.addOnGlobalLayoutListener {
            val rect = Rect()
            rootView.getWindowVisibleDisplayFrame(rect)
            val screenHeight = rootView.height
            val keypadHeight = screenHeight - rect.bottom

            // Threshold to determine when the keyboard is visible
            val threshold = screenHeight / 3

            if (keypadHeight > threshold) {
                // Calculate the new height for the root view
                val newHeight = screenHeight - keypadHeight

                // Create new LayoutParams with the adjusted height
                initialRootLayoutParams.height = newHeight

                // Apply the new LayoutParams to the root view
                rootView.layoutParams = initialRootLayoutParams
            } else {

                // Restore the initial LayoutParams when the keyboard is hidden
                rootView.layoutParams = initialRootLayoutParams
            }
        }
    }
}
