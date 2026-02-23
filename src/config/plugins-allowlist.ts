import type { genesisConfig } from "./config.js";

export function ensurePluginAllowlisted(cfg: genesisConfig, pluginId: string): genesisConfig {
  const allow = cfg.plugins?.allow;
  if (!Array.isArray(allow) || allow.includes(pluginId)) {
    return cfg;
  }
  return {
    ...cfg,
    plugins: {
      ...cfg.plugins,
      allow: [...allow, pluginId],
    },
  };
}
