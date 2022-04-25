---
layout: nodes.liquid
section: ethereum
date: Last Modified
title: 'Existing Job Request'
permalink: 'docs/existing-job-request/'
whatsnext:
  {
    'Find Existing Jobs': '/docs/listing-services/',
    'API Reference': '/docs/chainlink-framework/',
    'Contract Addresses': '/docs/decentralized-oracles-ethereum-mainnet/',
  }
metadata:
  title: 'Make an Existing Job Request'
  description: 'Learn how to utilize existing Chainlink external adapters to make calls to APIs from smart contracts.'
  image:
    0: '/files/OpenGraph_V3.png'
---

## Overview

Using an _existing_ Oracle Job makes your smart contract code more succinct. This page explains how to retrieve the gas price from an existing Chainlink job that calls [etherscan gas tracker API](https://docs.etherscan.io/api-endpoints/gas-tracker#get-gas-oracle).

**Table of Contents**

- [Existing Job](#existing-job)
- [Setting the LINK token address, Oracle, and JobId](#setting-the-link-token-address-oracle-and-jobid)
- [Make an Existing Job Request](#make-an-existing-job-request)

## Existing Job

In [Make a GET Request](../make-a-http-get-request/), the example contract code declared which URL to use, where to find the data in the response, and how to convert it so that it can be represented on-chain.

This example uses an existing job that is pre-configured to make requests to get [the gas price](https://docs.etherscan.io/api-endpoints/gas-tracker#get-gas-oracle).

[Etherscan gas oracle](https://docs.etherscan.io/api-endpoints/gas-tracker#get-gas-oracle) returns the current Safe, Proposed and Fast gas prices. To check the response, you can directly paste the following URL in your browser `https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=YourApiKeyToken` or run this command in your terminal:

```curl
curl -X 'GET' \
  'https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=YourApiKeyToken' \
  -H 'accept: application/json'
```

The response should be similar to the following:

```json
{
  "status": "1",
  "result": {
    "LastBlock": "14653286",
    "SafeGasPrice": "33",
    "ProposeGasPrice": "33",
    "FastGasPrice": "35",
    "suggestBaseFee": "32.570418457",
    "gasUsedRatio": "0.366502543599508,0.15439818258491,0.9729006,0.4925609,0.999657066666667"
  }
}
```

For this example, we created a job that leverages the [EtherScan External Adapter](https://github.com/smartcontractkit/external-adapters-js/tree/develop/packages/sources/etherscan) to fetch the _SafeGasPrice_ , _ProposeGasPrice_ and _FastGasPrice_. You can learn more about External Adapters [here](/docs/external-adapters/).
To consume an API, your contract must inherit from [ChainlinkClient](https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/ChainlinkClient.sol). This contract exposes a struct named `Chainlink.Request`, which your contract can use to build the API request. The request must include the following parameters:

- Link token address
- Oracle address
- Job id
- Request fee
- Task parameters
- Callback function signature

> ❗️ Note on Funding Contracts
>
> Making a GET request will fail unless your deployed contract has enough LINK to pay for it. **Learn how to [Acquire testnet LINK](../acquire-link/) and [Fund your contract](../fund-your-contract/)**.

```solidity
{% include 'samples/APIRequests/GetGasPrice.sol' %}
```

<div class="remix-callout">
    <a href="https://remix.ethereum.org/#url=https://docs.chain.link/samples/APIRequests/GetGasPrice.sol" target="_blank" >Open in Remix</a>
    <a href="/docs/conceptual-overview/#what-is-remix" >What is Remix?</a>
</div>

To use this contract:

1. Open the [contract in Remix](https://remix.ethereum.org/#url=https://docs.chain.link/samples/APIRequests/GetGasPrice.sol).

1. Compile and deploy the contract using the Injected Web3 environment. The contract includes all the configuration variables for the _Kovan_ testnet. Make sure your wallet is set to use _Kovan_. The _constructor_ sets the following parameters:

   - The Chainlink Token address for _Kovan_ by calling the [`setChainlinkToken`](/docs/chainlink-framework/#setchainlinktoken) function.
   - The Oracle contract address for _Kovan_ by calling the [`setChainlinkOracle`](/docs/chainlink-framework/#setchainlinkoracle) function.
   - The `jobId`: A specific job for the oracle node to run. In this case, the job is very specific to the use case as it returns the gas prices. You can find the job spec for the Chainlink node in this example [here](/docs/direct-request-existing-job/).

1. Fund your contract with 0.1 LINK. To learn how to send LINK to contracts, read the [Fund Your Contracts](/docs/fund-your-contract/) page.

1. Call the `gasPriceFast`, `gasPriceAverage` and `gasPriceSafe` functions to confirm that the `gasPriceFast`, `gasPriceAverage` and `gasPriceSafe` state variables are equal to zero.

1. Run the `requestGasPrice` function. This builds the `Chainlink.Request`. Note how succinct the request is.

1. After few seconds, call the `gasPriceFast`, `gasPriceAverage` and `gasPriceSafe` functions. You should get a non-zero responses.

## Setting the LINK token address, Oracle, and JobId

The [`setChainlinkToken`](/docs/chainlink-framework/#setchainlinktoken) function sets the LINK token address for the [network](/docs/link-token-contracts/) you are deploying to. The [`setChainlinkOracle`](/docs/chainlink-framework/#setchainlinkoracle) function sets a specific Chainlink oracle that a contract makes an API call from. The `jobId` refers to a specific job for that node to run.

Each job is unique and returns different types of data. For example, a job that returns a `bytes32` variable from an API would have a different `jobId` than a job that retrieved the same data, but in the form of a `uint256` variable.

[market.link](https://market.link/) provides a searchable catalogue of Oracles, Jobs and their subsequent return types.

## Make an Existing Job Request

If your contract is calling a public API endpoint, an Oracle job might already exist for it. It could mean that you do not need to add the URL or other adapter parameters into the request because the job is already configured to return the desired data. This makes your smart contract code more succinct. To see an example of a contract using an existing job, see the [Make an Existing Job Request](../existing-job-request/) guide.

For more information about the functions in `ChainlinkClient`, visit the [ChainlinkClient API Reference](../chainlink-framework/).
