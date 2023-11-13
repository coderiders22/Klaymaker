pragma solidity ^0.8.0;

contract SocialMedia {
    struct User {
        string username;
        string bio;
        address userAddress;
        address[] following;
        mapping(address => bool) followers;
        mapping(address => string[]) messages; // User's messages
    }

    mapping(address => User) public users;

    event UserRegistered(address user, string username);
    event MessageSent(address sender, address receiver, string content);

    function register(string memory _username, string memory _bio) public {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(users[msg.sender].userAddress != msg.sender, "User already registered");

        User storage newUser = users[msg.sender];
        newUser.username = _username;
        newUser.bio = _bio;
        newUser.userAddress = msg.sender;

        emit UserRegistered(msg.sender, _username);
    }

    function sendMessage(address _receiver, string memory _content) public {
        require(bytes(users[msg.sender].username).length > 0, "User is not registered");
        require(bytes(_content).length > 0, "Message content cannot be empty");
        require(_receiver != msg.sender, "Cannot send message to self");

        User storage receiver = users[_receiver];
        require(receiver.userAddress == _receiver, "Receiver is not a registered user");

        users[_receiver].messages[msg.sender].push(_content);

        emit MessageSent(msg.sender, _receiver, _content);
    }

    function getMessages(address _user) public view returns (string[] memory) {
        require(bytes(users[_user].username).length > 0, "User is not registered");
        return users[_user].messages[msg.sender];
    }
}
