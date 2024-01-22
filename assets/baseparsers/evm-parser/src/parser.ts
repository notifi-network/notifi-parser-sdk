import type { Evm, BlockchainType } from "@notifi-network/fusion-types";
import { encodeEventTopics, decodeEventLog, type Hex } from "viem";
import { ERC20_ABI as ABI } from "./abi.js";

const eventID = "";
type Log = Evm.ParserArgs["logs"][0];

type DecodedTransferLog = {
  from: `0x${string}`;
  to: `0x${string}`;
  value: bigint;
  hash: `0x${string}`;
};

const topic = {
  transferEvent: encodeEventTopics({
    abi: ABI,
    eventName: "Transfer",
  })[0],
} as const;

// ERC20 and ERC721 transfers are both emitted as Transfer events.
// However, ERC721 transfers have a data field that is empty
const isErc20Transfer = (log: Log) =>
  log.topics[0] === topic.transferEvent && log.data !== "0x";

// Decode the raw log into the underlying event arguments
// This is done using the viem library & the standard ERC20 ABI
// We also add the transaction hash to the returned object
const decodeTransferEventWithHash = (log: Log): DecodedTransferLog => ({
  ...decodeEventLog({
    abi: ABI,
    data: log.data,
    topics: log.topics,
    eventName: "Transfer",
  }).args,
  hash: log.transactionHash as Hex,
});

// Create two events for each transfer, one for the sender and one for the receiver
const createTransferEventsTuple =
  (blockchain: BlockchainType, blockNumber: number, rpc: Evm.Rpc) =>
  async (transfer: DecodedTransferLog) => {
    const { from, to, value, hash } = transfer;
    const [fromBalance, toBalance] = await Promise.all([
      rpc.getAccountBalance({ account: from, blockNumber }),
      rpc.getAccountBalance({ account: to, blockNumber }),
    ]);

    const commonEventStructure = {
      eventTypeId: eventID.toLowerCase(),
      metadata: {
        from: from.toLowerCase(),
        to: to.toLowerCase(),
        value: value.toString(),
      },
      blockchain,
      changeSignature: hash,
    };

    const fromEvent = {
      ...commonEventStructure,
      comparisonValue: from.toLowerCase(),
      metadata: {
        ...commonEventStructure.metadata,
        newBalance: fromBalance,
      },
    };

    const toEvent = {
      ...commonEventStructure,
      comparisonValue: to.toLowerCase(),
      metadata: {
        ...commonEventStructure.metadata,
        newBalance: toBalance,
      },
    };

    return [fromEvent, toEvent];
  };

// All parsers must export a parse function, this is the entrypoint for the parser
// This parser filters out ERC20 Transfers, decodes them, and returns a list of events
// (two per transfer, one for sender/receiver)
const parse: Evm.Parser["parse"] = async (
  args, // Contains the blockchain type information, alongside the raw block and logs
  rpc, // Used to make rpc calls to the blockchain
  // Note: the following arguments are not used in this parser, and could be omitted
  // here we include them for completeness
  _storage, // Used to store and retrieve data between parser runs
  _logger, // Used to log messages to your account's log stream
  _subscriptions, // Used to gather the subscriptions for a given parser source
  _fetchRpc // Used to make arbitrary http(s) requests to external services
) => {
  //destructure the given blockchain and block from parserArgs
  const { blockchain, logs } = args;
  //Gather all logs that are erc20 Transfers
  const transferLogs = logs.filter(isErc20Transfer);
  const decodedTransfers = transferLogs.map(decodeTransferEventWithHash);
  const blockNumber = Number(args.block.number);

  // Create events conforming to the CommonHost.Event interface
  const transferEventTuples = await Promise.all(
    decodedTransfers.map(
      createTransferEventsTuple(blockchain, blockNumber, rpc)
    )
  );
  // Flatten the array of tuples into a single array of events
  return transferEventTuples.flat();
};

export { parse };
