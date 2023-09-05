package fi.indigon.kd_filmrandomizer

import android.content.Context


class Film( var title: String = "Unknown", var genre: Int = 0, var isWatched : Int = 0, ) {
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
        context.getString(R.string.genre_musical)
    )
}



