import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  excludeSystems: ["ERC20System", "ERC20TestToken"],
  tables: {
    MetadataTable: {
      keySchema: {},
      tableIdArgument: true,
      schema: {
        totalSupply: "uint256",
        name: "string",
        symbol: "string",
      },
    },
    BalanceTable: {
      keySchema: { id: "address" },
      tableIdArgument: true,
      schema: {
        balance: "uint256",
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
