// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Paypal{

/* 
The contract starts by defining an owner of the contract, which is initially set to the address of the account 
that deploys the contract. This owner has special privileges within the contract.
*/

address public owner;

constructor(){
        owner = msg.sender;
}

//Create Struct and Mappping for request, transaction & name

/* 
# Several custom data structures are defined using structs:

-> request: Represents a payment request with the requestor (who initiated the request), the amount of payment, 
   an optional message, and an optional name.

-> sendReceive: Represents a payment transaction, recording whether it's a "Send" or "Receive" action, the amount, 
   a message, the other party's address, and their name.

-> userName: Associates a user's Ethereum address with a name and records whether they have provided a name.

# Three mappings are defined to store data:
-> names: Maps Ethereum addresses to user names.
-> requests: Maps Ethereum addresses to arrays of payment requests.
-> history: Maps Ethereum addresses to arrays of payment transactions. */

struct request {
        address requestor;
        uint256 amount;
        string message;
        string name;
}

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
mapping(address  => request[]) requests;
mapping(address  => sendReceive[]) history;

//Add a name to wallet address

function addName(string memory _name) public {
    
    userName storage newUserName = names[msg.sender];
    newUserName.name = _name;
    newUserName.hasName = true;

}

//Create a Request
function createRequest(address user, uint256 _amount, string memory _message) public {
        
    request memory newRequest;
    newRequest.requestor = msg.sender;
    newRequest.amount = _amount;
    newRequest.message = _message;
    if(names[msg.sender].hasName){
        newRequest.name = names[msg.sender].name;
    }
    requests[user].push(newRequest);

}


//Pay a Request

// The payRequest function allows users to pay a specific payment request. 
// It verifies that the request exists and the correct payment amount has been sent. 
// If everything checks out, it transfers the payment to the requestor and 
// adds the transaction to the transaction history.

function payRequest(uint256 _request) public payable {
    
    require(_request < requests[msg.sender].length, "No Such Request");
    request[] storage myRequests = requests[msg.sender];
    request storage payableRequest = myRequests[_request];
        
    uint256 toPay = payableRequest.amount;
    require(msg.value == (toPay), "Pay Correct Amount");

    payable(payableRequest.requestor).transfer(msg.value);

    addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);

    myRequests[_request] = myRequests[myRequests.length-1];
    myRequests.pop();

}

function addHistory(address sender, address receiver, uint256 _amount, string memory _message) private {
        
    sendReceive memory newSend;
    newSend.action = "Send";
    newSend.amount = _amount;
    newSend.message = _message;
    newSend.otherPartyAddress = receiver;
    if(names[receiver].hasName){
        newSend.otherPartyName = names[receiver].name;
    }
    history[sender].push(newSend);

    sendReceive memory newReceive;
    newReceive.action = "Receive";
    newReceive.amount = _amount;
    newReceive.message = _message;
    newReceive.otherPartyAddress = sender;
    if(names[sender].hasName){
        newReceive.otherPartyName = names[sender].name;
    }
    history[receiver].push(newReceive);
}

// Get all requests sent to a User
// The getMyRequests function allows a user to retrieve all the payment requests they have received. 
// It returns arrays of the requestor's address, amount, message, and name for each request.

function getMyRequests(address _user) public view returns(
         address[] memory, 
         uint256[] memory, 
         string[] memory, 
         string[] memory) 
{
    address[] memory addrs = new address[](requests[_user].length);
    uint256[] memory amnt = new uint256[](requests[_user].length);
    string[] memory msge = new string[](requests[_user].length);
    string[] memory nme = new string[](requests[_user].length);
    
    for (uint i = 0; i < requests[_user].length; i++) {
        request storage myRequests = requests[_user][i];
        addrs[i] = myRequests.requestor;
        amnt[i] = myRequests.amount;
        msge[i] = myRequests.message;
        nme[i] = myRequests.name;
    }
    
    return (addrs, amnt, msge, nme);        
         
}

// The getMyHistory function allows users to retrieve all historic 
// transactions they have been involved in. 

// It returns an array of sendReceive structs representing the transaction history. 
function getMyHistory(address _user) public view returns(sendReceive[] memory){
        return history[_user];
}

// The getMyName function is used to retrieve the name associated with a user's address.
function getMyName(address _user) public view returns(userName memory){
        return names[_user];
}

}
