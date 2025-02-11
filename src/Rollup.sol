// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BatchHeaderCodecV0} from "./BatchHeaderCodecV0.sol";
import {BatchHeaderCodecV1} from "./BatchHeaderCodecV1.sol";

contract Rollup {
    /// @notice Store committed public input hash.
    mapping(uint256 batchIndex => bytes32 piHash) public piHashs;

    /// @notice Store committed blobVersioned hash.
    mapping(uint256 batchIndex => bytes32 blobHash) public blobVersionedHashs;

    /// @notice Store committed public data hash.
    mapping(uint256 batchIndex => bytes32 dataHash) public dataHashs;

    function proveState(
        bytes calldata _batchHeader,
        bytes calldata _batchProof
    ) external {
        // get batch data from batch header
        (uint256 memPtr, bytes32 _batchHash) = _loadBatchHeader(_batchHeader);
        // check batch hash
        uint256 _batchIndex = BatchHeaderCodecV0.getBatchIndex(memPtr);

        _verifyProof(memPtr, _batchProof);
    }

    /// @dev Internal function to load batch header from calldata to memory.
    /// @param _batchHeader The batch header in calldata.
    /// @return _memPtr     The start memory offset of loaded batch header.
    /// @return _batchHash  The hash of the loaded batch header.
    function _loadBatchHeader(
        bytes calldata _batchHeader
    ) internal pure returns (uint256 _memPtr, bytes32 _batchHash) {
        uint8 _version = _getBatchVersion(_batchHeader);

        // load to memory
        uint256 _length;
        if (_version == 0) {
            (_memPtr, _length) = BatchHeaderCodecV0.loadAndValidate(
                _batchHeader
            );
        } else if (_version == 1) {
            (_memPtr, _length) = BatchHeaderCodecV1.loadAndValidate(
                _batchHeader
            );
        } else {
            revert("Unsupported batch version");
        }

        // compute batch hash
        // all the versions use the same way to compute batch hash
        _batchHash = BatchHeaderCodecV0.computeBatchHash(_memPtr, _length);
    }

    function _getBatchVersion(
        bytes calldata batchHeader
    ) internal pure returns (uint8 version) {
        require(batchHeader.length > 0, "Empty batch header");
        version = uint8(batchHeader[0]); // Safe extraction of the first byte
    }

    /// @dev Internal function to verify the zk proof.
    function _verifyProof(uint256 memPtr, bytes calldata _batchProof) private {
        // Check validity of proof
        require(_batchProof.length > 0, "Invalid batch proof");

        uint256 _batchIndex = BatchHeaderCodecV0.getBatchIndex(memPtr);
        bytes32 _blobVersionedHash = BatchHeaderCodecV0.getBlobVersionedHash(
            memPtr
        );
        bytes32 _dataHash = BatchHeaderCodecV0.getDataHash(memPtr);

        bytes32 _publicInputHash = keccak256(
            abi.encodePacked(
                uint64(53077),
                BatchHeaderCodecV0.getPrevStateHash(memPtr),
                BatchHeaderCodecV0.getPostStateHash(memPtr),
                BatchHeaderCodecV0.getWithdrawRootHash(memPtr),
                BatchHeaderCodecV0.getSequencerSetVerifyHash(memPtr),
                _dataHash,
                _blobVersionedHash
            )
        );

        // test data
        piHashs[_batchIndex] = _publicInputHash;
        blobVersionedHashs[_batchIndex] = _blobVersionedHash;
        dataHashs[_batchIndex] = _dataHash;
    }
}
