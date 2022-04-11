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

    event winningBidIncreased(address bidder, uint256 bidAmount);
    event Log(uint256 bidAmount);

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

        if (winnerAddress != address(0)) {
            // Sending the money back by simply using
            // winningBidder.send(winningBid) is a risk to the security
            // since it could execute a contract that is not trusted.
            // It is always preferable to let the recipients
            // withdraw their money themselves.
            refunds[winnerAddress] += winningBid;
        }
        winnerAddress = msg.sender;
        winningBid = msg.value;
        initialTime = time();
        emit Log(address(winnerAddress).balance);
        emit Log(address(this).balance);
        // winningBidIncreased(msg.sender, msg.value);
    }

    // Need to override the default implementation
    function getWinner() public view override returns (address winner) {
        // no winner should be declared before deadline
        if(time() < initialTime + biddingPeriod) return address(0);

        return winnerAddress;
        // TODO: place your code here
    }

    // function currentPrice() private view returns (uint){
    //     uint timeSinceStart = time() - initialTime;
    //     return initialPrice - timeSinceStart*offerPriceDecrement;
    // }
}
