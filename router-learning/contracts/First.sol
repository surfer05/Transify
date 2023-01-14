// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "evm-gateway-contract/contracts/ICrossTalkApplication.sol";
import "evm-gateway-contract/contracts/Utils.sol";
import "@routerprotocol/router-crosstalk-utils/contracts/CrossTalkUtils.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyContract is ERC1155, ICrossTalkApplication {
    // address of the admin
    address public owner;

    // address of the gateway contract
    address public gatewayContract;

    mapping(address => uint) public maxLossBearable;

    function setNewMaxLossBreareable(uint _percent) public returns (bool) {
        //setting the percentage to be set
        maxLossBearable[msg.sender] = _percent;
        //reteurns true after the value has been set
        return true;
    }

    mapping(uint64 => mapping(string => uint128)) public ratiosX1000;

    // 1000 multiplier
    // dest/source
    function setterRatio(
        uint64 chainType,
        string memory chainId,
        uint128 ratioX1000
    ) public {
        require(msg.sender == owner, "only owner");
        ratiosX1000[chainType][chainId] = ratioX1000;
    }

    function transferTokens(
        uint64 chainType,
        string memory chainId,
        uint amount,
        address payable receipientAddress,
        uint64 destGasPrice
    ) external payable {
        require(msg.value >= amount, "insufficient tokens"); //msg.value is the value transferred
        amount = msg.value;
        uint128 modifiedRatio = ratiosX1000[chainType][chainId];
        uint tokenToBeTransferred = (amount * modifiedRatio ) / 1000;

        TransferParams memory transferparams = TransferParams(
            receipientAddress, 
            tokenToBeTransferred
        );
        bytes memory payload = abi.encode(transferparams); //making payload
        Utils.DestinationChainParams memory destChainParams = Utils
            .DestinationChainParams(
                destGasLimit,
                destGasPrice,
                chainType,
                chainId
            );

        // creating a cross-chain communication request to the destination chain.
        CrossTalkUtils.singleRequestWithoutAcknowledgement(
            gatewayContract,
            0,
            destChainParams,
            ourContractOnChains[chainType][chainId], // destination contract address
            payload
        );
    }

    // gas limit required to handle cross-chain request on the destination chain
    // have to clear how to get it or set it
    uint64 public destGasLimit;

    // chain type + chain id => address of our contract in bytes
    mapping(uint64 => mapping(string => bytes)) public ourContractOnChains;

    // transfer params struct where we specify which NFTs should be transferred to
    // the destination chain and to which address
    // do we need it or not
    struct TransferParams {
        address payable recepient;
        uint value;
    }

    constructor(
        string memory _uri,
        address payable gatewayAddress,
        uint64 _destGasLimit
    ) ERC1155(_uri) {
        gatewayContract = gatewayAddress;
        destGasLimit = _destGasLimit;
        owner = msg.sender;
    }

    /// @notice function to set the address of our contracts on different chains.
    /// This will help in access control when a cross-chain request is received.
    /// @param contractAddress address of the NFT contract on the destination chain.
    function setContractOnChain(
        uint64 chainType,
        string memory chainId,
        address contractAddress
    ) external {
        require(msg.sender == owner, "only admin");
        ourContractOnChains[chainType][chainId] = CrossTalkUtils.toBytes(
            contractAddress
        );
    }

    /// @notice function to generate a cross-chain transfer request.
    /// @param chainType chain type of the destination chain.
    /// @param chainId chain ID of the destination chain in string.
    /// if the request has not already been executed, it will fail on the destination chain.
    /// If you don't want to provide any expiry duration, send type(uint64).max in its place.
    /// @param destGasPrice gas price of the destination chain.
    /// @param transferParams transfer params struct.
    function transferCrossChain(
        uint64 chainType,
        string memory chainId,
        uint64 destGasPrice, // after discussion
        TransferParams memory transferParams
    ) public payable {
        require(
            keccak256(ourContractOnChains[chainType][chainId]) !=
                keccak256(CrossTalkUtils.toBytes(address(0))),
            "contract on dest not set"
        );

        // sending the transfer params struct to the destination chain as payload.
        bytes memory payload = abi.encode(transferParams);

        Utils.DestinationChainParams memory destChainParams = Utils
            .DestinationChainParams(
                destGasLimit,
                destGasPrice,
                chainType,
                chainId
            );

        // creating a cross-chain communication request to the destination chain.
        CrossTalkUtils.singleRequestWithoutAcknowledgement(
            gatewayContract,
            0,
            destChainParams,
            ourContractOnChains[chainType][chainId], // destination contract address
            payload
        );
    }

    //unlock and unlock function
    // returns the value either funds have been sent to the locking contract or not after await

    /// @notice function to handle the cross-chain request received from some other chain.
    /// @param srcContractAddress address of the contract on source chain that initiated the request.
    /// @param payload the payload sent by the source chain contract when the request was created.
    /// @param srcChainId chain ID of the source chain in string.
    /// @param srcChainType chain type of the source chain.
    function handleRequestFromSource(
        bytes memory srcContractAddress,
        bytes memory payload,
        string memory srcChainId,
        uint64 srcChainType
    ) external override returns (bytes memory) {
        // ensuring that only the gateway contract can send the cross-chain handling request
        require(msg.sender == gatewayContract, "only gateway");
        // ensuring that our NFT contract initiated this request from the source chain
        require(
            keccak256(srcContractAddress) ==
                keccak256(ourContractOnChains[srcChainType][srcChainId]),
            "only our contract on source chain"
        );

        // decoding our payload
        TransferParams memory transferParams = abi.decode(
            payload,
            (TransferParams)
        );
        //unlock
        (transferParams.recepient).transfer(transferParams.value);
    }

    function handleCrossTalkAck(
        uint64 eventIdentifier,
        bool[] memory execFlags,
        bytes[] memory execData
    ) external view override{}
}

