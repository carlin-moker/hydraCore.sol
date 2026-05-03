// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
 * @title CosmicRoute_Gasless
 * @dev Tecnología de intercambio sin gas para Red 62
 */
contract CosmicRoute is EIP712 {
    using ECDSA for bytes32;

    address public owner;
    mapping(uint256 => bool) public usedNonces;

    event CosmicSwapExecuted(address indexed user, uint256 amountIn, uint256 nonce);

    constructor() EIP712("CosmicRoute", "1") {
        owner = msg.sender;
    }

    struct SwapRequest {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 nonce;
        uint256 deadline;
    }

    function executeCosmicSwap(
        SwapRequest calldata req,
        bytes calldata signature
    ) external {
        require(block.timestamp <= req.deadline, "Expired");
        require(!usedNonces[req.nonce], "Nonce already used");

        bytes32 structHash = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("SwapRequest(address user,address tokenIn,address tokenOut,uint256 amountIn,uint256 minAmountOut,uint256 nonce,uint256 deadline)"),
            req.user,
            req.tokenIn,
            req.tokenOut,
            req.amountIn,
            req.minAmountOut,
            req.nonce,
            req.deadline
        )));

        address signer = structHash.recover(signature);
        require(signer == req.user, "Invalid signature");

        usedNonces[req.nonce] = true;

        // Liquidity execution
        IERC20(req.tokenIn).transferFrom(req.user, address(this), req.amountIn);
        
        require(IERC20(req.tokenOut).balanceOf(address(this)) >= req.minAmountOut, "Insufficient liquidity");
        IERC20(req.tokenOut).transfer(req.user, req.minAmountOut);

        emit CosmicSwapExecuted(req.user, req.amountIn, req.nonce);
    }

    function withdraw(address token, uint256 amount) external {
        require(msg.sender == owner, "Unauthorized");
        IERC20(token).transfer(owner, amount);
    }
}
