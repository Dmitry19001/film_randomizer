package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.widget.TextView
import androidx.appcompat.app.AlertDialog

class MultipleGenreChoiceWidget(
    private val context: Context,
    private val textView: TextView,
    private val preselectedGenres: List<Film.Genre>? = null
) {

    private var selectedGenres: BooleanArray = booleanArrayOf()

    init {
        initMultipleGenreChoiceWidget()
    }

    fun getSelectedGenres(): BooleanArray {
        return selectedGenres
    }

    private fun preselectGenres(selectedGenresList: ArrayList<Int>, genres: Array<Film.Genre>) {
        for (genre in preselectedGenres!!) {
            selectedGenresList.add(genre.id)
            selectedGenres[genre.id] = true
        }

        val genreText = selectedGenresList.joinToString(", ") {
            genres[it].getDisplayName(context)
        }
        textView.text = genreText
    }

    private fun initMultipleGenreChoiceWidget() {
        val selectedGenresList = arrayListOf<Int>()

        val genres = Film.Genre.getAll()
        val genreNames = genres.map { it.getDisplayName(context) }.toTypedArray()

        selectedGenres = BooleanArray(genres.size)

        if (preselectedGenres != null) {
            preselectGenres(selectedGenresList, genres)
        }

        textView.setOnClickListener {
            val builder = AlertDialog.Builder(context)

            builder.setTitle(context.getString(R.string.genres_choose))

            builder.setCancelable(false)
            builder.setMultiChoiceItems(
                genreNames, selectedGenres
            ) { _, index, bool ->
                if (bool) {
                    selectedGenresList.add(index)
                    selectedGenresList.sort()
                } else {
                    selectedGenresList.remove(Integer.valueOf(index))
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
