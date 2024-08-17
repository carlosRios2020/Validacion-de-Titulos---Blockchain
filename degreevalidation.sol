// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseContract.sol";

contract UniversityDegreeValidation is BaseContract {
    struct Document {
        string diplomaHash;
        string gradeReportHash;
        bytes32 documentHash; // Hash generado para el documento
        bool isValidatedByTeacher;
        bool isValidatedByUniversity;
        bool isSentToBlockchain;
        address ownerAddress;
        string universityName;
        address universityAddress;
        uint256 uploadTimestamp;
        uint256 validationTimestamp;
        uint256 blockchainTimestamp;
    }

    mapping(string => Document) public documents; // Clave por documentId
    mapping(string => string) public universityInvitations; // Invitaciones a universidades por nombre

    event DocumentUploaded(string indexed documentId, string diplomaHash, string gradeReportHash, string universityName);
    event DocumentValidatedByTeacher(string indexed documentId);
    event DocumentValidatedByUniversity(string indexed documentId);
    event DocumentSentToBlockchain(string indexed documentId);
    event UniversityInvited(string universityName);

    // Función para subir documentos
    function uploadDocuments(
        string memory _diplomaHash,
        string memory _gradeReportHash,
        string memory _universityName
    ) public onlyRegisteredUser(msg.sender) {
        string memory documentId = users[msg.sender].documentId;
        require(bytes(documents[documentId].diplomaHash).length == 0, "Documents already uploaded");

        // Generar el hash del documento basado en el diploma y las notas
        bytes32 docHash = computeSingleHash(_diplomaHash); // Generar hash solo para el diploma

        documents[documentId] = Document({
            diplomaHash: _diplomaHash,
            gradeReportHash: _gradeReportHash,
            documentHash: docHash,
            isValidatedByTeacher: false,
            isValidatedByUniversity: false,
            isSentToBlockchain: false,
            ownerAddress: msg.sender,
            universityName: _universityName,
            universityAddress: address(0),
            uploadTimestamp: block.timestamp,
            validationTimestamp: 0,
            blockchainTimestamp: 0
        });

        // Guardar la invitación para la universidad
        universityInvitations[_universityName] = documentId;

        emit DocumentUploaded(documentId, _diplomaHash, _gradeReportHash, _universityName);
        emit UniversityInvited(_universityName);
    }

    // Función para validación por docente
    function validateByTeacher(string memory _studentDocumentId) public onlyRegisteredUniversity notStudent(documents[_studentDocumentId].ownerAddress, msg.sender) {
        Document storage doc = documents[_studentDocumentId];
        require(!doc.isValidatedByTeacher, "Document already validated by teacher");

        doc.isValidatedByTeacher = true;
        doc.validationTimestamp = block.timestamp;

        emit DocumentValidatedByTeacher(_studentDocumentId);
        _trySendToBlockchain(_studentDocumentId);
    }

    // Función para validación por universidad
    function validateByUniversity(string memory _studentDocumentId) public onlyRegisteredUniversity notStudent(documents[_studentDocumentId].ownerAddress, msg.sender) {
        Document storage doc = documents[_studentDocumentId];
        require(doc.universityAddress == msg.sender, "You are not authorized to validate this document");
        require(!doc.isValidatedByUniversity, "Document already validated by university");

        doc.isValidatedByUniversity = true;
        doc.validationTimestamp = block.timestamp;

        emit DocumentValidatedByUniversity(_studentDocumentId);
        _trySendToBlockchain(_studentDocumentId);
    }

    // Función interna para enviar el documento a la blockchain si ha sido validado
    function _trySendToBlockchain(string memory _studentDocumentId) internal {
        Document storage doc = documents[_studentDocumentId];
        if (doc.isValidatedByTeacher && doc.isValidatedByUniversity && !doc.isSentToBlockchain) {
            doc.isSentToBlockchain = true;
            doc.blockchainTimestamp = block.timestamp;

            emit DocumentSentToBlockchain(_studentDocumentId);
        }
    }

    // Función para obtener el estado de un documento
    function getDocumentStatus(string memory _studentDocumentId) public view returns (
        string memory studentName,
        string memory universityName,
        bool isValidatedByTeacher,
        bool isValidatedByUniversity,
        bool isSentToBlockchain,
        uint256 uploadTimestamp,
        uint256 validationTimestamp,
        uint256 blockchainTimestamp
    ) {
        Document memory doc = documents[_studentDocumentId];
        return (
            users[doc.ownerAddress].name,
            doc.universityName,
            doc.isValidatedByTeacher,
            doc.isValidatedByUniversity,
            doc.isSentToBlockchain,
            doc.uploadTimestamp,
            doc.validationTimestamp,
            doc.blockchainTimestamp
        );
    }
}
