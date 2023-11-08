package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import org.json.JSONArray
import org.json.JSONObject

@Parcelize
data class Film(
    val title: String = "Unknown",
    val genres: List<Genre> = emptyList(),
    var isWatched: Boolean = false,
    val id: Int = -1
): Parcelable {
    enum class Genre(val id: Int, private val stringResId: Int) {
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
            fun fromId(id: Int): Genre = values().find { it.id == id } ?: throw IllegalArgumentException("Invalid genre ID")

            fun getAll(): Array<Genre> = values()
        }

        fun getDisplayName(context: Context): String {
            return context.getString(stringResId)
        }
    }

    fun genresToString(context: Context): String {
        return genres.joinToString(", ") { it.getDisplayName(context) }
    }

    fun toJson(apiAction: APIAction, sheetURL: String): JSONObject {
        val filmJson = JSONObject().apply {
            put("apiAction", apiAction.name)
            put("sheetURL", sheetURL)
            put("filmTitle", title)
            put("filmGenresIDs", JSONArray(genres.map { it.id }))
        }

        when (apiAction) {
            APIAction.ADD -> {
                // For adding, we don't need an ID or isWatched status
            }
            APIAction.EDIT, APIAction.DELETE -> {
                filmJson.put("filmID", id)
                filmJson.put("filmIsWatched", if (isWatched) 1 else 0)
            }
        }

        return filmJson
    }

    fun markWatched() {
        isWatched = true
    }

}

object FilmUtils {

    fun jsonToFilms(jsonData: JSONArray): List<Film> {
        val filmList = mutableListOf<Film>()

        for (i in 0 until jsonData.length()) {
            val jsonObject = jsonData.getJSONObject(i)

            val title = jsonObject.getString("filmTitle")
            val genresJson = jsonObject.getJSONArray("filmGenresIDs")
            val isWatched = jsonObject.getInt("filmIsWatched")
            val genresList = (0 until genresJson.length()).map {
                Film.Genre.fromId(genresJson.getInt(it))
            }
            val id = jsonObject.getInt("filmID")

            filmList.add(Film(title, genresList, isWatched == 1, id))
        }

        return filmList
    }

    fun intArrayToGenresList(intArray: IntArray): List<Film.Genre> {
        val genresList = mutableListOf<Film.Genre>()

        for (index in intArray) {
            val genre = Film.Genre.fromId(index)
            genresList.add(genre)
        }

        return genresList
    }


}
