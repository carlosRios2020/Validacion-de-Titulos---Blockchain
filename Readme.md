# UniversityDegreeValidation Contract Documentation

## Overview

The `UniversityDegreeValidation` contract allows users (students), universities, and teachers to manage the validation of academic documents. The contract supports uploading documents, validating them by both teachers and universities, and recording their validation status on the blockchain.

## Functions

### `uploadDocuments`

```solidity
function uploadDocuments(
    string memory _diplomaHash,
    string memory _gradeReportHash,
    string memory _universityName
) public onlyRegisteredUser(msg.sender)
```

**Description:**
This function allows a registered user (student) to upload their academic documents, which include the diploma hash and grade report hash. The function generates a unique document hash for the diploma, stores the document data, and invites the specified university to validate the documents.

**Parameters:**
- `_diplomaHash`: The hash of the diploma document.
- `_gradeReportHash`: The hash of the grade report document.
- `_universityName`: The name of the university associated with the documents.

**Modifiers:**
- `onlyRegisteredUser`: Ensures that the function can only be called by a registered user.

**Events Emitted:**
- `DocumentUploaded`: Emitted when the documents are successfully uploaded.
- `UniversityInvited`: Emitted to invite the specified university to validate the documents.

---

### `validateByTeacher`

```solidity
function validateByTeacher(string memory _studentDocumentId) public onlyRegisteredUniversity notStudent(documents[_studentDocumentId].ownerAddress, msg.sender)
```

**Description:**
This function allows a teacher to validate a student's document. It ensures that the teacher is not the owner of the document and that the document has not already been validated by a teacher. Upon validation, the timestamp of the validation is recorded.

**Parameters:**
- `_studentDocumentId`: The document ID of the student’s document that is to be validated.

**Modifiers:**
- `onlyRegisteredUniversity`: Ensures the function can only be called by a registered university.
- `notStudent`: Ensures that the teacher validating the document is not the student who owns the document.

**Events Emitted:**
- `DocumentValidatedByTeacher`: Emitted when the document is successfully validated by the teacher.

---

### `validateByUniversity`

```solidity
function validateByUniversity(string memory _studentDocumentId) public onlyRegisteredUniversity notStudent(documents[_studentDocumentId].ownerAddress, msg.sender)
```

**Description:**
This function allows a university to validate a student's document. It checks that the university validating the document is the one associated with the document and that the university has not already validated it. If the validation is successful, a timestamp is recorded.

**Parameters:**
- `_studentDocumentId`: The document ID of the student’s document that is to be validated.

**Modifiers:**
- `onlyRegisteredUniversity`: Ensures the function can only be called by a registered university.
- `notStudent`: Ensures that the university validating the document is not the student who owns the document.

**Events Emitted:**
- `DocumentValidatedByUniversity`: Emitted when the document is successfully validated by the university.

---

### `_trySendToBlockchain`

```solidity
function _trySendToBlockchain(string memory _studentDocumentId) internal
```

**Description:**
This internal function is called after a document has been validated by both the teacher and the university. It checks if both validations are complete, and if so, it marks the document as sent to the blockchain and records the timestamp of this event.

**Parameters:**
- `_studentDocumentId`: The document ID of the student’s document.

**Events Emitted:**
- `DocumentSentToBlockchain`: Emitted when the document is successfully sent to the blockchain.

---

### `getDocumentStatus`

```solidity
function getDocumentStatus(string memory _studentDocumentId) public view returns (
    string memory studentName,
    string memory universityName,
    bool isValidatedByTeacher,
    bool isValidatedByUniversity,
    bool isSentToBlockchain,
    uint256 uploadTimestamp,
    uint256 validationTimestamp,
    uint256 blockchainTimestamp
)
```

**Description:**
This view function allows anyone to retrieve the current status of a student’s document, including whether it has been validated by a teacher and a university, and whether it has been sent to the blockchain. It also provides the relevant timestamps.

**Parameters:**
- `_studentDocumentId`: The document ID of the student’s document.

**Returns:**
- `studentName`: The name of the student who owns the document.
- `universityName`: The name of the university associated with the document.
- `isValidatedByTeacher`: Boolean indicating whether the document has been validated by a teacher.
- `isValidatedByUniversity`: Boolean indicating whether the document has been validated by the university.
- `isSentToBlockchain`: Boolean indicating whether the document has been sent to the blockchain.
- `uploadTimestamp`: The timestamp when the document was uploaded.
- `validationTimestamp`: The timestamp when the document was validated by either the teacher or the university.
- `blockchainTimestamp`: The timestamp when the document was sent to the blockchain.

---

## Modifiers

### `onlyRegisteredUser`

```solidity
modifier onlyRegisteredUser(address _userAddress)
```

**Description:**
This modifier ensures that the function can only be called by a registered user.

### `onlyRegisteredUniversity`

```solidity
modifier onlyRegisteredUniversity()
```

**Description:**
This modifier ensures that the function can only be called by a registered university.

### `notStudent`

```solidity
modifier notStudent(address _studentAddress, address _msgSender)
```

**Description:**
This modifier ensures that the teacher or university attempting to validate a document is not the student who owns the document.
