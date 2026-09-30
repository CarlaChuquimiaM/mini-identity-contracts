// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CuentaConGuardianes {
    // Estado actual
    address public owner;
    uint256 public quorum;
    
    // Guardianes
    address[] public guardianes;
    mapping(address => bool) public confirmado;
    
    // Recuperacion
    address public nuevoOwnerPendiente;
    uint256 public aprobacionesRecuperacion;
    uint256 public tiempoEjecucion;
    bool public hayRecuperacionEnCurso;
    
    // Constante
    uint256 public constant DIAS_ESPERA = 7 days;
    
    // === EVENTOS ===
    event GuardianInvitado(address indexed guardian);
    event GuardianConfirmado(address indexed guardian);
    event RecuperacionSolicitada(
        address indexed nuevoOwner,
        uint256 tiempoEjecucion
    );
    event RecuperacionAprobada(
        address indexed guardian,
        uint256 aprobacionesActuales
    );
    event RecuperacionEjecutada(address indexed nuevoOwner);
    event RecuperacionCancelada();
    
    // Constructor
    constructor(address _owner, uint256 _quorum) {
        require(_owner != address(0), "Owner no puede ser address(0)");
        require(_quorum > 0, "Quorum debe ser mayor a 0");
        
        owner = _owner;
        quorum = _quorum;
    }
    
    // === GUARDIANES ===
    
    // Owner invita un guardian
    function invitarGuardian(address guardian) public {
        require(msg.sender == owner, "Solo owner puede invitar");
        require(guardian != address(0), "Guardian no puede ser address(0)");
        require(!confirmado[guardian], "Ya es guardian");
        
        guardianes.push(guardian);
        emit GuardianInvitado(guardian);
    }
    
    // El guardian confirma que acepta
    function confirmarGuardian() public {
        require(msg.sender != address(0), "Direccion invalida");
        
        // Buscar si fue invitado
        bool fueInvitado = false;
        for (uint256 i = 0; i < guardianes.length; i++) {
            if (guardianes[i] == msg.sender) {
                fueInvitado = true;
                break;
            }
        }
        require(fueInvitado, "No fuiste invitado como guardian");
        require(!confirmado[msg.sender], "Ya confirmaste");
        
        confirmado[msg.sender] = true;
        emit GuardianConfirmado(msg.sender);
    }
    
    // === RECUPERACIoN ===
    
    // Solicitar recuperacion
    function solicitarRecuperacion(address nuevoOwner) public {
        require(nuevoOwner != address(0), "Nuevo owner no puede ser address(0)");
        require(!hayRecuperacionEnCurso, "Ya hay recuperacion en curso");
        require(nuevoOwner != owner, "Nuevo owner debe ser diferente");
        
        nuevoOwnerPendiente = nuevoOwner;
        aprobacionesRecuperacion = 0;
        tiempoEjecucion = block.timestamp + DIAS_ESPERA;
        hayRecuperacionEnCurso = true;
        
        emit RecuperacionSolicitada(nuevoOwner, tiempoEjecucion);
    }
    
    // Guardian aprueba
    function aprobarRecuperacion() public {
        require(msg.sender != address(0), "Direccion invalida");
        require(confirmado[msg.sender], "No eres guardian confirmado");
        require(hayRecuperacionEnCurso, "No hay recuperacion en curso");
        
        aprobacionesRecuperacion++;
        emit RecuperacionAprobada(msg.sender, aprobacionesRecuperacion);
    }
    
    // Ejecutar recuperacion
    function ejecutarRecuperacion() public {
        require(hayRecuperacionEnCurso, "No hay recuperacion en curso");
        require(aprobacionesRecuperacion >= quorum, "No hay suficientes aprobaciones");
        require(block.timestamp >= tiempoEjecucion, "Debe esperar 7 dias");
        
        address nuevoOwner = nuevoOwnerPendiente;
        owner = nuevoOwner;
        hayRecuperacionEnCurso = false;
        
        emit RecuperacionEjecutada(nuevoOwner);
    }
    
    // Owner cancela (en cualquier momento)
    function cancelarRecuperacion() public {
        require(msg.sender == owner, "Solo owner puede cancelar");
        require(hayRecuperacionEnCurso, "No hay recuperacion para cancelar");
        
        hayRecuperacionEnCurso = false;
        emit RecuperacionCancelada();
    }
}