// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FundMe {

    enum State {Active, Down}
    
    struct Fund {
        State isFundable;
        address payable owner;
        uint256 totalFunded;
        uint256 goal;
    }

    Fund MyFund;
    uint256[] public historyOfContributions;
    mapping(address => uint256) public contributions;

    constructor(State _isFundable, uint256 _totalFunded, uint256 _goal){
        MyFund = Fund(
            _isFundable,
            payable(msg.sender),
            _totalFunded,
            _goal
        );
    }

    error fundClosed(State currentFundState);
    error emptyFund();

    event funded(
        uint256 contributed,
        address contributor,
        uint256 totalAmount
    );

    event fundStateChanged(
        State newState
    );

    modifier onlyOwner() {
        require(
            msg.sender == MyFund.owner,
            "Only the owner has the permission for this function"
        );

        _;
    }

    modifier onlyContributor() {
        require(
            msg.sender != MyFund.owner,
            "Owner cannot do that!"
        );

        _;
    }

    function fundProject() public payable onlyContributor{

        if (MyFund.isFundable == State.Down) {
            revert fundClosed(MyFund.isFundable);
        }

        if (msg.value == 0) {
            revert emptyFund();
        }

        MyFund.totalFunded += msg.value;
        MyFund.owner.transfer(msg.value);
        historyOfContributions.push(msg.value);
        contributions[msg.sender] = contributions[msg.sender] + msg.value;
        emit funded(msg.value, msg.sender, MyFund.totalFunded);
    }

    function changeFundState() public onlyOwner{
        if (MyFund.isFundable == State.Active) {
            MyFund.isFundable = State.Down;
        } else {
            MyFund.isFundable = State.Active;
        }
        emit fundStateChanged(MyFund.isFundable);
    }

}