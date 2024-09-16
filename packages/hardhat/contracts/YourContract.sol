//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract LTV30 is
	ERC721,
	ERC721Enumerable,
	ERC721URIStorage,
	ERC721Burnable,
	AccessControl
{
	struct Expression {
		address owner;
		uint256 tokenId;
		string textIpfsCid;
		string imageIpfsCid;
	}

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	uint256 public tokenCounter;

	mapping(address => Expression) expressions;

	constructor(address defaultAdmin, address minter) ERC721("LTV30", "LTV30") {
		_grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
		_grantRole(MINTER_ROLE, minter);
	}

	function submit(
		string calldata textIpfsCid,
		string calldata imageIpfsCid
	) external {
		address sender = _msgSender();
		if (expressions[sender].tokenId != 0) {
			revert("already");
		}

		uint256 tokenId = ++tokenCounter;
		Expression memory expression = Expression({
			owner: sender,
			tokenId: tokenId,
			textIpfsCid: textIpfsCid,
			imageIpfsCid: imageIpfsCid
		});

		expressions[sender] = expression;

		_safeMint(sender, tokenId);
		_setTokenURI(tokenId, imageIpfsCid);
	}

	// The following functions are overrides required by Solidity.

	function _update(
		address to,
		uint256 tokenId,
		address auth
	) internal override(ERC721, ERC721Enumerable) returns (address) {
		return super._update(to, tokenId, auth);
	}

	function _increaseBalance(
		address account,
		uint128 value
	) internal override(ERC721, ERC721Enumerable) {
		super._increaseBalance(account, value);
	}

	function tokenURI(
		uint256 tokenId
	) public view override(ERC721, ERC721URIStorage) returns (string memory) {
		return super.tokenURI(tokenId);
	}

	function supportsInterface(
		bytes4 interfaceId
	)
		public
		view
		override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}
