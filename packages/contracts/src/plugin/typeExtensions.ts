import "@latticexyz/store/register";

interface TokenConfig {
  tokens: {
    name: string;
    symbol: string;
    type: "ERC20" | "ERC721";
  }[];
}

declare module "@latticexyz/config" {
  // eslint-disable-next-line @typescript-eslint/no-empty-interface
  export interface MUDCoreUserConfig extends TokenConfig {}
  // eslint-disable-next-line @typescript-eslint/no-empty-interface
  export interface MUDCoreConfig extends TokenConfig {}
}
