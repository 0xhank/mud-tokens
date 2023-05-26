import { getSrcDirectory } from "@latticexyz/common/foundry";
import { loadConfig } from "@latticexyz/config/node";
import path from "path";
import type { CommandModule } from "yargs";
import { z } from "zod";
import { zPluginTokenConfig } from "../plugin/plugin";
import { tokengen } from "./tokengenHandler";

export type TokenConfig = z.output<typeof zPluginTokenConfig>;

type Options = {
  configPath?: string;
};

const commandModule: CommandModule<Options, Options> = {
  command: "tokengen",

  describe: "Autogenerate MUD token smart contracts based on the config file",

  builder(yargs) {
    return yargs.options({
      configPath: { type: "string", desc: "Path to the config file" },
    });
  },

  async handler({ configPath }) {
    const config = (await loadConfig(configPath)) as TokenConfig;
    const srcDir = await getSrcDirectory();

    await tokengen(config.tokens, path.join(srcDir, config.codegenDirectory));

    process.exit(0);
  },
};

export default commandModule;
