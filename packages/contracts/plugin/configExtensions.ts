import { extendMUDCoreConfig } from "@latticexyz/config";
import { zPluginWorldConfig } from "@latticexyz/world";
import { zPluginTokenConfig } from "./plugin";

extendMUDCoreConfig((config) => {
  const modifiedConfig = { ...config } as Record<string, unknown>;
  const tokenConfig = zPluginTokenConfig.parse(config);

  if (!tokenConfig.tokens) return modifiedConfig;

  const worldConfig = zPluginWorldConfig.parse(config);

  const newModules = tokenConfig.tokens.map((token) => ({
    name: `${token.type}Module`,
    root: false,
    args: [
      { value: token.name, type: "string" },
      { value: token.symbol, type: "string" },
    ],
  }));

  modifiedConfig.modules = [
    ...worldConfig.modules,
    {
      name: "SnapSyncModule",
      root: true,
      args: [],
    },
    ...newModules,
  ];

  return modifiedConfig;
});
