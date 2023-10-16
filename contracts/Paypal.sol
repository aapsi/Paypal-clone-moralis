// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {

    // Define the owner of the smart contract
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    // Create struct and mappings for request, transaction & name

    struct request {
        address requestor;
        uint256 amount;
        string message;
        string name; 
    }

    // transaction
    struct sendReceive {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName {
        string name;
        bool hasName;
    }

    mapping(address => userName) names;
    mapping(address => request[]) requests;
    mapping(address => sendReceive[]) history;


    // add a name to wallet address

    function addName(string memory _name) public {
        userName storage newUserName = names[msg.sender];
        newUserName.name = _name;
        newUserName.hasName = true;
    }   


    // create a request

    // pay a request

    // get all requests sent to a user

    // get all historic transactions user has been a part of
}
