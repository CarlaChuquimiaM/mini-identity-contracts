// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {FabricaCuentas} from "../src/FabricaCuentas.sol";
import {CuentaInteligente} from "../src/CuentaInteligente.sol";

contract PruebaFabricaCuentas is Test {
    FabricaCuentas fabrica;
    
    function setUp() public {
        fabrica = new FabricaCuentas();
    }
    
    // Test 1: Predecir dirección (es un número válido)
    function test_PredecirDireccion() public {
        address predicha = fabrica.predecirDireccion(123);
        assertTrue(predicha != address(0));
    }
    
    // Test 2: Mismo salt = misma dirección predicha (consistencia)
    function test_SaltConsistenteDevuelveMismaDireccion() public {
        address predicha1 = fabrica.predecirDireccion(123);
        address predicha2 = fabrica.predecirDireccion(123);
        assertEq(predicha1, predicha2);
    }
    
    // Test 3: Salts diferentes = direcciones diferentes
    function test_SaltsDiferentesDanDireccionesDiferentes() public {
        address predicha1 = fabrica.predecirDireccion(123);
        address predicha2 = fabrica.predecirDireccion(456);
        assertTrue(predicha1 != predicha2);
    }
    
    // Test 4: Crear cuenta (desplegar realmente)
    function test_CrearCuenta() public {
        address cuenta = fabrica.crearCuenta(address(0x1), 123);
        assertTrue(cuenta != address(0));
        assertTrue(cuenta.code.length > 0);
    }
    
    // Test 5: La cuenta tiene el owner correcto
    function test_CuentaTieneOwnerCorrecto() public {
        address propietario = address(0x1);
        address cuentaAddr = fabrica.crearCuenta(propietario, 123);
        
        CuentaInteligente cuenta = CuentaInteligente(payable(cuentaAddr));
        assertEq(cuenta.owner(), propietario);
    }
    
    // Test 6: Contar cuentas
    function test_ContarCuentas() public {
        fabrica.crearCuenta(address(0x1), 123);
        fabrica.crearCuenta(address(0x2), 456);
        assertEq(fabrica.totalCuentas(), 2);
    }
}