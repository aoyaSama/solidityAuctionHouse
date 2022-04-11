// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

    // TODO: place your code here
    uint private initialTime;
    event Log(uint bidammount);

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;

        // TODO: place your code here
        initialTime = time();
    }


    function bid() public payable{

        // bid happened before initial time or if big happened after initial + bidding period
        require(initialTime <= time() && time() < initialTime + biddingPeriod);
        
        emit Log(msg.value);

        require(msg.value >= currentPrice());
        winningPrice = msg.value;
        winnerAddress = msg.sender;

        // if excess amount, then set a refund amount
        if (msg.value >= currentPrice()) refunds[winnerAddress] = msg.value - currentPrice();
        
        finalize();
        // if(msg.value == currentPrice()){
        //     winningPrice = msg.value;
        //     winnerAddress = msg.sender;
        //     finalize();
        // }
        // else if(msg.value >= currentPrice()){
        //     winnerAddress = msg.sender;
        //     winningPrice = msg.value;
        //     refund();
        // }
    }

    // calculates the current price by querying time() and
    // applying the specified rate of decline in price to the original price.
    function currentPrice() private view returns (uint){
        uint timeSinceStart = time() - initialTime;
        return initialPrice - timeSinceStart*offerPriceDecrement;
    }
}
