// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bond1.sol";

contract Bond1Factory {
    address[] public deployedContracts;

    event ContractDeployed(address indexed contractAddress);

    function createBond1Contract() external returns (address) {
        Bond1 newContract = new Bond1();
        deployedContracts.push(address(newContract));
        emit ContractDeployed(address(newContract));
        return address(newContract);
    }

    function getDeployedContracts() external view returns (address[] memory) {
        return deployedContracts;
    }
}
