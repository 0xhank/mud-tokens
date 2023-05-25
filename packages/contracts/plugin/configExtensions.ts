import { extendMUDCoreConfig } from "@latticexyz/config";
import { zPluginStoreConfig } from "@latticexyz/store/config";
import { zPluginWorldConfig } from "@latticexyz/world";
import { zPluginTokenConfig } from "./plugin";

extendMUDCoreConfig((config) => {
  const modifiedConfig = { ...config } as Record<string, unknown>;
  const tokenConfig = zPluginTokenConfig.parse(config);

  if (tokenConfig.tokens) {
    const worldConfig = zPluginWorldConfig.parse(config);
    const storeConfig = zPluginStoreConfig.parse(config);

    let excludeSystems = (worldConfig.excludeSystems || []) as string[];
    let modules = [];
    tokenConfig.tokens.forEach((token) => {
      const tokenName = `${token.type}${token.name}System.sol`;
      excludeSystems.push(tokenName);
      // modules.push({ name: TokenModule, root: "" });
    });
    modifiedConfig.excludeSystems = excludeSystems;
  }

  return modifiedConfig;
});
