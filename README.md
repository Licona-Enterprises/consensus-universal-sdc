# On-Chain Bond Issuance using ISmartDerivativeContract Interface

Issuing a bond on-chain using the ISmartDerivativeContract interface can leverage the smart contract's functionalities to automate and secure various aspects of the bond issuance and management process. Here are some potential use cases:

## 1. Automated Bond Issuance and Confirmation

### Incepting the Bond
The issuer can use the `inceptTrade` function to create a new bond issuance agreement with an investor, detailing the bond's terms, position, payment amount, and initial settlement data.
```solidity
inceptTrade(investorAddress, bondTerms, bondPosition, paymentAmount, initialSettlementData);
```

### Confirming the Bond
The investor confirms the bond issuance by calling the `confirmTrade` function, ensuring mutual agreement on the bond terms.
```solidity
confirmTrade(issuerAddress, bondTerms, bondPosition, paymentAmount, initialSettlementData);
```

### Event Emissions
The `TradeIncepted` and `TradeConfirmed` events are emitted, providing an immutable on-chain record of the bond issuance and agreement confirmation.
```solidity
emit TradeIncepted(issuerAddress, bondId, bondTerms);
emit TradeConfirmed(investorAddress, bondId);
```

## 2. Interest Payment and Settlement

### Initiating Interest Payment
Periodic interest payments can be managed by calling the `initiateSettlement` function. This triggers the settlement phase for interest payment.
```solidity
initiateSettlement();
```

### Performing Settlement
The bond issuer or a predefined automated process performs the actual interest payment settlement by calling the `performSettlement` function with the settlement amount and data.
```solidity
performSettlement(interestAmount, settlementData);
```

### Event Emission
The `TradeSettlementRequest` and `TradeSettlementPhase` events are emitted to track the settlement process.
```solidity
emit TradeSettlementRequest(bondTerms, lastSettlementData);
emit TradeSettlementPhase();
```

## 3. Bond Redemption and Termination

### Requesting Bond Termination
At the bond's maturity, the issuer can request the termination of the bond by calling the `requestTradeTermination` function with the bond ID and final payment amount.
```solidity
requestTradeTermination(bondId, finalPaymentAmount);
```

### Confirming Bond Termination
The investor confirms the bond termination by calling the `confirmTradeTermination` function.
```solidity
confirmTradeTermination(bondId, finalPaymentAmount);
```

### Event Emission
The `TradeSettlementPhase` event is emitted, marking the bond's termination and final settlement.
```solidity
emit TradeSettlementPhase();
```

## 4. Post-Transfer Actions

### Recording Transfers
Any transfer of bond ownership can be recorded by calling the `afterTransfer` function. This ensures all transfers are logged on-chain.
```solidity
afterTransfer(transactionHash, transferSuccess);
```

## 5. Transparency and Auditability

### On-Chain Records
All actions related to bond issuance, confirmation, settlements, and transfers are logged on-chain, providing transparency and an immutable audit trail for regulatory compliance and investor assurance.

## 6. Potential Integration with DeFi

### Liquidity Provision
The bond contract can be integrated with DeFi platforms, enabling bonds to be used as collateral for loans or traded on decentralized exchanges, increasing liquidity and market participation.

### Automated Yield Generation
Interest payments and bond settlements can be automated through smart contract interactions with yield farming protocols, optimizing returns for investors.

By leveraging the ISmartDerivativeContract interface, bond issuers and investors can benefit from increased automation, transparency, and efficiency in the bond issuance and management process, while also opening up new opportunities for integration with the broader decentralized finance ecosystem.
```


HARDHAT WORKSPACE

Hardhat workspace is present when:
i. Remix loads for the very first time 
ii. A new workspace is created with 'Default' template
iii. There are no files existing in the File Explorer

This workspace contains 3 directories:

1. 'contracts': Holds three contracts with increasing levels of complexity.
2. 'scripts': Contains four typescript files to deploy a contract. It is explained below.
3. 'tests': Contains one Solidity test file for 'Ballot' contract & one JS test file for 'Storage' contract.

SCRIPTS

The 'scripts' folder has four typescript files which help to deploy the 'Storage' contract using 'web3.js' and 'ethers.js' libraries.

For the deployment of any other contract, just update the contract's name from 'Storage' to the desired contract and provide constructor arguments accordingly 
in the file `deploy_with_ethers.ts` or  `deploy_with_web3.ts`

In the 'tests' folder there is a script containing Mocha-Chai unit tests for 'Storage' contract.

To run a script, right click on file name in the file explorer and click 'Run'. Remember, Solidity file must already be compiled.
Output from script will appear in remix terminal.

Please note, require/import is supported in a limited manner for Remix supported modules.
For now, modules supported are ethers, web3, swarmgw, chai, multihashes, and hardhat only for hardhat.ethers object/plugin.
