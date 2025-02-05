// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ConverPrice} from "./ConverPrice.sol";


contract FundMe {
    using ConverPrice for uint256;
    error FundeMe__Require_More_Fund();
    error FundMe__Only_Owner_Can_Withdraw();
    error FundMe__Withdrawal_Failed();

    address[] private funders;
    mapping(address => uint256) private fundersToAmount;
    address private i_owner;

    const MINIMUM_AMOUNT_FUNDING_USD = 5 * 10 ** 18; // 5e18 values are handled in wei and it is e18 to 1eth

    constructor() {
        // Set the owner as the contract intializer
        i_owner = msg.sender;
    }

    // Fund the contract by anyone
        // Minimum 5$ value of eth should be sent for qualifying
        // Follows CEI
    function fund() public payable{
        uint256 amountSentInUsd = convertEthToUsd(this.value);
        // Check if correct amount is sent if not revert with custom error
        if(amountSentInUsd < MINIMUM_AMOUNT_FUNDING_USD) {
            revert FundeMe__Require_More_Fund();
        }

        // Keep a list of funders addresses in an array
        funders.push(msg.sender)
        // Keep a mapping of funder's address to amount funded 
            // Consider the case if the same funder funds multiple time
        funderToAmount[msg.sender] += msg.value;
    }

    // Withdraw all funds from contract by the owner of the contract
        // Only owner can withdraw
    functio withdrawAllFundsFromContract() public isOwner {
        // Check if there is some balance in the contract
        if(address(this).balance == 0) {
            revert FundMe__No_Funds_To_Withdraw;
        }
        // Empty the funders array and mapping
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funderAddress = funders[funderIndex];
            fundersToAmount[funderAddress] = 0;
        }
        funders = new address[](0);

        // Transfer the amount from contract to owner
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if(!success) {
            revert FundMe__Withdrawal_Failed;
        }
    }

    modifier isOwner {
        if(msg.sender != i_owner) {
            revert FundMe__Only_Owner_Can_Withdraw;
        }
        _;
    }

    receive() external payable{
        fund();
    }

    fallback() external payable {
        fund();
    }

    // Getters
    function getFunderAddressByIndex(uint256 index) public view returns(address) {
        return funders[index];
    }

    function getAmountFundedByFunderAddress(address funderAddress) public view returns(uint256) {
        return fundersToAmount[funderAddress];
    }

    function getOwnerAddress() public view returns(address) {
        return i_owner;
    }

    function getMinimumAmountForFunding() public view returns(uint256) {
        return MINIMUM_AMOUNT_FUNDING_USD;
    }

    function getPriceFeedVersion() public view return (uint256) {
        return getPriceFeedVersionLib();
    }




}