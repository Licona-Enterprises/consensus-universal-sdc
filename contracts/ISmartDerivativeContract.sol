// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartDerivativeContract {
    function inceptTrade(
        address _withParty,
        string memory _tradeData,
        int _position,
        int256 _paymentAmount,
        string memory _initialSettlementData
    ) external;

    function confirmTrade(
        address _withParty,
        string memory _tradeData,
        int _position,
        int256 _paymentAmount,
        string memory _initialSettlementData
    ) external;

    function initiateSettlement() external;

    function performSettlement(
        int256 settlementAmount,
        string memory settlementData
    ) external;

    function afterTransfer(
        uint256 transactionHash,
        bool success
    ) external;

    function requestTradeTermination(
        string memory tradeId,
        int256 _terminationPayment
    ) external;

    function confirmTradeTermination(
        string memory tradeId,
        int256 _terminationPayment
    ) external;

    event TradeIncepted(
        address initiator,
        string tradeId,
        string tradeData
    );

    event TradeConfirmed(
        address confirmer,
        string tradeId
    );

    event TradeActivated(
        string tradeId
    );

    event TradeSettlementRequest(
        string tradeData,
        string lastSettlementData
    );

    event TradeSettlementPhase();
}
