// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract jk {
    address public owner;
    bytes32 private emergencyPinHash;
    
    struct MedicalRecord {
        bytes32 allergiesHash;
        bytes32 medicalHistoryHash;
        bytes32 medicationsHash;
    }
    
    MedicalRecord private record;
    
    mapping(address => bool) private authorizedProviders;
    
    event RecordUpdated(string recordType, bytes32 recordHash);
    event AccessGranted(address provider);
    event AccessRevoked(address provider);
    event EmergencyAccessUsed(address provider);
    
    modifier onlyPatient() {
        require(msg.sender == owner, "Only patient can perform this action");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == owner || authorizedProviders[msg.sender], "Unauthorized access");
        _;
    }

    constructor(bytes32 _emergencyPinHash) {
        owner = msg.sender;
        emergencyPinHash = _emergencyPinHash;
    }

    function grantAccess(address _provider) external onlyPatient {
        authorizedProviders[_provider] = true;
        emit AccessGranted(_provider);
    }

    function revokeAccess(address _provider) external onlyPatient {
        require(authorizedProviders[_provider], "Provider not found");
        authorizedProviders[_provider] = false;
        emit AccessRevoked(_provider);
    }

    function updateRecord(bytes32 _allergiesHash, bytes32 _medicalHistoryHash, bytes32 _medicationsHash) external onlyPatient {
        record = MedicalRecord(_allergiesHash, _medicalHistoryHash, _medicationsHash);
        emit RecordUpdated("Allergies", _allergiesHash);
        emit RecordUpdated("Medical History", _medicalHistoryHash);
        emit RecordUpdated("Medications", _medicationsHash);
    }

    function getRecord() external view onlyAuthorized returns (bytes32, bytes32, bytes32) {
        return (record.allergiesHash, record.medicalHistoryHash, record.medicationsHash);
    }

    function verifyRecord(string memory recordType, bytes32 providedHash) external view onlyAuthorized returns (bool) {
        bytes32 storedHash;
        
        if (keccak256(abi.encodePacked(recordType)) == keccak256(abi.encodePacked("Allergies"))) {
            storedHash = record.allergiesHash;
        } else if (keccak256(abi.encodePacked(recordType)) == keccak256(abi.encodePacked("MedicalHistory"))) {
            storedHash = record.medicalHistoryHash;
        } else if (keccak256(abi.encodePacked(recordType)) == keccak256(abi.encodePacked("Medications"))) {
            storedHash = record.medicationsHash;
        } else {
            revert("Invalid record type");
        }
        
        return providedHash == storedHash;
    }

    function setEmergencyPin(bytes32 _newPinHash) external onlyPatient {
        emergencyPinHash = _newPinHash;
    }

    function emergencyAccess(bytes32 providedPinHash) external {
        require(providedPinHash == emergencyPinHash, "Invalid emergency PIN");
        emit EmergencyAccessUsed(msg.sender);
    }
}
