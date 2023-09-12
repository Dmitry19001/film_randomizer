package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.isVisible

class FilmListAdapter(private val context: Context, private val filmList: MutableList<Film>) : BaseAdapter() {
    override fun getCount(): Int {
        return filmList.size
    }

    override fun getItem(position: Int): Any {
        return filmList[position]
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        val film = getItem(position) as Film

        // Inflate the custom layout for each item
        val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val listItemView = inflater.inflate(R.layout.list_item_layout, null)

        // Populate the custom layout views with data from the Film object
        val titleTextView = listItemView.findViewById<TextView>(R.id.titleTextView)
        val genreTextView = listItemView.findViewById<TextView>(R.id.genreTextView)
        val watchedTextView = listItemView.findViewById<TextView>(R.id.watchedTextView)

        titleTextView.text = film.title
        "${context.getString(R.string.genre)}: ${ if (film.genre < getGenres(context).size && film.genre >= 0) getGenres(context)[film.genre] else "@strings/unknown"}".also { genreTextView.text = it }
        "${context.getString(R.string.is_watched_header)}: ${ if (film.isWatched != 0) context.getString(R.string.yes) else context.getString(R.string.no)}".also { watchedTextView.text = it }

        val filmDeletePanel = listItemView.findViewById<LinearLayout>(R.id.filmDeletePanel)
        val buttonDeleteFilm = listItemView.findViewById<Button>(R.id.buttonDeleteFilm)
        val buttonCancelDelete = listItemView.findViewById<Button>(R.id.buttonCancelFilmDelete)

        // Handling Cancel Button
        buttonCancelDelete.setOnClickListener {
            switchDeletePanel(filmDeletePanel) // Hiding deletion panel
        }

        // Handling Delete Button
        buttonDeleteFilm.setOnClickListener {
            filmList.removeAt(position) // Remove the item from the list
            notifyDataSetChanged() // Notify the adapter that the data has changed
        }

        listItemView.setOnLongClickListener {
            switchDeletePanel(filmDeletePanel)
            true // Return true to indicate the long press is handled
        }

        return listItemView
    }

    private fun switchDeletePanel(filmDeletePanel: LinearLayout) {
        if (filmDeletePanel.isVisible) {
            filmDeletePanel.visibility = View.GONE
        } else {
            filmDeletePanel.visibility = View.VISIBLE
        }
    }


}