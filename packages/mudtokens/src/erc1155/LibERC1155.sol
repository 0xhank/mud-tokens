// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { IERC1155 } from "./interfaces/IERC1155.sol";
import { ERC1155Proxy } from "./ERC1155Proxy.sol";
import { IERC1155Receiver } from "./interfaces/IERC1155Receiver.sol";
import { IERC1155MetadataURI } from "./interfaces/IERC1155MetadataURI.sol";

import {ERC1155ApprovalTable as Approvals, ERC1155BalanceTable as Balance, ERC1155MetadataTable as Metadata} from "../codegen/Tables.sol";
import { ERC1155_APPROVAL_T as APPROVALS, ERC1155_BALANCE_T as BALANCE, ERC1155_METADATA_T as METADATA } from "../common/constants.sol";
import { ResourceSelector, ROOT_NAMESPACE } from "@latticexyz/world/src/ResourceSelector.sol";

library LibERC1155 {
  function getSelector(bytes16 namespace, bytes16 _name) private pure returns (bytes32) {
    return ResourceSelector.from(namespace, _name);
  }

  function supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
    return interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId;
  }

  function uri(bytes16 namespace) internal view returns (string memory) {
    return Metadata.getUri(getSelector(namespace, METADATA));
  }

  function uri(IBaseWorld world, bytes16 namespace) internal view returns (string memory) {
    return Metadata.getUri(world, getSelector(namespace, METADATA));
  }

  function proxy(bytes16 namespace) internal view returns (address) {
    return Metadata.getProxy(getSelector(namespace, METADATA));
  }

  function proxy(IBaseWorld world, bytes16 namespace) internal view returns (address) {
    return Metadata.getProxy(world, getSelector(namespace, METADATA));
  }

  function balanceOf(bytes16 namespace, address account, uint256 id) internal view returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return Balance.get(getSelector(namespace, BALANCE), id, account);
  }

  function balanceOf(IBaseWorld world, bytes16 namespace, address account, uint256 id) internal view returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return Balance.get(world, getSelector(namespace, BALANCE), id, account);
  }

  function balanceOfBatch(
    bytes16 namespace,
    address[] memory accounts,
    uint256[] memory ids
  ) internal view returns (uint256[] memory) {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; ++i) {
      batchBalances[i] = balanceOf(namespace, accounts[i], ids[i]);
    }

    return batchBalances;
  }

  function balanceOfBatch(
    IBaseWorld world,
    bytes16 namespace,
    address[] memory accounts,
    uint256[] memory ids
  ) internal view returns (uint256[] memory) {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; ++i) {
      batchBalances[i] = balanceOf(world, namespace, accounts[i], ids[i]);
    }

    return batchBalances;
  }

  /**
   * @dev See {IERC1155-setApprovalForAll}.
   */
  function setApprovalForAll(bytes16 namespace, address msgSender, address operator, bool approved) internal {
    _setApprovalForAll(namespace, msgSender, operator, approved);
  }

  function setApprovalForAll(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address operator,
    bool approved
  ) internal {
    _setApprovalForAll(world, namespace, msgSender, operator, approved);
  }

  /**
   * @dev See {IERC1155-isApprovedForAll}.
   */
  function isApprovedForAll(bytes16 namespace, address account, address operator) internal view returns (bool) {
    return Approvals.get(getSelector(namespace, APPROVALS), operator, account);
  }

  function isApprovedForAll(
    IBaseWorld world,
    bytes16 namespace,
    address account,
    address operator
  ) internal view returns (bool) {
    return Approvals.get(world, getSelector(namespace, APPROVALS), operator, account);
  }

  /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(namespace, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeTransferFrom(namespace, msgSender, from, to, id, amount, data);
  }

  function safeTransferFrom(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(world, namespace, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeTransferFrom(world, namespace, msgSender, from, to, id, amount, data);
  }

  /**
   * @dev See {IERC1155-safeBatchTransferFrom}.
   */
  function safeBatchTransferFrom(
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(namespace, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeBatchTransferFrom(namespace, msgSender, from, to, ids, amounts, data);
  }

  function safeBatchTransferFrom(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(world, namespace, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeBatchTransferFrom(world, namespace, msgSender, from, to, ids, amounts, data);
  }

  /**
   * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - `from` must have a balance of tokens of type `id` of at least `amount`.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _safeTransferFrom(
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: transfer to the zero address");

    uint256 fromBalance = Balance.get(getSelector(namespace, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
    Balance.set(getSelector(namespace, BALANCE), id, from, fromBalance - amount);

    uint256 toBalance = Balance.get(getSelector(namespace, BALANCE), id, to);
    Balance.set(getSelector(namespace, BALANCE), id, to, toBalance + amount);

    // emit TransferSingle(operator, from, to, id, amount);

    _doSafeTransferAcceptanceCheck(msgSender, from, to, id, amount, data);
  }

  function _safeTransferFrom(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: transfer to the zero address");

    uint256 fromBalance = Balance.get(world, getSelector(namespace, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
    Balance.set(world, getSelector(namespace, BALANCE), id, from, fromBalance - amount);

    uint256 toBalance = Balance.get(world, getSelector(namespace, BALANCE), id, to);
    Balance.set(world, getSelector(namespace, BALANCE), id, to, toBalance + amount);

    emitTransferSingle(namespace, msgSender, from, to, id, amount);

    _doSafeTransferAcceptanceCheck(msgSender, from, to, id, amount, data);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _safeBatchTransferFrom(
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];
      uint256 fromBalance = Balance.get(getSelector(namespace, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
      Balance.set(getSelector(namespace, BALANCE), id, from, fromBalance - amount);

      uint256 toBalance = Balance.get(getSelector(namespace, BALANCE), id, to);
      Balance.set(getSelector(namespace, BALANCE), id, to, toBalance + amount);
    }

    emitTransferBatch(namespace, operator, from, to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
  }

  function _safeBatchTransferFrom(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];
      uint256 fromBalance = Balance.get(world, getSelector(namespace, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
      Balance.set(world, getSelector(namespace, BALANCE), id, from, fromBalance - amount);

      uint256 toBalance = Balance.get(world, getSelector(namespace, BALANCE), id, to);
      Balance.set(world, getSelector(namespace, BALANCE), id, to, toBalance + amount);
    }

    emitTransferBatch(namespace, operator, from, to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
  }

  /**
   * @dev Sets a new URI for all token types, by relying on the token type ID
   * substitution mechanism
   * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
   *
   * By this mechanism, any occurrence of the `\{id\}` substring in either the
   * URI or any of the amounts in the JSON file at said URI will be replaced by
   * clients with the token type ID.
   *
   * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
   * interpreted by clients as
   * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
   * for token type ID 0x4cce0.
   *
   * See {uri}.
   *
   * Because these URIs cannot be meaningfully represented by the {URI} event,
   * this function emits no events.
   */
  function _setURI(bytes16 namespace, string memory newuri) internal {
    Metadata.setUri(getSelector(namespace, METADATA), newuri);
  }

  function _setURI(IBaseWorld world, bytes16 namespace, string memory newuri) internal {
    Metadata.setUri(world, getSelector(namespace, METADATA), newuri);
  }

  /**
   * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _mint(
    bytes16 namespace,
    address msgSender,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");

    address operator = msgSender;

    uint256 toBalance = Balance.get(getSelector(namespace, BALANCE), id, to);
    Balance.set(getSelector(namespace, BALANCE), id, to, amount + toBalance);

    emitTransferSingle(namespace, operator, address(0), to, id, amount);

    _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
  }

  function _mint(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");

    address operator = msgSender;

    uint256 toBalance = Balance.get(world, getSelector(namespace, BALANCE), id, to);
    Balance.set(world, getSelector(namespace, BALANCE), id, to, amount + toBalance);

    emitTransferSingle(namespace, operator, address(0), to, id, amount);

    _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - `ids` and `amounts` must have the same length.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _mintBatch(
    bytes16 namespace,
    address msgSender,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 balance = Balance.get(getSelector(namespace, BALANCE), ids[i], to);
      Balance.set(getSelector(namespace, BALANCE), ids[i], to, balance + amounts[i]);
    }

    // emit TransferBatch(operator, address(0), to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
  }

  function _mintBatch(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 balance = Balance.get(world, getSelector(namespace, BALANCE), ids[i], to);
      Balance.set(world, getSelector(namespace, BALANCE), ids[i], to, balance + amounts[i]);
    }

    emitTransferBatch(namespace, operator, address(0), to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
  }

  /**
   * @dev Destroys `amount` tokens of token type `id` from `from`
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `from` must have at least `amount` tokens of token type `id`.
   */
  function _burn(bytes16 namespace, address msgSender, address from, uint256 id, uint256 amount) internal {
    require(from != address(0), "ERC1155: burn from the zero address");

    address operator = msgSender;

    uint256 fromBalance = Balance.get(getSelector(namespace, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    Balance.set(getSelector(namespace, BALANCE), id, from, fromBalance - amount);

    emitTransferSingle(namespace, operator, from, address(0), id, amount);
  }

  function _burn(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address from,
    uint256 id,
    uint256 amount
  ) internal {
    require(from != address(0), "ERC1155: burn from the zero address");

    address operator = msgSender;

    uint256 fromBalance = Balance.get(world, getSelector(namespace, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    Balance.set(world, getSelector(namespace, BALANCE), id, from, fromBalance - amount);

    emitTransferSingle(namespace, operator, from, address(0), id, amount);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - `ids` and `amounts` must have the same length.
   */
  function _burnBatch(
    bytes16 namespace,
    address msgSender,
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal {
    require(from != address(0), "ERC1155: burn from the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];

      uint256 fromBalance = Balance.get(getSelector(namespace, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      Balance.set(getSelector(namespace, BALANCE), id, from, fromBalance - amount);
    }

    emitTransferBatch(namespace, operator, from, address(0), ids, amounts);
  }

  function _burnBatch(
    IBaseWorld world,
    bytes16 namespace,
    address msgSender,
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal {
    require(from != address(0), "ERC1155: burn from the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];

      uint256 fromBalance = Balance.get(world, getSelector(namespace, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      Balance.set(world, getSelector(namespace, BALANCE), id, from, fromBalance - amount);
    }

    emitTransferBatch(namespace, operator, from, address(0), ids, amounts);
  }

  /**
   * @dev Approve `operator` to operate on all of `owner` tokens
   *
   * Emits an {ApprovalForAll} event.
   */
  function _setApprovalForAll(bytes16 namespace, address owner, address operator, bool approved) internal {
    require(owner != operator, "ERC1155: setting approval status for self");
    Approvals.set(getSelector(namespace, APPROVALS), owner, operator, approved);
    emitApprovalForAll(namespace, owner, operator, approved);
  }

  function _setApprovalForAll(
    IBaseWorld world,
    bytes16 namespace,
    address owner,
    address operator,
    bool approved
  ) internal {
    require(owner != operator, "ERC1155: setting approval status for self");
    Approvals.set(world, getSelector(namespace, APPROVALS), owner, operator, approved);
    emitApprovalForAll(namespace, owner, operator, approved);
  }

  function emitTransferSingle(
    bytes16 namespace,
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 value
  ) internal {
    ERC1155Proxy(proxy(namespace)).emitTransferSingle(operator, from, to, id, value);
  }

  function emitTransferBatch(
    bytes16 namespace,
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values
  ) internal {
    ERC1155Proxy(proxy(namespace)).emitTransferBatch(operator, from, to, ids, values);
  }

  function emitApprovalForAll(bytes16 namespace, address account, address operator, bool approved) internal {
    ERC1155Proxy(proxy(namespace)).emitApprovalForAll(account, operator, approved);
  }

  /* -------------------------------------------------------------------------- */
  /*                           INFERRED ROOT NAMESPACE                          */
  /* -------------------------------------------------------------------------- */

  function uri() internal view returns (string memory) {
    return Metadata.getUri(getSelector(ROOT_NAMESPACE, METADATA));
  }

  function uri(IBaseWorld world) internal view returns (string memory) {
    return Metadata.getUri(world, getSelector(ROOT_NAMESPACE, METADATA));
  }

  function proxy() internal view returns (address) {
    return Metadata.getProxy(getSelector(ROOT_NAMESPACE, METADATA));
  }

  function proxy(IBaseWorld world) internal view returns (address) {
    return Metadata.getProxy(world, getSelector(ROOT_NAMESPACE, METADATA));
  }

  function balanceOf( address account, uint256 id) internal view returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, account);
  }

  function balanceOf(IBaseWorld world,  address account, uint256 id) internal view returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, account);
  }

  function balanceOfBatch(
    
    address[] memory accounts,
    uint256[] memory ids
  ) internal view returns (uint256[] memory) {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; ++i) {
      batchBalances[i] = balanceOf(ROOT_NAMESPACE, accounts[i], ids[i]);
    }

    return batchBalances;
  }

  function balanceOfBatch(
    IBaseWorld world,
    
    address[] memory accounts,
    uint256[] memory ids
  ) internal view returns (uint256[] memory) {
    require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](accounts.length);

    for (uint256 i = 0; i < accounts.length; ++i) {
      batchBalances[i] = balanceOf(world, ROOT_NAMESPACE, accounts[i], ids[i]);
    }

    return batchBalances;
  }

  /**
   * @dev See {IERC1155-setApprovalForAll}.
   */
  function setApprovalForAll( address msgSender, address operator, bool approved) internal {
    _setApprovalForAll(ROOT_NAMESPACE, msgSender, operator, approved);
  }

  function setApprovalForAll(
    IBaseWorld world,
    
    address msgSender,
    address operator,
    bool approved
  ) internal {
    _setApprovalForAll(world, ROOT_NAMESPACE, msgSender, operator, approved);
  }

  /**
   * @dev See {IERC1155-isApprovedForAll}.
   */
  function isApprovedForAll( address account, address operator) internal view returns (bool) {
    return Approvals.get(getSelector(ROOT_NAMESPACE, APPROVALS), operator, account);
  }

  function isApprovedForAll(
    IBaseWorld world,
    
    address account,
    address operator
  ) internal view returns (bool) {
    return Approvals.get(world, getSelector(ROOT_NAMESPACE, APPROVALS), operator, account);
  }

  /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(ROOT_NAMESPACE, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeTransferFrom(ROOT_NAMESPACE, msgSender, from, to, id, amount, data);
  }

  function safeTransferFrom(
    IBaseWorld world,
    
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(world, ROOT_NAMESPACE, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeTransferFrom(world, ROOT_NAMESPACE, msgSender, from, to, id, amount, data);
  }

  /**
   * @dev See {IERC1155-safeBatchTransferFrom}.
   */
  function safeBatchTransferFrom(
    
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(ROOT_NAMESPACE, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeBatchTransferFrom(ROOT_NAMESPACE, msgSender, from, to, ids, amounts, data);
  }

  function safeBatchTransferFrom(
    IBaseWorld world,
    
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(
      from == msgSender || isApprovedForAll(world, ROOT_NAMESPACE, from, msgSender),
      "ERC1155: caller is not token owner or approved"
    );
    _safeBatchTransferFrom(world, ROOT_NAMESPACE, msgSender, from, to, ids, amounts, data);
  }

  /**
   * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - `from` must have a balance of tokens of type `id` of at least `amount`.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _safeTransferFrom(
    
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: transfer to the zero address");


    uint256 fromBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
    Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);

    uint256 toBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, to);
    Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, to, toBalance + amount);

    // emit TransferSingle(operator, from, to, id, amount);

    _doSafeTransferAcceptanceCheck(msgSender, from, to, id, amount, data);
  }

  function _safeTransferFrom(
    IBaseWorld world,
    
    address msgSender,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: transfer to the zero address");


    uint256 fromBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
    Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);

    uint256 toBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, to);
    Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, to, toBalance + amount);

    emitTransferSingle(ROOT_NAMESPACE, msgSender, from, to, id, amount);

    _doSafeTransferAcceptanceCheck(msgSender, from, to, id, amount, data);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _safeBatchTransferFrom(
    
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];
      uint256 fromBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
      Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);

      uint256 toBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, to);
      Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, to, toBalance + amount);
    }

    emitTransferBatch(ROOT_NAMESPACE, operator, from, to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
  }

  function _safeBatchTransferFrom(
    IBaseWorld world,
    
    address msgSender,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
    require(to != address(0), "ERC1155: transfer to the zero address");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];
      uint256 fromBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
      Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);

      uint256 toBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, to);
      Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, to, toBalance + amount);
    }

    emitTransferBatch(ROOT_NAMESPACE, operator, from, to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
  }

  /**
   * @dev Sets a new URI for all token types, by relying on the token type ID
   * substitution mechanism
   * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
   *
   * By this mechanism, any occurrence of the `\{id\}` substring in either the
   * URI or any of the amounts in the JSON file at said URI will be replaced by
   * clients with the token type ID.
   *
   * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
   * interpreted by clients as
   * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
   * for token type ID 0x4cce0.
   *
   * See {uri}.
   *
   * Because these URIs cannot be meaningfully represented by the {URI} event,
   * this function emits no events.
   */
  function _setURI( string memory newuri) internal {
    Metadata.setUri(getSelector(ROOT_NAMESPACE, METADATA), newuri);
  }

  function _setURI(IBaseWorld world,  string memory newuri) internal {
    Metadata.setUri(world, getSelector(ROOT_NAMESPACE, METADATA), newuri);
  }

  /**
   * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _mint(
    
    address msgSender,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");

    address operator = msgSender;
    uint256 toBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, to);
    Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, to, amount + toBalance);

    emitTransferSingle(ROOT_NAMESPACE, operator, address(0), to, id, amount);

    _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
  }

  function _mint(
    IBaseWorld world,
    
    address msgSender,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");

    address operator = msgSender;

    uint256 toBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, to);
    Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, to, amount + toBalance);

    emitTransferSingle(ROOT_NAMESPACE, operator, address(0), to, id, amount);

    _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - `ids` and `amounts` must have the same length.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
   * acceptance magic value.
   */
  function _mintBatch(
    
    address msgSender,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 balance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), ids[i], to);
      Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), ids[i], to, balance + amounts[i]);
    }

    // emit TransferBatch(operator, address(0), to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
  }

  function _mintBatch(
    IBaseWorld world,
    
    address msgSender,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal {
    require(to != address(0), "ERC1155: mint to the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 balance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), ids[i], to);
      Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), ids[i], to, balance + amounts[i]);
    }

    emitTransferBatch(ROOT_NAMESPACE, operator, address(0), to, ids, amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
  }

  /**
   * @dev Destroys `amount` tokens of token type `id` from `from`
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `from` must have at least `amount` tokens of token type `id`.
   */
  function _burn( address msgSender, address from, uint256 id, uint256 amount) internal {
    require(from != address(0), "ERC1155: burn from the zero address");

    address operator = msgSender;

    uint256 fromBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);

    emitTransferSingle(ROOT_NAMESPACE, operator, from, address(0), id, amount);
  }

  function _burn(
    IBaseWorld world,
    
    address msgSender,
    address from,
    uint256 id,
    uint256 amount
  ) internal {
    require(from != address(0), "ERC1155: burn from the zero address");

    address operator = msgSender;

    uint256 fromBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from);
    require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);

    emitTransferSingle(ROOT_NAMESPACE, operator, from, address(0), id, amount);
  }

  /**
   * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
   *
   * Emits a {TransferBatch} event.
   *
   * Requirements:
   *
   * - `ids` and `amounts` must have the same length.
   */
  function _burnBatch(
    
    address msgSender,
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal {
    require(from != address(0), "ERC1155: burn from the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];

      uint256 fromBalance = Balance.get(getSelector(ROOT_NAMESPACE, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      Balance.set(getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);
    }

    emitTransferBatch(ROOT_NAMESPACE, operator, from, address(0), ids, amounts);
  }

  function _burnBatch(
    IBaseWorld world,
    
    address msgSender,
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal {
    require(from != address(0), "ERC1155: burn from the zero address");
    require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = msgSender;

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 id = ids[i];
      uint256 amount = amounts[i];

      uint256 fromBalance = Balance.get(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from);
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      Balance.set(world, getSelector(ROOT_NAMESPACE, BALANCE), id, from, fromBalance - amount);
    }

    emitTransferBatch(ROOT_NAMESPACE, operator, from, address(0), ids, amounts);
  }

  /**
   * @dev Approve `operator` to operate on all of `owner` tokens
   *
   * Emits an {ApprovalForAll} event.
   */
  function _setApprovalForAll( address owner, address operator, bool approved) internal {
    require(owner != operator, "ERC1155: setting approval status for self");
    Approvals.set(getSelector(ROOT_NAMESPACE, APPROVALS), owner, operator, approved);
    emitApprovalForAll(ROOT_NAMESPACE, owner, operator, approved);
  }

  function _setApprovalForAll(
    IBaseWorld world,
    
    address owner,
    address operator,
    bool approved
  ) internal {
    require(owner != operator, "ERC1155: setting approval status for self");
    Approvals.set(world, getSelector(ROOT_NAMESPACE, APPROVALS), owner, operator, approved);
    emitApprovalForAll(ROOT_NAMESPACE, owner, operator, approved);
  }

  function isContract(address to) private view returns (bool) {
    return to.code.length > 0;
  }

  function _doSafeTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal {
    if (isContract(to)) {
      try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
        if (response != IERC1155Receiver.onERC1155Received.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non-ERC1155Receiver implementer");
      }
    }
  }

  function _doSafeBatchTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) private {
    if (isContract(to)) {
      try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
        if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non-ERC1155Receiver implementer");
      }
    }
  }

  function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
    uint256[] memory array = new uint256[](1);
    array[0] = element;

    return array;
  }

  function emitTransferSingle(
    
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 value
  ) internal {
    ERC1155Proxy(proxy(ROOT_NAMESPACE)).emitTransferSingle(operator, from, to, id, value);
  }

  function emitTransferBatch(
    
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values
  ) internal {
    ERC1155Proxy(proxy(ROOT_NAMESPACE)).emitTransferBatch(operator, from, to, ids, values);
  }

  function emitApprovalForAll( address account, address operator, bool approved) internal {
    ERC1155Proxy(proxy(ROOT_NAMESPACE)).emitApprovalForAll(account, operator, approved);
  }
}
