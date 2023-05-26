import yargs from "yargs";
import commandModule from "./tokengen";

yargs(hideBin(process.argv)).command(commandModule).argv;

function hideBin(argv: string[]): string | readonly string[] | undefined {
  console.log("argv: ", argv);
  throw new Error("Function not implemented.");
}
