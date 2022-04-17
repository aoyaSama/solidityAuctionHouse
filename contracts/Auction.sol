// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Timer.sol";


contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;

    // TODO: place your code here
    bool internal finalized = false;
    bool internal refunded = false;
    uint refundAmount = 0;
    uint soldAmount = 0;

    // mapping of withdrawable funds by all bidders
    mapping(address => uint256) refunds;

    // constructor
    constructor(address _sellerAddress,
                     address _judgeAddress,
                     address _timerAddress) {

        judgeAddress = _judgeAddress;
        timerAddress = _timerAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == address(0))
          sellerAddress = msg.sender;
    }

    // This is provided for testing
    // You should use this instead of block.number directly
    // You should not modify this function.
    function time() public view returns (uint) {
        if (timerAddress != address(0))
          return Timer(timerAddress).getTime();

        return block.number;
    }

    function getWinner() public view virtual returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // Don’t allow any calls to call finalize() or refund() before the auction is over.
    // If no judge is specified, anybody can call this.
    function finalize() public virtual {
        // reject if auction already finalised 
        require(!finalized);

        // reject if no winner when finalising
        require(winnerAddress != address(0));

        // If a judge is specified, then only the judge or winning bidder may call.
        if(judgeAddress != address(0))
            require(msg.sender == judgeAddress || msg.sender == winnerAddress);

        soldAmount = winningPrice;
        finalized = true;
    }

    // Money should only be refunded to the winner.
    function refund() public {
        // cannot refund if already auction already finalised
        require(!finalized);

        // cannot call to refund twice
        require(!refunded);

        // reject if no winner when finalising
        require(winnerAddress != address(0));

        // ONLY be called by seller or the judge (if a judge exists).
        if(judgeAddress != address(0))
            require(msg.sender == judgeAddress || msg.sender == sellerAddress);
        else
            require(msg.sender == sellerAddress);
        
        // add amount into refunds
        refunds[winnerAddress] = winningPrice;

        // since it's refunded, the winning price goes back to 0
        winningPrice = 0; 
        
        refunded = true;
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    function withdraw() public {
        
        if(finalized && msg.sender == sellerAddress && soldAmount > 0){
            // set value to 0 so seller can't call this before 'transfer' returns
            soldAmount = 0;
            payable(msg.sender).transfer(winningPrice);
        }
        else if(refunds[msg.sender] > 0){
            // if seller or judge ends early, then winner can get refund
            // refund the full amount of their funds
            uint toRefund = refunds[msg.sender];
            refunds[msg.sender] = 0;
            payable(msg.sender).transfer(toRefund);
        }
    }
}
