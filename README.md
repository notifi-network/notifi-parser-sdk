# Notifi Parser SDK Repository

Welcome to the Notifi Parser SDK Repository, your gateway to developing blockchain parsers that run on the Notifi Fusion infrastructure. This repository is designed to provide you with all the necessary tools and files for an efficient development experience. Inside, you will find:

1. A Docker-Compose file that sets up the Notifi Parser development environment along with essential local services.
2. A convenient `start.sh` script to initialize and manage the development environment.
3. More to come!

## Setting Up and Operating the Development Environment

To kickstart the development environment, you need to run the `start.sh` script. Ensure that all necessary environment variables are in place before executing the script.

### Required Environment Variables

Below is a table describing the environment variables for the consumed by the script:

| Variable            | Purpose                                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `NOTIFI_INIT_TOKEN` | This is a special token utilized for generating future authentication tokens.                                                                    |
| `NOTIFI_DAPP_ID`    | Identifies the DApp for which you'll create auth tokens using the `NOTIFI_INIT_TOKEN`.                                                           |
| `NOTIFI_AUTH_TOKEN` | This token is necessary for API requests within the development environment - It can be derived from the `NOTIFI_INIT_TOKEN` if one is provided. |
| `FUSION_SOURCE_ID`  | Identifies the specific parser you intend to develop or modify in the Notifi environment.                                                        |

### Launching the Development Environment

To activate the environment, you must provide either of the following sets of variables:

- Set 1: `NOTIFI_INIT_TOKEN`, `NOTIFI_DAPP_ID`, and `FUSION_SOURCE_ID`.
- Set 2: `NOTIFI_AUTH_TOKEN` and `FUSION_SOURCE_ID`.

After securing these values, make sure they are set and run the script to start the environment.

For example, using the `NOTIFI_AUTH_TOKEN` and `FUSION_SOURCE_ID` variables:

```bash
FUSION_SOURCE_ID="<PARSER_SOURCE_ID_HERE>" NOTIFI_AUTH_TOKEN="<AUTH_TOKEN_HERE>" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/notifi-network/notifi-parser-sdk/main/start.sh)"
```
