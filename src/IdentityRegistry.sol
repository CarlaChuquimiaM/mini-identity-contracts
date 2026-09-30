// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RegistroIdentidad is AccessControl {
    // Definir el rol de emisor
    bytes32 public constant ROL_EMISOR = keccak256("ROL_EMISOR");
    
    // Almacenamiento: mapeo de dirección → hash de identidad
    mapping(address => bytes32) public hashIdentidad;
    
    // Evento: emitido cuando se registra una identidad
    event IdentidadRegistrada(
        address indexed usuario,
        bytes32 indexed hashIdentidad
    );
    
    // Constructor
    constructor() {
        // El que despliega es el administrador
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    // Función para registrar una identidad
    function registrarIdentidad(address usuario, bytes32 _hashIdentidad)
        public
        onlyRole(ROL_EMISOR)
    {
        // Validar que no sea dirección cero
        require(usuario != address(0), "Direccion invalida");
        
        // Guardar el hash en almacenamiento
        hashIdentidad[usuario] = _hashIdentidad;
        
        // Emitir evento
        emit IdentidadRegistrada(usuario, _hashIdentidad);
    }
    
    // Función para leer el hash de identidad (pública, cualquiera puede leer)
    function obtenerHashIdentidad(address usuario)
        public
        view
        returns (bytes32)
    {
        return hashIdentidad[usuario];
    }
}