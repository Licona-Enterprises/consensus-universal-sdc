// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CollateralizedOTC1.sol";

contract CollateralizedOTC1Factory {
    address[] public deployedContracts;

    event ContractDeployed(address deployedAddress, address owner);

    function deployCollateralizedOTC(int256 marginBuffer) external returns (address) {
        CollateralizedOTC1 newContract = new CollateralizedOTC1(marginBuffer);
        deployedContracts.push(address(newContract));
        emit ContractDeployed(address(newContract), msg.sender);
        return address(newContract);
    }

    function getDeployedContracts() external view returns (address[] memory) {
        return deployedContracts;
    }
}
