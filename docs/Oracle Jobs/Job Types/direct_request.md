---
layout: nodes.liquid
section: nodeOperator
date: Last Modified
title: 'Direct Request Jobs'
permalink: 'docs/jobs/types/direct-request/'
---

Executes a job upon receipt of an explicit request made by a user. The request is detected via a log emitted by an Oracle or Operator contract. This is similar to the legacy ethlog/runlog style of jobs.

## Spec format

```jpv2
type                = "directrequest"
schemaVersion       = 1
name                = "example eth request event spec"
contractAddress     = "0x613a38AC1659769640aaE063C651F48E0250454C"
# Optional externalJobID: Automatically generated if unspecified
externalJobID       = "0EEC7E1D-D0D2-476C-A1A8-72DFB6633F02"
observationSource   = """
    ds          [type="http" method=GET url="http://example.com"]
    ds_parse    [type="jsonparse" path="USD"]
    ds_multiply [type="multiply" times=100]

    ds -> ds_parse -> ds_multiply
"""
```

### Shared fields

See [shared fields](/docs/jobs/#shared-fields).

### Unique fields

- `contractAddress`: the Oracle or Operator contract to monitor for requests.

### Job type specific pipeline variables

- `$(jobSpec.databaseID)`: the ID of the job spec in the local database. You shouldn't need this in 99% of cases.
- `$(jobSpec.externalJobID)`: the globally-unique job ID for this job. Used to coordinate between node operators in certain cases.
- `$(jobSpec.name)`: the local name of the job.
- `$(jobRun.meta)`: a map of metadata that can be sent to a bridge, etc.
- `$(jobRun.logBlockHash)`: the block hash in which the initiating log was received.
- `$(jobRun.logBlockNumber)`: the block number in which the initiating log was received.
- `$(jobRun.logTxHash)`: the transaction hash that generated the initiating log.
- `$(jobRun.logAddress)`: the address of the contract to which the initiating transaction was sent.
- `$(jobRun.logTopics)`: the log's topics (`indexed` fields).
- `$(jobRun.logData)`: the log's data (non-`indexed` fields).

## Examples

### Get > String Job

Let's assume that a user makes a request to an oracle and would like to fetch a _string_ from the response.

- The smart contract example can be found [here](/docs/api-array-response/).
- The job spec example can be found [here](/docs/direct-request-get-string/).

### Get > Bytes Job

Let's assume that a user makes a request to an oracle and would like to fetch _bytes_ from the response (meaning a reponse that contains an arbitrary-length raw byte data).

- The smart contract example can be found [here](/docs/large-responses/).
- The job spec example can be found [here](/docs/direct-request-get-bytes/).

### Single-Word Example

For this example, assume that a user makes a request to the oracle using the following contract:

```solidity
contract MyClient is ChainlinkClient {
    function doRequest(uint256 _payment) public {
        Chainlink.Request memory req = buildChainlinkRequest(specId, address(this), this.fulfill.selector);
        req.add("fetchURL", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
        req.add("jsonPath", "USD");
        sendChainlinkRequest(req, _payment);
    }

    function fulfill(bytes32 requestID, uint256 answer) public {
        // ...
    }
}
```

This is a single-word response because aside from the `requestID`, the fulfill callback receives only a single-word argument in the `uint256 answer`. You can fulfill this request with a direct request job using the following pipeline:

```jpv2
// First, we parse the request log and the CBOR payload inside of it
decode_log  [type="ethabidecodelog"
             data="$(jobRun.logData)"
             topics="$(jobRun.logTopics)"
             abi="SomeContractEvent(bytes32 requestID, bytes cborPayload)"]

decode_cbor [type="cborparse"
             data="$(decode_log.cborPayload)"]

// Then, we use the decoded request parameters to make an HTTP fetch
fetch [type="http" method=GET url="$(decode_cbor.fetchURL)"]
parse [type="jsonparse" path="$(decode_cbor.jsonPath)" data="$(fetch)"]

// Finally, we send a response on-chain.
// Note that single-word responses automatically populate
// the requestId.
encode_response [type="ethabiencode"
                 abi="(uint256 data)"
                 data="{\\"data\\": $(parse) }"]

encode_tx       [type="ethabiencode"
                 abi="fulfillOracleRequest(bytes32 requestId, uint256 payment, address callbackAddress, bytes4 callbackFunctionId, uint256 expiration, bytes32 data)"
                 data="{\\"requestId\\": $(decode_log.requestId), \\"payment\\": $(decode_log.payment), \\"callbackAddress\\": $(decode_log.callbackAddr), \\"callbackFunctionId\\": $(decode_log.callbackFunctionId), \\"expiration\\": $(decode_log.cancelExpiration), \\"data\\": $(encode_response)}"
                 ]

submit_tx  [type="ethtx" to="0x613a38AC1659769640aaE063C651F48E0250454C" data="$(encode_tx)"]

decode_log -> decode_cbor -> fetch -> parse -> encode_response -> encode_tx -> submit_tx
```

### Multi-Word Example

Let's assume that a user makes a request to an oracle and would like to fetch multiple words in one single request.

- The smart contract example can be found [here](/docs/multi-variable-responses/).
- The job spec example can be found [here](/docs/example-job-spec-multi-word/).
