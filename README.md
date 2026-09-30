# Mini Identity Contracts — Módulo Solidity/Foundry

Proyecto de aprendizaje de contratos inteligentes para un sistema de identidad digital descentralizado.

## 🎯 Objetivo

Dominar Solidity y Foundry construyendo contratos de identidad desde cero, con énfasis en:
- Control de acceso (roles)
- Validación de datos
- Eventos y logs
- Testing con Foundry (unitarios, fuzz, invariants)
- Patrones de Account Abstraction (ERC-4337)

## 📋 Características planificadas

- [x] **Característica 1:** Registro de Identidades (RegistroIdentidad.sol)
- [ ] **Característica 2:** Cuenta Inteligente Simple (CuentaSimple.sol)
- [ ] **Característica 3:** Factory con CREATE2
- [ ] **Característica 4:** Sistema de Guardianes (recuperación social)
- [ ] **Característica 5:** Eventos y validaciones
- [ ] **Característica 6:** Upgrade con UUPS
- [ ] **Característica 7:** Tests + Cobertura ≥85%
- [ ] **Característica 8:** Script de despliegue

## ✅ Característica 1: Registro de Identidades

### Qué hace

Contrato que:
- Registra una identidad para cada dirección de usuario
- Guarda solo el **hash** de los datos (privacidad on-chain)
- Restringe quién puede registrar (rol EMISOR)
- Emite eventos cuando se registra una identidad

### Flujo de uso
Despliegue:
- Constructor da DEFAULT_ADMIN_ROLE al deployer
- El admin puede autorizar emisores
Autorizar un emisor:
- admin.grantRole(ROL_EMISOR, emisor_address)
Registrar identidad:
emisor.registrarIdentidad(usuario_address, hash_identidad)
- Valida que usuario != address(0)
- Guarda en storage: hashIdentidad[usuario] = hash
- Emite evento: IdentidadRegistrada(usuario, hash)
Leer identidad:
- cualquiera.obtenerHashIdentidad(usuario_address)
- Devuelve el hash (o 0x 000... si no existe)
### Estructura del contrato

```
contract RegistroIdentidad is AccessControl {
    bytes32 public constant ROL_EMISOR
    mapping(address => bytes32) public hashIdentidad
    
    event IdentidadRegistrada(address indexed usuario, bytes32 indexed hashIdentidad)
    
    constructor()
    
    // Funciones
    function registrarIdentidad(address, bytes32) onlyRole(ROL_EMISOR)
    function obtenerHashIdentidad(address) public view returns (bytes32)
}
```

### Tests incluidos

| Test | Qué valida |
|---|---|
| `prueba_SoloEmisorPuedeRegistrar` | Solo ROL_EMISOR puede registrar |
| `prueba_NoSePuedoRegistrarDireccionCero` | Rechaza address(0) |
| `prueba_EmiteEventoAlRegistrar` | Emite evento correctamente |
| `prueba_PuedeSobrescribirIdentidadExistente` | Permite actualizar identidad |
