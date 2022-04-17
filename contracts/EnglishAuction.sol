// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {
    uint256 public initialPrice;
    uint256 public biddingPeriod;
    uint256 public minimumPriceIncrement;

    // TODO: place your code here
    uint256 private initialTime;
    uint256 private winningBid;

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        address _timerAddress,
        uint256 _initialPrice,
        uint256 _biddingPeriod,
        uint256 _minimumPriceIncrement
    ) Auction(_sellerAddress, _judgeAddress, _timerAddress) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        // TODO: place your code here
        initialTime = time();
        winningBid = initialPrice;
    }

    function bid() public payable {
        // bid happened before initial time or if big happened after initial + bidding period
        require(initialTime <= time() && time() < initialTime + biddingPeriod);

        // check if inital bet
        if(time() == initialTime)
            require(msg.value >= winningBid);
        else // If the bid is not greater, the money is sent back.
            require(msg.value >= winningBid + minimumPriceIncrement);

        if (winnerAddress != address(0))
            //value of the previous bid made available immediately 
            // for withdrawal by the previous bidder
            refunds[winnerAddress] += winningBid;

        winnerAddress = msg.sender;
        winningBid = msg.value;
        initialTime = time();
    }

    // Need to override the default implementation
    function getWinner() public view override returns (address winner) {
        // no winner is annouced before auction bidding time is over
        if(time() < initialTime + biddingPeriod) 
            return address(0);
        else
            return winnerAddress;
    }
}
