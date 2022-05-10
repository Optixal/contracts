// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

// All code from SimpleStorage contract will be placed here, you can manually copy it in too
import "./SimpleStorage.sol";

// Inheritance with "is", it'll have everything from SimpleStorage
contract StorageFactory is SimpleStorage {
    SimpleStorage[] public simpleStorageArray;

    // Deploys a simple storage contract within this contract
    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage(); // new is for contracts/classes, structs dunnid
        simpleStorageArray.push(simpleStorage);
    }

    // Calls the store function in simple storage contract
    function sfStore(uint256 _simpleStorageIndex, uint256 simpleStorageNumber) public {
        // To interact with a contract, you need:
        // * Address
        // * ABI (Application Binary Interface)
        SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(simpleStorageNumber);
    }

    // Calls the retrieve function in simple storage contract
    function sfRetrieve(uint256 _simpleStorageIndex) public view returns (uint256) {
        return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).retrieve();
    }
}
