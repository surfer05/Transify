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

    receive() external payable {}

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
        uint tokenToBeTransferred = (amount * modifiedRatio) / 1000;

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
    ) external view override {}
}
