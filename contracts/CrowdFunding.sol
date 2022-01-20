// SPDX-License-Identifier: UNLICENCED

pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding{

    mapping(address=>uint) public contributor;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributor;


    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voter;
    }

    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline)  // 3600=1hr
    {
        target=_target;
        deadline =block.timestamp+_deadline;
        minContribution = 1 ether;
        manager =msg.sender;
    }

    function SendEth() public payable {
        require(block.timestamp<deadline,"Deadline has Passed sorry cannot fund");
        require(msg.value>=minContribution,"Contribute 1 or above 1 ether");

        if(contributor[msg.sender]==0){
            noOfContributor++;
        }

        contributor[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }



    function GetContractBalance() public view returns(uint){
        return address(this).balance;
    }


    function Refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"Not eligible for Refund");
        require(contributor[msg.sender]>0,"you have not contributed any fund or got refund already");
        
        address payable user=payable(msg.sender);
        user.transfer(contributor[msg.sender]);
        contributor[msg.sender]=0;
    }



    modifier onlyManager(){
        require(msg.sender==manager,"Manager only");
        _;
    }


    function CreateRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
        Request storage newRequest= requests[numRequests];
        numRequests++;

        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }




    function VoteRequest(uint _requestNo)public{

        require(contributor[msg.sender]>0,"You must contribute First for Votting");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voter[msg.sender]==false,"you have already votted");

        thisRequest.voter[msg.sender]=true;
        thisRequest.noOfVoters++;
    }



    function MakePayment(uint _requestNo)public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"the Request has been completed cause has been funded already");
        require(thisRequest.noOfVoters>noOfContributor/2,"Majority does not support the cause");

        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}//end of Contract