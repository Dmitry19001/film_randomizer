package fi.indigon.kd_filmrandomizer
import android.content.Context
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.isVisible
import kotlinx.coroutines.DelicateCoroutinesApi

class FilmListAdapter(
    private val context: Context,
    private val filmList: MutableList<Film>,
) : BaseAdapter() {
    private var onFilmDeleteListener: OnFilmDeleteListener? = null
    private var onFilmEditListener: OnFilmEditListener? = null

    fun interface OnFilmDeleteListener {
        fun onFilmDeleted(film: Film)
    }

    fun interface OnFilmEditListener {
        fun onFilmEdit(film: Film, watchedOnly: Boolean)
    }


    private class ViewHolder(view: View) {
        val titleTextView: TextView
        val genreTextView: TextView
        val watchedTextView: TextView
        val filmEditPanel: LinearLayout
        val buttonDeleteFilm: Button
        val buttonCancelEdit: Button
        val buttonEditFilm: Button
        val buttonWatchedFilm: Button

        init {
            titleTextView = view.findViewById(R.id.titleTextView)
            genreTextView = view.findViewById(R.id.genreTextView)
            watchedTextView = view.findViewById(R.id.watchedTextView)
            filmEditPanel = view.findViewById(R.id.filmEditPanel)
            buttonDeleteFilm = view.findViewById(R.id.buttonDeleteFilm)
            buttonCancelEdit = view.findViewById(R.id.buttonCancelFilmEdit)
            buttonEditFilm = view.findViewById(R.id.buttonEditFilm)
            buttonWatchedFilm = view.findViewById(R.id.buttonWatchedFilm)
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
        viewHolder.genreTextView.text = "${context.getString(R.string.genres)}: ${film.genresToString(context)}"

        val watchedText = "${context.getString(R.string.is_watched_header)}: ${
            if (film.isWatched) context.getString(R.string.yes) else context.getString(R.string.no)
        }"
        viewHolder.watchedTextView.text = watchedText


        // Handling Cancel Button
        viewHolder.buttonCancelEdit.setOnClickListener {
            viewHolder.filmEditPanel.isVisible = !viewHolder.filmEditPanel.isVisible // Hiding deletion panel
        }

        // Handling Delete Button
        viewHolder.buttonDeleteFilm.setOnClickListener {
            onFilmDeleteListener?.onFilmDeleted(film)
        }

        // Handling Edit Button
        viewHolder.buttonEditFilm.setOnClickListener {
            onFilmEditListener?.onFilmEdit(film, false) // Editing whole film
            viewHolder.filmEditPanel.isVisible = !viewHolder.filmEditPanel.isVisible // Hiding panel
        }

        // Handling Watched Button
        viewHolder.buttonWatchedFilm.isVisible = !film.isWatched

        viewHolder.buttonWatchedFilm.setOnClickListener {
            onFilmEditListener?.onFilmEdit(film, true) // Only need to send that film is watched
            viewHolder.filmEditPanel.isVisible = !viewHolder.filmEditPanel.isVisible // Hiding panel
        }

        listItemView.setOnLongClickListener {
            vibrateForFeedback(context)
            viewHolder.filmEditPanel.isVisible = !viewHolder.filmEditPanel.isVisible
            true // Return true to indicate the long press is handled
        }

        return listItemView
    }

    fun setOnFilmDeleteListener(listener: OnFilmDeleteListener?) {
        onFilmDeleteListener = listener
    }

    fun setOnFilmEditListener(listener: OnFilmEditListener?) {
        onFilmEditListener = listener
    }

    private fun vibrateForFeedback(context: Context) {
        val vibrator = context.getSystemService(Vibrator::class.java) as Vibrator

        // Check if the device has a vibrator
        if (vibrator.hasVibrator()) {
            // Vibrate for a short period, e.g., 50 milliseconds
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                // For API 26 and above
                vibrator.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                // For API 25 and below
                @Suppress("DEPRECATION")
                vibrator.vibrate(50)
            }
        }
    }
}