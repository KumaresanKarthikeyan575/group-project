// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract BlockchainHealthRecords is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    struct PatientRecord {
        uint256 patientId;
        address owner;
        string ipfsHash; // Off-chain storage (IPFS/Arweave)
        address[] authorizedDoctors;
        uint256 timestamp;
    }

    mapping(uint256 => PatientRecord) public patientRecords;
    mapping(uint256 => bytes32) private emergencyPins;

    uint256 public nextPatientId;

    event PatientRecordAdded(uint256 patientId, address indexed owner, string ipfsHash);
    event PatientRecordUpdated(uint256 patientId, string newIpfsHash);
    event AccessGranted(uint256 patientId, address indexed doctor);
    event EmergencyPinSet(uint256 patientId);

    constructor() {
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(PATIENT_ROLE, ADMIN_ROLE);
        _setRoleAdmin(DOCTOR_ROLE, ADMIN_ROLE);
    }

    modifier onlyPatient(uint256 _patientId) {
        require(msg.sender == patientRecords[_patientId].owner, "Not the record owner.");
        _;
    }

    function addPatientRecord(string memory _ipfsHash) public {
        require(hasRole(PATIENT_ROLE, msg.sender), "Not a registered patient.");
        
        uint256 patientId = nextPatientId;
        patientRecords[patientId] = PatientRecord({
            patientId: patientId,
            owner: msg.sender,
            ipfsHash: _ipfsHash,
            authorizedDoctors: new address [](0),
            timestamp: block.timestamp
        });

        nextPatientId++;

        emit PatientRecordAdded(patientId, msg.sender, _ipfsHash);
    }

    function updatePatientRecord(uint256 _patientId, string memory _newIpfsHash) public onlyPatient(_patientId) {
        require(_patientId < nextPatientId, "Patient record does not exist.");

        patientRecords[_patientId].ipfsHash = _newIpfsHash;
        patientRecords[_patientId].timestamp = block.timestamp;

        emit PatientRecordUpdated(_patientId, _newIpfsHash);
    }

    function grantAccess(uint256 _patientId, address _doctor) public onlyPatient(_patientId) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        require(hasRole(DOCTOR_ROLE, _doctor), "Not a registered doctor.");

        for (uint256 i = 0; i < patientRecords[_patientId].authorizedDoctors.length; i++) {
            require(patientRecords[_patientId].authorizedDoctors[i] != _doctor, "Already authorized.");
        }

        patientRecords[_patientId].authorizedDoctors.push(_doctor);
        emit AccessGranted(_patientId, _doctor);
    }

    function getPatientRecord(uint256 _patientId) public view returns (string memory) {
        require(
            msg.sender == patientRecords[_patientId].owner || isAuthorized(_patientId, msg.sender),
            "Not authorized."
        );
        return patientRecords[_patientId].ipfsHash;
    }

    function isAuthorized(uint256 _patientId, address _caller) internal view returns (bool) {
        for (uint256 i = 0; i < patientRecords[_patientId].authorizedDoctors.length; i++) {
            if (patientRecords[_patientId].authorizedDoctors[i] == _caller) {
                return true;
            }
        }
        return false;
    }

    function setEmergencyPin(uint256 _patientId, string memory _pin) public onlyPatient(_patientId) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        emergencyPins[_patientId] = keccak256(abi.encodePacked(_pin));
        emit EmergencyPinSet(_patientId);
    }

    function emergencyAccess(uint256 _patientId, string memory _pin) public view returns (string memory) {
        require(_patientId < nextPatientId, "Patient record does not exist.");
        require(keccak256(abi.encodePacked(_pin)) == emergencyPins[_patientId], "Incorrect PIN.");
        return patientRecords[_patientId].ipfsHash;
    }

    function assignRole(address _account, bytes32 _role) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Not an admin.");
        grantRole(_role, _account);
    }
}
