# prt_3_team5

# Tokenized Asset Fund

## Introduction

## Technology

- [Standard ERC20](https://docs.openzeppelin.com/contracts/4.x/erc20) since we want our tokenized fund share to be fungible, me make it compliant to this standard
- [Ownable contract](https://docs.openzeppelin.com/contracts/2.x/access-control) so we have power over access control
- [SafeMath](https://docs.openzeppelin.com/contracts/2.x/api/math) to perform sound mathematical operation because we are operating with unsigned integers only
- [Uniswap](https://docs.uniswap.org/) to give us access to an automated market maker, liquidity pools and pairs
- [Ganache](https://trufflesuite.com/ganache/) to create a dummy blockchain on which to test our contract
- [Remix](https://remix.ethereum.org/) as a compiler and to deploy compiled smart contracts

## Usage

## License

Copyright 2022 - Antonio Parolini, Edgar Pocaterra, Maxwell Snyder, Meina Bian, Michael Adut

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.