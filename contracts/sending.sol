// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IEFTT.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract SocialSend is AccessControl {

    IEFTT immutable ieftt;


    constructor(address _addieftt){
        ieftt = IEFTT(_addieftt);
    }

    


}