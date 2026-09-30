// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Script.sol";
// import {RegistroIdentidad} from "../src/IdentityRegistry.sol";

// contract DesplegarRegistroIdentidad is Script {
//     function run() public {
//         // Obtener la clave privada del .env o usar una por defecto
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
//         vm.startBroadcast(deployerPrivateKey);
        
//         // 1. Desplegar el contrato
//         RegistroIdentidad registro = new RegistroIdentidad();
//         console.log("RegistroIdentidad desplegado en:", address(registro));
        
//         // 2. Obtener la dirección del emisor (Account #1 de Anvil)
//         address emisor = 0x70997970C51812e339D9B73b0245ad59DDD2F0B4;
        
//         // 3. Dar el rol EMISOR al segundo account
//         registro.grantRole(registro.ROL_EMISOR(), emisor);
//         console.log("Rol EMISOR otorgado a:", emisor);
        
//         // 4. Registrar una identidad (como emisor)
//         bytes32 hashIdentidad = keccak256(abi.encode("Juan", "12345678"));
//         address usuario = 0x90F79bf6EB2c4f870365E785982E1f101E93b906; // Account #2
        
//         // Cambiar a emisor para registrar
//         vm.startPrank(emisor);
//         registro.registrarIdentidad(usuario, hashIdentidad);
//         console.log("Identidad registrada para:", usuario);
        
//         // 5. Leer la identidad registrada
//         bytes32 hashLeido = registro.obtenerHashIdentidad(usuario);
//         console.log("Hash leido:");
//         console.logBytes32(hashLeido);
        
//         vm.stopPrank();
//         vm.stopBroadcast();
//     }
// }