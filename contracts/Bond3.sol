// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/ISmartDerivativeContract.sol";
import "contracts/LendingContractLogic.sol";

contract Bond3 is Pausable, AccessControl, ISmartDerivativeContract, LendingContractLogic  {
    struct Trade {
        address initiator;
        address counterparty;
        string tradeData;
        int position;
        int256 paymentAmount;
        string initialSettlementData;
        bool confirmed;
        bool settled;
    }
    mapping(string => Trade) public trades;
    string[] public tradeIds;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event RequestSent(address indexed recipient, uint256 amount);

    constructor(uint256 _annualInterestRate) LendingContractLogic(_annualInterestRate) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function inceptTrade(
        address _withParty, 
        string memory _tradeData, 
        int _position, 
        int256 _paymentAmount, 
        string memory _initialSettlementData
    ) external override {
        string memory tradeId = string(abi.encodePacked(_tradeData, _position, block.timestamp));
        trades[tradeId] = Trade({
            initiator: msg.sender,
            counterparty: _withParty,
            tradeData: _tradeData,
            position: _position,
            paymentAmount: _paymentAmount,
            initialSettlementData: _initialSettlementData,
            confirmed: false,
            settled: false
        });
        tradeIds.push(tradeId);
        trades[tradeId].confirmed = true;
        // TODO collect protocol fee
        
        emit TradeIncepted(msg.sender, tradeId, _tradeData);
    }
    
    function confirmTrade(
        address _withParty, 
        string memory _tradeData, 
        int _position, 
        int256 _paymentAmount, 
        string memory _initialSettlementData
    ) external override {
        string memory tradeId = string(abi.encodePacked(_tradeData, _position, block.timestamp));
        require(trades[tradeId].counterparty == msg.sender, "Not the counterparty");
        trades[tradeId].confirmed = true;
        emit TradeConfirmed(msg.sender, tradeId);
    }
    
    function initiateSettlement() external override {
        // For simplicity, we assume there is only one active trade at a time.
        require(tradeIds.length > 0, "No trades available");
        string memory tradeId = tradeIds[tradeIds.length - 1];
        require(trades[tradeId].confirmed, "Trade not confirmed");
        emit TradeSettlementRequest(trades[tradeId].tradeData, trades[tradeId].initialSettlementData);
    }
    
    function performSettlement(
        int256 settlementAmount, 
        string memory settlementData
    ) external override {
        require(tradeIds.length > 0, "No trades available");
        string memory tradeId = tradeIds[tradeIds.length - 1];
        require(trades[tradeId].confirmed, "Trade not confirmed");
        trades[tradeId].settled = true;
        trades[tradeId].paymentAmount = settlementAmount;
        address payable counterparty = payable(trades[tradeId].counterparty);
        payable(counterparty).transfer(uint256(trades[tradeId].paymentAmount));
        emit TradeSettlementPhase();
    }
    
    function afterTransfer(
        uint256 transactionHash, 
        bool success
    ) external override {
        // Implementation of transfer logic if needed
    }
    
    function requestTradeTermination(
        string memory tradeId, 
        int256 _terminationPayment
    ) external override {
        require(trades[tradeId].initiator == msg.sender, "Not the initiator");
        trades[tradeId].settled = true;
        trades[tradeId].paymentAmount = _terminationPayment;
        emit TradeSettlementPhase();
    }
    
    function confirmTradeTermination(
        string memory tradeId, 
        int256 _terminationPayment
    ) external override {
        require(trades[tradeId].counterparty == msg.sender, "Not the counterparty");
        trades[tradeId].settled = true;
        trades[tradeId].paymentAmount = _terminationPayment;
        emit TradeSettlementPhase();
    }

    function testSendFunds(uint256 _amount) external {
        emit RequestSent(msg.sender, _amount);
    }
}
