import { mudConfig } from "@latticexyz/world/register";
// import "@latticexyz/world/token";
export default mudConfig({
  excludeSystems: ["ERC20System", "ERC721System"],
  // tokens: [{ name: "ERC20Test", symbol: "ERC", type: "ERC20" }],
  tables: {},
  systems: {},
  modules: [
    {
      name: "ERC721TestModule",
      root: false,
      args: [
        { value: "ERC721Test", type: "string" },
        { value: "ERC", type: "string" },
      ],
    },
  ],
});
