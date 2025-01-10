// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";

contract TestUniswapFactory is Test {
    address public factoryAddress = 0xd0C5d23290d63E06a0c4B87F14bD2F7aA551a895; // Address of the UniswapV2Factory contract

    function testCreatePairWithInvalidTokens() public {
        address factory = factoryAddress;

        // Check the number of pairs before attempting to create an invalid pair
        (bool successAllPairsBefore, bytes memory dataAllPairsBefore) = factory.call(
            abi.encodeWithSignature("allPairsLength()")
        );
        require(successAllPairsBefore, "Failed to query allPairsLength before");
        uint256 allPairsLengthBefore = abi.decode(dataAllPairsBefore, (uint256));

        // Use two random invalid addresses (non-ERC-20)
        address invalidTokenAddress1 = 0x5555555555555555555555555555555555555555; // Fictitious address 1
        address invalidTokenAddress2 = 0x6666666666666666666666666666666666666666; // Fictitious address 2

        // Attempt to create the pair with the two "invalid tokens" with different addresses
        (bool success, bytes memory returnData) = factory.call(
            abi.encodeWithSignature("createPair(address,address)", invalidTokenAddress1, invalidTokenAddress2)
        );

        // Debug: Print the reason for failure, if any
        if (!success) {
            emit log_bytes(returnData);
        }

        // Validation: Ensure the pair creation failed
        require(!success, "Pair creation should not have succeeded");

        // Check the number of pairs after the attempted invalid pair creation
        (bool successAllPairsAfter, bytes memory dataAllPairsAfter) = factory.call(
            abi.encodeWithSignature("allPairsLength()")
        );
        require(successAllPairsAfter, "Failed to query allPairsLength after");
        uint256 allPairsLengthAfter = abi.decode(dataAllPairsAfter, (uint256));

        // Ensure that the number of pairs has not changed
        assertEq(allPairsLengthBefore, allPairsLengthAfter, "Invalid pair should not have been added to the allPairs list");

        // Check if the pair was not created in the getPair mapping
        (bool successGetPair, bytes memory dataGetPair) = factory.call(
            abi.encodeWithSignature("getPair(address,address)", invalidTokenAddress1, invalidTokenAddress2)
        );
        require(successGetPair, "Failed to query getPair");
        address storedPair = abi.decode(dataGetPair, (address));
        assertEq(storedPair, address(0), "Invalid pair should not exist in the getPair mapping");
    }
}
