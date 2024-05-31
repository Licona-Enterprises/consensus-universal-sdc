// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC1271.sol";

contract SmartContractWallet is IERC1271 {
    address public owner;
    mapping(bytes32 => bool) public executedMessages;
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;
    event MessageSigned(bytes32 indexed messageHash, address indexed signer);
    event RequestSent(address indexed recipient, uint256 amount);
    event FundsSent(address indexed from, address indexed to, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Function to verify if the provided signature is valid for the given data.
     * @param _data Hash of the data that was signed
     * @param _signature Signature byte array associated with _data
     * @return magicValue either 0x1626ba7e or 0x00000000 (0x1626ba7e if valid)
     */
    function isValidSignature(bytes32 _data, bytes memory _signature) external view override returns (bytes4 magicValue) {
        bytes32 messageHash = keccak256(abi.encodePacked(_data, address(this)));
        require(executedMessages[messageHash] == false, "Message already executed");
        
        // Reconstruct the expected signer
        bytes32 r;
        bytes32 s;
        uint8 v;
        // Signature should be 65 bytes, split it
        require(_signature.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        address recoveredSigner = ecrecover(messageHash, v, r, s);
        if (recoveredSigner == owner) {
            return MAGICVALUE;
        } else {
            return 0x00000000;
        }
    }

    function signMessage(string memory _data) external onlyOwner {
        // Parse the string to extract recipient and amount
        (address recipient, uint256 amount) = _parseData(_data);

        // Create the hash of the data
        bytes32 messageHash = keccak256(abi.encodePacked(recipient, amount, address(this)));
        
        // Mark the message as executed
        executedMessages[messageHash] = true;
        
        // Emit the event
        emit MessageSigned(messageHash, msg.sender);
    }

    function _parseData(string memory _data) internal pure returns (address, uint256) {
        // Parsing logic to extract recipient and amount from the string
        // Assume the format is "recipient,amount"
        bytes memory data = bytes(_data);
        uint256 commaIndex;
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] == ",") {
                commaIndex = i;
                break;
            }
        }
        
        // Extract recipient address
        bytes memory recipientBytes = new bytes(commaIndex);
        for (uint256 i = 0; i < commaIndex; i++) {
            recipientBytes[i] = data[i];
        }
        address recipient = _bytesToAddress(recipientBytes);

        // Extract amount
        bytes memory amountBytes = new bytes(data.length - commaIndex - 1);
        for (uint256 i = commaIndex + 1; i < data.length; i++) {
            amountBytes[i - commaIndex - 1] = data[i];
        }
        uint256 amount = _stringToUint(string(amountBytes));

        return (recipient, amount);
    }

    function _bytesToAddress(bytes memory _address) internal pure returns (address) {
        uint160 addr = 0;
        for (uint256 i = 0; i < _address.length; i++) {
            addr <<= 8;
            addr |= uint160(uint8(_address[i]));
        }
        return address(addr);
    }

    function _stringToUint(string memory _s) internal pure returns (uint256) {
        bytes memory b = bytes(_s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] >= 0x30 && b[i] <= 0x39) {
                result = result * 10 + (uint256(uint8(b[i])) - 48);
            }
        }
        return result;
    }

    // Function to send funds from the sender to a contract address
    function sendFundsToContract(address payable _to) external payable onlyOwner {
        require(_to != address(0), "Invalid contract address");
        require(msg.value > 0, "Must send a positive amount");

        (bool success, ) = _to.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit FundsSent(msg.sender, _to, msg.value);
    }
}
