// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC721.sol";
import "../interfaces/IERC721Receiver.sol";
import "../interfaces/IERC721Metadata.sol";
import "../interfaces/ERC165.sol";

import { IWorld } from "../../codegen/world/IWorld.sol";
import {ERC721System, SYSTEM_NAME} from "./ERC721System.sol";
import {nameToBytes16} from "../../utils.sol";
import { console } from "forge-std/console.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Proxy is ERC165, IERC721, IERC721Metadata {
    IWorld private world;
    ERC721System private token;
    bytes16 private mudId;

    function setup (IWorld _world, ERC721System _token, string memory _name) internal {
      world = _world;
      token = _token;
      mudId = nameToBytes16(_name);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function totalSupply() public view virtual returns (uint256) {
      return token.totalSupply();
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
      return token.balanceOf(owner);
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return token.ownerOf(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return token.name();
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return token.symbol();
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      return token.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        token.setTokenURIBypass(tokenId, _tokenURI);
    }
    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
      return token.baseURI();
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
      return token.getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return token.isApprovedForAll(owner, operator);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        _safeTransfer(from, to, tokenId, data);
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
      return token.ownerOf(tokenId);
    }
    
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = _ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
    }
    
    function _mint(address to, uint256 tokenId) internal virtual {
      console.log('to: ', to);
      console.log('tokenId: ', tokenId);
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC721System.mintBypass.selector,
          to,
          tokenId
        )
      );
    }
    
    function _burn(uint256 tokenId) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC721System.burnBypass.selector,
          tokenId
        )
      );
    }

    
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC721System.transferBypass.selector,
          from,
          to,
         tokenId 
        )
      );
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC721System.approveBypass.selector,
          to,
          tokenId
        )
      );
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC721System.setApprovalForAllBypass.selector,
          owner,
          operator,
          approved
        )
      );
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
      world.call(
        mudId,
        SYSTEM_NAME,
        abi.encodeWithSelector(
          ERC721System.unsafe_increase_balance.selector,
          account,
          amount
        )
      );
    }
}
