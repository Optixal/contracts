// SPDX-License-Identifier: MIT

// Version of solidity, ^0.6.0 is 0.6.x
pragma solidity >=0.6.0 <0.9.0;

// All of this gets compiled down to EVM, can deploy on other EVM-compatible chains

// Like a class
contract SimpleStorage {
    // Initialized to 0
    uint256 internal favouriteNumber; // index 0
    bool internal favouriteBool; // index 1

    // Structs
    struct People {
        uint256 favouriteNumber; // index 0
        string name; // index 1
    }

    // A Person
    People public person = People({favouriteNumber: 2, name: "Patrick"});

    // Dynamic Array of People
    People[] public people; // can oso specify fixed size of array with People[5]

    // Mapping/Dictionary of People Names to their Favourite Numbers
    mapping(string => uint256) public nameToFavouriteNumber;

    // Append a person to end of array and record in mapping, has state change
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        // For object parameters like a "string" you need to specify:
        // memory: only stored during execution
        // storage: will persist in storage

        people.push(People(_favoriteNumber, _name)); // people.push(People({favouriteNumber: _favoriteNumber, name: _name}));
        nameToFavouriteNumber[_name] = _favoriteNumber;
    }

    // Store a favourite number, has state change
    function store(uint256 _favoriteNumber) public {
        favouriteNumber = _favoriteNumber;
    }

    // View Function: no state change, no transaction
    function retrieve() public view returns (uint256) {
        return favouriteNumber;
    }

    // Pure Function: has to be "pure", only math. Cannot read from environment or state (use view instead)
    function calculate(uint256 a, uint256 b) public pure {
        a + b;
    }
}
