// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Proxy } from "./interfaces/IERC721Proxy.sol";
import { IERC165 } from "../common/IERC165.sol";
import { LibERC721 } from "./LibERC721.sol";

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { LibERC721 } from "./LibERC721.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";

contract ERC721Proxy is IERC721Proxy {
  IBaseWorld private world;
  bytes16 private immutable namespace;

  constructor(IBaseWorld _world, bytes16 _namespace) {
    world = _world;
    namespace = _namespace;
  }

  modifier onlySystemOrWorld() {
    // is there a system within the namespace that exists at the msg.sender address?
    if (msg.sender != address(world) && msg.sender != address(this)) {
      bytes32 systemId = SystemRegistry.get(world, msg.sender);
      require(
        ResourceSelector.getNamespace(systemId) == namespace,
        "ERC721: Only World or system or this contract can execute call"
      );
    }
    _;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
    return LibERC721.supportsInterface(interfaceId);
  }

  function totalSupply() public view virtual returns (uint256) {
    return LibERC721.totalSupply(world, namespace);
  }

  /**
   * @dev See {IERC721-balanceOf}.
   */
  function balanceOf(address owner) public view virtual override returns (uint256) {
    return LibERC721.balanceOf(world, namespace, owner);
  }

  /**
   * @dev See {IERC721-ownerOf}.
   */
  function ownerOf(uint256 tokenId) public view virtual override returns (address) {
    return LibERC721.ownerOf(world, namespace, tokenId);
  }

  /**
   * @dev See {IERC721Metadata-name}.
   */
  function name() public view virtual override returns (string memory) {
    return LibERC721.name(world, namespace);
  }

  /**
   * @dev See {IERC721Metadata-symbol}.
   */
  function symbol() public view virtual override returns (string memory) {
    return LibERC721.symbol(world, namespace);
  }

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return LibERC721.tokenURI(world, namespace, tokenId);
  }

  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    LibERC721._setTokenURI(world, namespace, tokenId, _tokenURI);
  }

  /**
   * @dev See {IERC721-approve}.
   */
  function approve(address to, uint256 tokenId) public virtual override {
    LibERC721._approve(world, namespace, to, tokenId);
  }

  /**
   * @dev See {IERC721-getApproved}.
   */
  function getApproved(uint256 tokenId) public view virtual override returns (address) {
    return LibERC721.getApproved(world, namespace, tokenId);
  }

  /**
   * @dev See {IERC721-setApprovalForAll}.
   */
  function setApprovalForAll(address operator, bool approved) public virtual override {
    LibERC721._setApprovalForAll(world, namespace, msg.sender, operator, approved);
  }

  /**
   * @dev See {IERC721-isApprovedForAll}.
   */
  function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
    return LibERC721.isApprovedForAll(world, namespace, owner, operator);
  }

  /**
   * @dev See {IERC721-transferFrom}.
   */
  function transferFrom(address from, address to, uint256 tokenId) public virtual override {
    LibERC721.transferFrom(world, namespace, msg.sender, from, to, tokenId);
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
    LibERC721.safeTransferFrom(world, namespace, msg.sender, from, to, tokenId, "");
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
    LibERC721.safeTransferFrom(world, namespace, msg.sender, from, to, tokenId, data);
  }

  function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
    LibERC721._safeTransfer(world, namespace, msg.sender, from, to, tokenId, data);
  }

  function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
    return LibERC721._ownerOf(world, namespace, tokenId);
  }

  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return LibERC721._exists(world, namespace, tokenId);
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    return LibERC721._isApprovedOrOwner(world, namespace, spender, tokenId);
  }

  function _safeMint(address to, uint256 tokenId) internal virtual {
    LibERC721._safeMint(world, namespace, msg.sender, to, tokenId);
  }

  function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
    LibERC721._safeMint(world, namespace, msg.sender, to, tokenId, data);
  }

  function _mint(address to, uint256 tokenId) internal virtual {
    LibERC721._mint(world, namespace, to, tokenId);
  }

  function _burn(uint256 tokenId) internal virtual {
    LibERC721._burn(world, namespace, tokenId);
  }

  function _transfer(address from, address to, uint256 tokenId) internal virtual {
    LibERC721._transfer(world, namespace, from, to, tokenId);
  }

  function _approve(address to, uint256 tokenId) internal virtual {
    LibERC721._approve(world, namespace, to, tokenId);
  }

  function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
    LibERC721._setApprovalForAll(world, namespace, owner, operator, approved);
  }

  function _requireMinted(uint256 tokenId) internal view virtual {
    LibERC721._requireMinted(world, namespace, tokenId);
  }

  function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
    return LibERC721._checkOnERC721Received(msg.sender, from, to, tokenId, data);
  }

  // solhint-disable-next-line func-name-mixedcase
  function unsafe_increase_balance(address account, uint256 amount) internal {
    LibERC721.unsafe_increase_balance(world, namespace, account, amount);
  }

  function emitTransfer(address from, address to, uint256 tokenId) public onlySystemOrWorld {
    emit Transfer(from, to, tokenId);
  }

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
   */
  function emitApproval(address owner, address approved, uint256 tokenId) public onlySystemOrWorld {
    emit Approval(owner, approved, tokenId);
  }

  /**
   * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
   */
  function emitApprovalForAll(address owner, address operator, bool approved) public onlySystemOrWorld {
    emit ApprovalForAll(owner, operator, approved);
  }
}
