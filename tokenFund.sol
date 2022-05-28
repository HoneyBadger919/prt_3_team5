pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract assetFund is ERC20, Ownable {
	using SafeMath for uint256;
	using SafeMath for uint;

	//Reference to the router of an automated market maker (UniSwap)
	IUniswapV2Router02 private amm;

	//Use a struct type to define a record (i.e. asset in the fund)
	struct Token {
		address tokenAddress;
		uint256 amount;
	}

	//Represents the list of assets inside the fund
	Token[] private tokens;

	constructor(string memory name, string memory symbol, address _amm) ERC20(name,symbol) Ownable(){
		amm = IUniswapV2Router02(_amm);
	}

	//Function returning the list of the tokens and amounts held by the fund
	function getTokens() public view returns(Token[] memory) {
		Token[] memory fTokens = new Token[](tokens.length);
		for (uint256 i=0;i<tokens.length;i++){
			fTokens[i]=Token(tokens[i].tokenAddress,tokens[i].amount);
		}
		return fTokens;
	}
	
	//Get the sender user share in per thousand respect the total supply of the fund
	function getShare() public view returns(uint256){
		uint256 balance = this.balanceOf(msg.sender);
		return balance.mul(1000).div(totalSupply());
	}

