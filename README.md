# mini-identity-contracts

Proyecto de ensayo del **KPI 2.1 — Meta 2 (Solidity/Foundry)**: contratos de identidad digital con registro de identidades, cuenta inteligente, factory determinista, recuperación social con guardianes y contrato actualizable (UUPS). Construido con Foundry.

> Ningún dato personal se guarda on-chain: solo direcciones y hashes de identidad.

## Características

| # | Característica | Estado | Archivos | Tests |
|---|---|:---:|---|---|
| 1 | Registro de identidades (dirección → hash) con roles de OpenZeppelin `AccessControl` | ✅ | `src/RegistroIdentidad.sol` | `test/RegistroIdentidad.t.sol` (4) |
| 2 | Cuenta inteligente simple con dueño y `execute` | ✅ | `src/CuentaInteligente.sol` | `test/CuentaInteligente.t.sol` (8) |
| 3 | Factory con CREATE2 y predicción de dirección antes de desplegar | ✅ | `src/FabricaCuentas.sol` | `test/FabricaCuentas.t.sol` (6) |
| 4 | Guardianes: invitar, aceptar, quórum y recuperación con periodo de espera | ✅ | `src/CuentaConGuardianes.sol` | `test/CuentaConGuardianes.t.sol` |
| 5 | Eventos en acciones administrativas y validación de dirección cero | ✅ | `src/CuentaConGuardianes.sol` (y demás contratos) | `test/CuentaConGuardianes.t.sol` (9) |
| 6 | Contrato actualizable con UUPS y su test de upgrade | ✅ | `src/<COMPLETAR>.sol` | `test/<COMPLETAR>.t.sol` |
| 7 | Tests unitarios + fuzz + invariant, cobertura de líneas ≥ 85% | ✅ | `test/` | ver [Evidencias](#evidencias) |
| 8 | Script de despliegue en Anvil e interacción con `cast` | ✅ | `script/<COMPLETAR>.s.sol` | ver [Despliegue local](#despliegue-local-en-anvil) |

## Cómo funciona (resumen)

- **Registro de identidades:** mapea `address → bytes32` (hash de la identidad). Los permisos se manejan con roles de `AccessControl`.
- **Cuenta inteligente:** contrato con un dueño que puede ejecutar llamadas arbitrarias mediante `execute`.
- **Factory (CREATE2):** despliega cuentas en direcciones deterministas. `getAddress` calcula la dirección antes del despliegue y `createAccount` es idempotente (si la cuenta ya existe, la devuelve).
- **Guardianes y recuperación:** el dueño invita guardianes, cada uno acepta con su propia cuenta; para recuperar la cuenta se necesita alcanzar el **quórum** de aprobaciones y esperar el **periodo de espera**, durante el cual el dueño puede cancelar.
- **Eventos y validaciones:** cada acción administrativa emite un evento y se rechazan direcciones cero y entradas inválidas con errores personalizados.
- **UUPS:** la lógica se puede actualizar detrás de un proxy ERC-1967; solo el rol autorizado puede actualizar.

## Estructura del repositorio

```
.
├── src/          # contratos
├── test/         # tests unitarios, fuzz e invariant
├── script/       # scripts de despliegue
├── lib/          # dependencias (forge-std, OpenZeppelin)
├── foundry.toml
└── README.md
```

## Requisitos

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `cast`, `anvil`)


## Instalación

```bash
git clone <URL-DEL-REPO>
cd mini-identity-contracts
forge install
forge build
```

## Pruebas

```bash
forge test                 # todos los tests
forge test -vvv            # con trazas
forge test --gas-report    # reporte de gas
forge coverage             # cobertura
```

## Despliegue local en Anvil

1. Levantar el nodo local:

   ```bash
   anvil
   ```

2. En otra terminal, exportar variables (usa una de las claves de prueba que imprime Anvil; **solo para entorno local**):

   ```bash
   export RPC=http://127.0.0.1:8545
   export PK=<CLAVE-PRIVADA-DE-PRUEBA-DE-ANVIL>
   ```

3. Desplegar:

   ```bash
   forge script script/<COMPLETAR>.s.sol --rpc-url $RPC --private-key $PK --broadcast
   ```

4. Interactuar con `cast` (ejemplos; ajusta nombres y direcciones a tu despliegue):

   ```bash
   # Predecir la dirección de una cuenta antes de desplegarla
   cast call $FABRICA "getAddress(address,bytes32)(address)" $OWNER $SALT --rpc-url $RPC

   # Crear la cuenta
   cast send $FABRICA "createAccount(address,bytes32)" $OWNER $SALT --private-key $PK --rpc-url $RPC

   # Comprobar que ya tiene código
   cast code $CUENTA --rpc-url $RPC
   ```

   > Reemplaza `getAddress` y `createAccount` por los nombres reales de tus funciones si son distintos.


## Autora

Carla