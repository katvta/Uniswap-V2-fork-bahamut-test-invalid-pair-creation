# Uniswap-V2-fork-bahamut-test-invalid-pair-creation

Aqui está um exemplo de `README.md` que você pode adicionar ao seu repositório Foundry no GitHub para documentar o relatório de bug bounty:

```markdown
# UniswapV2Factory ERC-20 Validation Vulnerability

Este repositório contém um relatório detalhado e um Proof of Concept (PoC) para uma vulnerabilidade identificada no contrato `UniswapV2Factory`. A vulnerabilidade permite a criação de pares de tokens sem validar se os endereços fornecidos são contratos ERC-20 válidos, o que pode comprometer a segurança e a integridade do ecossistema Uniswap.

## Descrição do Bug

O contrato `UniswapV2Factory` permite a criação de pares de tokens sem validar se os endereços fornecidos são contratos ERC-20 válidos. A função `createPair` apenas impede o uso de tokens idênticos ou o endereço zero para a criação de pares. Isso cria uma vulnerabilidade significativa, pois qualquer endereço (válido ou inválido) pode ser usado para criar pares, incluindo contratos não ERC-20 ou até mesmo contratos maliciosos.

### Impacto

A falta de validação para conformidade ERC-20 nos tokens fornecidos à função `createPair` compromete a integridade e a segurança do ecossistema Uniswap. Essa vulnerabilidade pode levar a:

- **Instabilidade dos Pools de Liquidez**: A capacidade de criar pares com tokens inválidos pode resultar em pools de liquidez sem valor real, afetando a descoberta de preços e a operação suave da exchange descentralizada.
  
- **Exploração de Vulnerabilidades em Protocolos Dependentes**: Pares de tokens inválidos podem interagir com outros protocolos ou contratos inteligentes que dependem da Uniswap para liquidez, potencialmente desencadeando comportamentos imprevistos.

- **Erosão da Confiança do Usuário**: Usuários que interagem com a plataforma podem, sem saber, engajar-se com pares de tokens inválidos, resultando em transações falhas, perdas financeiras ou ativos bloqueados.

## Risco

- **Dificuldade de Exploração**: Fácil
- **Pontuação no Sistema de Pontuação de Vulnerabilidade Remedy 1.0**: 8.2 (Alto)

## Recomendações

### Validação ERC-20

Recomenda-se adicionar uma verificação para garantir que os tokens fornecidos para a criação de pares estejam em conformidade com o padrão ERC-20. A validação deve garantir que ambos os tokens implementem as funções básicas do ERC-20, como `totalSupply`, `balanceOf` e `transfer`.

#### Exemplo de Código de Verificação:

```solidity
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

function isERC20(address token) internal view returns (bool) {
    try IERC20(token).totalSupply() returns (uint256) {
        return true;
    } catch {
        return false;
    }
}
```

### Implementação na Função `createPair`

Adicione a validação ERC-20 na função `createPair` para garantir que ambos os tokens sejam válidos antes de permitir a criação do par.

#### Exemplo de Código Modificado:

```solidity
function createPair(address tokenA, address tokenB) external returns (address pair) {
    require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
    require(isERC20(tokenA) && isERC20(tokenB), "UniswapV2: INVALID_ERC20");
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
    require(getPair[token0][token1] == address(0), "UniswapV2: PAIR_EXISTS");

    bytes memory bytecode = type(UniswapV2Pair).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    assembly {
        pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }

    IUniswapV2Pair(pair).initialize(token0, token1);
    getPair[token0][token1] = pair;
    getPair[token1][token0] = pair;
    allPairs.push(pair);
    emit PairCreated(token0, token1, pair, allPairs.length);
}
```

### Testes Unitários

Implemente testes unitários abrangentes para validar a correção das verificações, incluindo casos de sucesso (tokens válidos) e casos de falha (tokens inválidos ou não conformes com ERC-20).

## Proof of Concept (PoC)

O repositório inclui um teste que demonstra a vulnerabilidade. O teste tenta criar um par com tokens inválidos e verifica se a criação do par falha conforme esperado.

### Executando o Teste

1. **Instale o Foundry**:
   Certifique-se de que o Foundry está instalado no seu sistema. Siga o [guia de instalação do Foundry](https://book.getfoundry.sh/getting-started/installation.html) se necessário.

2. **Execute o Anvil**:
   Inicie o Anvil com um fork da rede:
   ```bash
   anvil --fork-url https://bahamut-rpc.publicnode.com
   ```

3. **Execute os Testes**:
   Execute os testes com o seguinte comando:
   ```bash
   forge test --fork-url https://bahamut-rpc.publicnode.com
   ```

## Conclusão

Este relatório destaca uma vulnerabilidade crítica no contrato `UniswapV2Factory` que permite a criação de pares com tokens inválidos. Recomenda-se a implementação de verificações adicionais para garantir que apenas tokens ERC-20 válidos possam ser usados para criar pares, protegendo assim a integridade e a segurança do ecossistema Uniswap.

---

Para mais detalhes, consulte o código-fonte e os testes incluídos neste repositório.
