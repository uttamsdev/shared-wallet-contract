//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract SharedWallet is Ownable{
    event AllowanceChanged(address  indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount);
    mapping(address => uint) public allowance;

    address public isowner;

    constructor() {
        isowner = msg.sender;
    }
    function isOwner() public view returns(bool){
        if(isowner ==  msg.sender){
            return true;
        }
    }

    function addAllowance(address _who, uint _amount) public onlyOwner{
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }


    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not owner");
        _;
    }

    // address public owner;

    // constructor() {
    //     owner = msg.sender;
    // }

    // modifier onlyOwner() {
    //     require(owner == msg.sender, "You are not owner");
    //     _;

    // }

    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] -= _amount;
    }

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(_amount <= address(this).balance, "There is no enough balance into the smart contract");
        if(!isOwner()){
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    function SendMoneyToContract() payable public {
        emit MoneyReceived(msg.sender, msg.value);
    }
}