import path from "node:path";
import { describe, expect, it } from "vitest";
import { formatCliCommand } from "./command-format.js";
import { applyCliProfileEnv, parseCliProfileArgs } from "./profile.js";

describe("parseCliProfileArgs", () => {
  it("leaves gateway --dev for subcommands", () => {
    const res = parseCliProfileArgs([
      "node",
      "genesis",
      "gateway",
      "--dev",
      "--allow-unconfigured",
    ]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBeNull();
    expect(res.argv).toEqual(["node", "genesis", "gateway", "--dev", "--allow-unconfigured"]);
  });

  it("still accepts global --dev before subcommand", () => {
    const res = parseCliProfileArgs(["node", "genesis", "--dev", "gateway"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("dev");
    expect(res.argv).toEqual(["node", "genesis", "gateway"]);
  });

  it("parses --profile value and strips it", () => {
    const res = parseCliProfileArgs(["node", "genesis", "--profile", "work", "status"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("work");
    expect(res.argv).toEqual(["node", "genesis", "status"]);
  });

  it("rejects missing profile value", () => {
    const res = parseCliProfileArgs(["node", "genesis", "--profile"]);
    expect(res.ok).toBe(false);
  });

  it.each([
    ["--dev first", ["node", "genesis", "--dev", "--profile", "work", "status"]],
    ["--profile first", ["node", "genesis", "--profile", "work", "--dev", "status"]],
  ])("rejects combining --dev with --profile (%s)", (_name, argv) => {
    const res = parseCliProfileArgs(argv);
    expect(res.ok).toBe(false);
  });
});

describe("applyCliProfileEnv", () => {
  it("fills env defaults for dev profile", () => {
    const env: Record<string, string | undefined> = {};
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    const expectedStateDir = path.join(path.resolve("/home/peter"), ".genesis-dev");
    expect(env.genesis_PROFILE).toBe("dev");
    expect(env.genesis_STATE_DIR).toBe(expectedStateDir);
    expect(env.genesis_CONFIG_PATH).toBe(path.join(expectedStateDir, "genesis.json"));
    expect(env.genesis_GATEWAY_PORT).toBe("19001");
  });

  it("does not override explicit env values", () => {
    const env: Record<string, string | undefined> = {
      genesis_STATE_DIR: "/custom",
      genesis_GATEWAY_PORT: "19099",
    };
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    expect(env.genesis_STATE_DIR).toBe("/custom");
    expect(env.genesis_GATEWAY_PORT).toBe("19099");
    expect(env.genesis_CONFIG_PATH).toBe(path.join("/custom", "genesis.json"));
  });

  it("uses genesis_HOME when deriving profile state dir", () => {
    const env: Record<string, string | undefined> = {
      genesis_HOME: "/srv/genesis-home",
      HOME: "/home/other",
    };
    applyCliProfileEnv({
      profile: "work",
      env,
      homedir: () => "/home/fallback",
    });

    const resolvedHome = path.resolve("/srv/genesis-home");
    expect(env.genesis_STATE_DIR).toBe(path.join(resolvedHome, ".genesis-work"));
    expect(env.genesis_CONFIG_PATH).toBe(
      path.join(resolvedHome, ".genesis-work", "genesis.json"),
    );
  });
});

describe("formatCliCommand", () => {
  it.each([
    {
      name: "no profile is set",
      cmd: "genesis doctor --fix",
      env: {},
      expected: "genesis doctor --fix",
    },
    {
      name: "profile is default",
      cmd: "genesis doctor --fix",
      env: { genesis_PROFILE: "default" },
      expected: "genesis doctor --fix",
    },
    {
      name: "profile is Default (case-insensitive)",
      cmd: "genesis doctor --fix",
      env: { genesis_PROFILE: "Default" },
      expected: "genesis doctor --fix",
    },
    {
      name: "profile is invalid",
      cmd: "genesis doctor --fix",
      env: { genesis_PROFILE: "bad profile" },
      expected: "genesis doctor --fix",
    },
    {
      name: "--profile is already present",
      cmd: "genesis --profile work doctor --fix",
      env: { genesis_PROFILE: "work" },
      expected: "genesis --profile work doctor --fix",
    },
    {
      name: "--dev is already present",
      cmd: "genesis --dev doctor",
      env: { genesis_PROFILE: "dev" },
      expected: "genesis --dev doctor",
    },
  ])("returns command unchanged when $name", ({ cmd, env, expected }) => {
    expect(formatCliCommand(cmd, env)).toBe(expected);
  });

  it("inserts --profile flag when profile is set", () => {
    expect(formatCliCommand("genesis doctor --fix", { genesis_PROFILE: "work" })).toBe(
      "genesis --profile work doctor --fix",
    );
  });

  it("trims whitespace from profile", () => {
    expect(formatCliCommand("genesis doctor --fix", { genesis_PROFILE: "  jbgenesis  " })).toBe(
      "genesis --profile jbgenesis doctor --fix",
    );
  });

  it("handles command with no args after genesis", () => {
    expect(formatCliCommand("genesis", { genesis_PROFILE: "test" })).toBe(
      "genesis --profile test",
    );
  });

  it("handles pnpm wrapper", () => {
    expect(formatCliCommand("pnpm genesis doctor", { genesis_PROFILE: "work" })).toBe(
      "pnpm genesis --profile work doctor",
    );
  });
});
