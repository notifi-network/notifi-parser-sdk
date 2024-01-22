# Guide for generated parser(s)

The source files for your generated parser are inside of /src, with the main file being `parser.ts`. <br />
Inside of `parser.ts` there is a basic blueprint parser. This parser is intended mainly to give you a rough idea of how they are to be written/implemented <br />
Other files/folders include: <br />

1. [/rollup.config.js](`rollup.config.js`) , this file dictates how the parser files are built and transpiled to js. They will be output to a `/dist` directory. You can build the parser files with `npm run build`
2. `/graphl` contains all of the js scripts that handle the creation and upload of your parser. These shouldn't be edited.
   - You can run all of these scripts through the various npm scripts detailed in the package.json file.
3. [/parserConfig.json](`parserConfig.json`) contains all information relevant to the uploading/updating of your parser, as well as some external API calls that the scripts will make. <br />
   The config is split into two parts.

# parserConfig.json

### The parser config contains two main parts:

- fusionConfig -> This contains all properties that are used when creating/updating your parser. Some of these fields will require manual editing, others will be automatically updated.
- tooling-> This contains two values that are used when making external API calls

## fusionConfig

- `blockChainType` just corresponds to the blockchain your parser is intended for, when you generate the parser you will be prompted to choose one of the following.
  - ARBITRUM
  - AVALANCHE
  - BINANACE
  - ETHEREUM
  - EVMOS
  - INJECTIVE
  - OFF-CHAIN
  - OPTIMISM
  - OSMOSIS
  - POLYGON
  - SUI
  - ZKSYNC
    <br />
- `filter` , this JSON object defines some of your parsers behaviour when running. Fields in this object include: <br />

  - EventTypes/TopicHashes -> The field name for this changes depending on the blockchainType, TopicHashes for EVM parsers and EventTypes for most others. It determines what blocks are processed by your parser. For example in an Ethereum parser, including "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef" in TopicHashes will cause only blocks with transfer events to be parsed.
  - CronExecutionInterval -> This field dictates when your parser is ran. Having it set to `00:00:00` means that your parser will not be treated as a `cron job`. Otherwise, the value you set will determine how often your parser is invoked. For example if you set it to `00:01:00`, then your parser will be invoked every minute.
  - ContractAddresses -> This field contains the wallet address(es) that will be emitting your parsers events.

  #### Notes for different chains filters

- `fusionEventTypeIds` , this property is an array that contains the IDs and names for all of your parsers events (the events that it will be emitting). By default, there should be one entry in the array `{"eventID": {id}, "name": {name}}`, this is the ID and the name for the sample event Type inside of `parser.ts` (the ID is a unique UUID, and you should change the event name depending on the context). If you choose to emit different events from your parser then you will need to add these entries to this list. It is recommend to use UUID to generate a unique ID for the event, and give the name some relevant context.

- `parserID` is the unique ID for your parser source. It's null by default (and should be kept so). When you create the source for your parser, an ID will be automatically generated and this value will be updated in the parserConfig file accordingly.
- `maxScheduleIntervalInSeconds` is set to **10** by default, change to suit your use case but keep it above 0.
  `parserConfig` whenever you want. If you leave the value unset (null) then default mainnet RPC endpoints will be used. These endpoints are used when fetching block heights when activating your fusion source.

## tooling

This part of the `parserConfig` file contains two values:

- `rpcEndpoint`: When generating the parser you will be prompted to enter your own RPC endpoint for your parser (with an API key if applicable). You may change this value inside of the `parserConfig` file whenever you want. This endpoint is used to fetch block heights when activating the parser at a specific block height. Feel free to use your own private endpoints, if left as `null` then a mainnet public endpoint will be used instead.
- `storedCursor`: This value is automatically saved and updated, it contains the cursor of some fusion execution logs. This is then used when fetching logs at a given point.

# Details for uploading/updating your parser and its event type(s)

Inside of `package.json` there are three main scripts to be aware of:

- **test** This script is used to run the tests for your parser. By default, your parser comes with a basic test that runs it against an example scenario. For example, with EVM based parsers, the initial test runs the parser against a block with some transfers. <br />
  The tests use the jest testing library with ts-jest.
- **build** This script uses the rollup config to transpile your parsers `parser.ts typescript` file into `javascript`.

- **debug** This script will start a node debugger inside of the container allowing you to debug your parser TS file directly. You can then connect to this debugger from your external VSCode window (on your machine) using the provided launch config inside of `.vscode/launch.json`
- **createSource**: This script is responsible for creating the entry for your parser in the database. The details of your new entry will be pulled from `parserConfig` . Note that this is responsible purely for creating the new Fusion Source, not for creating your parsers Event entries, or uploading/activating your parser.
- **addEvents**: This script is responsible for creating the entries for your parsers Events. This script will first create Fusion Event entries for the events that your parser is emitting from `parserConfig.json`, and then will attempt to register these events for your fusion source (if you've already ran the `createSource` script). You can run this script as much as you want, already registered events will be ignored
- **updateSource**: This script is responsible for updating the details of your parsers Fusion Source. This should be ran if you wish to make changes after already creating the source. Details to be updated will again be pulled from the [/parserConfig.json](`parserConfig.json`).
- **buildUpload**: This script will transpile your parsers `typescript` files into `javascript` and then upload them to an s3 bucket on AWS.
- **uploadParser**: This script behaves the same as `buildUpload` but skips the build step. Use this if your file is already built and you want to skip redundantly rebuilding.
- **getLogs**: This script fetches fusion execution logs for your parser. When you run this you will have the choice to grab the **x** most recent execution logs, or grab the next **x** logs based on the most recent stored cursor in [/parserConfig.json](`parserConfig.json`)

# Order of execution (of scripts)

Order of execution of the various NPM scripts is not very important, though there is a general flow you should follow. <br />

1. run `npm run createSource` to create the Fusion Source entry for your parser. This will not handle the creation of your event types (this comes after). If you attempt to create the source twice, it will be ignored.
2. To add your event types to your new Fusion Source, you can run `npm run addEvents`, this will both create the Fusion Event entries, and (if you've created your Fusion Source), will also 'link' them to the Fusion Source. Each time you add a new event to your parser, you will have to manually add its ID to the eventTypeIds array in [/parserConfig.json](`parserConfig.json`).
3. Once you have your Fusion Source created, and the relevant Event Types linked, then you can run `npm run buildUpload` to upload the parser files to an S3 bucket. Note that this script needs to be ran after the Fusion Source and its associated events are added and linked.
4. Finally, to active the source you can run `npm run activateFusionSource`, You will be prompted to either enter a block height or default to 'latest'. This will be the block your parser starts at upon activation.
