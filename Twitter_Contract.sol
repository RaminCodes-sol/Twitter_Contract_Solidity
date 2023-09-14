// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";



interface IProfile {
    struct UserProfileStruct {
        string displayName;
        string bio;
    }

    function getProfile (address _userAddress) external view returns(UserProfileStruct memory);
}



/*-------Twitter-Contract-------*/
contract TwitterContract is Ownable {

    uint16 MAX_TWEET_LENGTH = 280;
    
    IProfile createProfileContract;

    constructor (address _createProfileContractAddress) {
        createProfileContract = IProfile(_createProfileContractAddress);
    }

    modifier OnlyRegistered () {
        IProfile.UserProfileStruct memory userProfile = createProfileContract.getProfile(msg.sender);
        require(bytes(userProfile.displayName).length > 0, "User Not Registered!");
        _;
    }
    

    struct TweetStruct {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping (address => TweetStruct[]) public tweets;
    
    
    /*-------Events-------*/
    event TweetCreated (uint256 _id, address indexed _author, string _content, uint256 _timestamp);
    event TweetLiked (address indexed _liker, address _tweetAuthor, uint256 _tweetId, uint256 _likesCount);
    event TweetUnLiked (address indexed _unLiker, address _tweetAuthor, uint256 _tweetId, uint256 _likesCount);


    /*-------Create-Tweet-------*/
    function createTweet (string memory _tweetText) public OnlyRegistered {
        require(bytes(_tweetText).length <= MAX_TWEET_LENGTH, "Tweet is too long!");

        TweetStruct memory newTweet = TweetStruct({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweetText,
            timestamp: block.timestamp,
            likes: 0
        });
          
        tweets[msg.sender].push(newTweet);
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }


    /*-------Change-Tweet-Length-------*/
    function changeTweetLength (uint16 _newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = _newTweetLength;
    }


    /*-------Like-Tweet-------*/
    function likeTweet (address _author, uint256 _id) external OnlyRegistered {
        require(tweets[_author][_id].id == _id, "Tweet Doesn't Exist!");
        tweets[_author][_id].likes += 1;

        emit TweetLiked(msg.sender, _author, _id, tweets[_author][_id].likes);
    }


    /*-------UnLike-Tweet-------*/
    function unLikeTweet (address _author, uint256 _id) external OnlyRegistered {
        require(tweets[_author][_id].id == _id, "Tweet Doesn't Exist!");
        require(tweets[_author][_id].likes > 0, "Tweet Has No Likes!");

        tweets[_author][_id].likes -= 1;

        emit TweetUnLiked(msg.sender, _author, _id, tweets[_author][_id].likes);
    }


    /*-------Get-Tweet-------*/
    function getTweet (uint256 _i) public view returns (TweetStruct memory) {
        return tweets[msg.sender][_i];
    }


    /*-------Get-All-Tweets-------*/
    function getAllTweets (address _authorAddress) public view returns(TweetStruct[] memory) {
        return tweets[_authorAddress];
    }


    /*-------Get-Total-Likes-------*/
    function getTotalLikes (address _authorAddress) external view returns (uint256) {
        uint256 totalLikes;

        for (uint256 i = 0; i < tweets[_authorAddress].length; i++) {
            totalLikes += tweets[_authorAddress][i].likes;
        }
        return totalLikes;
    }
}


