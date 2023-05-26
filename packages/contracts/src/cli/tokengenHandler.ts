import { formatSolidity, renderedSolidityHeader } from "@latticexyz/common/codegen";
import { access, constants, writeFile } from "fs";
import path from "path";

type Token = {
  name: string;
  symbol: string;
  type: string;
};

export async function tokengen(config: Token[], outputBaseDirectory: string) {
  const tokensWithDirectories = new Set(
    config.map((token) => ({ path: path.join("/token/", `${token.name}System.sol`), content: renderToken(token) }))
  );

  // write tables to files
  for (const token of tokensWithDirectories) {
    const fullOutputPath = path.join(outputBaseDirectory, token.path);
    const formattedOutput = await formatSolidity(token.content);
    createFileIfNotExists(fullOutputPath, formattedOutput);
  }
}

function renderToken(config: Token) {
  return `${renderedSolidityHeader}

import { ${config.type}System } from "../src/modules/erc20/${config.type}System.sol";

contract ${config.name}System is ${config.type}System {

  constructor() ${config.type}System("${config.name}") {}
  
}
`;
}

function createFileIfNotExists(filename: string, content: string) {
  access(filename, constants.F_OK, (err) => {
    if (err) {
      writeFile(filename, content, (err) => {
        if (err) throw err;
        console.log(`File ${filename} created.`);
      });
    } else {
      console.log(`File ${filename} already exists.`);
    }
  });
}
