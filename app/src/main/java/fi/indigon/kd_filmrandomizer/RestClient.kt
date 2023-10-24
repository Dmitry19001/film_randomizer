package fi.indigon.kd_filmrandomizer

import android.content.Context
import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.request.get
import io.ktor.client.request.parameter
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.readBytes
import io.ktor.http.ContentType
import io.ktor.http.URLProtocol
import io.ktor.http.contentType
import org.json.JSONArray
import java.net.URL

enum class ApiAction {
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

class RestClient(private val context: Context, private val sheetURL: String) {
    private val client = HttpClient(OkHttp)
    private val apiURL = URL(context.getString(R.string.RESTApiLink))

    fun interface OnDataLoadedListener {
        fun onDataLoaded(data: JSONArray?)
    }

    fun interface OnDataUploadedListener {
        fun onDataUploaded(success: Boolean, responseCode: ResponseCode)
    }

    suspend fun getFilmsData(callback: OnDataLoadedListener) {
        try {
            val response = client.get(apiURL) {
                url {
                    protocol = URLProtocol.HTTPS
                }
                parameter("sheetURL", sheetURL)
            }

            when (response.status.value) {
                in 200..299 -> {
                    val responseBody = response.readBytes().toString(Charsets.UTF_8)
                    println(responseBody)
                    val jsonArray = if (responseBody.isNotEmpty()) JSONArray(responseBody) else null
                    callback.onDataLoaded(jsonArray)
                }
                else -> {
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

    suspend fun postFilmData(film: Film, apiAction: ApiAction, callback: OnDataUploadedListener) {
        try {
            val filmJson = filmToJson(film, apiAction.toString(), sheetURL)

            val response = client.post(apiURL) {
                url {
                    protocol = URLProtocol.HTTPS
                }

                contentType(ContentType.Application.Json)
                setBody(filmJson.toString())
            }

            var status = response.status
            val responseText = response.readBytes().toString(Charsets.UTF_8)

            println("Status $status")
            println("ResponseText $responseText")

            val responseCode = when (status.value) {
                in 200..299 -> {
                    when (responseText) {
                        "EXISTS" -> {
                            ResponseCode.ALREADY_EXISTS
                        }
                        "NOT_FOUND" -> {
                            ResponseCode.NOT_FOUND
                        }
                        "DELETED" -> {
                            ResponseCode.SUCCESS
                        }
                        else -> {
                            ResponseCode.UPLOADED_SUCCESSFULLY
                        }
                    }
                }
                in 300..399 -> {
                    val locationHeader = response.headers["Location"]
                    if (locationHeader != null) {
                        val redirectUrl = URL(locationHeader)
                        val redirectedResponse = client.get(redirectUrl)

                        status = redirectedResponse.status

                        if (redirectedResponse.status.value in 200..299) {
                            when (redirectedResponse.readBytes().toString(Charsets.UTF_8)) {
                                "EXISTS" -> {
                                    ResponseCode.ALREADY_EXISTS
                                }
                                "NOT_FOUND" -> {
                                    ResponseCode.NOT_FOUND
                                }
                                "DELETED" -> {
                                    ResponseCode.SUCCESS
                                }
                                else -> {
                                    ResponseCode.UPLOADED_SUCCESSFULLY
                                }
                            }
                        } else {
                            ResponseCode.UNKNOWN_ERROR
                        }
                    } else {
                        ResponseCode.UNKNOWN_ERROR
                    }
                }
                404 -> ResponseCode.NOT_FOUND
                else -> ResponseCode.UNKNOWN_ERROR
            }

            callback.onDataUploaded(status.value in 200..299, responseCode)
        } catch (e: Exception) {
            e.printStackTrace()
            callback.onDataUploaded(false, ResponseCode.UNKNOWN_ERROR)
        } finally {
            client.close()
        }
    }
}
