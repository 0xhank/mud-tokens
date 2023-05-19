import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    ERC20Table: {
      keySchema: { tokenId: "address", id: "address" },
      schema: {
        // accessed via owner address
        balance: "uint256",
        allowance: "uint256",

        // only accessed via Singleton Key, set once during post deploy script
        totalSupply: "uint256",
        name: "string",
        symbol: "string",
      },
    },
    AllowanceTable: {
      keySchema: { tokenId: "address", owner: "address", operator: "address" },
      schema: {
        allowance: "uint256",
      },
    },
  },
});
