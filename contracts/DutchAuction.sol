// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

    // TODO: place your code here
    uint private initialTime;

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
        // TODO: place your code here
        // bid happened before initial time or if big happened after initial + bidding period
        require(initialTime <= time() && time() < initialTime + biddingPeriod);

        require(msg.value >= currentPrice());
        winningPrice = msg.value;
        winnerAddress = msg.sender;

        // if excess amount, then set a refund amount
        if (msg.value >= currentPrice()) refunds[winnerAddress] = msg.value - currentPrice();
        
        finalize();
    }

    // calculates the current price by querying time() and
    // applying the specified rate of decline in price to the original price.
    function currentPrice() private view returns (uint){
        uint timeSinceStart = time() - initialTime;
        return initialPrice - timeSinceStart*offerPriceDecrement;
    }
}
