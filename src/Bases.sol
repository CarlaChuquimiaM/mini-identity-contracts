// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IdentityRegistry {
    // variables de  estado
    address public owner;

    //Constructor
    constructor() {
        owner = msg.sender;
    }

    //funcion
    function getOwner() public view returns (address) {
        return owner;
    }

    uint256 public totalIdentitidades = 0;
    function createIdentity() public {
        uint256 temporaryId = totalIdentitidades + 1;
        totalIdentitidades = temporaryId;
    }

    // function getIdentity(address user) public view returns (bytes32) {
    //     //Consulta una identidad
    // }
    mapping(address => bytes32) public identidades;

    function registraridentidad(bytes32 identityhash) public {
        identidades[msg.sender] = identityhash;
    }

    function getIdentidad(address user) public view returns (bytes32) {
        return identidades[user];
    }

    struct Identidad {
        bytes32 identidadHash;
        uint256 creadoPor;
        bool active;
    }

    enum IdentidadEstado {
        NoRegistado,
        Activo,
        Revocado
    }

    mapping(address => bytes32) public identities;
}
