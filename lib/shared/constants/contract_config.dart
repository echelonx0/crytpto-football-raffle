class ContractConfig {
  static const String raffleContractAddress =
      '0x5c6A781D663B689b7975A6339AD3eDe910023C6d';

  static const String raffleTokenAddress =
      '0x07Aa1131A1C06B4680458b0547528272BB603358';

  // Network configuration
  static const String rpcUrl = 'https://rpc.sepolia-api.lisk.com';
  static const int chainId = 4202;

  // ✅ Complete SoccerRaffle ABI
  static const String raffleAbi = '''
  [
  // Add to raffleAbi in contract_config.dart

{
  "inputs": [
    {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
    {"internalType": "uint256", "name": "amount", "type": "uint256"},
    {"internalType": "bytes32", "name": "predictionCommit", "type": "bytes32"}
  ],
  "name": "joinRaffle",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
},
{
  "inputs": [
    {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
    {"internalType": "string", "name": "prediction", "type": "string"},
    {"internalType": "string", "name": "secret", "type": "string"}
  ],
  "name": "revealPrediction",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
},
{
  "inputs": [
    {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
    {"internalType": "string", "name": "result", "type": "string"}
  ],
  "name": "setMatchResult",
  "outputs": [],
  "stateMutability": "nonpayable",
  "type": "function"
},
{
  "inputs": [
    {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
    {"internalType": "address", "name": "participant", "type": "address"}
  ],
  "name": "getParticipantPredictionReveal",
  "outputs": [
    {"internalType": "bool", "name": "revealed", "type": "bool"},
    {"internalType": "string", "name": "prediction", "type": "string"}
  ],
  "stateMutability": "view",
  "type": "function"
},
{
  "inputs": [
    {"internalType": "uint256", "name": "raffleId", "type": "uint256"}
  ],
  "name": "getRaffleWinnerInfo",
  "outputs": [
    {"internalType": "address", "name": "winner", "type": "address"},
    {"internalType": "bool", "name": "seedRevealed", "type": "bool"},
    {"internalType": "uint256", "name": "revealDeadline", "type": "uint256"},
    {"internalType": "bool", "name": "resultSet", "type": "bool"},
    {"internalType": "string", "name": "matchResult", "type": "string"}
  ],
  "stateMutability": "view",
  "type": "function"
},
    {
      "inputs": [
        {"internalType": "address", "name": "_token", "type": "address"},
        {"internalType": "string", "name": "_name", "type": "string"},
        {"internalType": "string", "name": "_symbol", "type": "string"}
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "inputs": [],
      "name": "raffleToken",
      "outputs": [{"internalType": "contract IERC20", "name": "", "type": "address"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "raffleCount",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "platformFee",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "permissionlessEnabled",
      "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "paused",
      "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "name": "raffles",
      "outputs": [
        {"internalType": "address", "name": "creator", "type": "address"},
        {"internalType": "uint256", "name": "prizePool", "type": "uint256"},
        {"internalType": "uint256", "name": "minBet", "type": "uint256"},
        {"internalType": "uint256", "name": "maxBet", "type": "uint256"},
        {"internalType": "uint256", "name": "maxParticipants", "type": "uint256"},
        {"internalType": "uint256", "name": "startTime", "type": "uint256"},
        {"internalType": "uint256", "name": "endTime", "type": "uint256"},
        {"internalType": "uint256", "name": "revealDeadline", "type": "uint256"},
        {"internalType": "uint256", "name": "creatorFee", "type": "uint256"},
        {"internalType": "bool", "name": "drawn", "type": "bool"},
        {"internalType": "bool", "name": "cancelled", "type": "bool"},
        {"internalType": "address", "name": "winner", "type": "address"},
        {"internalType": "uint256", "name": "winnerPrize", "type": "uint256"},
        {"internalType": "bytes32", "name": "seedCommit", "type": "bytes32"},
        {"internalType": "uint256", "name": "seedReveal", "type": "uint256"},
        {"internalType": "bool", "name": "seedRevealed", "type": "bool"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getActiveRaffles",
      "outputs": [{"internalType": "uint256[]", "name": "", "type": "uint256[]"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "getRaffleDetails",
      "outputs": [
        {"internalType": "address", "name": "creator", "type": "address"},
        {"internalType": "uint256", "name": "prizePool", "type": "uint256"},
        {"internalType": "uint256", "name": "participantCount", "type": "uint256"},
        {"internalType": "uint256", "name": "startTime", "type": "uint256"},
        {"internalType": "uint256", "name": "endTime", "type": "uint256"},
        {"internalType": "bool", "name": "drawn", "type": "bool"},
        {"internalType": "bool", "name": "cancelled", "type": "bool"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "getRaffleParticipants",
      "outputs": [{"internalType": "address[]", "name": "", "type": "address[]"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"internalType": "address", "name": "participant", "type": "address"}
      ],
      "name": "getParticipantBet",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "getRaffleWinnerInfo",
      "outputs": [
        {"internalType": "address", "name": "winner", "type": "address"},
        {"internalType": "bool", "name": "seedRevealed", "type": "bool"},
        {"internalType": "uint256", "name": "revealDeadline", "type": "uint256"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "isRaffleActive",
      "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "seed", "type": "uint256"}],
      "name": "generateSeedCommit",
      "outputs": [{"internalType": "bytes32", "name": "", "type": "bytes32"}],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "uint256", "name": "minBet", "type": "uint256"},
        {"internalType": "uint256", "name": "maxBet", "type": "uint256"},
        {"internalType": "uint256", "name": "maxParticipants", "type": "uint256"},
        {"internalType": "uint256", "name": "duration", "type": "uint256"},
        {"internalType": "uint256", "name": "creatorFee", "type": "uint256"},
        {"internalType": "bytes32", "name": "seedCommit", "type": "bytes32"}
      ],
      "name": "createRaffle",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"internalType": "uint256", "name": "amount", "type": "uint256"}
      ],
      "name": "joinRaffle",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"internalType": "uint256", "name": "seed", "type": "uint256"}
      ],
      "name": "revealSeed",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "drawWinner",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "emergencyDraw",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "cancelRaffle",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "raffleId", "type": "uint256"}],
      "name": "claimRefund",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "togglePermissionless",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "pause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "unpause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"indexed": true, "internalType": "address", "name": "creator", "type": "address"},
        {"indexed": false, "internalType": "uint256", "name": "minBet", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "maxBet", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "maxParticipants", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "startTime", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "endTime", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "creatorFee", "type": "uint256"},
        {"indexed": false, "internalType": "bytes32", "name": "seedCommit", "type": "bytes32"}
      ],
      "name": "RaffleCreated",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"indexed": true, "internalType": "address", "name": "participant", "type": "address"},
        {"indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "newPrizePool", "type": "uint256"}
      ],
      "name": "RaffleJoined",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "seed", "type": "uint256"}
      ],
      "name": "SeedRevealed",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "uint256", "name": "raffleId", "type": "uint256"},
        {"indexed": true, "internalType": "address", "name": "winner", "type": "address"},
        {"indexed": false, "internalType": "uint256", "name": "prize", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "creatorReward", "type": "uint256"},
        {"indexed": false, "internalType": "uint256", "name": "platformReward", "type": "uint256"}
      ],
      "name": "WinnerDrawn",
      "type": "event"
    }
  ]
  ''';

  // Raffle Token ABI
  static const String raffleTokenABI = '''
  [
    {
      "inputs": [{"internalType": "address", "name": "account", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "spender", "type": "address"},
        {"internalType": "uint256", "name": "amount", "type": "uint256"}
      ],
      "name": "approve",
      "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "owner", "type": "address"},
        {"internalType": "address", "name": "spender", "type": "address"}
      ],
      "name": "allowance",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "decimals",
      "outputs": [{"internalType": "uint8", "name": "", "type": "uint8"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "name",
      "outputs": [{"internalType": "string", "name": "", "type": "string"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [{"internalType": "string", "name": "", "type": "string"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "faucet",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ]
  ''';
}
