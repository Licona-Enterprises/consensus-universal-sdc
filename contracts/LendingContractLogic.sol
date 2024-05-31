// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract LendingContractLogic {
    address public owner;
    uint256 public principal;
    uint256 public annualInterestRate; // Annual interest rate in percentage (e.g., 5 for 5%)
    uint256 public lastInterestCalculationTime;
    uint256 public totalInterestOwed;

    event PrincipalDeposited(address indexed lender, uint256 amount);
    event InterestUpdated(uint256 newTotalInterestOwed);
    event InterestWithdrawn(uint256 amount);

    constructor(uint256 _annualInterestRate) {
        owner = msg.sender;
        annualInterestRate = _annualInterestRate;
        lastInterestCalculationTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function depositPrincipal() external payable virtual onlyOwner {
        principal = msg.value;
        lastInterestCalculationTime = block.timestamp;
        emit PrincipalDeposited(msg.sender, msg.value);
    }

    function calculateInterest() public virtual {

        uint256 timeElapsed = block.timestamp - lastInterestCalculationTime;
        uint256 interest = (principal * annualInterestRate * timeElapsed) / (365 days * 100);

        totalInterestOwed += interest;
        lastInterestCalculationTime = block.timestamp;

        emit InterestUpdated(totalInterestOwed);
    }

    function getTotalInterestOwed() external view virtual returns (uint256) {
        return totalInterestOwed;
    }

    function withdrawInterest() external virtual onlyOwner {
        require(totalInterestOwed > 0, "No interest owed");

        payable(owner).transfer(totalInterestOwed);
        emit InterestWithdrawn(totalInterestOwed);

        totalInterestOwed = 0;
        lastInterestCalculationTime = block.timestamp;
    }
}
