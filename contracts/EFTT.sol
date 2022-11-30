// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol"; 

contract EFTT is ERC20, ERC20Burnable, Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
    bytes32 public constant BURN_ADMIN = keccak256("BURN_ADMIN");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    

    uint256 public constant maxSupply = 10 * 10**18;
    address public act1 =0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    
    
    struct  Handle {
        bool verified;
        bytes32 handleID;
    }
    mapping(address => Handle) public handle;
    mapping(address => uint256) public StakeBalanceOf;
    uint256 public stakedSupply;
    bool internal locked;

    modifier _noReentry() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() ERC20("ElonFreedomTwitterToken", "EFTT") {
        _grantRole(DEFAULT_ADMIN_ROLE,msg.sender);
        _grantRole(BURN_ROLE, act1);
    }


    function mint(address _to, uint256 _amnt) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(totalSupply() + _amnt <= maxSupply, "tried to mint more than total supply");
        _mint(_to, _amnt* 10**18);
    }

    event Staked(address, uint256);
    event UnStaked(address, uint256);
    
    function getBalance(address _address) public view returns(uint256){
        return StakeBalanceOf[_address];
    }


    function addTwitterHandle(bytes32 _handle) public  {
        handle[msg.sender].handleID = _handle;
    }

    function stake(uint256 _amnt) public _noReentry{
        require(balanceOf(msg.sender) > 0, "amount = 0");
        transferFrom(msg.sender, address(this), _amnt);
        StakeBalanceOf[msg.sender] += _amnt;
        stakedSupply += _amnt;
        emit Staked(msg.sender, _amnt);
    }


    function unStake(uint256 _amnt) public _noReentry{
        require(balanceOf(msg.sender)  > 0, "amount = 0");
        require(_amnt <= StakeBalanceOf[msg.sender],"nothing to unstake" );
        transfer(msg.sender, _amnt);
        StakeBalanceOf[msg.sender] -= _amnt;
        stakedSupply -= _amnt;
        emit UnStaked(msg.sender, _amnt);
    }

    function verifyHandle(bool _verified, address _address, bytes32 _handle) public onlyRole(VALIDATOR_ROLE){
        handle[_address].handleID = _handle;
        handle[_address].verified = _verified;
    } 

    function rewards() private {

    }

    function addRole(address _address)public onlyRole(DEFAULT_ADMIN_ROLE){
         _grantRole(VALIDATOR_ROLE,_address);
    }
    function getHandle(address _addres)public view returns(bytes32){
        return(handle[_addres].handleID);
    }
}
