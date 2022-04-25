---
layout: nodes.liquid
section: nodeOperator
date: Last Modified
title: 'Direct Request Jobs'
permalink: 'docs/jobs/types/direct-request/'
---

Executes a job upon receipt of an explicit request made by a user. The request is detected via a log emitted by an Oracle or Operator contract. This is similar to the legacy ethlog/runlog style of jobs.

**Table of Contents**

- [Spec format](#spec-format)
  - [Shared fields](#shared-fields)
  - [Unique fields](#unique-fields)
  - [Job type specific pipeline variables](#job-type-specific-pipeline-variables)
- [Examples](#examples)
  - [Get > Uint256 Job](#get--uint256-job)
  - [Get > String Job](#get--string-job)
  - [Get > Bytes Job](#get--bytes-job)
  - [Multi-Word Job](#multi-word-job)
  - [Existing Job](#existing-job)

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

### Get > Uint256 Job

Let's assume that a user makes a request to an oracle to call a public API, retrieve a number from the response, remove any decimals and return _uint256_.

- The smart contract example can be found [here](/docs/single-word-response/).
- The job spec example can be found [here](/docs/direct-request-get-uint256/).

### Get > String Job

Let's assume that a user makes a request to an oracle and would like to fetch a _string_ from the response.

- The smart contract example can be found [here](/docs/api-array-response/).
- The job spec example can be found [here](/docs/direct-request-get-string/).

### Get > Bytes Job

Let's assume that a user makes a request to an oracle and would like to fetch _bytes_ from the response (meaning a response that contains an arbitrary-length raw byte data).

- The smart contract example can be found [here](/docs/large-responses/).
- The job spec example can be found [here](/docs/direct-request-get-bytes/).

### Multi-Word Job

Let's assume that a user makes a request to an oracle and would like to fetch multiple words in one single request.

- The smart contract example can be found [here](/docs/multi-variable-responses/).
- The job spec example can be found [here](/docs/direct-request-multi-word/).

### Existing Job

Using an _existing_ Oracle Job makes your smart contract code more succinct. Let's assume that a user makes a request to an oracle that leverages [Etherscan External Adapter](https://github.com/smartcontractkit/external-adapters-js/tree/develop/packages/sources/etherscan) to retrieve the gas price.

- The smart contract example can be found [here](/docs/existing-job-request/).
- The job spec example can be found [here](/docs/direct-request-existing-job/).
