import { vi } from "vitest";
import { installChromeUserDataDirHooks } from "./chrome-user-data-dir.test-harness.js";

const chromeUserDataDir = { dir: "/tmp/genesis" };
installChromeUserDataDirHooks(chromeUserDataDir);

vi.mock("./chrome.js", () => ({
  isChromeCdpReady: vi.fn(async () => true),
  isChromeReachable: vi.fn(async () => true),
  launchgenesisChrome: vi.fn(async () => {
    throw new Error("unexpected launch");
  }),
  resolvegenesisUserDataDir: vi.fn(() => chromeUserDataDir.dir),
  stopgenesisChrome: vi.fn(async () => {}),
}));
