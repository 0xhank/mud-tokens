// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// common
import { AllowanceTable } from "./common/AllowanceTable.sol";
import { BalanceTable } from "./common/BalanceTable.sol";
import { MetadataTable } from "./common/MetadataTable.sol";
import "./common/constants.sol";

// erc721
import { ERC721Proxy } from "./erc721/ERC721Proxy.sol";
import { ERC721Registration } from "./erc721/ERC721Registration.sol";
import { ERC721Table } from "./erc721/ERC721Table.sol";
import { LibERC721 } from "./erc721/LibERC721.sol";

// erc1155
import { ERC1155Proxy } from "./erc1155/ERC1155Proxy.sol";
import { ERC1155Registration } from "./erc1155/ERC1155Registration.sol";
import { ERC1155ApprovalTable } from "./erc1155/ERC1155ApprovalTable.sol";
import { ERC1155BalanceTable } from "./erc1155/ERC1155BalanceTable.sol";
import { ERC1155MetadataTable } from "./erc1155/ERC1155MetadataTable.sol";
import { LibERC1155 } from "./erc1155/LibERC1155.sol";

// erc20
import { ERC20Proxy } from "./erc20/ERC20Proxy.sol";
import { ERC20Registration } from "./erc20/ERC20Registration.sol";
import { LibERC20 } from "./erc20/LibERC20.sol";
