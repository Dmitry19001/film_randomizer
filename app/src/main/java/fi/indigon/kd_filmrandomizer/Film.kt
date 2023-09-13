package fi.indigon.kd_filmrandomizer

import android.content.Context


class Film( var title: String = "Unknown", var genre: Int = 0, var isWatched : Int = 0 ) {
    override fun toString(): String {
        return super.toString()
    }
}

fun getGenres(context: Context): Array<String> {
    return arrayOf(
        context.getString(R.string.genre_comedy),
        context.getString(R.string.genre_drama),
        context.getString(R.string.genre_action),
        context.getString(R.string.genre_documentary),
        context.getString(R.string.genre_musical),
        context.getString(R.string.genre_romance),
        context.getString(R.string.genre_science_fiction),
        context.getString(R.string.genre_crime),
        context.getString(R.string.genre_fantasy),
        context.getString(R.string.genre_thriller)
    )
}

fun csvToFilms(csvData: List<List<String>>) : MutableList<Film> {
    val filmList: MutableList<Film> = mutableListOf()

    if (csvData.count() < 2) return filmList

    for (i in csvData) {
        if (i[0].isEmpty()) {
            continue
        }

        filmList.add(Film(i[0], i[1].toInt(), i[2].toInt()))
    }

    return filmList
}




