import { Offchain, CommonHost, BlockchainType } from "@notifi-network/fusion-types";
const eventID = ""; //placeholder for now

//grab events from args
//iterate through the event strings and parse them to json to get appropriate metadata
//then with those form a list of Commonhost.Event objects to return

const makeReturnEvent = (event: string): CommonHost.Event => {
  //parse the string to json
  const parsedEvent = JSON.parse(event);
  //return an object that matches CommonHost.Event interface
  return {
    eventTypeId: eventID.toLowerCase(),
    comparisonValue: "*", //all people subscribed to this event will receive an alert
    metadata: {
      from: "placeholder",
      title: parsedEvent.title,
      text: parsedEvent.text,
    },
    blockchain: BlockchainType.BLOCKCHAIN_TYPE_OFF_CHAIN,
    changeSignature: parsedEvent.title + parsedEvent.text,
  };
};

const parse: Offchain.Parser["parse"] = async (
  args,
  _rpc,
  _storage,
  logger,
  _subscriptions,
  _fetchRpc
) => {
  //grab events from args
  const events = args.offchainEvents;

  logger.debug("started parsing");
  //map over list of events and create CommonHost.Event objects for each one
  const returnEvents: CommonHost.Event[] = events.map((event) =>
    makeReturnEvent(event.event)
  );
  return returnEvents;
};

export { parse };
