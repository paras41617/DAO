// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface TokenInterface {
    function updateTotalSupply(uint256 amount , address sender) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

contract DAO {
    struct Proposal {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 votingStartTime;
        uint256 votingEndTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    address public tokenAddress;
    TokenInterface public token;
    address public admin;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    mapping(address => uint256) public rewards;
    mapping(uint256 => mapping(address => bool)) voters;

    uint256 public constant REWARD_PER_VOTE = 1;
    uint256 public tokenPrice = 1 ether;

    event Vote(
        uint256 proposalId,
        address voter,
        bool inSupport,
        uint256 votes
    );
    event ProposalExecuted(uint256 proposalId);
    event RewardClaimed(address recipient, uint256 amount);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        token = TokenInterface(_tokenAddress);
        admin = msg.sender;
        proposalCount = 0;
    }

    function createProposal(string memory _title, string memory _description)
        public
        returns (uint256)
    {
        Proposal memory newProposal = Proposal({
            id:proposalCount,
            creator: msg.sender,
            title: _title,
            description: _description,
            votingStartTime: block.timestamp,
            votingEndTime: block.timestamp + 30,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });

        proposals[proposalCount] = newProposal;
        proposalCount++;
        return proposalCount;
    }

    function vote(uint256 _proposalId, bool _inSupport) public {
        Proposal storage proposal = proposals[_proposalId];
        require(token.balanceOf(msg.sender) > 0, "Must have tokens to vote");
        require(block.timestamp > proposal.votingEndTime , "Voting is still going on");
        require(!proposal.executed, "Proposal has already been executed");
        require(!voters[_proposalId][msg.sender], "Already voted");
        uint256 votes = token.balanceOf(msg.sender);
        require(votes > 0, "Must have tokens to vote");
        voters[_proposalId][msg.sender] = true;
        if (_inSupport) {
            proposal.forVotes += 1;
        } else {
            proposal.againstVotes += 1;
        }

        if (votes >= proposalCount/2) {
            uint256 rewardAmount = REWARD_PER_VOTE;
            rewards[msg.sender] += rewardAmount;
            token.updateTotalSupply(rewardAmount , msg.sender);
        }

        emit Vote(_proposalId, msg.sender, _inSupport, votes);
    }

    function executeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];

        require(!proposal.executed, "Proposal has already been executed");
        require(
            block.timestamp > proposal.votingEndTime,
            "Voting period has not ended yet"
        );

        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        require(totalVotes > 0, "No votes for proposal");

        if (proposal.forVotes > proposal.againstVotes) {
            proposal.executed = true;

            emit ProposalExecuted(_proposalId);
        }
    }

    function fetchProposals() public view returns (Proposal[] memory) {
        uint256 currentIndex = 0;

        Proposal[] memory items = new Proposal[](proposalCount);
        for (uint256 i = 0; i < proposalCount; i++) {
            Proposal storage currentItem = proposals[i];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return items;
    }

    function mint(uint256 input_amount) public payable {
        uint256 _amount = input_amount; // the amount sent by the user
        require(_amount > 0, "Amount should be greater than 0");
        token.updateTotalSupply(_amount , msg.sender);
    }
    
    function rights() public view returns (uint256) {
        return token.balanceOf(msg.sender);
    }
}
