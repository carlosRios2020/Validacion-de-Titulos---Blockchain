// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseContract {
    enum DocumentType { CC, PASSPORT, TE }

    struct User {
        string name;
        string documentId;
        DocumentType documentType;
        string email;
        bool isRegistered;
    }

    struct University {
        string name;
        string city;
        string email;
        address universityAddress;
        bool isRegistered;
    }

    struct Teacher {
        string name;
        string email;
        address teacherAddress;
        bool isRegistered;
    }

    mapping(address => User) public users;
    mapping(address => University) public universities;
    mapping(address => Teacher) public teachers;

    event UserRegistered(address indexed user, string name, string documentId, DocumentType documentType, string email);
    event UniversityRegistered(address indexed university, string name, string city, string email);
    event TeacherRegistered(address indexed teacher, string name, string email);

    // Función para registrar un usuario
    function registerUser(string memory _name, DocumentType _documentType, string memory _documentId, string memory _email) public {
        require(!users[msg.sender].isRegistered, "User already registered");

        users[msg.sender] = User({
            name: _name,
            documentId: _documentId,
            documentType: _documentType,
            email: _email,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name, _documentId, _documentType, _email);
    }

    // Función para registrar una universidad
    function registerUniversity(string memory _name, string memory _city, string memory _email) public {
        require(!universities[msg.sender].isRegistered, "University already registered");

        universities[msg.sender] = University({
            name: _name,
            city: _city,
            email: _email,
            universityAddress: msg.sender,
            isRegistered: true
        });

        emit UniversityRegistered(msg.sender, _name, _city, _email);
    }

    // Función para registrar un docente
    function registerTeacher(string memory _name, string memory _email) public {
        require(!teachers[msg.sender].isRegistered, "Teacher already registered");

        teachers[msg.sender] = Teacher({
            name: _name,
            email: _email,
            teacherAddress: msg.sender,
            isRegistered: true
        });

        emit TeacherRegistered(msg.sender, _name, _email);
    }

    // Función para calcular el hash de un único documento
    function computeSingleHash(string memory _documentContent) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_documentContent));
    }

    modifier onlyRegisteredUser(address _userAddress) {
        require(users[_userAddress].isRegistered, "User is not registered");
        _;
    }

    modifier onlyRegisteredUniversity() {
        require(universities[msg.sender].isRegistered, "University is not registered");
        _;
    }

    modifier notStudent(address _studentAddress, address _msgSender) {
        require(_studentAddress != _msgSender, "You cannot validate your own document");
        _;
    }
}
