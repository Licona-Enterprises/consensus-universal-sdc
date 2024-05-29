// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISmartDerivativeContract.sol";

contract CollateralizedOTC1 is ISmartDerivativeContract {
    struct Trade {
        address withParty;
        string tradeData;
        int position;
        int256 paymentAmount;
        string initialSettlementData;
        bool isActive;
        bool isSettled;
        int256 collateral;
    }

    mapping(string => Trade) public trades;
    int256 public marginBuffer;

    constructor(int256 _marginBuffer) {
        marginBuffer = _marginBuffer;
    }

    function inceptTrade(
        address _withParty, 
        string memory _tradeData, 
        int _position, 
        int256 _paymentAmount, 
        string memory _initialSettlementData
    ) 
        external override 
    {
        require(_paymentAmount >= marginBuffer, "Insufficient collateral");
        
        Trade memory newTrade = Trade({
            withParty: _withParty,
            tradeData: _tradeData,
            position: _position,
            paymentAmount: _paymentAmount,
            initialSettlementData: _initialSettlementData,
            isActive: false,
            isSettled: false,
            collateral: _paymentAmount
        });

        trades[_tradeData] = newTrade;
        emit TradeIncepted(msg.sender, _tradeData, _tradeData);
    }

    function confirmTrade(
        address _withParty, 
        string memory _tradeData, 
        int _position, 
        int256 _paymentAmount, 
        string memory _initialSettlementData
    ) 
        external override 
    {
        Trade storage trade = trades[_tradeData];
        require(trade.withParty == _withParty, "Trade party mismatch");
        require(trade.paymentAmount >= marginBuffer, "Insufficient collateral");

        trade.isActive = true;
        emit TradeConfirmed(msg.sender, _tradeData);
    }

    function initiateSettlement() external override {
        // Placeholder for settlement logic
        emit TradeSettlementPhase();
    }

    function performSettlement(
        int256 settlementAmount, 
        string memory settlementData
    ) 
        external override 
    {
        // Settlement logic: update the trade's payment amount
        Trade storage trade = trades[settlementData];
        require(trade.isActive, "Trade is not active");

        trade.paymentAmount += settlementAmount;
        trade.isSettled = true;

        // Reset the trade's value to zero after settlement
        trade.paymentAmount = 0;
        emit TradeSettlementRequest(trade.tradeData, settlementData);
    }

    function afterTransfer(uint256 transactionHash, bool success) external override {
        // Placeholder for post-transfer logic
    }

    function requestTradeTermination(
        string memory tradeId, 
        int256 _terminationPayment
    ) 
        external override 
    {
        Trade storage trade = trades[tradeId];
        require(trade.isActive, "Trade is not active");

        // If the termination payment is sufficient, terminate the trade
        if (_terminationPayment >= marginBuffer) {
            trade.isActive = false;
            trade.isSettled = true;
            emit TradeActivated(tradeId);
        } else {
            revert("Insufficient termination payment");
        }
    }

    function confirmTradeTermination(
        string memory tradeId, 
        int256 _terminationPayment
    ) 
        external override 
    {
        Trade storage trade = trades[tradeId];
        require(trade.isActive, "Trade is not active");

        // If the termination payment is sufficient, terminate the trade
        if (_terminationPayment >= marginBuffer) {
            trade.isActive = false;
            trade.isSettled = true;
            emit TradeActivated(tradeId);
        } else {
            revert("Insufficient termination payment");
        }
    }
}
