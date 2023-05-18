import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    ERC20TokenTable: {
      keySchema: { tokenId: "uint256", id: "address" },
      schema: {
        // accessed via owner address
        balance: "uint256",
        allowance: "uint256",

        // only accessed via Singleton Key, set once during post deploy script
        proxy: "address",
        totalSupply: "uint256",
        name: "string",
        symbol: "string",
      },
    },
    AllowanceTable: {
      keySchema: { tokenId: "uint256", owner: "address", operator: "address" },
      schema: {
        allowance: "uint256",
      },
    },
  },
});
