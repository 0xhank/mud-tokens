import { mudConfig } from "@latticexyz/world/register";
export default mudConfig({
  systems: {
    ERC721TestToken: {
      name: "ERC721Test",
      openAccess: true,
    },
    ERC1155TestToken: {
      name: "ERC1155Test",
      openAccess: true,
    },
    ERC20TestToken: {
      name: "ERC20Test",
      openAccess: true,
    },
  },

  tables: {
    TokenLocation: {
      keySchema: { id: "uint256" },
      schema: {
        x: "uint256",
        y: "uint256",
      },
    },
  },
});
