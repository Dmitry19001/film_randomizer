package fi.indigon.kd_filmrandomizer

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable

class LoadingDialog(context: Context) {
    private val dialog: AlertDialog

    init {
        val builder = AlertDialog.Builder(context)
        val inflater = (context as Activity).layoutInflater
        builder.setView(inflater.inflate(R.layout.dialog_loading, null))
        builder.setCancelable(false)  // Disallow outside touch
        dialog = builder.create()

        dialog.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT)) // Set the background to transparent
    }

    fun show() {
        dialog.show()
    }

    fun dismiss() {
        dialog.dismiss()
    }
}