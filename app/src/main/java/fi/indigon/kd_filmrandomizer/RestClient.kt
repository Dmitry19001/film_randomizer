package fi.indigon.kd_filmrandomizer

import android.content.Context
import fi.indigon.kd_filmrandomizer.DataHolder.DevMode
import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.request.get
import io.ktor.client.request.parameter
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.readBytes
import io.ktor.http.ContentType
import io.ktor.http.URLProtocol
import io.ktor.http.contentType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import java.net.URL

enum class APIAction {
    ADD,
    EDIT,
    DELETE;

    override fun toString(): String {
        return name
    }
}

enum class ResponseCode {
    ALREADY_EXISTS,
    UNKNOWN_ERROR,
    UPLOADED_SUCCESSFULLY,
    SUCCESS,
    NOT_FOUND;
}

class RestClient(context: Context) {
    private val client = HttpClient(OkHttp)
    private val apiURL = URL(context.getString(R.string.GoogleAppLink))

    fun interface OnDataLoadedListener {
        fun onDataLoaded(data: JSONArray?)
    }

    suspend fun getFilmsData(callback: OnDataLoadedListener) {
        try {
            val response = client.get(apiURL) {
                url {
                    protocol = URLProtocol.HTTPS
                }
                if (DevMode) {
                    // passing the devmode parameter
                    parameter("devMode", 1)
                }
            }

            when (response.status.value) {
                in 200..299 -> {
                    val responseBody = response.readBytes().toString(Charsets.UTF_8)
                    val jsonArray = if (responseBody.isNotEmpty()) JSONArray(responseBody) else null
                    callback.onDataLoaded(jsonArray)
                }

                else -> {
                    //val responseBody = response.readBytes().toString(Charsets.UTF_8)
                    callback.onDataLoaded(null)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            callback.onDataLoaded(null)
        } finally {
            client.close()
        }
    }

    private suspend fun handleRedirection(response: HttpResponse): HttpResponse {
        val locationHeader = response.headers["Location"]
        return if (locationHeader != null) {
            val redirectUrl = URL(locationHeader)
            client.get(redirectUrl)
        } else {
            response
        }
    }

    private suspend fun parseResponse(response: HttpResponse): Pair<Boolean, ResponseCode> {
        val status = response.status
        val responseText = response.readBytes().toString(Charsets.UTF_8)

        val responseCode = when (status.value) {
            in 200..299 -> {
                when (responseText) {
                    "EXISTS" -> ResponseCode.ALREADY_EXISTS
                    "NOT_FOUND" -> ResponseCode.NOT_FOUND
                    "DELETED" -> ResponseCode.SUCCESS
                    else -> ResponseCode.UPLOADED_SUCCESSFULLY
                }
            }

            404 -> ResponseCode.NOT_FOUND
            else -> ResponseCode.UNKNOWN_ERROR
        }

        return Pair(status.value in 200..299, responseCode)
    }

    suspend fun postFilmData(film: Film, apiAction: APIAction): Pair<Boolean, ResponseCode> {
        return withContext(Dispatchers.IO) {
            try {
                val initialResponse = client.post(apiURL) {
                    url {
                        protocol = URLProtocol.HTTPS
                    }
                    contentType(ContentType.Application.Json)
                    setBody(film.toJson(apiAction).toString())
                }

                // Checking redirect
                val finalResponse = if (initialResponse.status.value in 300..399) {
                    handleRedirection(initialResponse)
                } else {
                    initialResponse
                }

                parseResponse(finalResponse)
            } catch (e: Exception) {
                e.printStackTrace()
                Pair(false, ResponseCode.UNKNOWN_ERROR)
            } finally {
                client.close()
            }
        }
    }
}
