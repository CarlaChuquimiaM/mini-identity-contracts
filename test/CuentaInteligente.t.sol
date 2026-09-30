// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CuentaInteligente} from "../src/CuentaInteligente.sol";

// Contrato dummy para recibir llamadas
contract Dummy {
    uint256 public valor;

    function establecerValor(uint256 _valor) public {
        valor = _valor;
    }

    // ARREGLO: Agregar receive() para poder recibir ETH
    receive() external payable {}
}

contract PruebaCuentaInteligente is Test {
    // Eventos (duplicados para poder emitir en el test)
    event Ejecutado(address indexed target, uint256 value, bytes data);

    event EtherRecibido(address indexed remitente, uint256 cantidad);

    CuentaInteligente cuenta;
    Dummy dummy;
    address owner = address(0x1);
    address usuario = address(0x2);

    function setUp() public {
        cuenta = new CuentaInteligente(owner);
        dummy = new Dummy();
    }

    // Test 1: El constructor asigna el owner correctamente
    function test_ConstructorAsignaOwner() public {
        assertEq(cuenta.owner(), owner);
    }

    // Test 2: Solo el owner puede ejecutar
    function test_SoloOwnerPuedeEjecutar() public {
        bytes memory data = abi.encodeWithSignature(
            "establecerValor(uint256)",
            42
        );

        // Usuario normal intenta ejecutar (debe fallar)
        vm.prank(usuario);
        vm.expectRevert("Solo el propietario puede ejecutar");
        cuenta.ejecutar(address(dummy), 0, data);

        // Owner ejecuta (debe pasar)
        vm.prank(owner);
        cuenta.ejecutar(address(dummy), 0, data);

        // Verifica que se ejecutó
        assertEq(dummy.valor(), 42);
    }

    // Test 3: Se puede enviar ETH con execute
    function test_PuedeEnviarEthConEjecutar() public {
        // ARREGLO: Usar vm.deal() para dar ETH a la cuenta
        vm.deal(address(cuenta), 1 ether);
        assertEq(cuenta.verBalance(), 1 ether);

        // Owner envía 0.5 ETH a dummy
        vm.prank(owner);
        cuenta.ejecutar(address(dummy), 0.5 ether, bytes(""));

        // Verifica que dummy recibió
        assertEq(address(dummy).balance, 0.5 ether);
        assertEq(cuenta.verBalance(), 0.5 ether);
    }

    // Test 4: Emite evento cuando ejecuta
    function test_EmiteEventoAlEjecutar() public {
        bytes memory data = abi.encodeWithSignature(
            "establecerValor(uint256)",
            99
        );

        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit Ejecutado(address(dummy), 0, data);
        cuenta.ejecutar(address(dummy), 0, data);
    }

    // Test 5: Recibe ETH con receive()
    function test_RecibeEthConReceive() public {
        // ARREGLO: Usar vm.deal() para dar ETH al usuario
        vm.deal(usuario, 2 ether);

        vm.prank(usuario);
        vm.expectEmit(true, false, false, true);
        emit EtherRecibido(usuario, 2 ether);
        (bool success, ) = address(cuenta).call{value: 2 ether}("");
        require(success);

        assertEq(cuenta.verBalance(), 2 ether);
    }

    // Test 6: Solo owner puede cambiar propietario
    function test_SoloOwnerPuedeCambiarPropietario() public {
        address nuevoOwner = address(0x3);

        // Usuario intenta cambiar (debe fallar)
        vm.prank(usuario);
        vm.expectRevert("Solo el propietario puede ejecutar");
        cuenta.cambiarPropietario(nuevoOwner);

        // Owner cambia (debe pasar)
        vm.prank(owner);
        cuenta.cambiarPropietario(nuevoOwner);

        assertEq(cuenta.owner(), nuevoOwner);
    }

    // Test 7: No se puede cambiar a owner inválido
    function test_NoSePuedoCambiarAOwnerInvalido() public {
        vm.prank(owner);
        vm.expectRevert("Owner invalido");
        cuenta.cambiarPropietario(address(0));
    }

    // Test 8: No se puede ejecutar con target inválido
    function test_NoSePuedeEjecutarConTargetInvalido() public {
        vm.prank(owner);
        vm.expectRevert("direccion de target no puede ser 0");
        cuenta.ejecutar(address(0), 0, bytes(""));
    }
}
