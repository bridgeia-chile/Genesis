package ai.genesis.android.node

import android.os.Build
import ai.genesis.android.BuildConfig
import ai.genesis.android.SecurePrefs
import ai.genesis.android.gateway.GatewayClientInfo
import ai.genesis.android.gateway.GatewayConnectOptions
import ai.genesis.android.gateway.GatewayEndpoint
import ai.genesis.android.gateway.GatewayTlsParams
import ai.genesis.android.protocol.genesisCanvasA2UICommand
import ai.genesis.android.protocol.genesisCanvasCommand
import ai.genesis.android.protocol.genesisCameraCommand
import ai.genesis.android.protocol.genesisLocationCommand
import ai.genesis.android.protocol.genesisScreenCommand
import ai.genesis.android.protocol.genesisSmsCommand
import ai.genesis.android.protocol.genesisCapability
import ai.genesis.android.LocationMode
import ai.genesis.android.VoiceWakeMode

class ConnectionManager(
  private val prefs: SecurePrefs,
  private val cameraEnabled: () -> Boolean,
  private val locationMode: () -> LocationMode,
  private val voiceWakeMode: () -> VoiceWakeMode,
  private val smsAvailable: () -> Boolean,
  private val hasRecordAudioPermission: () -> Boolean,
  private val manualTls: () -> Boolean,
) {
  companion object {
    internal fun resolveTlsParamsForEndpoint(
      endpoint: GatewayEndpoint,
      storedFingerprint: String?,
      manualTlsEnabled: Boolean,
    ): GatewayTlsParams? {
      val stableId = endpoint.stableId
      val stored = storedFingerprint?.trim().takeIf { !it.isNullOrEmpty() }
      val isManual = stableId.startsWith("manual|")

      if (isManual) {
        if (!manualTlsEnabled) return null
        if (!stored.isNullOrBlank()) {
          return GatewayTlsParams(
            required = true,
            expectedFingerprint = stored,
            allowTOFU = false,
            stableId = stableId,
          )
        }
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = null,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      // Prefer stored pins. Never let discovery-provided TXT override a stored fingerprint.
      if (!stored.isNullOrBlank()) {
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = stored,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      val hinted = endpoint.tlsEnabled || !endpoint.tlsFingerprintSha256.isNullOrBlank()
      if (hinted) {
        // TXT is unauthenticated. Do not treat the advertised fingerprint as authoritative.
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = null,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      return null
    }
  }

  fun buildInvokeCommands(): List<String> =
    buildList {
      add(genesisCanvasCommand.Present.rawValue)
      add(genesisCanvasCommand.Hide.rawValue)
      add(genesisCanvasCommand.Navigate.rawValue)
      add(genesisCanvasCommand.Eval.rawValue)
      add(genesisCanvasCommand.Snapshot.rawValue)
      add(genesisCanvasA2UICommand.Push.rawValue)
      add(genesisCanvasA2UICommand.PushJSONL.rawValue)
      add(genesisCanvasA2UICommand.Reset.rawValue)
      add(genesisScreenCommand.Record.rawValue)
      if (cameraEnabled()) {
        add(genesisCameraCommand.Snap.rawValue)
        add(genesisCameraCommand.Clip.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(genesisLocationCommand.Get.rawValue)
      }
      if (smsAvailable()) {
        add(genesisSmsCommand.Send.rawValue)
      }
      if (BuildConfig.DEBUG) {
        add("debug.logs")
        add("debug.ed25519")
      }
      add("app.update")
    }

  fun buildCapabilities(): List<String> =
    buildList {
      add(genesisCapability.Canvas.rawValue)
      add(genesisCapability.Screen.rawValue)
      if (cameraEnabled()) add(genesisCapability.Camera.rawValue)
      if (smsAvailable()) add(genesisCapability.Sms.rawValue)
      if (voiceWakeMode() != VoiceWakeMode.Off && hasRecordAudioPermission()) {
        add(genesisCapability.VoiceWake.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(genesisCapability.Location.rawValue)
      }
    }

  fun resolvedVersionName(): String {
    val versionName = BuildConfig.VERSION_NAME.trim().ifEmpty { "dev" }
    return if (BuildConfig.DEBUG && !versionName.contains("dev", ignoreCase = true)) {
      "$versionName-dev"
    } else {
      versionName
    }
  }

  fun resolveModelIdentifier(): String? {
    return listOfNotNull(Build.MANUFACTURER, Build.MODEL)
      .joinToString(" ")
      .trim()
      .ifEmpty { null }
  }

  fun buildUserAgent(): String {
    val version = resolvedVersionName()
    val release = Build.VERSION.RELEASE?.trim().orEmpty()
    val releaseLabel = if (release.isEmpty()) "unknown" else release
    return "genesisAndroid/$version (Android $releaseLabel; SDK ${Build.VERSION.SDK_INT})"
  }

  fun buildClientInfo(clientId: String, clientMode: String): GatewayClientInfo {
    return GatewayClientInfo(
      id = clientId,
      displayName = prefs.displayName.value,
      version = resolvedVersionName(),
      platform = "android",
      mode = clientMode,
      instanceId = prefs.instanceId.value,
      deviceFamily = "Android",
      modelIdentifier = resolveModelIdentifier(),
    )
  }

  fun buildNodeConnectOptions(): GatewayConnectOptions {
    return GatewayConnectOptions(
      role = "node",
      scopes = emptyList(),
      caps = buildCapabilities(),
      commands = buildInvokeCommands(),
      permissions = emptyMap(),
      client = buildClientInfo(clientId = "genesis-android", clientMode = "node"),
      userAgent = buildUserAgent(),
    )
  }

  fun buildOperatorConnectOptions(): GatewayConnectOptions {
    return GatewayConnectOptions(
      role = "operator",
      scopes = listOf("operator.read", "operator.write", "operator.talk.secrets"),
      caps = emptyList(),
      commands = emptyList(),
      permissions = emptyMap(),
      client = buildClientInfo(clientId = "genesis-control-ui", clientMode = "ui"),
      userAgent = buildUserAgent(),
    )
  }

  fun resolveTlsParams(endpoint: GatewayEndpoint): GatewayTlsParams? {
    val stored = prefs.loadGatewayTlsFingerprint(endpoint.stableId)
    return resolveTlsParamsForEndpoint(endpoint, storedFingerprint = stored, manualTlsEnabled = manualTls())
  }
}
