import { mudConfig } from "@latticexyz/world/register";
// import "@latticexyz/world/token";
export default mudConfig({
  excludeSystems: [],
  // tokens: [{ name: "ERC20Test", symbol: "ERC", type: "ERC20" }],
  tables: {
    TokenLocation: {
      keySchema: { id: "uint256" },
      tableIdArgument: true,
      schema: {
        x: "uint256",
        y: "uint256",
      },
    },
  },
  systems: {},
});
