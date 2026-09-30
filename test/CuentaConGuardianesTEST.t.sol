// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CuentaConGuardianes} from "../src/CuentaConGuardianes.sol";

contract PruebaCuentaConGuardianes is Test {
    CuentaConGuardianes cuenta;
    
    address owner = address(0x1);
    address bob = address(0x2);
    address carol = address(0x3);
    address nuevoOwner = address(0x5);
    
    function setUp() public {
        cuenta = new CuentaConGuardianes(owner, 2);
    }
    
    // === TESTS UNITARIOS ===
    
    function test_ConstructorAsignaOwner() public view {
        assertEq(cuenta.owner(), owner);
    }
    
    function test_ConstructorAsignaQuorum() public view{
        assertEq(cuenta.quorum(), 2);
    }
    
    function test_InvitarGuardian() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        assertTrue(cuenta.confirmado(bob) == false);
    }
    
    function test_ConfirmarGuardian() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(bob);
        cuenta.confirmarGuardian();
        
        assertTrue(cuenta.confirmado(bob));
    }
    
    function test_SolicitarRecuperacion() public {
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        assertEq(cuenta.nuevoOwnerPendiente(), nuevoOwner);
        assertTrue(cuenta.hayRecuperacionEnCurso());
    }
    
    function test_AprobarRecuperacion() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(bob);
        cuenta.confirmarGuardian();
        
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        vm.prank(bob);
        cuenta.aprobarRecuperacion();
        
        assertEq(cuenta.aprobacionesRecuperacion(), 1);
    }
    
    function test_EjecutarRecuperacion() public {
        // Setup: 2 guardianes, solicitar, ambos aprueban
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(owner);
        cuenta.invitarGuardian(carol);
        
        vm.prank(bob);
        cuenta.confirmarGuardian();
        
        vm.prank(carol);
        cuenta.confirmarGuardian();
        
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        vm.prank(bob);
        cuenta.aprobarRecuperacion();
        
        vm.prank(carol);
        cuenta.aprobarRecuperacion();
        
        // Avanzar tiempo
        vm.warp(block.timestamp + 7 days + 1);
        
        // Ejecutar
        cuenta.ejecutarRecuperacion();
        
        assertEq(cuenta.owner(), nuevoOwner);
    }
    
    function test_CancelarRecuperacion() public {
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        vm.prank(owner);
        cuenta.cancelarRecuperacion();
        
        assertFalse(cuenta.hayRecuperacionEnCurso());
    }
    
    // === FUZZ TESTS ===
    
    function testFuzz_NoSePuedeInvitarAddressCero(address random) public {
        vm.assume(random == address(0));
        
        vm.prank(owner);
        vm.expectRevert("Guardian no puede ser address(0)");
        cuenta.invitarGuardian(random);
    }
    
    function testFuzz_NoSePuedeSolicitarConNuevoOwnerCero(address random) public {
        vm.assume(random == address(0));
        
        vm.prank(owner);
        vm.expectRevert("Nuevo owner no puede ser address(0)");
        cuenta.solicitarRecuperacion(random);
    }
    
    function testFuzz_NuevoOwnerNoDebeSerMismoOwner(address random) public {
        vm.assume(random != address(0));
        vm.assume(random == owner);
        
        vm.prank(owner);
        vm.expectRevert("Nuevo owner debe ser diferente");
        cuenta.solicitarRecuperacion(random);
    }
    
    function testFuzz_AprobacionesNoExcedenGuardianes() public {
        // Setup con random guardianes
        address[] memory guardianes = new address[](5);
        guardianes[0] = address(0x10);
        guardianes[1] = address(0x11);
        guardianes[2] = address(0x12);
        guardianes[3] = address(0x13);
        guardianes[4] = address(0x14);
        
        // Invitar todos
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(owner);
            cuenta.invitarGuardian(guardianes[i]);
            
            vm.prank(guardianes[i]);
            cuenta.confirmarGuardian();
        }
        
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(guardianes[i]);
            cuenta.aprobarRecuperacion();
        }
        
        // Las aprobaciones no deben exceder guardianes
        assertTrue(cuenta.aprobacionesRecuperacion() <= 5);
    }
    
    // === INVARIANT TESTS ===
    
    function invariant_OwnerNuncaCambiaHastaMintrasRecuperacion() public {
        // El owner no debe cambiar hasta que se ejecute la recuperación
        assertEq(cuenta.owner(), owner);
    }
    
    function invariant_QuorumNuncaCambia() public {
        // El quórum debe ser siempre 2
        assertEq(cuenta.quorum(), 2);
    }
}