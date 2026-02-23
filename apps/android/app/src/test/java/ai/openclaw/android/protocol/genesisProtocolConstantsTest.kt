package ai.genesis.android.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class genesisProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", genesisCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", genesisCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", genesisCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", genesisCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", genesisCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", genesisCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", genesisCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", genesisCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", genesisCapability.Canvas.rawValue)
    assertEquals("camera", genesisCapability.Camera.rawValue)
    assertEquals("screen", genesisCapability.Screen.rawValue)
    assertEquals("voiceWake", genesisCapability.VoiceWake.rawValue)
  }

  @Test
  fun screenCommandsUseStableStrings() {
    assertEquals("screen.record", genesisScreenCommand.Record.rawValue)
  }
}
