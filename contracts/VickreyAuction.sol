// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;

    // TODO: place your code here
    mapping(address => bytes32) bids;
    mapping(address => uint) bidValues;
    mapping(address => bool) deposits;

    uint private bidders = 0;
    address[] revealedBidders;

    event Log(uint bidAmount);
    event xLog(bytes32 encoded);

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            address _timerAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;

        // TODO: place your code here
    }

    // Record the player's bid commitment
    // Bidders can update their previous bid for free if desired.
    function commitBid(bytes32 bidCommitment) public payable {
        // TODO: place your code here
        // Only allow commitments before biddingDeadline
        require(time() < biddingDeadline);

        // Make sure exactly bidDepositAmount is provided (for new bids)
        if(bids[msg.sender] == 0)
            require(msg.value == bidDepositAmount);
        else // Bet is free now, so reject if bidder put another deposit
            require(msg.value == 0);
        
        bids[msg.sender] = bidCommitment;
    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(bytes32 nonce) public payable{
        // TODO: place your code here

        // reject early reveal
        require(biddingDeadline <= time() && time() < revealDeadline);

        // there might be a collision???
        bytes32 bid = keccak256(abi.encodePacked(msg.value, nonce));

        // reject reveal if incorrect nounce or funding given
        require(bid == bids[msg.sender]);

        // once bid correctly revealed, then deposit can be returned
        if(bids[msg.sender] != 0)
            refunds[msg.sender] += bidDepositAmount;
        
        // check if bid higher than minimum price, if not refund the bidder
        if(msg.value >= minimumPrice){
            bidValues[msg.sender] = msg.value;
            revealedBidders.push(msg.sender);
            bidders += 1;
        }
        else{
            refunds[msg.sender] += msg.value;
        }
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){
        // TODO: place your code here

        // no winner should declared before deadline nor when there isn't a valid bid
        if(time() < revealDeadline || revealedBidders.length == 0) 
            winner = address(0);
        else if (revealedBidders.length == 1) // only 1 valid bid
            winner = revealedBidders[0];
        else if (revealedBidders.length > 1)
            (winner, ) = getHighestBidder();
        
        return winner;
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {
        // TODO: place your code here

        if (revealedBidders.length == 1){ // only 1 valid bid
            winnerAddress = revealedBidders[0];
            winningPrice = minimumPrice;
        } 
        else if (revealedBidders.length > 1){
            (winnerAddress, winningPrice) = getHighestBidder();

            // set refund amount for each bidder
            for(uint i = 0; i < revealedBidders.length; i++) {
                address bidder = revealedBidders[i];
                if(bidder == winnerAddress)
                    continue;
                refunds[bidder] += bidValues[bidder];
                bidValues[bidder] = 0;
            }
        }

        // pay only the price of the second highest revealed bid, refund rest
        refunds[winnerAddress] += bidValues[winnerAddress] - winningPrice;
        bidValues[winnerAddress] = 0;

        // call the general finalize() logic
        super.finalize();
    }

    // returns the bidder with the highest bid and the second highest bid
    function getHighestBidder() public view returns (address winner, uint){
        uint highestBid = minimumPrice;
        uint secondHighest = 0;
        for(uint i = 0; i < revealedBidders.length; i++) {
            if(bidValues[revealedBidders[i]] > highestBid){
                secondHighest = highestBid;
                highestBid = bidValues[revealedBidders[i]];
                winner = revealedBidders[i];
            }
            if(secondHighest < bidValues[revealedBidders[i]] 
                    && bidValues[revealedBidders[i]] < highestBid)
                secondHighest = bidValues[revealedBidders[i]];
        }
        if(secondHighest == 0)
            secondHighest = minimumPrice;

        return (winner, secondHighest);
    }
}
