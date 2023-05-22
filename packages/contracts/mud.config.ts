import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  excludeSystems: ["ERC20System", "ERC20TestToken"],
  tables: {
    ERC20Table: {
      keySchema: { id: "address" },
      tableIdArgument: true,
      schema: {
        // accessed via owner address
        balance: "uint256",
        allowance: "uint256",

        // only accessed via Singleton Key, set once during deployment of proxy
        totalSupply: "uint256",
        name: "string",
        symbol: "string",
      },
    },
    AllowanceTable: {
      keySchema: { owner: "address", operator: "address" },
      tableIdArgument: true,
      schema: {
        allowance: "uint256",
      },
    },
  },
});
