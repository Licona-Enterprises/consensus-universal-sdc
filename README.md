# On-Chain Bond Issuance using ISmartDerivativeContract Interface

Issuing a bond on-chain using the ISmartDerivativeContract interface can leverage the smart contract's functionalities to automate and secure various aspects of the bond issuance and management process. Here are some potential use cases:

## 1. Automated Bond Issuance and Confirmation

### Incepting the Bond
The issuer can use the `inceptTrade` function to create a new bond issuance agreement with an investor, detailing the bond's terms, position, payment amount, and initial settlement data.
```solidity
inceptTrade(investorAddress, bondTerms, bondPosition, paymentAmount, initialSettlementData);


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