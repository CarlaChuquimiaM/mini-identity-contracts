// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address public owner;
    address public implementacion;

    constructor(address _owner, address _implementacion) {
        owner = _owner;
        implementacion = _implementacion;
    }

    // Cambiar la implementación (solo owner)
    function upgradeTo(address newImplementacion) public {
        require(msg.sender == owner, "Solo owner puede upgradearse");
        implementacion = newImplementacion;
    }
    // Recibir ETH
    receive() external payable {}
    // FALLBACK: delega TODAS las llamadas a implementación
    fallback() external payable {
        address impl = implementacion;
        assembly {
            // delegatecall al implementación
            // Las variables (owner, implementacion) viven aquí
            // La nueva lógica está en 'impl'
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                gas(),
                impl,
                ptr,
                calldatasize(),
                ptr,
                0x20
            )
            returndatacopy(ptr, 0, returndatasize())

            switch result
            case 0 {
                revert(ptr, returndatasize())
            }
            default {
                return(ptr, returndatasize())
            }
        }
    }
}
