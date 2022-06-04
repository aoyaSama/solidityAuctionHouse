# solidityAuctionHouse
In this project, develop some Ethereum contracts to implement decentralised auctions. This is a classic application for a smart contract platform and can be implemented (in basic form) in a very small amount of code.

1. Arbitration

    Use a designated judge to arbitrate disputes
    
    Arbitration is optimistic in that the judge (if specified) does not need to be involved in the common case. After the auction ends, either the buyer themselves can call finalize() to release payment to the seller (if the item is received successfully) or the seller can call refund() to return the money to the buyer if they are unable to complete the transaction. If a judge address is specified, the judge also has the ability to call either refund() or finalize() to adjudicate a dispute on behalf of the buyer or seller, respectively. If no judge is specified, then your contract should default to favoring the seller: the seller can call refund() if desired, or anybody can call finalize().

2. Dutch auction

    Price descends until some bidder is willing to pay it

    A Dutch auction, also called an open-bid descending-price auction or clock auction, is a type of auction in which the price of the offering (the item for sale) is initially set to a very high value and then gradually lowered. The first bidder to make a bid instantly wins the offering at the current price. There may be a non-zero reserve price representing the minimum price the seller is willing to sell for. The offering can never be sold for less than the reserve price, which prevents the auction from being won at a price that is lower than what the offering’s owner is willing to accept.

3. English auction

    New bids increase the price until no new bid has been posted for a fixed number of blocks

    This is the classic auction house format: the auctioneer starts with an initial offering price (the reserve price) and asks for an opening bid. Once some individual has placed a bid at or above this price, others are free to offer a higher bid within a short time interval. This is usually where the auctioneer will say “Going once, going twice...” before declaring the offering sold to the last bidder.

4. Vickrey 

    Bidders submit sealed bid commitments and later reveal them. Highest revealed bid wins but pays only the price of the second highest revealed bid. Bidders who don’t reveal forfeit a deposit.

    An offline Vickrey auction proceeds as follows: all participants submit their bid in a sealed envelope. The auctioneer then opens all of the envelopes, and the highest bidder obtains the offering but only pays the price specified by the second-highest bidder (hence the term second-price auction). You can see intuitively why this is equivalent to the outcome an English auction would have eventually produced: this is the price the highest bidder would have needed to pay (perhaps plus a small increment) to outbid their closest competitor in an English auction.

## Requirement
Truffle
Ganache
Dev Container for Ethereum

### Run test

```bash
truffle test
```

To run individual tests
```bash
truffle test test/Bidders.sol test/TestFramework.sol test/<test_name>.sol
```

## Author
Auction.sol, DutchAuction.sol, EnglishAuction.sol, and VickreyAuction.sol by Takemitsu Yamanaka #757038

Code forked from @jcb82

This assignment was originally developed by Joseph Bonneau and Benedikt Bünz at Stanford, with later development by Joseph Bonneau, Assimakis Kattis and Kevin Choi at NYU.