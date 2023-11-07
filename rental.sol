pragma solidity ^0.8.0;

contract RentalHouse {
    address payable public landlord;
    uint256 public rentAmount;
    uint256 public securityDeposit;
    uint256 public leaseDuration;
    uint256 public leaseStart;
    address public tenant;
    bool public isLeased;

    event LeaseStarted(address indexed _tenant, uint256 _leaseStart);
    event LeaseEnded(address indexed _tenant, uint256 _leaseEnd);

    constructor(uint256 _rentAmount, uint256 _securityDeposit, uint256 _leaseDuration) {
        landlord = payable(msg.sender);
        rentAmount = _rentAmount;
        securityDeposit = _securityDeposit;
        leaseDuration = _leaseDuration;
    }

    function lease(address _tenant) public payable {
        require(msg.sender == landlord, "Only landlord can lease the house");
        require(!isLeased, "House is already leased");
        require(msg.value == rentAmount + securityDeposit, "Incorrect amount sent");

        tenant = _tenant;
        isLeased = true;
        leaseStart = block.timestamp;

        emit LeaseStarted(_tenant, leaseStart);
    }

    function endLease() public {
        require(msg.sender == landlord || msg.sender == tenant, "Only landlord or tenant can end the lease");
        require(isLeased, "House is not leased");

        uint256 leaseEnd = block.timestamp;
        uint256 duration = leaseEnd - leaseStart;
        uint256 refundAmount = securityDeposit;

        if (duration < leaseDuration) {
            refundAmount -= rentAmount * (leaseDuration - duration);
        }

        isLeased = false;
        tenant = address(0);
        leaseStart = 0;

        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }

        emit LeaseEnded(msg.sender, leaseEnd);
    }
}
