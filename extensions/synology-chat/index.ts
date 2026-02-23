import type { genesisPluginApi } from "genesis/plugin-sdk";
import { emptyPluginConfigSchema } from "genesis/plugin-sdk";
import { createSynologyChatPlugin } from "./src/channel.js";
import { setSynologyRuntime } from "./src/runtime.js";

const plugin = {
  id: "synology-chat",
  name: "Synology Chat",
  description: "Native Synology Chat channel plugin for genesis",
  configSchema: emptyPluginConfigSchema(),
  register(api: genesisPluginApi) {
    setSynologyRuntime(api.runtime);
    api.registerChannel({ plugin: createSynologyChatPlugin() });
  },
};

export default plugin;
