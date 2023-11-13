pragma solidity ^0.8.0;

contract SocialMedia {
    struct User {
        string username;
        string bio;
        uint256 latitude; // Store location data
        uint256 longitude; // Store location data
        address userAddress;
        address[] following;
        mapping(address => bool) followers;
        mapping(address => string[]) messages; // User's messages
    }

    mapping(address => User) public users;
     function updateLocation(uint256 _latitude, uint256 _longitude) public {
        users[msg.sender].latitude = _latitude;
        users[msg.sender].longitude = _longitude;
    }
    function getNearbyUsers(uint256 _radius) public view returns (address[] memory) {
        address[] memory nearbyUsers = new address[](100); // Assuming a maximum of 100 nearby users
        uint256 count = 0;

        User storage currentUser = users[msg.sender];

        for (uint256 i = 0; i < 100; i++) {
            User storage otherUser = users[address(i)];
            if (otherUser.latitude != 0 && otherUser.longitude != 0) { // User exists and has a location set
                uint256 distance = calculateDistance(currentUser.latitude, currentUser.longitude, otherUser.latitude, otherUser.longitude);
                if (distance <= _radius && address(i) != msg.sender) { // Within radius and not the current user
                    nearbyUsers[count] = address(i);
                    count++;
                }
            }
        }

        return nearbyUsers;
    }
    function calculateDistance(uint256 lat1, uint256 lon1, uint256 lat2, uint256 lon2) public pure returns (uint256) {
        // Formula for calculating distance (You might use a more accurate formula)
        return ((lat1 - lat2)**2 + (lon1 - lon2)**2);
    }
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
