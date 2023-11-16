package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.os.Parcelable
import android.util.Log
import fi.indigon.kd_filmrandomizer.DataHolder.DevMode
import kotlinx.parcelize.IgnoredOnParcel
import kotlinx.parcelize.Parcelize
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

@Parcelize
data class Film(
    val id: Int = -1,
    val title: String = "Unknown",
    val genres: Array<Genre> = arrayOf(),
    val isWatchedInitial: Boolean = false
) : Parcelable {
    @IgnoredOnParcel // No need in passing this information through Intent so ignoring
    var isWatched = isWatchedInitial
        private set // Setter should be private to prevent purposeless changes

    fun genresToString(context: Context): String {
        return genres.joinToString(", ") { it.getDisplayName(context) }
    }

    fun toJson(apiAction: APIAction): JSONObject {
        val filmJson = JSONObject().apply {
            if (DevMode) {
                put("devMode", 1)
            }
            put("apiAction", apiAction.name)
            put("filmTitle", title)
            put("filmGenresIDs", JSONArray(genres.map { it.id }))
        }

        when (apiAction) {
            APIAction.EDIT, APIAction.DELETE -> {
                filmJson.put("filmID", id)
                filmJson.put("filmIsWatched", if (isWatched) 1 else 0)
            }
            APIAction.ADD -> {
                // For adding, we don't need an ID or isWatched status
            }
        }

        return filmJson
    }

    fun markWatched() {
        isWatched = true
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Film

        if (id != other.id) return false
        if (title != other.title) return false
        if (!genres.contentEquals(other.genres)) return false
        if (isWatched != other.isWatched) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id
        result = 31 * result + title.hashCode()
        result = 31 * result + genres.contentHashCode()
        result = 31 * result + isWatched.hashCode()
        return result
    }

}

object FilmUtils {
    fun jsonToFilms(jsonData: JSONArray): List<Film> {
        val filmList: MutableList<Film> = mutableListOf()

        for (i in 0 until jsonData.length()) {
            try {
                val jsonObject: JSONObject = jsonData.getJSONObject(i)

                val id: Int = jsonObject.getInt("filmID")
                val title: String = jsonObject.getString("filmTitle")
                val genresJson: JSONArray = jsonObject.getJSONArray("filmGenresIDs")
                val isWatched: Int = jsonObject.getInt("filmIsWatched")

                val genresArray: Array<Genre> = Array(genresJson.length()) {
                    Genre.fromId(genresJson.getInt(it))
                }

                filmList.add(Film(id, title, genresArray, isWatched == 1))
            } catch (e: JSONException) {
                // If there's an error, add a placeholder film to the list
                filmList.add(Film(-1, "Error: Film data is invalid", emptyArray(), false))
                // Optionally, log the error or inform the user
                Log.e("jsonToFilms", "Error parsing JSON for film at index $i: ${e.message}")
            }
        }

        return filmList
    }

    fun intArrayToGenresArray(intArray: IntArray): Array<Genre> {
        return Array(intArray.size) { index ->
            Genre.fromId(intArray[index])
        }
    }
}
