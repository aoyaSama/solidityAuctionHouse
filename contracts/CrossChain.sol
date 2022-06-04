// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CrossChain {
    uint256 t2;
    uint256 y;
    address alice;
    address bob;

    //Bob sends 1 Ether to this contract
    //
    /*
    Alice will send her Bitcoin to a transaction output with the above script. 
    Bob will send his Ether to a special (one-time use) smart contract sketched
    below. Either Bob should end up with Alice’s Bitcoin and Alice 
    with Bob’s Ether, or neither should change hands.*/

    function AliceRedeem(uint256 x) public {
        require(block.timestamp < t2); // Alice reveals before t2
        require(bytes32(y) == sha256(abi.encodePacked(x))); // Alice reveals x
        selfdestruct(payable(alice)); // send ether to alice
    }

    function BobRedeem() public {
        require(msg.sender == bob); // Bob can reclaim the funds
        require(block.timestamp >= t2); // Bob can reclaim at or after t2
        selfdestruct(payable(bob));
    }
}
