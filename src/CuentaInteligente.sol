// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CuentaInteligente {
    // Almacenamiento
    address public owner;

    // Eventos
    event Ejecutado(address indexed target, uint256 value, bytes data);

    event EtherRecibido(address indexed remitente, uint256 cantidad);

    event PropietarioActualizado(address indexed nuevoOwner);

    // Constructor
    constructor(address _owner) {
        require(_owner != address(0), "Owner invalido");
        owner = _owner;
    }

    // Modificador: solo el owner puede ejecutar
    modifier soloOwner() {
        require(msg.sender == owner, "Solo el propietario puede ejecutar");
        _;
    }

    // Función principal: ejecutar una llamada arbitraria
    function ejecutar(
        address target,
        uint256 value,
        bytes calldata data
    ) public soloOwner returns (bool success, bytes memory result) {
        require(target != address(0), "direccion de target no puede ser 0");

        emit Ejecutado(target, value, data);

        (success, result) = target.call{value: value}(data);
        require(success, "Ejecucion fallo");
    }

    // Recibir ETH
    receive() external payable {
        emit EtherRecibido(msg.sender, msg.value);
    }

    // Ver el balance de la cuenta
    function verBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Cambiar el propietario (solo owner)
    function cambiarPropietario(address nuevoOwner) public soloOwner {
        require(nuevoOwner != address(0), "Owner invalido");
        owner = nuevoOwner;

        emit PropietarioActualizado(nuevoOwner);
    }
}
