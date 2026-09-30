// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IdentificarRegistro {
    address public admin;
    mapping(address => bytes32) public identidades;

    event RegistrandoIdentidad(address usuario, bytes32 identidadHash);

    constructor() {
        admin = msg.sender;
    }

    modifier soloAdmin() {
        require(msg.sender == admin, "No es admin");
        _;
    }

    function registrarIdentidad(
        address usuario,
        bytes32 identidadHash
    ) public soloAdmin {
        identidades[usuario] = identidadHash;

        emit RegistrandoIdentidad(usuario, identidadHash);
    }
}
