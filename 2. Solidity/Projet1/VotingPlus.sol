// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    string private constant ADDRESS_NOT_CORRECT = "Address is not correct.";
    string private constant ADDRESS_ALREADY_IN_WHITELIST = "Address already in whitelist.";
    string private constant ADDRESS_NOT_IN_WHITELIST = "Address not in whitelist.";
    string private constant ALREADY_VOTED = "Already voted.";
    string private constant PROPOSAL_NOT_IN_PANEL = "Proposal is not in the panel.";
    string private constant REGISTRATION_START_NOT_ALLOWED = "Registration start not allowed.";
    string private constant REGISTRATION_END_NOT_ALLOWED = "Registration end not allowed.";
    string private constant REGISTRATION_NOT_ALLOWED = "Registration not allowed.";
    string private constant PROPOSAL_START_NOT_ALLOWED = "Proposals start not allowed.";
    string private constant PROPOSAL_END_NOT_ALLOWED = "Proposals end not allowed.";
    string private constant PROPOSAL_NOT_ALLOWED = "Proposal not allowed.";
    string private constant VOTE_START_NOT_ALLOWED = "Vote start not allowed.";
    string private constant VOTE_END_NOT_ALLOWED = "Vote end not allowed.";
    string private constant VOTE_NOT_ALLOWED = "Vote not allowed.";
    string private constant TALLY_VOTES_NOT_ALLOWED = "TallyVotes not allowed";
    string private constant GET_WINNER_NOT_ALLOWED = "Get winner not allowed";

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    
    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        Waiting,
        RegisteringVotersStarted,
        RegisteringVotersEnded,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    WorkflowStatus public currentWorkflowStatus = WorkflowStatus.Waiting;
    mapping(WorkflowStatus => uint256) public workflowStatusChangeDate;

    mapping(bytes32 => bool) private proposalDescriptions;
    
    uint public winningProposalId;

    modifier checkAddress(address _address) {
        require(_address != address(0), ADDRESS_NOT_CORRECT);
        _;
    }

    modifier alreadyWhiteListed(address _address) {
        require(!voters[_address].isRegistered, ADDRESS_ALREADY_IN_WHITELIST);
        _;
    }

    modifier isWhiteListed(address _address) {
        require(voters[_address].isRegistered, ADDRESS_NOT_IN_WHITELIST);
        _;
    }

    modifier alreadyVoted(address _address) {
        require(!voters[_address].hasVoted, ALREADY_VOTED);
        _;
    }

    modifier isProposal(uint256 _proposalId) {
        require(_proposalId < proposals.length, PROPOSAL_NOT_IN_PANEL);
        _;
    }

    modifier isAllowedByCurrentWorkflowStatus(WorkflowStatus _workflowStatus, string memory errorMesssage) {
        require(currentWorkflowStatus == _workflowStatus, errorMesssage);
        _;
    }

    constructor() Ownable(msg.sender) {}

    //Function to change currentWorkflowStatus
    function updateWorkflowStatus(WorkflowStatus _workflowStatus) private {
        currentWorkflowStatus = _workflowStatus; // Change the current status
        workflowStatusChangeDate[currentWorkflowStatus] = block.timestamp; // Log the timestamp of the new workflow status starting
    }

    // Function to start whitelisting session
    function startWhitelistSession() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.Waiting, REGISTRATION_START_NOT_ALLOWED) 
    {
        updateWorkflowStatus(WorkflowStatus.RegisteringVotersStarted);
    }

    // Function to stop whitelisting session
    function endWhitelistSession() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.RegisteringVotersStarted, REGISTRATION_END_NOT_ALLOWED)   
    {
        updateWorkflowStatus(WorkflowStatus.RegisteringVotersEnded);
    }

    // Function to start proposal registration session
    function startProposalsRegistration() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.RegisteringVotersEnded, PROPOSAL_START_NOT_ALLOWED) 
    {
        updateWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted);
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVotersEnded, WorkflowStatus.ProposalsRegistrationStarted);
    }

    // Function to stop proposal registration session
    function endProposalsRegistration() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted, PROPOSAL_END_NOT_ALLOWED) 
    {
        updateWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded);
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    // Function to start voting session
    function startVotingSession() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded, VOTE_START_NOT_ALLOWED) 
    {
        updateWorkflowStatus(WorkflowStatus.VotingSessionStarted);
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    // Function to end voting session
    function endVotingSession() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.VotingSessionStarted, VOTE_END_NOT_ALLOWED) 
    {
        updateWorkflowStatus(WorkflowStatus.VotingSessionEnded);
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    // Function to whitelist an address
    function registerVoter(address _voterAddress) 
        external onlyOwner 
        checkAddress(_voterAddress) 
        alreadyWhiteListed(_voterAddress) 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.RegisteringVotersStarted, REGISTRATION_NOT_ALLOWED)
    {
        voters[_voterAddress].isRegistered = true;
        emit VoterRegistered(_voterAddress);
    }

    //Function to string to lowercase
    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // If uppercase, convert in lowercase
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    // Function for a whitelisted voter to register a proposal
    function registerProposal(string calldata _description) 
        external isWhiteListed(msg.sender) 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted, PROPOSAL_NOT_ALLOWED) 
    {        
        bytes32 descriptionHash = keccak256(bytes(toLowerCase(_description)));
        require(!proposalDescriptions[descriptionHash], "Proposal already submitted.");

        proposalDescriptions[descriptionHash] = true;
        proposals.push(Proposal(_description,0));
        emit ProposalRegistered(proposals.length - 1);
    }

    // Function for a whitelisted voter to vote on a proposal
    function vote(uint _proposalId) 
        external isWhiteListed(msg.sender) 
        alreadyVoted(msg.sender) 
        isProposal(_proposalId) 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.VotingSessionStarted, VOTE_NOT_ALLOWED) 
    {
        proposals[_proposalId].voteCount++;
        voters[msg.sender].hasVoted = true;
        emit Voted (msg.sender, _proposalId);
    }

    // Function to count all votes and determine the winning proposal
    function tallyVotes() 
        external onlyOwner 
        isAllowedByCurrentWorkflowStatus(WorkflowStatus.VotingSessionEnded, TALLY_VOTES_NOT_ALLOWED) 
    {
        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            } else if (proposals[i].voteCount == winningVoteCount) {
                //Use external random function to manage equality
            }
        }

        updateWorkflowStatus(WorkflowStatus.VotesTallied);

        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }

    // Function to return the winner
    function getWinner() 
        external isAllowedByCurrentWorkflowStatus(WorkflowStatus.VotesTallied, GET_WINNER_NOT_ALLOWED) 
        view returns (Proposal memory) 
    {
        return proposals[winningProposalId];
    }


}
