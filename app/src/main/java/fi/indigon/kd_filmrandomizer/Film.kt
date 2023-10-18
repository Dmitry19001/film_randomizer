package fi.indigon.kd_filmrandomizer

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject


class Film {
    var title: String
        private set
    var genres: IntArray
        private set
    var isWatched: Int
        private set
    var id: Int
        private set

    constructor(title: String = "Unknown", genres: IntArray = intArrayOf(), isWatched: Int = 0, id: Int = -1) {
        this.title = title
        this.genres = genres
        this.isWatched = isWatched
        this.id = id
    }

    fun genresToString(context: Context) : String {
        return genres.joinToString(", ") { genreId ->
            val genreName = getGenres(context)[genreId]
            genreName
        }
    }

    fun toJson() : JSONArray{
        val json = JSONArray(this);
        // Format: first line empty (,,) and every film is newline
        println(json);
        return json;
    }


    override fun toString(): String {
        return "$title,$genres,$isWatched"
    }
}

fun getGenres(context: Context): Array<String> {
    return context.resources.getStringArray(R.array.genre_names)
}

@Deprecated("Will be replaced to JSON!")
fun csvToFilms(csvData: List<List<String>>) : MutableList<Film> {
    val filmList: MutableList<Film> = mutableListOf()

    if (csvData.count() < 2) return filmList

    for (i in csvData) {
        if (i[0].isEmpty()) {
            continue
        }

        filmList.add(Film(i[0], intArrayOf(i[1].toInt()), i[2].toInt()))
    }

    return filmList
}


fun jsonToFilms(jsonData: JSONArray) : MutableList<Film> {
    val filmList: MutableList<Film> = mutableListOf()

    if (jsonData.length() < 1) return filmList

    for (i in 0 until jsonData.length()) {
        val jsonObject = jsonData.getJSONObject(i)

        // Process the JSON
        val title = jsonObject.getString("filmTitle")

        val genresJson = jsonObject.getJSONArray("filmGenresIDs") // Genres
        val isWatched = jsonObject.getInt("filmIsWatched")

        val genresList: List<Int> = (0 until genresJson.length()).map { genresJson.getInt(it) }

        val id = jsonObject.getInt("filmID")

        val film = Film(title, genresList.toIntArray(), isWatched, id)
        filmList.add(film)
    }

    return filmList
}

fun filmToJson(film: Film, apiAction : String = "ADD") : JSONObject {
    val filmJson = JSONObject().apply {
        put("apiAction", apiAction)
        put("filmTitle", film.title)
        put("filmGenresIDs", JSONArray(film.genres))
    }

    if (apiAction != "ADD") {
        filmJson.put("filmID", film.id)
        filmJson.put("filmIsWatched", film.isWatched)
    }

    return filmJson
}


