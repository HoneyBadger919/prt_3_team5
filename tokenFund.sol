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

	// Sell a token held by the fund
	function removeToken(address _token) public onlyOwner returns(uint256) {
		// Check if it is the right token
		for (uint256 i=0;i<tokens.length;i++){
			if(tokens[i].tokenAddress==_token){
                IUniswapV2Factory factory = IUniswapV2Factory(amm.factory());
              	IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(amm.WETH(), _token));
                (uint112 token0r,uint112 token1r, uint32 bl) = pair.getReserves();
                //Calculate estimated output of the swap
			    uint256 amountOut;
                if (pair.token0() == amm.WETH()) {
                   		amountOut = amm.getAmountOut(tokens[i].amount, token1r, token0r);
                } else {
                   		amountOut = amm.getAmountOut(tokens[i].amount, token0r, token1r);
                }
                //Approve asset transfer to AMM router
                IERC20 inToken = IERC20(tokens[i].tokenAddress);
                inToken.approve(address(amm),tokens[i].amount);
                address[] memory route = new address[](2);
                route[0] = _token;
                route[1] = amm.WETH();
                //Do the swap
                uint[] memory amounts = amm.swapExactTokensForTokens(tokens[i].amount, amountOut.mul(85).div(100), route, address(this), block.timestamp.add(60));
                //Delete token from list.
                tokens[i]=tokens[tokens.length-1];
                delete tokens[tokens.length-1];
                tokens.pop();
                return amounts[amounts.length-1];
			}
		}
        return 0;
	}

    // Add a token to the fund.
    // This method take the address of the token to buy
    // and the amount of WETH to swap to the specified asset.
    // It allows 15% slippage on the swap.
    function addToken(address _token, uint256 amount) public onlyOwner{
        IERC20 weth = IERC20(amm.WETH());
        //Verify the contract has enough WETH
        require(weth.balanceOf(address(this)) >= amount, "invalid amount");
        IUniswapV2Factory factory = IUniswapV2Factory(amm.factory());
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(amm.WETH(), _token));
        //Calculate estimated amount of asset output.
        (uint112 token0r,uint112 token1r, uint32 bl) = pair.getReserves();
        uint256 amountOut;
        if (pair.token0() == amm.WETH()) {
            amountOut = amm.getAmountOut(amount, token0r, token1r);
        } else {
            amountOut = amm.getAmountOut(amount, token1r, token0r);
        }
        weth.approve(address(amm), amount);
        address[] memory route = new address[](2);
        route[0] = amm.WETH();
        route[1] = _token;
        //Perform the swap
        uint[] memory amounts = amm.swapExactTokensForTokens(amount, amountOut.mul(85).div(100), route, address(this), block.timestamp.add(60));
        //Add the token to the list.
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].tokenAddress == _token) {
                tokens[i].amount = tokens[i].amount.add(amounts[amounts.length - 1]);
                return;
            }
        }
        tokens.push(Token(_token, amounts[amounts.length - 1]));
        return;
    }

    //This method allow an user to withdraw his investment in WETH.
    // It swap the exact user share of the fund of every token in the pool
    // and send it to the user in WETH.
    function retireInvestment() public returns (uint256){
        uint256 share = getShare();
        IUniswapV2Factory factory = IUniswapV2Factory(amm.factory());
        uint totalAmountOut = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(amm.WETH(), tokens[i].tokenAddress));
            (uint112 token0r,uint112 token1r, uint32 bl) = pair.getReserves();
            //Get user share of token
            uint256 swappableAmount = tokens[i].amount.mul(share).div(1000);
            //Get estimated amount out of the swap.
            uint256 amountOut;
            if (pair.token0() == amm.WETH()) {
                amountOut = amm.getAmountOut(swappableAmount, token1r, token0r);
            } else {
                amountOut = amm.getAmountOut(swappableAmount, token0r, token1r);
            }
            IERC20 inToken = IERC20(tokens[i].tokenAddress);
            inToken.approve(address(amm),swappableAmount);
            address[] memory route = new address[](2);
            route[0] = tokens[i].tokenAddress;
            route[1] = amm.WETH();
            //Performs the swap.
            uint[] memory amounts = amm.swapExactTokensForTokens(swappableAmount, amountOut.mul(85).div(100), route, address(this), block.timestamp.add(60));
            totalAmountOut = totalAmountOut.add(amounts[amounts.length - 1]);
            tokens[i].amount = tokens[i].amount.sub(swappableAmount);
        }
        //Send WETH to the user
        IERC20 weth = IERC20(amm.WETH());
        weth.transfer(msg.sender, totalAmountOut);
        //Burn user shares.
        _burn(msg.sender, balanceOf(msg.sender));
        return totalAmountOut;
    }

    //Mint new shares to an user.
    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to,amount);
    }
}
	

