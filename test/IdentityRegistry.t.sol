// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {RegistroIdentidad} from "../src/IdentityRegistry.sol";

contract PruebaRegistroIdentidad is Test {
    // Duplica la declaración del evento aquí
    event IdentidadRegistrada(
        address indexed usuario,
        bytes32 indexed hashIdentidad
    );
    
    RegistroIdentidad registro;
    address administrador = address(0x1);
    address emisor = address(0x2);
    address usuario = address(0x3);
    
    function setUp() public {
        registro = new RegistroIdentidad();
        registro.grantRole(registro.ROL_EMISOR(), emisor);
    }
    
    // Test 1: Solo un emisor autorizado puede registrar
    function test_SoloEmisorPuedeRegistrar() public {
        bytes32 hashIdentidad = keccak256(abi.encode("Alicia", "12345678"));
        
        // Intenta registrar como usuario normal (debe fallar)
        vm.prank(usuario);
        vm.expectRevert();
        registro.registrarIdentidad(usuario, hashIdentidad);
        
        // Registra como emisor (debe pasar)
        vm.prank(emisor);
        registro.registrarIdentidad(usuario, hashIdentidad);
        
        // Verifica que se registró
        assertEq(registro.obtenerHashIdentidad(usuario), hashIdentidad);
    }
    
    // Test 2: No se puede registrar la dirección cero
    function test_NoSePuedoRegistrarDireccionCero() public {
        bytes32 hashIdentidad = keccak256(abi.encode("Alicia", "12345678"));
        
        vm.prank(emisor);
        vm.expectRevert("Direccion invalida");
        registro.registrarIdentidad(address(0), hashIdentidad);
    }
    
    // Test 3: Emite evento cuando se registra
    function test_EmiteEventoAlRegistrar() public {
        bytes32 hashIdentidad = keccak256(abi.encode("Alicia", "12345678"));
        
        vm.prank(emisor);
        vm.expectEmit(true, true, false, true);
        emit IdentidadRegistrada(usuario, hashIdentidad);
        registro.registrarIdentidad(usuario, hashIdentidad);
    }
    
    // Test 4: Se puede sobrescribir una identidad existente
    function test_PuedeSobrescribirIdentidadExistente() public {
        bytes32 hash1 = keccak256(abi.encode("Alicia", "12345678"));
        bytes32 hash2 = keccak256(abi.encode("Alicia", "87654321"));
        
        vm.prank(emisor);
        registro.registrarIdentidad(usuario, hash1);
        assertEq(registro.obtenerHashIdentidad(usuario), hash1);
        
        vm.prank(emisor);
        registro.registrarIdentidad(usuario, hash2);
        assertEq(registro.obtenerHashIdentidad(usuario), hash2);
    }
}