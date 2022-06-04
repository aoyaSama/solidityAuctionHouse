// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {
    uint256 public initialPrice;
    uint256 public biddingPeriod;
    uint256 public offerPriceDecrement;

    // TODO: place your code here
    uint256 private initialTime;

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        address _timerAddress,
        uint256 _initialPrice,
        uint256 _biddingPeriod,
        uint256 _offerPriceDecrement
    ) Auction(_sellerAddress, _judgeAddress, _timerAddress) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;

        // TODO: place your code here
        initialTime = time();
    }

    function bid() public payable {
        // bid happened before initial time or
        // if big happened after initial + bidding period
        require(initialTime <= time() && time() < initialTime + biddingPeriod);

        require(msg.value >= currentPrice());
        winningPrice = msg.value;
        winnerAddress = msg.sender;

        // if excess amount, then set a refund amount
        if (msg.value >= currentPrice())
            refunds[winnerAddress] = msg.value - currentPrice();

        finalize();
    }

    // calculates the current price by querying time() and
    // applying the specified rate of decline in price to the original price.
    function currentPrice() private view returns (uint256) {
        uint256 timeSinceStart = time() - initialTime;
        return initialPrice - timeSinceStart * offerPriceDecrement;
    }
}
