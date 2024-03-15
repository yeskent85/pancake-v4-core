// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";
import "forge-std/Test.sol";
import {CLPoolManager} from "../src/pool-cl/CLPoolManager.sol";
import {Vault} from "../src/Vault.sol";
import {IVault} from "../src/interfaces/IVault.sol";
import {ICLPoolManager} from "../src/pool-cl/interfaces/ICLPoolManager.sol";
import {IProtocolFeeController} from "../src/interfaces/IProtocolFeeController.sol";

contract ExtsloadTest is Test, GasSnapshot {
    // Slot
    // 0	 	PoolManager#Ownable#_owner
    // 1	 	PooAlManager#Fees#protocolFeesAccrued
    // 2		PooAlManager#Fees#protocolFeeController
    // 3 		PooAlManager#pools
    ICLPoolManager poolManager;

    function setUp() public {
        IVault vault = new Vault();
        poolManager = new CLPoolManager(vault, 500000);

        poolManager.setProtocolFeeController(IProtocolFeeController(address(0xabcd)));
    }

    function testExtsload() public {
        snapStart("ExtsloadTest#extsload");
        bytes32 slot0 = poolManager.extsload(0x00);
        snapEnd();
        assertEq(abi.encode(slot0), abi.encode(address(this)));

        bytes32 slot2 = poolManager.extsload(bytes32(uint256(0x02)));
        assertEq(abi.encode(slot2), abi.encode(address(0xabcd)));
    }

    function testExtsloadInBatch() public {
        bytes32[] memory slots = new bytes32[](2);
        slots[0] = 0x00;
        slots[1] = bytes32(uint256(0x02));
        snapStart("ExtsloadTest#extsloadInBatch");
        slots = poolManager.extsload(slots);
        snapEnd();

        assertEq(abi.encode(slots[0]), abi.encode(address(this)));
        assertEq(abi.encode(slots[1]), abi.encode(address(0xabcd)));
    }
}
