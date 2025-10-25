# YieldPuzzle Smart Contract

A gamified financial literacy platform built on the Stacks blockchain using Clarity. Players stake STX, solve DeFi and financial puzzles, and earn yield rewards based on their knowledge and participation.

## 🎮 Overview

YieldPuzzle combines education with earning opportunities. Players must demonstrate financial literacy by solving puzzles correctly to unlock yield from a shared pool. The more you stake and the harder the puzzles you solve, the more you can earn.

## 🌟 Features

- **Stake-to-Play**: Deposit STX to participate in the game
- **Educational Puzzles**: Learn about DeFi, investing, and financial concepts
- **Yield Rewards**: Earn real STX by solving puzzles correctly
- **Progressive Difficulty**: Puzzles range from beginner to advanced
- **Secure Answers**: All answers are hashed to prevent cheating
- **Player Progress Tracking**: Monitor your stats and earnings
- **One-Time Solve**: Each puzzle can only be solved once per player

## 📋 Contract Functions

### For Players

#### `stake-to-play`
```clarity
(stake-to-play (amount uint))
```
Deposit STX to join the game. Minimum stake is 1 STX (1,000,000 microSTX).

**Parameters:**
- `amount`: Amount of microSTX to stake (1 STX = 1,000,000 microSTX)

**Returns:** `(ok true)` on success

---

#### `solve-puzzle`
```clarity
(solve-puzzle (puzzle-id uint) (answer (string-ascii 64)))
```
Submit an answer to a puzzle. Correct answers unlock yield rewards.

**Parameters:**
- `puzzle-id`: The ID of the puzzle to solve
- `answer`: Your answer (case-sensitive)

**Returns:** The amount of STX earned as reward

**Example:**
```clarity
(contract-call? .yield-puzzle solve-puzzle u1 "compound-interest")
```

---

#### `get-player-progress`
```clarity
(get-player-progress (player principal))
```
View your game statistics.

**Returns:**
- `puzzles-solved`: Number of puzzles completed
- `total-staked`: Total STX you've deposited
- `total-earned`: Total yield earned
- `last-solved`: ID of your most recent puzzle

---

#### `get-puzzle`
```clarity
(get-puzzle (puzzle-id uint))
```
View puzzle details (question, reward, difficulty).

**Returns:** Puzzle information (note: answer hash is not readable)

---

#### `is-puzzle-solved`
```clarity
(is-puzzle-solved (player principal) (puzzle-id uint))
```
Check if you've already solved a specific puzzle.

**Returns:** `true` or `false`

---

### For Contract Owner

#### `create-puzzle`
```clarity
(create-puzzle (question (string-ascii 256)) 
               (answer (string-ascii 64))
               (reward-percentage uint)
               (difficulty uint))
```
Add a new puzzle to the game.

**Parameters:**
- `question`: The puzzle question (max 256 characters)
- `answer`: The correct answer (will be hashed)
- `reward-percentage`: Percentage of player's stake to reward (e.g., 10 = 10%)
- `difficulty`: Difficulty level (1-10)

**Example:**
```clarity
(contract-call? .yield-puzzle create-puzzle 
  "What is the annual percentage yield if interest compounds continuously at 5%?"
  "5.127"
  u15
  u7)
```

---

#### `deactivate-puzzle`
```clarity
(deactivate-puzzle (puzzle-id uint))
```
Disable a puzzle (no longer solvable).

---

#### `emergency-withdraw`
```clarity
(emergency-withdraw (amount uint))
```
Emergency function to withdraw funds from the contract.

---

## 🚀 Getting Started

### Deployment

1. Deploy the contract to Stacks blockchain:
```bash
clarinet contract deploy yield-puzzle
```

2. Create initial puzzles:
```clarity
(contract-call? .yield-puzzle create-puzzle 
  "What does DeFi stand for?"
  "Decentralized Finance"
  u5
  u1)
```

### For Players

1. **Stake STX to play:**
```clarity
(contract-call? .yield-puzzle stake-to-play u5000000) ;; Stake 5 STX
```

2. **Check available puzzles:**
```clarity
(contract-call? .yield-puzzle get-puzzle u1)
```

3. **Solve a puzzle:**
```clarity
(contract-call? .yield-puzzle solve-puzzle u1 "Decentralized Finance")
```

4. **Check your progress:**
```clarity
(contract-call? .yield-puzzle get-player-progress tx-sender)
```

---

## 💰 Reward System

Rewards are calculated based on:
- **Your stake**: Higher stake = higher rewards
- **Puzzle difficulty**: Harder puzzles may offer better percentages
- **Reward percentage**: Set per puzzle by the contract owner

**Formula:**
```
Reward = (Player's Total Stake × Puzzle Reward Percentage) / 100
```

**Example:**
- You staked: 10 STX
- Puzzle reward: 15%
- Your reward: 1.5 STX

---

## 🔒 Security Features

- **Hashed Answers**: Answers are stored as SHA256 hashes, making them unreadable
- **One-Time Solve**: Each player can only solve each puzzle once
- **Minimum Stake**: Requires at least 1 STX to play
- **Access Control**: Only owner can create puzzles and manage the contract
- **Yield Pool Protection**: Rewards limited to available pool balance

---

## 📊 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Function restricted to contract owner |
| u101 | `err-already-solved` | You've already solved this puzzle |
| u102 | `err-wrong-answer` | Incorrect answer submitted |
| u103 | `err-insufficient-stake` | Need to stake more STX to play |
| u104 | `err-no-yield` | Yield pool is empty |
| u105 | `err-puzzle-not-found` | Puzzle doesn't exist or is inactive |

---

## 🎯 Example Puzzle Topics

- DeFi concepts and terminology
- Interest calculations (simple vs compound)
- Risk management strategies
- Liquidity pool mechanics
- Staking and yield farming
- Token economics
- Smart contract basics
- Portfolio diversification

---

## 🛠️ Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Stacks wallet

### Testing
```bash
clarinet test
```

### Local Console
```bash
clarinet console
```

---

## 📝 Sample Puzzles

Here are some example puzzles to get started:

**Puzzle 1 (Easy):**
- Question: "What does APY stand for in DeFi?"
- Answer: "Annual Percentage Yield"
- Reward: 5%

**Puzzle 2 (Medium):**
- Question: "What is impermanent loss associated with?"
- Answer: "Liquidity Pools"
- Reward: 10%

**Puzzle 3 (Hard):**
- Question: "If you invest $1000 at 10% compound interest annually, what is your balance after 2 years?"
- Answer: "1210"
- Reward: 15%

---

## ⚠️ Important Notes

- Always double-check your answers (case-sensitive)
- Keep track of your staked amount
- Rewards depend on yield pool availability
- You cannot unstake once deposited (consider this in future versions)
- Contract owner has emergency withdrawal capabilities

---

## 🔮 Future Enhancements

- Unstaking mechanism with cooldown period
- Multiplayer leaderboards
- Time-limited puzzles with bonus rewards
- NFT badges for puzzle completion milestones
- Integration with other DeFi protocols
- Dynamic difficulty adjustment

---

## 📄 License

This smart contract is open source and available for educational purposes.

---

## 🤝 Contributing

Contributions are welcome! Please consider:
- Adding more educational puzzles
- Improving reward mechanisms
- Enhancing security features
- Building a frontend interface

---

## 📞 Support

For questions or issues:
- Review the error codes above
- Check your stake balance before solving puzzles
- Ensure answers match exactly (case-sensitive)

---

**Built with ❤️ on Stacks Blockchain**