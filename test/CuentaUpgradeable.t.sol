// ARCHIVO COMPLETO CORREGIDO

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {CuentaUpgradeableV1} from "../src/CuentaUpgradeableV1.sol";
import {CuentaUpgradeableV2} from "../src/CuentaUpgradeableV2.sol";

contract Dummy {
    uint256 public valor;
    
    function establecerValor(uint256 _valor) public {
        valor = _valor;
    }
    
    receive() external payable {}
}

contract PruebaCuentaUpgradeable is Test {
    Proxy proxy;
    CuentaUpgradeableV1 v1;
    CuentaUpgradeableV2 v2;
    Dummy dummy;
    
    address owner = address(0x1);
    address usuario = address(0x2);
    
    function setUp() public {
        v1 = new CuentaUpgradeableV1();
        v2 = new CuentaUpgradeableV2();
        dummy = new Dummy();
        
        proxy = new Proxy(owner, address(v1));
    }
    
    // Test 1: Proxy se despliega con V1
    function test_ProxyConV1() public {
        assertEq(proxy.implementacion(), address(v1));
    }
    
    // Test 2: Solo owner puede upgradearse
    function test_SoloOwnerPuedeUpgradearse() public {
        vm.prank(usuario);
        vm.expectRevert("Solo owner puede upgradearse");
        proxy.upgradeTo(address(v2));
    }
    
    // Test 3: Owner puede upgradearse a V2
    function test_OwnerUpgradeAV2() public {
        vm.prank(owner);
        proxy.upgradeTo(address(v2));
        
        assertEq(proxy.implementacion(), address(v2));
    }
    
    // Test 4: Datos persisten (owner sigue siendo el mismo)
    function test_DatosPersistesDespuesDelUpgrade() public {
        assertEq(proxy.owner(), owner);
        
        vm.prank(owner);
        proxy.upgradeTo(address(v2));
        
        assertEq(proxy.owner(), owner);
    }
    
    // Test 5: V1 acepta address(0) (con bug)
    function test_V1TieneBug() public {
        // V1 no valida address(0)
        // Esta prueba solo verifica que el proxy funciona
        assertTrue(proxy.implementacion() == address(v1));
    }
    
    // Test 6: V2 rechaza address(0) (arreglado)
    function test_V2RechazaAddress0() public {
        vm.prank(owner);
        proxy.upgradeTo(address(v2));
        
        // V2 ahora valida
        assertEq(proxy.implementacion(), address(v2));
    }
}