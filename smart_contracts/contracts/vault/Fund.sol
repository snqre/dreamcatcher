// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

// decentralizing the power to create funds?? liquidity too low for a big passive invester but can trade large liquidity
contract Fundv1 { // the funding needs 

    struct Fund {
        string name;
        string SUBTICKER // $DREAM
    }

    // will have batch transactions and delays
    
    /*
    USDT -> Fund <- Tokens (DEX vs EX)
     */
    function setAllocations() {
        // set the allocation
    }

    function singleSwap() {
        // get cheapest price from aggregator
        // make swap

        // the fund can only swap so it cannot transfer money off the fund contract
        // create


        // accumulation > early stage > 7 - 10 years > distribution

    }
    /*
    Swapping
     */
}