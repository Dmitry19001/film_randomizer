package fi.indigon.kd_filmrandomizer

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.TextView

class GenresListAdapter(private val context: Context, private val genres: Array<String>) :  BaseAdapter(){
    override fun getCount(): Int {
        return genres.size
    }

    override fun getItem(position: Int): Any {
        return genres[position]
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun getView(position: Int, p1: View?, p2: ViewGroup?): View {
        val genre = getItem(position) as String

        // Inflate the custom layout for each item
        val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val listItemView = inflater.inflate(R.layout.list_item_layout, null)

        // Populate the custom layout views with data from the Film object
        val titleTextView = listItemView.findViewById<TextView>(R.id.titleTextView)

        titleTextView.text = genre

        return listItemView
    }

}
