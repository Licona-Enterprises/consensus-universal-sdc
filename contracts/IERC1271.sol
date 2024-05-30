// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1271 {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    // bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    /**
     * @dev Should return whether the signature provided is valid for the provided data.
     * @param _data Arbitrary length data that was signed
     * @param _signature Signature byte array associated with _data
     * @return magicValue either 0x1626ba7e or 0x00000000 (0x1626ba7e if valid)
     */
    function isValidSignature(bytes32 _data, bytes memory _signature) external view returns (bytes4 magicValue);
}
