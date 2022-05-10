// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// import SafeMath if <0.8.0, then "using SafeMathChainlink for uint256"

contract FundMe {
    address public owner;
    AggregatorV3Interface internal priceFeed;

    // Keep track of who sent us money
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Executes immediately on contract deployment
    constructor() {
        owner = msg.sender;

        /**
         * Network: Rinkeby
         * Aggregator: ETH/USD
         * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
         */
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    // Payable function, user can specify a value in wei in a transaction
    function fundWei() public payable {
        // msg.sender, msg.value
        funders.push(msg.sender); // note, same sender fund multiple times will keep adding to this array! refer to below if statement
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // Payable function, user can specify a value in wei in a transaction
    function fundUSD() public payable {
        // msg.sender, msg.value
        uint256 minimumUSD = 50 * 10**18; // USD 50, 18 dp
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH."); // or without a error msg
        if (addressToAmountFunded[msg.sender] == 0) {
            // to check if this funder already exists (sent an amount before) in the mapping
            funders.push(msg.sender);
        }
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // answer is 8 dp (without the decimals)
        // answer * 10 * 10 ** 10 = 18 dp, matches with wei
        // cast int256 -> uint256
        return uint256(answer * 10000000000);
    }

    // Price (USD, 18 dp) per wei
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        return (ethAmount * getPrice()) / 1000000000000000000;
    }

    // Modifiers are used to change the behaviour of a function in a declarative way
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this.");
        _; // the rest of the code will be run here. onlyOwner wraps the code
    }

    function withdraw() public payable onlyOwner {
        // Reset the mappings back to 0
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            addressToAmountFunded[funders[funderIndex]] = 0;
        }

        // Reset the funders array
        // New keyword for contracts and arrays
        funders = new address[](0);
        // Why we do this instead of just making a new mapping?
        // Bcos mappings cannot be reassigned

        // Only allow the owner/creator of this contract (set in constructor) to withdraw
        // require(msg.sender == owner, "Only the contract owner can withdraw.");
        // msg.sender is an address, need to wrap in payable() to make it a payable address
        payable(msg.sender).transfer(address(this).balance);
        // Transfer last to avoid reentrancy
    }
}
