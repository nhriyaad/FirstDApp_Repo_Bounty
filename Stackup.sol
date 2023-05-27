// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StackUp {
    enum playerQuestStatus {
        NOT_JOINED,
        JOINED,
        SUBMITTED
    }

    struct Quest {
        uint256 questId;
        uint256 numberOfPlayers;
        string title;
        uint8 reward;
        uint256 numberOfRewards;
        uint256 startTime; // New field for quest start time
        uint256 endTime;   // New field for quest end time
    }

    address public admin;
    uint256 public nextQuestId;
    mapping(uint256 => Quest) public quests;
    mapping(address => mapping(uint256 => playerQuestStatus))
        public playerQuestStatuses;

    constructor() {
        admin = msg.sender;
    }

    function createQuest(
        string calldata title_,
        uint8 reward_,
        uint256 numberOfRewards_,
        uint256 startTime_,
        uint256 endTime_
    ) external {
        require(msg.sender == admin, "Only the admin can create quests");
        quests[nextQuestId].questId = nextQuestId;
        quests[nextQuestId].title = title_;
        quests[nextQuestId].reward = reward_;
        quests[nextQuestId].numberOfRewards = numberOfRewards_;
        quests[nextQuestId].startTime = startTime_;
        quests[nextQuestId].endTime = endTime_;
        nextQuestId++;
    }

    function editQuest(
        uint256 questId,
        string calldata title_,
        uint8 reward_,
        uint256 numberOfRewards_
    ) external questExists(questId) {
        require(msg.sender == admin, "Only the admin can edit quests");

        Quest storage thisQuest = quests[questId];
        thisQuest.title = title_;
        thisQuest.reward = reward_;
        thisQuest.numberOfRewards = numberOfRewards_;
    }
    function deleteQuest(uint256 questId) external questExists(questId) {
    require(msg.sender == admin, "Only the admin can delete quests");

    delete quests[questId];
    delete playerQuestStatuses[msg.sender][questId];
}

    function joinQuest(uint256 questId) external questExists(questId) {
        require(
            playerQuestStatuses[msg.sender][questId] ==
                playerQuestStatus.NOT_JOINED,
            "Player has already joined/submitted this quest"
        );
        require(quests[questId].startTime > block.timestamp, "Quest started");
        require(quests[questId].endTime > block.timestamp, "Quest ended");
        playerQuestStatuses[msg.sender][questId] = playerQuestStatus.JOINED;
        Quest storage thisQuest = quests[questId];
        thisQuest.numberOfPlayers++;
    }

    function submitQuest(uint256 questId) external questExists(questId) {
        require(
            playerQuestStatuses[msg.sender][questId] ==
                playerQuestStatus.JOINED,
            "Player must first join the quest"
        );
        playerQuestStatuses[msg.sender][questId] = playerQuestStatus.SUBMITTED;
    }

    modifier questExists(uint256 questId) {
        require(quests[questId].reward != 0, "Quest does not exist");
        _;
    }
}
