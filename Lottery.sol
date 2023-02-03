//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address public manager; //address type because we will store address of manager, not of array type because a single manager is there.
    address payable[] public participants; //payable bcz we need to transfer ethers to the winner's account, array type because no. of participant would be there

    constructor()
    {
        manager = msg.sender; //global variable(msg.sender)-> when it will be compiled and deployed, the assress of account will be transferred to the manager, ultimately manager will become controller of the project, All authorities of contract to manager, that's why in constructoer in the beginning. This line will be used when we'll use require statement.From that, we'll ensure that the control is with manager only and how much amount can a participant transfer.
    }

    receive () external payable //Recieve can be used only once in the contract so as to transfer a particular amount of ether to the contract, it'll be external, remain payable, and nothing can be passed in its arguments. This function is to transfer ethers from participants to contract
    {
        require(msg.value==1 ether); //for participation, one shuld transact a minimum of 1 ether. Otherwise, the registration of participant wouldn't occour.
        participants.push(payable(msg.sender)); //registering the participant's address from whom we are receiving ethers. This is a dynamic array, so push is used. msg.sender to store address
    }

    function getBalance() public view returns(uint)
    {
        require(msg.sender== manager); //the address of the participant should be equal to the address of manager.
        return address(this).balance;
    }

    function random() public view returns(uint){ //to randomly choose among the participants
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));//keccak to select random participant as winner.
    }//these random functions should never be used in actual smart contract as some values may repeat themselves.
    
    // function selectWinner() public view returns(address)
    function selectWinner() public //from this function, our manager is going to select the winner. Returning address type to chack if our random function is working properly, and if its woking properly, then, we'll transfer the whole balance in the contract.
    {
        require(msg.sender==manager); //managed by manager only
        require(participants.length>=3); //minimum requrement satisfaction of participants.
        uint r=random();
        address payable winner;
        uint index = r % participants.length; //***throuh this, we'll select the participants from our dynamic array. r is any random value which is being divided by the length of our array and the remainder will be accessed, i.e. we'll get the index value.
        winner = participants[index];
        winner.transfer(getBalance()); //the total balance is meing transferred to the winner's account.
        // return winner;
        participants=new address payable[](0);//as soon as the winner gets selected, we'll reset our dynamic array.
    }
}
