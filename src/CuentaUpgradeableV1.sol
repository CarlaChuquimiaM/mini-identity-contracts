// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CuentaUpgradeableV1 {
    address public owner;
    address public implementacion; 
    
    function ejecutar(address target, bytes calldata data) public {
        require(msg.sender == owner, "Solo owner");
        
        // BUG: falta validar target != address(0)
        (bool success, ) = target.call(data);
        require(success, "Llamada fallo");
    }
}