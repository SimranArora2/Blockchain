// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 < 0.9.0;

contract Twitter{
    struct Tweet{
        uint id;
        address author;
        uint createdAt;
        string content;
    }
    struct Message{
        uint id;
        address from;
        address to;
        string content;
        uint createdAt;
    }

    // mapping(address=>Tweet) Tweets; we'll take uint instead of address for reffering the indices, and insert the tweets in them. 
    // We'll create a tweetsOf mapping in which we'll access a particular tweet from a particular id. 
    // In that case, we'll be going from address to uint type and through that, we'll be able to access a particular array element(value).
    mapping(uint=>Tweet) tweets;//public tweets;
    mapping(address=>uint[]) public tweetsOf;//store tweets
    // mapping(address=>Message) Conversation; THERE IS AN ISSUE OVER HERE, WILL ONE PERSON DO A SINGLE MESSAGE OR CAN HE DO MULTIPLE MESSAGES!?
    // One can do multiple messages so, if we say that address is only for message, then this will restrict this address for a particular message only. 
    // In such a case we can convert it into dynamic array. From that address we'll make a mapping on a dynamic array through which(address) we'll be a ble to leep multiple messages.
    // In Tweet, this issue will not occur.
    mapping(address=>Message[]) conversation;
    mapping(address=>address[]) followers;
    mapping(address=>mapping(address=>bool)) public operators;
    //2D mapping will be used when we want to give access of one account to a user, who does'nt own it

    uint nextId;
    uint nextMessageId;

    function tweet(address _from, string memory _content) internal {//public { //here address is passed if it is the same person who has called the functon!
        require(msg.sender==_from || operators[_from][msg.sender]==true, "You are not authorised");//if it'll be the same person, then, we'll move ahead otherwise this message will be displayed
        tweets[nextId]=Tweet(nextId,_from,block.timestamp,_content);
        tweetsOf[_from].push(nextId);
        nextId++;
    }

    function _sendMessage(string memory _content, address _from, address _to) internal{ //public{
        require(msg.sender==_from || operators[_from][msg.sender]==true, "You are not authorised");// we are using two keys to hold one value in 2D mapping
        conversation[_from].push(Message(nextMessageId, _from, _to, _content, block.timestamp));
        nextMessageId++;
    }

    function tweet(string calldata _content) public{
        tweet(msg.sender, _content);
    }

    function tweetFrom(address _from, string memory _content) public {
        tweet(_from,_content);
    }

    function _sendMessage(string memory _content, address _to) public{
        _sendMessage(_content, msg.sender, _to);
    }

    function sendMessageFrom(address _from, address _to, string memory _content) public {
        _sendMessage(_content, _from, _to);
    }
    
    function follow(address _followed) public {
        followers[msg.sender].push(_followed);  //here we are using mapping with dynamic array
    }

    function allow(address _operator) public{
        operators[msg.sender][_operator]=true;
    }

    function disallow(address _operator) public{
        operators[msg.sender][_operator]=false;
    }

    //we can't perform arithmetic operations on addresses.

    function getLatestTweet(uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId, "Not found");
        Tweet[] memory memTweets = new Tweet[](count); //initialize an empty array of size count
        uint j;
        for(uint i=nextId-count;i<nextId;i++){//i=5;i<10; i++
            Tweet storage _tweets=tweets[i];
            memTweets[j]=Tweet(_tweets.id,_tweets.author,_tweets.createdAt,_tweets.content); // createdAt contains the value of block.timestamp()
            j++;
        }
        return memTweets;
    } //Herewe are fetching n tweets in this function.

    function getTweetsOf(address user, uint count) public view returns(Tweet[] memory){
        uint[] storage tweetsId= tweetsOf[user];
        require(count>0 && count<=tweetsOf[user].length,"Tweets not found");
        Tweet[] memory _tweets= new Tweet[](count);
        uint j;
        // for(uint i=tweetsOf[user].length-count;i<tweetsOf[user].length;i++){
        for(uint i=tweetsId.length-count;i<tweetsId.length;i++){
            Tweet storage _tweet=tweets[tweetsId[i]];
            // Tweet storage _tweet=tweets[10]; //here, 10--->TweetId, from which we'll able to fetch the particular tweet
            _tweets[j]=Tweet(_tweet.id, _tweet.author, _tweet.createdAt, _tweet.content);
            j++;
        }
        return _tweets; 
    }   
}
