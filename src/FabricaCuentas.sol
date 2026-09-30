// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CuentaInteligente} from "./CuentaInteligente.sol";

contract FabricaCuentas {
    // Solo guardar las cuentas creadas
    address[] public cuentas;
    
    // Evento
    event CuentaCreada(
        address indexed propietario,
        address direccion
    );
    
    // Función 1: PREDECIR dirección (sin crear)
    function predecirDireccion(uint256 salt)
        public
        view
        returns (address)
    {
        return address(uint160(uint256(keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                bytes32(salt),
                keccak256(type(CuentaInteligente).creationCode)
            )
        ))));
    }
    
    // Función 2: CREAR cuenta
    function crearCuenta(address propietario, uint256 salt)
        public
        returns (address)
    {
        require(propietario != address(0), "Propietario invalido");
        
        // Predecir dónde vivirá
        address predicha = predecirDireccion(salt);
        
        // Emitir antes
        emit CuentaCreada(propietario, predicha);
        
        // Desplegar con CREATE2
        CuentaInteligente cuenta = new CuentaInteligente{salt: bytes32(salt)}(propietario);
        
        // Guardar
        cuentas.push(address(cuenta));
        
        return address(cuenta);
    }
    
    // Ver cuántas cuentas
    function totalCuentas() public view returns (uint256) {
        return cuentas.length;
    }
}