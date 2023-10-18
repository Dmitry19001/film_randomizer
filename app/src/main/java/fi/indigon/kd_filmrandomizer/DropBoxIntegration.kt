package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.view.View
import com.dropbox.core.DbxRequestConfig
import com.dropbox.core.v2.DbxClientV2
import com.dropbox.core.v2.files.WriteMode
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.ByteArrayInputStream
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader

@Deprecated("Doesn't meet needed requirements, will be replaced with something better!")
class DropBoxIntegration(private val context: Context, private val view: View, private val accessToken: String) {
    private val config = DbxRequestConfig.newBuilder("FilmRandomizer").build()
    private val client = DbxClientV2(config, accessToken)
    fun interface OnDataLoadedListener {
        fun onDataLoaded(data: List<List<String>>)
    }

    fun interface OnDataUploadedListener {
        fun onDataUploaded(data: Boolean)
    }

    fun downloadCSV(onDataLoadedListener: OnDataLoadedListener) : List<List<String>>{

        var csvData: List<List<String>> = mutableListOf()

        // Use coroutines to fetch csv data asynchronously
        GlobalScope.launch(Dispatchers.IO) {
            try {
                val file = client.files().download("/FilmRandomizerList.csv").inputStream

                // Update the UI with the display name (assuming you have a way to do this)
                withContext(Dispatchers.Main) {
                    // Reading inputStream as csv
                    csvData = readCSVFromInputStream(context, file)

                    // Notify the listener with the loaded data
                    withContext(Dispatchers.Main) {
                        onDataLoadedListener.onDataLoaded(csvData)
                    }
                }
            } catch (e: Exception) {
                showSnackbar(view, "Error fetching Dropbox account: ${e.message}")
                //view.findViewById<TextView>(R.id.debug_text).text = "Error fetching Dropbox account: ${e.message}";
            }
        }
        return csvData
    }

    fun sendFilmsToCloud(filmList: MutableList<Film>, onDataUploadedListener: OnDataUploadedListener) : Boolean {
        GlobalScope.launch(Dispatchers.IO) {
            val csvData = filmListToCSV(filmList)

            try {
                val inputStream = ByteArrayInputStream(csvData.toByteArray())
                client.files().uploadBuilder("/FilmRandomizerList.csv")
                    .withMode(WriteMode.OVERWRITE)
                    .uploadAndFinish(inputStream)

                onDataUploadedListener.onDataUploaded(true)
            } catch (e: Exception) {
                onDataUploadedListener.onDataUploaded(false)
                e.printStackTrace()
            }
        }

        return false
    }


    private fun filmListToCSV(filmList: MutableList<Film>) : String {
        val csvLines = filmList.map { it.toString() }
        // Format: first line empty (,,) and every film is newline
        return ",,\n" + csvLines.joinToString("\n")
    }


    private fun readCSVFromInputStream(context: Context, inputStream: InputStream) : List<List<String>> {
        val csvData: MutableList<List<String>> = mutableListOf()
        try {
            val reader = BufferedReader(InputStreamReader(inputStream))
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                val rowData = line!!.split(",").map { it.trim() }
                csvData.add(rowData)
            }
            reader.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return csvData
    }


    private fun showSnackbar(view: View, message: String) {
        Snackbar.make(view, message, Snackbar.LENGTH_LONG).show()
    }
}