# Notifi Fusion EVM Parser
This project has been bootstrapped with the [Notifi Fusion CLI tool](https://www.npmjs.com/package/@notifi-network/local-fusion). A scaffold for a simple parser has been provided - please find the entrypoint in [src/parser.ts](./src/parser.ts).

## Project Config
Inside the root you will see a notifi.config.json file. This file is used to declare the parsers within the project - if you bootstrapped this projet using the notifi developer envrionemt this will be precofigured for you for a single parser.

## Getting Started
To get started, please install the project dependencies by running:
```bash
npm install
```

Once the dependencies are installed, you can start writing your arbitrary parser logic in [src/parser.ts](./src/parser.ts). Inside the file you will see a single export, `parse`. If you have the typescript plugins installed in your IDE, you should be able to see the type definitions for the `parse` function.

Essentially, the parse function has the following signature:
```typescript
(args: Evm.ParserArgs, rpc: Evm.Rpc, storage: Storage, logger: winston.Logger, subscriptions: FusionSubscriptions, fetchProxy: FetchProxy) => Promise<CommonHost.Event[]>
```

The events which are returned will be materialized into the configured alerts in the Notifi Fusion UI via our core services.


Each of the injected arguments are described below:
1. `args` - This contains the raw block data and any logs which matched the parser's filter.
2. `rpc` - This is an instance of the `Rpc` class which provides a simple interface to interact with the Ethereum JSON-RPC API.
3. `storage` - This is an instance of the `Storage` class which provides a simple interface to interact with the Notifi Fusion storage layers (you have access to both Persistent and Ephemeral store).
4. `logger` - This is an instance of the `winston.Logger` class which provides a simple interface to log messages - any logs will be forwarded to the Notifi Fusion logging layers.
5. `subscriptions` - This is an instance of the `FusionSubscriptions` class which provides a simple interface to fetch the alert subscriptions for a given event topic.
6. `fetchProxy` - This is an instance of the `FetchProxy` class which provides a simple interface to make RESTful API requests.

## Building the Parser
You will see a rollup.config.js file in the root of the project. This file is used to build the parser into a single file which can be run in the Notifi Fusion infrastructure. To build the parser, you can run:
```bash
npm run build
```

Depending on which dependencies you add, you may need to adjust the rollup configuration.

## CLI commands
The Notifi Fusion CLI tool provides a number of commands to help you manage your parser.

1. `fusion parser import <fusion source id>`: This command will automatically add your parser to the project config - this is useful if you have multiple parsers in the same project.

2. `fusion parser upload <fusion source id>`: This command will locate the entrypoint for the specified fusion source ID via your project config and upload the parser to the Notifi Fusion infrastructure.

3. `fusion parser activate <fusion source id> [cursor value]`: This command will activate the specified parser in the Notifi Fusion infrastructure. Note the optional cursor value which can be used to specify the block number to start from.

4. `fusion parser deactivate <fusion source id>`: This command will deactivate the specified parser in the Notifi Fusion infrastructure.