package ai.genesis.android.ui

import androidx.compose.runtime.Composable
import ai.genesis.android.MainViewModel
import ai.genesis.android.ui.chat.ChatSheetContent

@Composable
fun ChatSheet(viewModel: MainViewModel) {
  ChatSheetContent(viewModel = viewModel)
}
