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
        val selectedGenresList = arrayListOf<Int>()

        val genres = Film.Genre.getAll()
        val genreNames = genres.map { it.getDisplayName(context) }.toTypedArray()

        selectedGenres = BooleanArray(genres.size)

        textView.setOnClickListener {
            val builder = AlertDialog.Builder(context)

            builder.setTitle(context.getString(R.string.genres_choose))

            builder.setCancelable(false)
            builder.setMultiChoiceItems(
                genreNames, selectedGenres
            ) { _, i, b ->
                if (b) {
                    selectedGenresList.add(i)
                    selectedGenresList.sort()
                } else {
                    selectedGenresList.remove(Integer.valueOf(i))
                }
            }
            builder.setPositiveButton(
                context.getString(R.string.button_ok)
            ) { _, _ ->
                val genreText = selectedGenresList.joinToString(", ") {
                    genres[it].getDisplayName(context)
                }
                textView.text = genreText
            }
            builder.setNegativeButton(context.getString(R.string.button_cancel)) { dialogInterface, _ ->
                dialogInterface.dismiss()
            }
            builder.setNeutralButton(
                context.getString(R.string.button_clear_all)
            ) { _, _ ->
                for (j in selectedGenres.indices) {
                    selectedGenres[j] = false
                }
                selectedGenresList.clear()
                textView.text = ""
            }
            builder.show()
        }
    }
}
