// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract hsh {
    
    struct PatientRecord {
        uint256 patientId;
        address owner;
        bytes32 nationalIDhash;
        bytes32 insuranceIDhash;
        bytes32 nameHash;
        bytes32 dobHash;
        bytes32 genderHash;
        bytes32 bloodTypeHash;
        bytes32 phoneHash;
        bytes32 addressHash;
        bytes32[] allergiesHash;
        bytes32[] medicalHistoryHash;
        bytes32[] medicationsHash;
        bytes32 emergencyContactHash;
        bytes32[] organDonorStatus;
        bytes32[] vaccinationRecordsHash;
        uint256 lastcheckupTimestamp;
        bytes32 doctorNotesHash;
        bytes32[] wearableDeviceDataHash;
        bytes32 fitnessLevelHash;
        bytes32 dietPlanHash;
        uint256 accessLevel;
        mapping (address=>bool) authorizedProviders;
        uint256 timestamp;
    }

    mapping(uint256 => PatientRecord) public patientRecords;
    uint256 public nextPatientId;

    modifier onlyPatient(uint256 _patientId) {
        require(msg.sender == patientRecords[_patientId].owner, "Only the patient can update the record.");
        _;
    }

    function addPatientRecord(
        bytes32 _nationalIDhash,
        bytes32 _insuranceIDhash,
        bytes32 _nameHash,
        bytes32 _dobHash,
        bytes32 _genderHash,
        bytes32 _bloodTypeHash,
        bytes32 _phoneHash,
        bytes32 _addressHash,
        bytes32[] memory _allergiesHash,
        bytes32[] memory _medicalHistoryHash,
        bytes32[] memory _medicationsHash,
        bytes32 _emergencyContactHash,
        bytes32[] memory _organDonorStatus,
        bytes32[] memory _vaccinationRecordsHash,
        uint256 _lastcheckupTimestamp,
        bytes32 _doctorNotesHash,
        bytes32[] memory _wearableDeviceDataHash,
        bytes32 _fitnessLevelHash,
        bytes32 _dietPlanHash
    ) public {
        uint256 patientId = nextPatientId;

        patientRecords[patientId] = PatientRecord(
            patientId,
            msg.sender,
            _nationalIDhash,
            _insuranceIDhash,
            _nameHash,
            _dobHash,
            _genderHash,
            _bloodTypeHash,
            _phoneHash,
            _addressHash,
            _allergiesHash,
            _medicalHistoryHash,
            _medicationsHash,
            _emergencyContactHash,
            _organDonorStatus,
            _vaccinationRecordsHash,
            _lastcheckupTimestamp,
            _doctorNotesHash,
            _wearableDeviceDataHash,
            _fitnessLevelHash,
            _dietPlanHash,
            0, 
            authorizedProviders: bool,
            block.timestamp
        );

        nextPatientId++;
    }
    
    function updatePatientRecord(
        uint256 _patientId,
        bytes32 _nationalIDhash,
        bytes32 _insuranceIDhash,
        bytes32 _nameHash,
        bytes32 _dobHash,
        bytes32 _genderHash,
        bytes32 _bloodTypeHash,
        bytes32 _phoneHash,
        bytes32 _addressHash,
        bytes32[] memory _allergiesHash,
        bytes32[] memory _medicalHistoryHash,
        bytes32[] memory _medicationsHash,
        bytes32 _emergencyContactHash,
        bytes32[] memory _organDonorStatus,
        bytes32[] memory _vaccinationRecordsHash,
        uint256 _lastcheckupTimestamp,
        bytes32 _doctorNotesHash,
        bytes32[] memory _wearableDeviceDataHash,
        bytes32 _fitnessLevelHash,
        bytes32 _dietPlanHash

    ) public onlyPatient(_patientId) {
        require(_patientId < nextPatientId, "Patient record does not exist.");

        PatientRecord storage record = patientRecords[_patientId];
        
        record.nationalIDhash = _nationalIDhash;
        record.insuranceIDhash = _insuranceIDhash;
        record.nameHash = _nameHash;
        record.dobHash = _dobHash;
        record.genderHash = _genderHash;
        record.bloodTypeHash = _bloodTypeHash;
        record.phoneHash = _phoneHash;
        record.addressHash = _addressHash;
        record.allergiesHash = _allergiesHash;
        record.medicalHistoryHash = _medicalHistoryHash;
        record.medicationsHash = _medicationsHash;
        record.emergencyContactHash = _emergencyContactHash;
        record.organDonorStatus = _organDonorStatus;
        record.vaccinationRecordsHash = _vaccinationRecordsHash;
        record.lastcheckupTimestamp = _lastcheckupTimestamp;
        record.doctorNotesHash = _doctorNotesHash;
        record.wearableDeviceDataHash = _wearableDeviceDataHash;
        record.fitnessLevelHash = _fitnessLevelHash;
        record.dietPlanHash = _dietPlanHash;
        record.timestamp = block.timestamp;
    }
    

    function grantAccess(uint256 _patientId, address _provider) public onlyPatient(_patientId) {
        require(!patientRecords[_patientId].authorizedProviders[_provider], "Provider already has access.");
    patientRecords[_patientId].authorizedProviders[_provider] = true;
    }


    function verifynationalID(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        return keccak256(abi.encode(_proof)) == record.nationalIDhash;
    }


    function verifyinsuranceIDhash(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        return keccak256(abi.encode(_proof)) == record.insuranceIDhash;
    }


    function verifyBloodType(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        return keccak256(abi.encode(_proof)) == record.bloodTypeHash;
    }


    function verifyAllergy(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

     
        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        for (uint256 i = 0; i < record.allergiesHash.length; i++) {
            if (keccak256(abi.encode(_proof)) == record.allergiesHash[i]) {
                return true;
            }
        }
        return false;
    }

    
    function verifyMedicalHistory(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];
     
      
        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );
         for (uint256 i = 0; i < record.medicalHistoryHash.length; i++) {
            if (keccak256(abi.encode(_proof)) == record.medicalHistoryHash[i]) {
                return true;
            }
        }
        return false;
    }

    
    function verifyMedications(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];
     
      
        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );
         for (uint256 i = 0; i < record.medicationsHash.length; i++) {
            if (keccak256(abi.encode(_proof)) == record.medicationsHash[i]) {
                return true;
            }
        }
        return false;
    }

    
    function verifyorganDonorStatus(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];
     
      
        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );
         for (uint256 i = 0; i < record.organDonorStatus.length; i++) {
            if (keccak256(abi.encode(_proof)) == record.organDonorStatus[i]) {
                return true;
            }
        }
        return false;
    }

    
    function verifyvaccinationRecordsHash(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];
     
      
        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );
         for (uint256 i = 0; i < record.vaccinationRecordsHash.length; i++) {
            if (keccak256(abi.encode(_proof)) == record.vaccinationRecordsHash[i]) {
                return true;
            }
        }
        return false;
    }

    
    function verifydoctorNotesHash(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        return keccak256(abi.encode(_proof)) == record.doctorNotesHash;
    }
    
    
    function verifywearableDeviceDataHash(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];
     
      
        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );
         for (uint256 i = 0; i < record.wearableDeviceDataHash.length; i++) {
            if (keccak256(abi.encode(_proof)) == record.wearableDeviceDataHash[i]) {
                return true;
            }
        }
        return false;
    }

    
    function verifyfitnessLevelHash(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        return keccak256(abi.encode(_proof)) == record.fitnessLevelHash;
    }


    function verifydietPlanHash(uint256 _patientId, bytes32 _proof) public view returns (bool) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        
        PatientRecord storage record = patientRecords[_patientId];

        require(
            msg.sender == tx.origin || isAuthorized(record, msg.sender),
            "Not authorized to verify."
        );

      
        return keccak256(abi.encode(_proof)) == record.dietPlanHash;
    }

    
    function getNormalRecords(uint _patientId) public view returns 
    (bytes32 nameHash,bytes32 dobHash,bytes32 genderHash,bytes32 phoneHash,bytes32 addressHash,bytes32 emergencyContactHash,uint256 lastcheckupTimestamp)
    {
        require(_patientId < nextPatientId, "Patient record does not exist.");

        PatientRecord storage record = patientRecords[_patientId];

        return (
            record.nameHash,
            record.dobHash,
            record.genderHash,
            record.phoneHash,
            record.addressHash,
            record.emergencyContactHash,
            record.lastcheckupTimestamp
        );
    }


    function isAuthorized(PatientRecord storage record, address _caller) internal view returns (bool) {
        for (uint256 i = 0; i < record.authorizedProviders.length; i++) {
            if (record.authorizedProviders[i] == _caller) {
                return true;
            }
        }
        return false;
    }

     
    mapping(uint256 => bytes32) private emergencyPins;

    function setEmergencyPin(uint256 _patientId, string memory _pin) public {
    require(_patientId < nextPatientId, "Patient record does not exist.");
    emergencyPins[_patientId] = keccak256(abi.encodePacked(_pin));
    }

    function emergencyAccess(uint256 _patientId, string memory _pin) public view returns (
        bytes32 nationalIDhash,
        bytes32 insuranceIDhash,
        bytes32 nameHash,
        bytes32 dobHash,
        bytes32 genderHash,
        bytes32 bloodTypeHash,
        bytes32 phoneHash,
        bytes32 addressHash,
        bytes32[] memory allergiesHash,
        bytes32[] memory medicalHistoryHash,
        bytes32[] memory medicationsHash,
        bytes32 emergencyContactHash,
        bytes32[] memory organDonorStatus,
        bytes32[] memory vaccinationRecordsHash,
        uint256 lastcheckupTimestamp,
        bytes32 doctorNotesHash,
        bytes32[] memory wearableDeviceDataHash,
        bytes32 fitnessLevelHash,
        bytes32 dietPlanHash
    ) {
    require(_patientId < nextPatientId, "Patient record does not exist.");
    require(
        keccak256(abi.encodePacked(_pin)) == emergencyPins[_patientId],
        "Invalid PIN."
           );

    PatientRecord storage record = patientRecords[_patientId];

        return (
           record.nationalIDhash, 
           record.insuranceIDhash,
           record.nameHash, 
           record.dobHash,
           record.genderHash,
           record.bloodTypeHash,
           record.phoneHash, 
           record.addressHash, 
           record.allergiesHash, 
           record.medicalHistoryHash, 
           record.medicationsHash, 
           record.emergencyContactHash, 
           record.organDonorStatus, 
           record.vaccinationRecordsHash, 
           record.lastcheckupTimestamp, 
           record.doctorNotesHash, 
           record.wearableDeviceDataHash, 
           record.fitnessLevelHash, 
           record.dietPlanHash 
        );
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
    
} 