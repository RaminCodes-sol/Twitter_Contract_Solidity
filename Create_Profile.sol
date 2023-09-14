// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/access/Ownable.sol";



contract Create_Profile {
    
    struct UserProfileStruct {
        string displayName;
        string bio;
    }

    mapping(address => UserProfileStruct) public profiles;

    
    function createProfile (string memory _displayName, string memory _bio) public {
        profiles[msg.sender] = UserProfileStruct(_displayName, _bio);
    }

    function getProfile (address _userAddress) public view returns (UserProfileStruct memory) {
        return profiles[_userAddress];
    }

}