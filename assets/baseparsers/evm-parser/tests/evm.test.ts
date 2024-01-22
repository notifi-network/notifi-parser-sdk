// This file serves as a simple example of how to use the LocalEvmHost (& its builder) to execute a parser inside a test.
import { LocalEvmHostBuilder } from "@notifi-network/local-fusion";
import * as parser from "../src/parser.js";

// Substitute with your own provider if you hit rate limits!
const RPC_URL = "https://rpc.ankr.com/avalanche" as const;
//This is the BlockchainTypeEnum value for Avalanche
const BLOCKCHAIN_TYPE = 10 as const;

describe("EVM Parser", () => {
  it("should parse all value transactions into a seperate event", async () => {
    const evmHost = new LocalEvmHostBuilder(BLOCKCHAIN_TYPE, RPC_URL)
      .withParserSource(parser)
      .build();

    const events = await evmHost.executeSourceUsingBlock("latest", {
      contractAddresses: [],
      topicHashes: [],
    });

    // Using console.dir to print the events to the console, this is useful for debugging as it will show the full object tree.
    console.dir({ yourParsedEvents: events }, { depth: null });
    // Add your own assertions here!
    expect(events).toBeInstanceOf(Array);
  });
});
