import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    Counter: {
      keySchema: {},
      schema: "uint32",
      tableIdArgument: true,
    },
    /* --------------------------------- COMMON --------------------------------- */
    AllowanceTable: {
      keySchema: { owner: "address", spender: "address" },
      schema: "uint256",
      tableIdArgument: true,
    },
    BalanceTable: {
      keySchema: { owner: "address" },
      schema: "uint256",
      tableIdArgument: true,
    },
    MetadataTable: {
      keySchema: {},
      schema: {
        totalSupply: "uint256",
        proxy: "address",
        name: "string",
        symbol: "string",
      },
      tableIdArgument: true,
    },
    /* --------------------------------- ERC721 --------------------------------- */
    ERC721Table: {
      keySchema: {
        tokenId: "uint256",
      },
      schema: {
        owner: "address",
        tokenApproval: "address",
        uri: "string",
      },
      tableIdArgument: true,
    },
    /* --------------------------------- ERC1155 -------------------------------- */

    ERC1155ApprovalTable: {
      keySchema: { owner: "address", operator: "address" },
      schema: "bool",
      tableIdArgument: true,
    },
    ERC1155BalanceTable: {
      keySchema: { tokenId: "uint256", owner: "address" },
      schema: "uint256",
      tableIdArgument: true,
    },
    ERC1155MetadataTable: {
      keySchema: {},
      schema: { proxy: "address", uri: "string" },
      tableIdArgument: true,
    },
  },
});
