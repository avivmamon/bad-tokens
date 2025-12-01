// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * ⚠️ WARNING: TEST CONTRACT FOR SECURITY RESEARCH ONLY ⚠️
 *
 * This deployment script is part of a security research project.
 * FOR EDUCATIONAL AND TESTING PURPOSES ONLY
 */

import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Visual Spoofing (a)
import {SpoofToken} from "../src/SpoofToken.sol";

// Metadata Manipulation (b)
import {MaliciousNameToken} from "../src/MaliciousNameToken.sol";
import {MaliciousSymbolToken} from "../src/MaliciousSymbolToken.sol";
import {MaliciousURIToken} from "../src/MaliciousURIToken.sol";

// Contract Deception (c)
import {HoneypotToken} from "../src/HoneypotToken.sol";
import {HiddenMintToken} from "../src/HiddenMintToken.sol";
import {HighTaxToken} from "../src/HighTaxToken.sol";
import {HiddenRestrictionToken} from "../src/HiddenRestrictionToken.sol";
import {NormalToken} from "../src/NormalToken.sol";

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DeployAll is Script {
    address constant UNISWAP_V2_ROUTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24; // Base Mainnet Router

    uint256 public deployerPrivateKey;
    address public deployer;
    IUniswapV2Router02 public router;
    IUniswapV2Factory public factory;
    address public weth;

    // Contract tracking
    address[20] public deployedContracts;
    string[20] public contractNames;
    uint256 public contractCount;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.addr(deployerPrivateKey);
        router = IUniswapV2Router02(UNISWAP_V2_ROUTER);
        weth = router.WETH();
        factory = IUniswapV2Factory(router.factory());
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        console.log("=== Deploying All Contracts ===");
        console.log("Deployer:", deployer);

        // Deploy all categories
        deployVisualSpoofing();
        deployMetadataManipulation();
        deployContractDeception();

        vm.stopBroadcast();

        console.log("\n=== Deployment Summary ===");
        for (uint i = 0; i < contractCount; i++) {
            console.log(contractNames[i], ":", deployedContracts[i]);
        }
    }

    // Deploy specific contracts by ID
    function deploy_spoof1() public {
        // Exact Name Spoof - USDC
        vm.startBroadcast(deployerPrivateKey);
        SpoofToken token = new SpoofToken("USD Coin", "USDC", 1_000_000 * 1e18);
        console.log("spoof1 - Exact Name Spoof:", address(token));
        vm.stopBroadcast();
    }

    function deploy_spoof2() public {
        // Homoglyph Token - Cyrillic S
        vm.startBroadcast(deployerPrivateKey);
        SpoofToken token = new SpoofToken("USD Coin", unicode"UЅDC", 1_000_000 * 1e18);
        console.log("spoof2 - Homoglyph Token:", address(token));
        vm.stopBroadcast();
    }

    function deploy_spoof3() public {
        // Invisible Char Token - Zero Width Space
        vm.startBroadcast(deployerPrivateKey);
        SpoofToken token = new SpoofToken("USD Coin", unicode"U​SDC", 1_000_000 * 1e18);
        console.log("spoof3 - Invisible Char Token:", address(token));
        vm.stopBroadcast();
    }

    function deploy_metadata1() public {
        // Malicious Name Token - URL in token name
        vm.startBroadcast(deployerPrivateKey);
        MaliciousNameToken token = new MaliciousNameToken(
            "Claim Reward Visit claim-airdrop-fake-dapp.vercel.app",
            "REWARD",
            1_000_000 * 1e18
        );
        console.log("metadata1 - Malicious Name Token:", address(token));
        vm.stopBroadcast();
    }

    function deploy_metadata2() public {
        // Malicious Symbol Token - URL in token symbol
        vm.startBroadcast(deployerPrivateKey);
        MaliciousSymbolToken token = new MaliciousSymbolToken(
            "Airdrop Token",
            "claim-airdrop-fake-dapp.vercel.app",
            1_000_000 * 1e18
        );
        console.log("metadata2 - Malicious Symbol Token:", address(token));
        vm.stopBroadcast();
    }

    function deploy_metadata3() public {
        // Malicious URI Token - NFT with malicious image URI
        vm.startBroadcast(deployerPrivateKey);
        MaliciousURIToken token = new MaliciousURIToken(
            "Exclusive Rewards Club",
            "REWARDS",
            "https://i.imgur.com/j9tEF9M.png"
        );
        console.log("metadata3 - Malicious URI Token (NFT):", address(token));
        token.mint(deployer);
        console.log("  - Minted NFT to deployer");
        vm.stopBroadcast();
    }

    function deploy_honeypot1() public {
        setUp();
        vm.startBroadcast(deployerPrivateKey);
        HoneypotToken hp = new HoneypotToken(1_000_000 * 1e18);
        console.log("honeypot1 - Classic Honeypot:", address(hp));
        // 1.5$ worth of ETH at 2833.36 $/ETH is approx 0.0005294 ETH
        _createPairAndAddLiquidity(address(hp), 0.00053 ether);
        address hpPair = factory.getPair(address(hp), weth);
        if (hpPair != address(0)) {
            hp.setUniswapPair(hpPair);
        }
        vm.stopBroadcast();
    }

    function deploy_honeypot2() public {
        setUp();
        vm.startBroadcast(deployerPrivateKey);
        HiddenMintToken hm = new HiddenMintToken(1_000_000 * 1e18);
        console.log("honeypot2 - Hidden Mint Token:", address(hm));
        _createPairAndAddLiquidity(address(hm), 0.00001 ether);
        vm.stopBroadcast();
    }

    function deploy_honeypot3() public {
        setUp();
        vm.startBroadcast(deployerPrivateKey);
        HighTaxToken ht = new HighTaxToken(1_000_000 * 1e18, deployer);
        console.log("honeypot3 - High Tax Token:", address(ht));
        _createPairAndAddLiquidity(address(ht), 0.00001 ether);
        address htPair = factory.getPair(address(ht), weth);
        if (htPair != address(0)) {
            ht.setUniswapPair(htPair);
        }
        vm.stopBroadcast();
    }

    function deploy_honeypot4() public {
        setUp();
        vm.startBroadcast(deployerPrivateKey);
        HiddenRestrictionToken hr = new HiddenRestrictionToken(1_000_000 * 1e18);
        console.log("honeypot4 - Hidden Restriction Token:", address(hr));
        _createPairAndAddLiquidity(address(hr), 0.00001 ether);
        address hrPair = factory.getPair(address(hr), weth);
        if (hrPair != address(0)) {
            hr.setUniswapPair(hrPair);
        }
        vm.stopBroadcast();
    }

    function deployVisualSpoofing() internal {
        console.log("\n--- Category A: Visual Spoofing ---");

        // spoof1 - Exact Name Spoof
        SpoofToken spoof1 = new SpoofToken("USD Coin", "USDC", 1_000_000 * 1e18);
        _trackContract(address(spoof1), "spoof1 - Exact Name Spoof");

        // spoof2 - Homoglyph Token (Cyrillic S)
        SpoofToken spoof2 = new SpoofToken("USD Coin", unicode"UЅDC", 1_000_000 * 1e18);
        _trackContract(address(spoof2), "spoof2 - Homoglyph Token");

        // spoof3 - Invisible Char Token (Zero Width Space)
        SpoofToken spoof3 = new SpoofToken("USD Coin", unicode"U​SDC", 1_000_000 * 1e18);
        _trackContract(address(spoof3), "spoof3 - Invisible Char Token");
    }

    function deployMetadataManipulation() internal {
        console.log("\n--- Category B: Metadata Manipulation ---");

        // metadata1 - Malicious Name Token
        MaliciousNameToken malName = new MaliciousNameToken(
            "Claim Reward Visit claim-airdrop-fake-dapp.vercel.app",
            "REWARD",
            1_000_000 * 1e18
        );
        _trackContract(address(malName), "metadata1 - Malicious Name Token");

        // metadata2 - Malicious Symbol Token
        MaliciousSymbolToken malSymbol = new MaliciousSymbolToken(
            "Airdrop Token",
            "claim-airdrop-fake-dapp.vercel.app",
            1_000_000 * 1e18
        );
        _trackContract(address(malSymbol), "metadata2 - Malicious Symbol Token");

        // metadata3 - Malicious URI Token (NFT)
        MaliciousURIToken malURI = new MaliciousURIToken(
            "Exclusive Rewards Club",
            "REWARDS",
            "https://i.imgur.com/j9tEF9M.png"
        );
        _trackContract(address(malURI), "metadata3 - Malicious URI Token (NFT)");
        malURI.mint(deployer);
        console.log("  - Minted NFT to deployer");
    }

    function deployContractDeception() internal {
        console.log("\n--- Category C: Contract Deception ---");

        // Control - Normal Token
        NormalToken normal = new NormalToken(1_000_000 * 1e18);
        _trackContract(address(normal), "control - Normal Token");

        // honeypot1 - Classic Honeypot
        HoneypotToken hp = new HoneypotToken(1_000_000 * 1e18);
        _trackContract(address(hp), "honeypot1 - Classic Honeypot");
        _createPairAndAddLiquidity(address(hp), 0.00003 ether);
        address hpPair = factory.getPair(address(hp), weth);
        if (hpPair != address(0)) {
            hp.setUniswapPair(hpPair);
        }

        // honeypot2 - Hidden Mint Token
        HiddenMintToken hm = new HiddenMintToken(1_000_000 * 1e18);
        _trackContract(address(hm), "honeypot2 - Hidden Mint Token");
        _createPairAndAddLiquidity(address(hm), 0.00001 ether);

        // honeypot3 - High Tax Token
        HighTaxToken ht = new HighTaxToken(1_000_000 * 1e18, deployer);
        _trackContract(address(ht), "honeypot3 - High Tax Token");
        _createPairAndAddLiquidity(address(ht), 0.00001 ether);
        address htPair = factory.getPair(address(ht), weth);
        if (htPair != address(0)) {
            ht.setUniswapPair(htPair);
        }

        // honeypot4 - Hidden Restriction Token
        HiddenRestrictionToken hr = new HiddenRestrictionToken(1_000_000 * 1e18);
        _trackContract(address(hr), "honeypot4 - Hidden Restriction Token");
        _createPairAndAddLiquidity(address(hr), 0.00001 ether);
        address hrPair = factory.getPair(address(hr), weth);
        if (hrPair != address(0)) {
            hr.setUniswapPair(hrPair);
        }
    }

    function _createPairAndAddLiquidity(address token, uint256 ethAmount) internal {
        ERC20(token).approve(address(router), type(uint256).max);

        try router.addLiquidityETH{value: ethAmount}(
            token,
            1000 * 1e18,
            0,
            0,
            deployer,
            block.timestamp + 300
        ) {
            console.log("  - Liquidity added");
            address pair = factory.getPair(token, weth);
            console.log("  - Pair address:", pair);

            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = weth;

            try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                100 * 1e18,
                0,
                path,
                deployer,
                block.timestamp + 300
            ) {
                console.log("  - Swapped 100 tokens for ETH");
            } catch {
                console.log("  - Swap failed");
            }
        } catch {
            console.log("  - Failed to add liquidity");
        }
    }

    function _trackContract(address addr, string memory name) internal {
        deployedContracts[contractCount] = addr;
        contractNames[contractCount] = name;
        contractCount++;
        console.log(name, ":", addr);
    }
}
