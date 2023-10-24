package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.widget.TextView
import androidx.appcompat.app.AlertDialog

class MultipleGenreChoiceWidget(
    private val context: Context,
    private val textView: TextView
) {

    private var selectedGenres: BooleanArray = booleanArrayOf()

    init {
        initMultipleGenreChoiceWidget()
    }

    fun getSelectedGenres(): BooleanArray {
        return selectedGenres
    }

    private fun initMultipleGenreChoiceWidget() {
        // assign variable
        val selectedGenresList = arrayListOf<Int>()

        // Getting genres
        val genres = getGenres(context)

        // initialize selected language array
        selectedGenres = BooleanArray(genres.count())

        textView.setOnClickListener { // Initialize alert dialog
            val builder = AlertDialog.Builder(context)

            // set title
            builder.setTitle(context.getString(R.string.genres_choose))

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
                    selectedGenresList.sort()
                } else {
                    // when checkbox unselected
                    // Remove position from langList
                    selectedGenresList.remove(Integer.valueOf(i))
                }
            }
            builder.setPositiveButton(
                context.getString(R.string.button_ok)
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
            builder.setNegativeButton(context.getString(R.string.button_cancel)
            ) { dialogInterface, i -> // dismiss dialog
                dialogInterface.dismiss()
            }
            builder.setNeutralButton(
                context.getString(R.string.button_clear_all)
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
}