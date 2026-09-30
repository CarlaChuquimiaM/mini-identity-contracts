// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IdentificarRegistro {
    address public admin;
    mapping(address => bytes32) public identidades;

    constructor() {
        admin = msg.sender;
    }

    // function registrarIdentidad(address usuario, bytes32 identidadHash) public {
    //     identidades[usuario] = identidadHash;
    // }
    modifier soloAdmin() {
        require(msg.sender == admin, "No es admin");
        _;
    }

    function registrarIdentidad(
        address usuario,
        bytes32 identidadHash
    ) public soloAdmin {
        identidades[usuario] = identidadHash;
    }
}