// uint256 public value;
// address public owner;

// constructor(address _genericHandler) RouterCrossTalk(_genericHandler) {
//     owner = msg.sender;
// }

// modifier onlyOwner() {
//     require(msg.sender == owner, "Only owner can call this function");
//     _;
// }

// function ExternalSetValue(
//     uint8 _chainID,
//     uint256 _value
// ) public returns (bool) {
//     // Encoding the data to send
//     bytes memory data = abi.encode(_value);
//     // The function interface to be called on the destination chain
//     bytes4 _interface = bytes4(keccak256("SetValue(uint256)"));
//     // ChainID, Selector, Data, Gas Usage(let gas = 1000000), Gas Price(1000000000)
//     (bool success, ) = routerSend(
//         _chainID,
//         _interface,
//         data,
//         1000000,
//         1000000000
//     );
//     return success;
// }

// function _routerSyncHandler(
//     bytes4 _interface,
//     bytes memory _data
// ) internal virtual override returns (bool, bytes memory) {
//     uint256 _v = abi.decode(_data, (uint256));
//     (bool success, bytes memory returnData) = address(this).call(
//         abi.encodeWithSelector(_interface, _v)
//     );
//     return (success, returnData);
// }

// function replayTransaction(
//     bytes32 hash,
//     uint256 _crossChainGasLimit,
//     uint256 _crossChainGasPrice
// ) external {
//     routerReplay(hash, _crossChainGasLimit, _crossChainGasPrice);
// }

// function SetValue(uint256 _value) external isSelf {
//     value = _value;
// }

// function setLinker(address _linker) external onlyOwner {
//     setLink(_linker);
// }

// function setFeeAddress(address _feeAddress) external onlyOwner {
//     setFeeToken(_feeAddress);
// }

// function approveFee(address _feeToken, uint256 _value) external {
//     approveFees(_feeToken, _value);
// }

// address of the admin
// address public owner;

// // address of the gateway contract
// address public gatewayContract;

// // address where liquidity is to be locked
// // address payable public lock01;
// // address payable public lock02;
// // address payable public lock03;

// // gas limit required to handle cross-chain request on the destination chain
// uint64 public destGasLimit;

// // chain type + chain id => address of our contract in bytes
// mapping(uint64 => mapping(string => bytes)) public ourContractOnChains;

// // transfer params struct where we specify which NFTs should be transferred to
// // the destination chain and to which address
// struct TransferParams {
//     uint value;    // the amount of currency we want to transfer from one chain to another.
//     address contractAddress;  // address of the reicpient of the NFTs on the destination chain
// }

// constructor(
//     string memory _uri,
//     address payable gatewayAddress,
//     uint64 _destGasLimit
// ) ERC1155(_uri) {
//     gatewayContract = gatewayAddress;
//     destGasLimit = _destGasLimit;
//     owner = msg.sender;
// }

