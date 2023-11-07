package fi.indigon.kd_filmrandomizer.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun FilmsLayout() {
    Column {
        // Replace with a LazyColumn or similar for showing the list
        LazyColumn(modifier = Modifier.weight(1f)) {
            // items(...) { ... }
        }

        EssentialButtonsPanel()
    }
}