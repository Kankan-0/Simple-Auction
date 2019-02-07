pragma solidity >= 0.4.22 < 0.6.0 ;

contract SimpleAuction {
    address payable public beneficiary;
    uint public auctionEndTime;

    address public highestBidder;
    uint public highestBid;
    
    mapping (address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor (
        uint _biddingTime,
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
        auctionEndTime = now + _biddingTime;
    }

    function bid() public payable {

        /**
        Check whether auction ended or not
        Check whether the bid value is greater than the existing highest bid
        */

        require(now <= auctionEndTime, 'Already Ended');
        require(msg.value > highestBid, 'Already has a higher bid');
        

        /**
        If the bid value exceed the current highest bid
        Mark the bid value to be returned to the bidder.
        Set the new highest bid and highest bidder
        */

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(highestBidder, highestBid);

    }

    function withDraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {

            /**
            First make the pending return value for the address zero and then try to withdraw. If failed, reset the amount 
            Otherwise if we try withdrawing first and making it zero later, security problem can arise where someone can execute the withdraw multiple times before it gets to the make zero statement
            */

            pendingReturns[msg.sender] = 0;
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        /**
        A good design practice is to structure the functions that interact with other contracts into three phrases
        1. Check the conditions
        2. Perform the actions
        3. Interact with other contracts
        */

        // 1. Checking the conditions

        require(now >= auctionEndTime);
        require(!ended, 'function has already been called');

        // 2. Performing the actions

        ended = true;
        emit AuctionEnded (highestBidder, highestBid);

        // 3. Interacting with other contracts

        beneficiary.transfer(highestBid);

    }

}
