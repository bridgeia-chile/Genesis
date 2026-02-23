import type {
  AnyAgentTool,
  genesisPluginApi,
  genesisPluginToolFactory,
} from "../../src/plugins/types.js";
import { createLobsterTool } from "./src/lobster-tool.js";

export default function register(api: genesisPluginApi) {
  api.registerTool(
    ((ctx) => {
      if (ctx.sandboxed) {
        return null;
      }
      return createLobsterTool(api) as AnyAgentTool;
    }) as genesisPluginToolFactory,
    { optional: true },
  );
}
