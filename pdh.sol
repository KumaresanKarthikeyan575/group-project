// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract pdh {
    struct PatientRecord {
        uint256 patientId;
        string name;
        string dob;
        string gender;
        string bloodType;
        string[] allergies;
        string[] medicalHistory;
        string[] medications;
        string emergencyContact;
        uint256 accessLevel;
        address[] authorizedProviders;
        uint256 timestamp;
    }

    mapping(uint256 => PatientRecord) public patientRecords;
    uint256 public nextPatientId;

    function addPatientRecord(
        string memory _name,
        string memory _dob,
        string memory _gender,
        string memory _bloodtype,
        string[] memory _allergies,
        string[] memory _medicalHistory,
        string[] memory _medications,
        string memory _emergencyContact
    ) public {
        uint256 patientId = nextPatientId;

        patientRecords[patientId] = PatientRecord(
            patientId,
            _name,
            _dob,
            _gender,
            _bloodtype,
            _allergies,
            _medicalHistory,
            _medications,
            _emergencyContact,
            0,
            new address [](0),
            block.timestamp 
        );


        nextPatientId++;
    }

    function updatePatientRecord(
        uint256 _patientId,
        string memory _name,
        string memory _dob,
        string memory _gender,
        string memory _bloodType,
        string[] memory _allergies,
        string[] memory _medicalHistory,
        string[] memory _medications,
        string memory _emergencyContact
    ) public {
        require(_patientId < nextPatientId, "Patient record does not exist.");

        PatientRecord storage record = patientRecords[_patientId];
        record.name = _name;
        record.dob = _dob;
        record.gender = _gender;
        record.bloodType = _bloodType;
        record.allergies = _allergies;
        record.medicalHistory = _medicalHistory;
        record.medications = _medications;
        record.emergencyContact = _emergencyContact;
        record.timestamp = block.timestamp; 
    }
    
    function grantAccess(uint256 _patientId, address _provider) public {
        require(_patientId < nextPatientId, "Patient record does not exist.");
    
        PatientRecord storage record = patientRecords[_patientId];
    
        for (uint256 i = 0; i < record.authorizedProviders.length; i++) {
            require(record.authorizedProviders[i] != _provider, "Provider already has access.");
        }

        record.authorizedProviders.push(_provider);
    }

    function verifyBloodType(uint256 _patientId, string memory _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

        return keccak256(abi.encodePacked(_proof)) == keccak256(abi.encodePacked(record.bloodType));
    }

    function verifyAllergy(uint256 _patientId, string memory _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

        for (uint256 i = 0; i < record.allergies.length; i++) {
            if (keccak256(abi.encodePacked(_proof)) == keccak256(abi.encodePacked(record.allergies[i]))) {
                return true;
            }
        }
        return false;
    }

    function isAuthorized(PatientRecord storage record, address _caller) internal view returns (bool) {
        for (uint256 i = 0; i < record.authorizedProviders.length; i++) {
            if (record.authorizedProviders[i] == _caller) {
                return true;
            }
        }
        return false;
    }

    function revokeAccess(uint256 _patientId, address _provider) public {
        require(_patientId < nextPatientId, "Patient record does not exist.");

        PatientRecord storage record = patientRecords[_patientId];
        
        for (uint256 i = 0; i < record.authorizedProviders.length; i++) {
            if (record.authorizedProviders[i] == _provider) {
                record.authorizedProviders[i] = record.authorizedProviders[record.authorizedProviders.length - 1];
                record.authorizedProviders.pop();
                break;
            }
        }
    }
    
    mapping(uint256 => string) private emergencyPins;

    function setEmergencyPin(uint256 _patientId, string memory _pin) public {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        emergencyPins[_patientId] = _pin;
    }

    function emergencyAccess(uint256 _patientId, string memory _pin) public view returns (
        string memory, string memory, string memory, string memory
    ) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        require(
            keccak256(abi.encodePacked(_pin)) == keccak256(abi.encodePacked(emergencyPins[_patientId])),
            "Invalid PIN."
        );
        
        PatientRecord storage record = patientRecords[_patientId];
        
        return (
            record.name,
            record.bloodType,
            record.allergies.length > 0 ? record.allergies[0] : "No allergies",
            record.emergencyContact
        );
    }
}
