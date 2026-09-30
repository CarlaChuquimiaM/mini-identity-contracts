// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CuentaUpgradeableV2 {
    address public owner;
    address public implementacion;
    
    // ARREGLO: ahora valida address(0)
    function ejecutar(address target, bytes calldata data) public {
        require(msg.sender == owner, "Solo owner");
        require(target != address(0), "Target no puede ser address(0)");
        
        (bool success, ) = target.call(data);
        require(success, "Llamada fallp");
    }
}