// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import ".deps/npm/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IEFTT.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ICO is AccessControl{
    using SafeMath for uint256;
    bytes32 public constant INVESTOR_ROLE = keccak256("INVESTOR_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant EXTEND_ICO_ROLE = keccak256("EXTEND_ICO_ROLE");

    address payable owner;
    //address payable private devAddress;
    //address constant burnAddres =0x000000000000000000000000000000000000dEaD;
    address[] minters_;
    uint256 maxSupply_;
    uint256 timeLock=18000000000;
    IEFTT eftt;
    uint256 maxICO = 100000 *10**18;
    uint256 SoldInMetis;
    uint256 SoldEFTT;
    uint256 ratioMetis =1;
    mapping(uint => uint) timeLocks;
    bool private BURNED = false;
    bool internal locked;
    uint256 month =2592000;
    uint256 week = 604800;
    uint256 immutable creationtTime;
    uint256 ICOtimeLock;


    constructor(address _eftt, address _dev) payable {
        //below might have to obfuscate with for loop
        _grantRole(INVESTOR_ROLE, _dev);
        _grantRole(BURNER_ROLE, _dev);
        _grantRole(EXTEND_ICO_ROLE, _dev);
        owner = payable(msg.sender);
        eftt = IEFTT(_eftt);
        devAddress = payable(_dev);
        creationtTime = block.timestamp;
        timeLocks[0] = 111;
        timeLocks[1] = 222;
        timeLocks[2] = 333;
            }


    event Log(string func);
    event Sold(uint);
    event Burned(uint);
 
    modifier _timeCheck(){
        require(block.timestamp < timeLock,"ICO is over :( ");
        _;
    }

    modifier _burnCheck(){
        require(!BURNED,"the supply is already burned");
        _;
        BURNED = true;
    }
    modifier _onlyOwner(){
        require(owner == msg.sender,"You're not the owner");
        _;
    }
    
    modifier _noReentry() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    
    receive() external payable {
        //add in if just metis sent to contract
        emit Log("fallback hit");
        buy();
    }


    function buy() public payable _timeCheck returns(bool){
        require(msg.value > 0,"them/they please send metis");
        uint256 buyAmount = conversion(msg.value);

        require(buyAmount + SoldEFTT < maxICO, "exceeds the total for sale");
        eftt.approve( address(this), buyAmount);
        eftt.transfer(msg.sender, buyAmount);
        SoldEFTT = buyAmount + SoldEFTT;
        emit Sold(buyAmount);
        return true;
    }

    function withdraw(uint256 _amnt) onlyRole(INVESTOR_ROLE) public {
        
        if ( creationtTime + month * 18 > block.timestamp){
            uint256 convertedAmnt =percentFromICO(_amnt);
            eftt.approve( address(this), convertedAmnt);
            payable(msg.sender).transfer(convertedAmnt);
        } else if ( creationtTime + month * 12 > block.timestamp){
            uint256 convertedAmnt =percentFromICO(_amnt);
            payable(msg.sender).transfer(convertedAmnt);
        } else if ( creationtTime + month * 6 > block.timestamp){
            uint256 convertedAmnt =percentFromICO(_amnt);
            payable(msg.sender).transfer(convertedAmnt);
        }
        
    }

    function endICO() public _timeCheck onlyRole(BURNER_ROLE) _burnCheck{
        uint256 burnAmnt = (maxICO.sub(SoldEFTT));
        eftt.burn(burnAmnt);
        emit Burned(burnAmnt);
    }

    function conversion(uint256 _amnt) private view returns(uint256){
        return(_amnt.mul(ratioMetis));
    }

    function percentFromICO(uint256 _amnt) private view returns(uint256){
        return _amnt.mul(soldPercent());
    }

    function soldPercent() private view returns(uint256){
        return SoldEFTT.div(maxICO);
    }
    function burned() public view returns(bool){
        return BURNED;
    }
}