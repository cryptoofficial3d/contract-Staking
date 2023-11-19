// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

// Start contarct staking

contract staking 
    {
        address public owner;


        struct Position 
        {
            uint PositionId;
            address walletAdrres;
            uint createData;
            uint unlockData;
            uint percentInterest;
            uint weiStaking;
            uint weiInterest;
            bool open;
        }

         Position position;

        uint public currentPositionId;

        mapping(uint => Position) public positions;
        mapping(address => uint[]) public positionIdsByAddress;
        mapping(uint => uint) public tiers;

        uint[] public lockPeriods;


        constructor() payable 
        {
            owner = msg.sender;
            currentPositionId = 0;

            tiers[0] = 700;
            tiers[30] = 800;
            tiers[60] = 900;
            tiers[90] = 1200;


            lockPeriods.push(0);
            lockPeriods.push(30);
            lockPeriods.push(60);
            lockPeriods.push(90);
        }


        function stakeEthre (uint numDays) external payable
        {
            require(tiers[numDays] > 0, "Mapping not found");

            positions[currentPositionId] = Position 
            (
                currentPositionId,
                msg.sender,
                block.timestamp,
                block.timestamp + (numDays * 1 days),
                tiers[numDays],
                msg.value,
                calculateInterest(tiers[numDays], msg.value),
                true
            );

            positionIdsByAddress[msg.sender].push(currentPositionId);
            currentPositionId +=1;
        }

        function calculateInterest(uint basisPosition , uint weiAmount) private pure returns (uint)
        {
            return basisPosition * weiAmount / 10000;
        }

        function getLockPeriods() external view returns (uint[] memory)
        {
            return lockPeriods;
        }

        function getInterestRate(uint numDays) external view returns (uint)
        {
            return tiers[numDays];
        }

        function getPositionById(uint PositionId) external view returns (Position memory)
        {
            return positions[PositionId];
        }

        function getPositionIdsForAddress(address walletAdrres) external view returns (uint[] memory)
        {
            return positionIdsByAddress[walletAdrres];
        }

        function closePosition (uint PositionId) external
        {
            require(positions[PositionId].walletAdrres == msg.sender, "only position creator may modify position");
            require(positions[PositionId].open == true, "position is closed");

            positions[PositionId].open = false;

            uint amount = positions[PositionId].weiStaking + positions[PositionId].weiInterest;
            payable(msg.sender).call{value: amount}("");
        }
    }
    