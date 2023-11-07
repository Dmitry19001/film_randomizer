package fi.indigon.kd_filmrandomizer.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import fi.indigon.kd_filmrandomizer.R

@Composable
fun MainLayout() {
    Box(modifier = Modifier.fillMaxSize()) {
        Column {
            TopMenuPanel()
            FilmsLayout()
            ButtonAddNew()
        }
    }
}

@Composable
fun EssentialButtonsPanel() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(65.dp)
    ) {
        // Sync Button
        Button(
            onClick = { /* Handle click */ },
            modifier = Modifier.weight(1f)
        ) {
            Icon(
                painter = painterResource(id = R.drawable.sync),
                contentDescription = "Sync"
            )
            Text("Sync")
        }

        // Random Button
        Button(
            onClick = { /* Handle click */ },
            modifier = Modifier.weight(1f)
        ) {
            Icon(
                painter = painterResource(id = R.drawable.random),
                contentDescription = "Random"
            )
            Text("Random")
        }
    }
}


