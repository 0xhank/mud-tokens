import { extendMUDCoreConfig } from "@latticexyz/config";
import { zPluginWorldConfig } from "@latticexyz/world";
import { zPluginTokenConfig } from "./plugin";

extendMUDCoreConfig((config) => {
  const modifiedConfig = { ...config } as Record<string, unknown>;
  const tokens = zPluginTokenConfig.parse(config)?.tokens;
  console.log("tokens", tokens);

  if (!tokens || tokens.length === 0) return modifiedConfig;

  const worldConfig = zPluginWorldConfig.parse(config);

  const newModules = tokens.map((token) => ({
    name: `${token.type}Module`,
    root: false,
    args: [
      { value: token.name, type: "string" },
      { value: token.symbol, type: "string" },
    ],
  }));

  modifiedConfig.systems = tokens.reduce((acc: Record<string, { name: string; openAccess: boolean }>, token) => {
    let key = token.name + "System";
    acc[key] = {
      name: token.name,
      openAccess: true,
    };
    return acc;
  }, {});

  modifiedConfig.modules = [...worldConfig.modules, ...newModules];

  modifiedConfig.excludeSystems = [...worldConfig.excludeSystems, "ERC20System", "ERC721System"];
  console.log("config extended", modifiedConfig);
  return modifiedConfig;
});
