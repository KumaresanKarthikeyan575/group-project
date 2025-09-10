// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Health {
    struct PatientRecord {
        uint256 patientId;
        address owner;
        bytes32 ipfsHash; // Reference to complete off-chain data
        mapping(address => bool) authorizedProviders;
        mapping(string => bytes32) fieldHashes; // Store hash of each field
        uint256 accessLevel;
        uint256 timestamp;
        bytes32 emergencyPinHash;
    }

    mapping(uint256 => PatientRecord) public patientRecords;
    uint256 public nextPatientId;

    event RecordAdded(uint256 indexed patientId, address owner, bytes32 ipfsHash);
    event RecordUpdated(uint256 indexed patientId, bytes32 ipfsHash);
    event AccessGranted(uint256 indexed patientId, address provider);
    event AccessRevoked(uint256 indexed patientId, address provider);

    modifier onlyPatient(uint256 _patientId) {
        require(msg.sender == patientRecords[_patientId].owner, "Only patient can modify");
        _;
    }

    // Add new patient record with field hashes
    function addPatientRecord(bytes32 _ipfsHash, bytes32[] memory _fieldHashes, string[] memory _fieldNames) 
        public 
    {
        require(_fieldHashes.length == _fieldNames.length, "Mismatch in field counts");
        uint256 patientId = nextPatientId;
        
        PatientRecord storage record = patientRecords[patientId];
        record.patientId = patientId;
        record.owner = msg.sender;
        record.ipfsHash = _ipfsHash;
        record.timestamp = block.timestamp;
        
        for (uint i = 0; i < _fieldNames.length; i++) {
            record.fieldHashes[_fieldNames[i]] = _fieldHashes[i];
        }
        
        nextPatientId++;
        emit RecordAdded(patientId, msg.sender, _ipfsHash);
    }

    // Update patient record
    function updatePatientRecord(uint256 _patientId, bytes32 _ipfsHash, bytes32[] memory _fieldHashes, string[] memory _fieldNames) 
        public 
        onlyPatient(_patientId) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        require(_fieldHashes.length == _fieldNames.length, "Mismatch in field counts");
        
        PatientRecord storage record = patientRecords[_patientId];
        record.ipfsHash = _ipfsHash;
        record.timestamp = block.timestamp;
        
        for (uint i = 0; i < _fieldNames.length; i++) {
            record.fieldHashes[_fieldNames[i]] = _fieldHashes[i];
        }
        
        emit RecordUpdated(_patientId, _ipfsHash);
    }

    // Grant access to providers
    function grantAccess(uint256 _patientId, address _provider) 
        public 
        onlyPatient(_patientId) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        require(!patientRecords[_patientId].authorizedProviders[_provider], "Provider already authorized");
        
        patientRecords[_patientId].authorizedProviders[_provider] = true;
        emit AccessGranted(_patientId, _provider);
    }

    // Revoke access from providers
    function revokeAccess(uint256 _patientId, address _provider) 
        public 
        onlyPatient(_patientId) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        require(patientRecords[_patientId].authorizedProviders[_provider], "Provider not authorized");
        
        patientRecords[_patientId].authorizedProviders[_provider] = false;
        emit AccessRevoked(_patientId, _provider);
    }

    // Set emergency PIN
    function setEmergencyPin(uint256 _patientId, string memory _pin) 
        public 
        onlyPatient(_patientId) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        patientRecords[_patientId].emergencyPinHash = keccak256(abi.encodePacked(_pin));
    }

    // Get record reference for authorized users
    function getRecordReference(uint256 _patientId) 
        public 
        view 
        returns (bytes32 ipfsHash, uint256 timestamp) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        PatientRecord storage record = patientRecords[_patientId];
        
        require(
            msg.sender == record.owner || 
            record.authorizedProviders[msg.sender],
            "Not authorized"
        );
        
        return (record.ipfsHash, record.timestamp);
    }

    // Emergency access
    function emergencyAccess(uint256 _patientId, string memory _pin) 
        public 
        view 
        returns (bytes32 ipfsHash) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        PatientRecord storage record = patientRecords[_patientId];
        
        require(
            keccak256(abi.encodePacked(_pin)) == record.emergencyPinHash,
            "Invalid emergency PIN"
        );
        
        return record.ipfsHash;
    }

    // Verify specific data field
    function verifyRecordField(uint256 _patientId, string memory _fieldName, string memory _fieldValue) 
        public 
        view 
        returns (bool) 
    {
        require(_patientId < nextPatientId, "Record does not exist");
        PatientRecord storage record = patientRecords[_patientId];
        
        require(
            msg.sender == record.owner || 
            record.authorizedProviders[msg.sender],
            "Not authorized"
        );
        
        bytes32 expectedHash = keccak256(abi.encodePacked(_fieldValue));
        return record.fieldHashes[_fieldName] == expectedHash;
    }
}