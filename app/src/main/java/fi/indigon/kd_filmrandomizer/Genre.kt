package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
enum class Genre(val id: Int, private val stringResId: Int) : Parcelable {
    COMEDY(0, R.string.genre_comedy),
    DRAMA(1, R.string.genre_drama),
    ACTION(2, R.string.genre_action),
    DOCUMENTARY(3, R.string.genre_documentary),
    MUSICAL(4, R.string.genre_musical),
    ROMANCE(5, R.string.genre_romance),
    SCIENCE_FICTION(6, R.string.genre_science_fiction),
    CRIME(7, R.string.genre_crime),
    FANTASY(8, R.string.genre_fantasy),
    THRILLER(9, R.string.genre_thriller),
    SERIES(10, R.string.genre_series),
    ANIMATION(11, R.string.genre_animation);

    companion object {
        fun fromId(id: Int): Genre =
            values().find { it.id == id } ?: throw IllegalArgumentException("Invalid genre ID")

        fun getAll(): Array<Genre> = values()
    }

    fun getDisplayName(context: Context): String {
        return context.getString(stringResId)
    }
}