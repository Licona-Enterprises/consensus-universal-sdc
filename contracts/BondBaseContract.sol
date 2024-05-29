// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "contracts/ISmartDerivativeContract.sol";

abstract contract BondBaseContract is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, ISmartDerivativeContract  {
    struct Trade {
        address initiator;
        address counterparty;
        string tradeData;
        int position;
        uint256 paymentAmount;
        string initialSettlementData;
        bool confirmed;
        bool settled;
    }
    mapping(string => Trade) public trades;
    string[] public tradeIds;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address pauser, address upgrader)
        initializer public
    {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(UPGRADER_ROLE, upgrader);
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
        uint256 _paymentAmount, 
        string memory _initialSettlementData
    ) external {
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

        // TODO transfer funds to this contract from msg.sender to address this
        // Transfer funds from msg.sender to this contract address
        address payable contractAddress = payable(address(this));
        contractAddress.transfer(_paymentAmount);

        // TODO collect protocol fee
        
        emit TradeIncepted(msg.sender, tradeId, _tradeData);
    }
    
    function confirmTrade(
        address _withParty, 
        string memory _tradeData, 
        int _position, 
        uint256 _paymentAmount, 
        string memory _initialSettlementData
    ) external {
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
        uint256 settlementAmount, 
        string memory settlementData
    ) external {
        require(tradeIds.length > 0, "No trades available");
        string memory tradeId = tradeIds[tradeIds.length - 1];
        require(trades[tradeId].confirmed, "Trade not confirmed");

        // TODO transfer the settlementAmount to the counterparty


        trades[tradeId].settled = true;
        trades[tradeId].paymentAmount = settlementAmount;
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
        uint256 _terminationPayment
    ) external {
        require(trades[tradeId].initiator == msg.sender, "Not the initiator");
        trades[tradeId].settled = true;
        trades[tradeId].paymentAmount = _terminationPayment;
        emit TradeSettlementPhase();
    }
    
    function confirmTradeTermination(
        string memory tradeId, 
        uint256 _terminationPayment
    ) external {
        require(trades[tradeId].counterparty == msg.sender, "Not the counterparty");
        trades[tradeId].settled = true;
        trades[tradeId].paymentAmount = _terminationPayment;
        emit TradeSettlementPhase();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}
