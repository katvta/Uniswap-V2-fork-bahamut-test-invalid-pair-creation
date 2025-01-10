// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";

contract TestUniswapFactory is Test {
    address public factoryAddress = 0xd0C5d23290d63E06a0c4B87F14bD2F7aA551a895;  // Endereço do contrato UniswapV2Factory

    function testCreatePairWithInvalidTokens() public {
        address factory = factoryAddress;

        // Verifica o número de pares antes da tentativa de criação do par inválido
        (bool successAllPairsBefore, bytes memory dataAllPairsBefore) = factory.call(
            abi.encodeWithSignature("allPairsLength()")
        );
        require(successAllPairsBefore, "Falha ao consultar allPairsLength antes");
        uint256 allPairsLengthBefore = abi.decode(dataAllPairsBefore, (uint256));

        // Utiliza dois endereços aleatórios inválidos (não ERC-20)
        address invalidTokenAddress1 = 0x5555555555555555555555555555555555555555;  // Endereço fictício 1
        address invalidTokenAddress2 = 0x6666666666666666666666666666666666666666;  // Endereço fictício 2

        // Tentativa de criar o par com os dois "tokens inválidos" com endereços diferentes
        (bool success, bytes memory returnData) = factory.call(
            abi.encodeWithSignature("createPair(address,address)", invalidTokenAddress1, invalidTokenAddress2)
        );

        // Depuração: Imprime o motivo da falha, se houver
        if (!success) {
            emit log_bytes(returnData);
        }

        // Validação: Certifica-se de que a criação do par falhou
        require(!success, "A criacao do par nao deveria ter sido bem-sucedida");

        // Verifica o número de pares após a tentativa de criação do par inválido
        (bool successAllPairsAfter, bytes memory dataAllPairsAfter) = factory.call(
            abi.encodeWithSignature("allPairsLength()")
        );
        require(successAllPairsAfter, "Falha ao consultar allPairsLength depois");
        uint256 allPairsLengthAfter = abi.decode(dataAllPairsAfter, (uint256));

        // Verifica que o número de pares não foi alterado
        assertEq(allPairsLengthBefore, allPairsLengthAfter, "O par invalido nao deveria ter sido adicionado a lista allPairs");

        // Verifique se o par não foi criado no mapeamento getPair
        (bool successGetPair, bytes memory dataGetPair) = factory.call(
            abi.encodeWithSignature("getPair(address,address)", invalidTokenAddress1, invalidTokenAddress2)
        );
        require(successGetPair, "Falha ao consultar getPair");
        address storedPair = abi.decode(dataGetPair, (address));
        assertEq(storedPair, address(0), "O par invalido nao deveria existir no mapeamento getPair");
    }
}
