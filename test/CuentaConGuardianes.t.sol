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
    
    event GuardianInvitado(address indexed guardian);
    event GuardianConfirmado(address indexed guardian);
    event RecuperacionSolicitada(address indexed nuevoOwner, uint256 tiempoEjecucion);
    event RecuperacionAprobada(address indexed guardian, uint256 aprobacionesActuales);
    event RecuperacionEjecutada(address indexed nuevoOwner);
    event RecuperacionCancelada();
    
    function setUp() public {
        cuenta = new CuentaConGuardianes(owner, 2);
    }
    
    // Test 1: No se puede crear con owner = address(0)
    function test_NoSePuedeCrearConOwnerCero() public {
        vm.expectRevert("Owner no puede ser address(0)");
        new CuentaConGuardianes(address(0), 2);
    }
    
    // Test 2: Invitar guardián emite evento
    function test_InvitarGuardianEmiteEvento() public {
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit GuardianInvitado(bob);
        cuenta.invitarGuardian(bob);
    }
    
    // Test 3: No se puede invitar address(0)
    function test_NoSePuedeInvitarAddressCero() public {
        vm.prank(owner);
        vm.expectRevert("Guardian no puede ser address(0)");
        cuenta.invitarGuardian(address(0));
    }
    
    // Test 4: Confirmar guardián emite evento
    function test_ConfirmarGuardianEmiteEvento() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(bob);
        vm.expectEmit(true, false, false, false);
        emit GuardianConfirmado(bob);
        cuenta.confirmarGuardian();
    }
    
    // Test 5: Solicitar recuperación emite evento
    function test_SolicitarRecuperacionEmiteEvento() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit RecuperacionSolicitada(nuevoOwner, block.timestamp + 7 days);
        cuenta.solicitarRecuperacion(nuevoOwner);
    }
    
    // Test 6: No se puede solicitar con address(0)
    function test_NoSePuedeSolicitarConAddressCero() public {
        vm.prank(owner);
        vm.expectRevert("Nuevo owner no puede ser address(0)");
        cuenta.solicitarRecuperacion(address(0));
    }
    
    // Test 7: Aprobar emite evento con contador
    function test_AprobarEmiteEventoConContador() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(bob);
        cuenta.confirmarGuardian();
        
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        vm.prank(bob);
        vm.expectEmit(true, false, false, false);
        emit RecuperacionAprobada(bob, 1);
        cuenta.aprobarRecuperacion();
    }
    
    // Test 8: Ejecutar emite evento
    function test_EjecutarEmiteEvento() public {
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
        
        vm.warp(block.timestamp + 7 days + 1);
        
        vm.expectEmit(true, false, false, false);
        emit RecuperacionEjecutada(nuevoOwner);
        cuenta.ejecutarRecuperacion();
    }
    
    // Test 9: Cancelar emite evento
    function test_CancelarEmiteEvento() public {
        vm.prank(owner);
        cuenta.invitarGuardian(bob);
        
        vm.prank(owner);
        cuenta.solicitarRecuperacion(nuevoOwner);
        
        vm.prank(owner);
        vm.expectEmit(false, false, false, false);
        emit RecuperacionCancelada();
        cuenta.cancelarRecuperacion();
    }
}