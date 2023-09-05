// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

struct MetadataTableData {
  uint256 totalSupply;
  address proxy;
  string name;
  string symbol;
}

library MetadataTable {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](0);

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](4);
    _schema[0] = SchemaType.UINT256;
    _schema[1] = SchemaType.ADDRESS;
    _schema[2] = SchemaType.STRING;
    _schema[3] = SchemaType.STRING;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](0);
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](4);
    fieldNames[0] = "totalSupply";
    fieldNames[1] = "proxy";
    fieldNames[2] = "name";
    fieldNames[3] = "symbol";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register(bytes32 _tableId) internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store, bytes32 _tableId) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get totalSupply */
  function getTotalSupply(bytes32 _tableId) internal view returns (uint256 totalSupply) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Get totalSupply (using the specified store) */
  function getTotalSupply(IStore _store, bytes32 _tableId) internal view returns (uint256 totalSupply) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Set totalSupply */
  function setTotalSupply(bytes32 _tableId, uint256 totalSupply) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((totalSupply)), getValueSchema());
  }

  /** Set totalSupply (using the specified store) */
  function setTotalSupply(IStore _store, bytes32 _tableId, uint256 totalSupply) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((totalSupply)), getValueSchema());
  }

  /** Get proxy */
  function getProxy(bytes32 _tableId) internal view returns (address proxy) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Get proxy (using the specified store) */
  function getProxy(IStore _store, bytes32 _tableId) internal view returns (address proxy) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Set proxy */
  function setProxy(bytes32 _tableId, address proxy) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((proxy)), getValueSchema());
  }

  /** Set proxy (using the specified store) */
  function setProxy(IStore _store, bytes32 _tableId, address proxy) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((proxy)), getValueSchema());
  }

  /** Get name */
  function getName(bytes32 _tableId) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (string(_blob));
  }

  /** Get name (using the specified store) */
  function getName(IStore _store, bytes32 _tableId) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (string(_blob));
  }

  /** Set name */
  function setName(bytes32 _tableId, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 2, bytes((name)), getValueSchema());
  }

  /** Set name (using the specified store) */
  function setName(IStore _store, bytes32 _tableId, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 2, bytes((name)), getValueSchema());
  }

  /** Get the length of name */
  function lengthName(bytes32 _tableId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 2, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of name (using the specified store) */
  function lengthName(IStore _store, bytes32 _tableId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 2, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of name
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemName(bytes32 _tableId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        2,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (string(_blob));
    }
  }

  /**
   * Get an item of name (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemName(IStore _store, bytes32 _tableId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 2, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /** Push a slice to name */
  function pushName(bytes32 _tableId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.pushToField(_tableId, _keyTuple, 2, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to name (using the specified store) */
  function pushName(IStore _store, bytes32 _tableId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.pushToField(_tableId, _keyTuple, 2, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from name */
  function popName(bytes32 _tableId) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.popFromField(_tableId, _keyTuple, 2, 1, getValueSchema());
  }

  /** Pop a slice from name (using the specified store) */
  function popName(IStore _store, bytes32 _tableId) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.popFromField(_tableId, _keyTuple, 2, 1, getValueSchema());
  }

  /**
   * Update a slice of name at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateName(bytes32 _tableId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 2, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of name (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateName(IStore _store, bytes32 _tableId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 2, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Get symbol */
  function getSymbol(bytes32 _tableId) internal view returns (string memory symbol) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (string(_blob));
  }

  /** Get symbol (using the specified store) */
  function getSymbol(IStore _store, bytes32 _tableId) internal view returns (string memory symbol) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (string(_blob));
  }

  /** Set symbol */
  function setSymbol(bytes32 _tableId, string memory symbol) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 3, bytes((symbol)), getValueSchema());
  }

  /** Set symbol (using the specified store) */
  function setSymbol(IStore _store, bytes32 _tableId, string memory symbol) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 3, bytes((symbol)), getValueSchema());
  }

  /** Get the length of symbol */
  function lengthSymbol(bytes32 _tableId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of symbol (using the specified store) */
  function lengthSymbol(IStore _store, bytes32 _tableId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of symbol
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemSymbol(bytes32 _tableId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        3,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (string(_blob));
    }
  }

  /**
   * Get an item of symbol (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemSymbol(IStore _store, bytes32 _tableId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 3, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /** Push a slice to symbol */
  function pushSymbol(bytes32 _tableId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.pushToField(_tableId, _keyTuple, 3, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to symbol (using the specified store) */
  function pushSymbol(IStore _store, bytes32 _tableId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.pushToField(_tableId, _keyTuple, 3, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from symbol */
  function popSymbol(bytes32 _tableId) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /** Pop a slice from symbol (using the specified store) */
  function popSymbol(IStore _store, bytes32 _tableId) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /**
   * Update a slice of symbol at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateSymbol(bytes32 _tableId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of symbol (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateSymbol(IStore _store, bytes32 _tableId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Get the full data */
  function get(bytes32 _tableId) internal view returns (MetadataTableData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 _tableId) internal view returns (MetadataTableData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 _tableId,
    uint256 totalSupply,
    address proxy,
    string memory name,
    string memory symbol
  ) internal {
    bytes memory _data = encode(totalSupply, proxy, name, symbol);

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 _tableId,
    uint256 totalSupply,
    address proxy,
    string memory name,
    string memory symbol
  ) internal {
    bytes memory _data = encode(totalSupply, proxy, name, symbol);

    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(bytes32 _tableId, MetadataTableData memory _table) internal {
    set(_tableId, _table.totalSupply, _table.proxy, _table.name, _table.symbol);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 _tableId, MetadataTableData memory _table) internal {
    set(_store, _tableId, _table.totalSupply, _table.proxy, _table.name, _table.symbol);
  }

  /**
   * Decode the tightly packed blob using this table's schema.
   * Undefined behaviour for invalid blobs.
   */
  function decode(bytes memory _blob) internal pure returns (MetadataTableData memory _table) {
    // 52 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 52));

    _table.totalSupply = (uint256(Bytes.slice32(_blob, 0)));

    _table.proxy = (address(Bytes.slice20(_blob, 32)));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 52) {
      // skip static data length + dynamic lengths word
      uint256 _start = 84;
      uint256 _end;
      unchecked {
        _end = 84 + _encodedLengths.atIndex(0);
      }
      _table.name = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      unchecked {
        _end += _encodedLengths.atIndex(1);
      }
      _table.symbol = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    uint256 totalSupply,
    address proxy,
    string memory name,
    string memory symbol
  ) internal pure returns (bytes memory) {
    PackedCounter _encodedLengths;
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = PackedCounterLib.pack(bytes(name).length, bytes(symbol).length);
    }

    return abi.encodePacked(totalSupply, proxy, _encodedLengths.unwrap(), bytes((name)), bytes((symbol)));
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple() internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 _tableId) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 _tableId) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}