// // unlock and lock function

// /// This will help in access control when a cross-chain request is received.
// /// @param contractAddress address of the contract on the destination chain.
// function setContractOnChain(
//     uint64 chainType,
//     string memory chainId,
//     address contractAddress
// ) external {
//     require(msg.sender == owner, "only admin");
//     ourContractOnChains[chainType][chainId] = toBytes(contractAddress);
// }

// /// @notice function to generate a cross-chain transfer request.
// /// @param chainType chain type of the destination chain.
// /// @param chainId chain ID of the destination chain in string.
// /// if the request has not already been executed, it will fail on the destination chain.
// /// If you don't want to provide any expiry duration, send type(uint64).max in its place.
// /// @param destGasPrice gas price of the destination chain.
// /// @param transferParams transfer params struct.
// function transferCrossChain(
//     uint64 chainType,
//     string memory chainId,
//     uint64 destGasPrice, // how to set it or set it in advance ourselves
//     TransferParams memory transferParams
// ) public payable {
//     require(
//         keccak256(ourContractOnChains[chainType][chainId]) !=
//             keccak256(CrossTalkUtils.toBytes(address(0))),
//         "contract on dest not set"
//     );

//     // unlock and lock functions

//     // sending the transfer params struct to the destination chain as payload.
//     bytes memory payload = abi.encode(transferParams);

//     Utils.DestinationChainParams memory destChainParams = Utils
//         .DestinationChainParams(
//             destGasLimit,
//             destGasPrice,
//             chainType,
//             chainId
//         );

//     // creating a cross-chain communication request to the destination chain.
//     CrossTalkUtils.singleRequestWithoutAcknowledgement(
//         gatewayContract,
//         0,
//         destChainParams,
//         ourContractOnChains[chainType][chainId], // destination contract address
//         payload
//     );
// }

// /// @notice function to handle the cross-chain request received from some other chain.
// /// @param srcContractAddress address of the contract on source chain that initiated the request.
// /// @param payload the payload sent by the source chain contract when the request was created.
// /// @param srcChainId chain ID of the source chain in string.
// /// @param srcChainType chain type of the source chain.
// function handleRequestFromSource(
//     bytes memory srcContractAddress,
//     bytes memory payload,
//     string memory srcChainId,
//     uint64 srcChainType
// ) external override returns (bytes memory) {
//     // ensuring that only the gateway contract can send the cross-chain handling request
//     require(msg.sender == gatewayContract, "only gateway");
//     // ensuring that our NFT contract initiated this request from the source chain
//     require(
//         keccak256(srcContractAddress) ==
//             keccak256(ourContractOnChains[srcChainType][srcChainId]),
//         "only our contract on source chain"
//     );

//     // decoding our payload
//     TransferParams memory transferParams = abi.decode(
//         payload,
//         (TransferParams)
//     );

//     // since we don't want to return any data, we will just return empty string
//     return "";
// }

// /// @notice function to handle the acknowledgement received from the destination chain
// /// back on the source chain.
// /// @param eventIdentifier event nonce which is received when we create a cross-chain request
// /// We can use it to keep a mapping of which nonces have been executed and which did not.
// /// @param execFlags an array of boolean values suggesting whether the calls were successfully
// /// executed on the destination chain.
// /// @param execData an array of bytes returning the data returned from the handleRequestFromSource
// /// function of the destination chain.
// /// Since we don't want to handle the acknowledgement, we will leave it as empty function.
// function handleCrossTalkAck(
//     uint64 eventIdentifier,
//     bool[] memory execFlags,
//     bytes[] memory execData
// ) external view override {}

// // Function to convert address to bytes
// function toBytes(address a) public pure returns (bytes memory b) {
//     assembly {
//         let m := mload(0x40)
//         a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
//         mstore(
//             add(m, 20),
//             xor(0x140000000000000000000000000000000000000000, a)
//         )
//         mstore(0x40, add(m, 52))
//         b := m
//     }
// }

// // Function to convert bytes to address
// function toAddress(
//     bytes memory _bytes
// ) public pure returns (address contractAddress) {
//     bytes20 srcTokenAddress;
//     assembly {
//         srcTokenAddress := mload(add(_bytes, 0x20))
//     }
//     contractAddress = address(srcTokenAddress);
// }
