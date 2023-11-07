package fi.indigon.kd_filmrandomizer.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import fi.indigon.kd_filmrandomizer.R

@Composable
fun ButtonAddNew() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(end = 24.dp, bottom = 75.dp),
        contentAlignment = Alignment.BottomEnd
    ) {
        // Add New Button
        IconButton(icon = R.drawable.add, contentDescription = "Add New")
    }
}

@Composable
fun IconButton(icon: Int, contentDescription: String) {
    Button(
        onClick = { /* Handle click */ },
        modifier = Modifier.size(60.dp)
    ) {
        Icon(
            painter = painterResource(id = icon),
            contentDescription = contentDescription
        )
    }
}