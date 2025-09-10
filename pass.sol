// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract pass {
    struct user {
        uint256 id;
        string email;
        bytes32 passwordhash; 
    }

    mapping(string => bool) private registered; 
    mapping(string => user) private users; 

    event signup(uint256 id, string email);
    event successlogin(uint256 id, string email);
    
    function generateid(string memory email) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(email, block.timestamp, msg.sender))) % 1000000;
    }

    function usignUp(string memory email, string memory password) public returns (string memory) {
        require(bytes(email).length > 0, "email can't be empty");
        require(bytes(password).length > 0, "password can't be empty");
        require(!registered[email], "email already exist");
        uint256 newId = generateid(email);
        users[email] = user(newId, email, keccak256(abi.encodePacked(password)));
        registered[email] = true;
        emit signup(newId, email);
        return "signup success";
    }

    function login(string memory email, string memory password) public view returns (bool, uint256) {
        if (!registered[email]) {
            return (false, 0); 
        }

        user memory User = users[email];
        if (User.passwordhash != keccak256(abi.encodePacked(password))) {
            return (false, 0); 
        }

        return (true, User.id);
    }
}
