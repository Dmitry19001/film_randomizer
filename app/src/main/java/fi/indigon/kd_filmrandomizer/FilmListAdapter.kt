
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.isVisible
import fi.indigon.kd_filmrandomizer.Film
import fi.indigon.kd_filmrandomizer.R
import kotlinx.coroutines.DelicateCoroutinesApi

class FilmListAdapter(
    private val context: Context,
    private val filmList: MutableList<Film>,
) : BaseAdapter() {
    private var onFilmDeleteListener: OnFilmDeleteListener? = null

    fun interface OnFilmDeleteListener {
        fun onFilmDeleted(film: Film)
    }

    private class ViewHolder(view: View) {
        val titleTextView: TextView
        val genreTextView: TextView
        val watchedTextView: TextView
        val filmDeletePanel: LinearLayout
        val buttonDeleteFilm: Button
        val buttonCancelDelete: Button

        init {
            titleTextView = view.findViewById(R.id.titleTextView)
            genreTextView = view.findViewById(R.id.genreTextView)
            watchedTextView = view.findViewById(R.id.watchedTextView)
            filmDeletePanel = view.findViewById(R.id.filmDeletePanel)
            buttonDeleteFilm = view.findViewById(R.id.buttonDeleteFilm)
            buttonCancelDelete = view.findViewById(R.id.buttonCancelFilmDelete)
        }
    }

    override fun getCount(): Int {
        return filmList.size
    }

    override fun getItem(position: Int): Any {
        return filmList[position]
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    @OptIn(DelicateCoroutinesApi::class)
    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        val film = getItem(position) as Film
        val listItemView: View
        val viewHolder: ViewHolder

        if (convertView == null) {
            val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            listItemView = inflater.inflate(R.layout.list_item_layout, null)
            viewHolder = ViewHolder(listItemView)
            listItemView.tag = viewHolder
        } else {
            listItemView = convertView
            viewHolder = listItemView.tag as ViewHolder
        }

        viewHolder.titleTextView.text = film.title
        val genreText = "${context.getString(R.string.genres)}: ${film.genresToString(context)}"
        viewHolder.genreTextView.text = genreText
        val watchedText = "${context.getString(R.string.is_watched_header)}: ${
            if (film.isWatched) context.getString(R.string.yes) else context.getString(R.string.no)
        }"
        viewHolder.watchedTextView.text = watchedText

        val filmDeletePanel = viewHolder.filmDeletePanel
        val buttonDeleteFilm = viewHolder.buttonDeleteFilm
        val buttonCancelDelete = viewHolder.buttonCancelDelete

        // Handling Cancel Button
        buttonCancelDelete.setOnClickListener {
            switchDeletePanel(filmDeletePanel) // Hiding deletion panel
        }

        // Handling Delete Button
        buttonDeleteFilm.setOnClickListener {
            println("TRYING TO DELETE $film")

            onFilmDeleteListener?.onFilmDeleted(film)
        }

        listItemView.setOnLongClickListener {
            switchDeletePanel(filmDeletePanel)
            true // Return true to indicate the long press is handled
        }

        return listItemView
    }

    fun setOnFilmDeleteListener(listener: OnFilmDeleteListener?) {
        onFilmDeleteListener = listener
    }

    private fun switchDeletePanel(filmDeletePanel: LinearLayout) {
        if (filmDeletePanel.isVisible) {
            filmDeletePanel.visibility = View.GONE
        } else {
            filmDeletePanel.visibility = View.VISIBLE
        }
    }
}