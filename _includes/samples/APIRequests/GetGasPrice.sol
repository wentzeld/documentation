// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract GetGasPrice is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 public gasPriceFast;
    uint256 public gasPriceAverage;
    uint256 public gasPriceSafe;

    bytes32 private jobId;
    uint256 private fee;

    event RequestGasPrice(
        bytes32 indexed requestId,
        uint256 gasPriceFast,
        uint256 gasPriceAverage,
        uint256 gasPriceSafe
    );

    /**
     * @notice Initialize the link token and target oracle
     *
     * Kovan Testnet details:
     * Link Token: 0xa36085F69e2889c224210F603D836748e7dC0088
     * Oracle: 0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656 (Chainlink DevRel)
     * jobId: 7223acbd01654282865b678924126013
     *
     */
    constructor() {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        setChainlinkOracle(0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656);
        jobId = '7223acbd01654282865b678924126013';
        fee = 0.1 * 10**18; // (Varies by network and job)
    }

    /**
     * Create a Chainlink request the gas price from Etherscan
     */
    function requestGasPrice() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        // No need extra parameters for this job. Send the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _gasPriceFast,
        uint256 _gasPriceAverage,
        uint256 _gasPriceSafe
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestGasPrice(_requestId, _gasPriceFast, _gasPriceAverage, _gasPriceSafe);
        gasPriceFast = _gasPriceFast;
        gasPriceAverage = _gasPriceAverage;
        gasPriceSafe = _gasPriceSafe;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
