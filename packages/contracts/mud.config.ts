import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  excludeSystems: ["ERC20System", "ERC721System"],
  tables: {
    MetadataTable: {
      keySchema: {},
      tableIdArgument: true,
      schema: {
        totalSupply: "uint256",
        proxy: "address",
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
    ERC721Table: {
      keySchema: { id: "uint256" },
      tableIdArgument: true,
      schema: {
        owner: "address",
        tokenApproval: "address",
        uri: "string",
      },
    },
  },
});
