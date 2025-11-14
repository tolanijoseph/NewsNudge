# NewsNudge 📰💰

A decentralized tipping platform for independent journalists and news creators built on the Stacks blockchain using Clarity smart contracts.

## Overview

NewsNudge enables supporters to directly tip independent journalists with STX tokens, creating a sustainable funding model for quality journalism. The platform removes intermediaries and ensures journalists receive their tips quickly and transparently.

## Features

### For Journalists
- **Easy Registration**: Sign up with your name and bio
- **Profile Management**: Update your information anytime
- **Direct Payments**: Receive tips directly to your wallet
- **Performance Tracking**: View total tips received and tip count
- **Transparent History**: All tips are recorded on-chain

### For Supporters
- **Simple Tipping**: Send STX tips with optional messages
- **Journalist Discovery**: Browse registered journalists and their profiles
- **Message Support**: Include a personal note with your tip (up to 140 characters)
- **Minimum Tip**: 0.1 STX minimum ensures meaningful support

### Platform
- **Low Fees**: Only 5% platform fee (configurable)
- **Transparent**: All transactions recorded on blockchain
- **Secure**: Built with Clarity's safety guarantees
- **Immutable**: Tip history preserved permanently

## Smart Contract Functions

### Public Functions

#### `register-journalist`
Register as a journalist on the platform.

```clarity
(register-journalist "John Doe" u"Investigative journalist covering tech and policy")
```

**Parameters:**
- `name` (string-ascii 50): Your display name
- `bio` (string-utf8 200): Brief description of your work

**Returns:** `(ok true)` on success

---

#### `update-profile`
Update your journalist profile information.

```clarity
(update-profile "Jane Smith" u"Award-winning reporter focusing on climate change")
```

**Parameters:**
- `name` (string-ascii 50): Updated display name
- `bio` (string-utf8 200): Updated bio

**Returns:** `(ok true)` on success

---

#### `send-tip`
Send a tip to a registered journalist.

```clarity
(send-tip 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u500000 u"Great article!")
```

**Parameters:**
- `journalist` (principal): The journalist's wallet address
- `amount` (uint): Tip amount in microSTX (1 STX = 1,000,000 microSTX)
- `message` (string-utf8 140): Optional message to the journalist

**Returns:** `(ok tip-id)` - The unique ID of the tip

**Minimum Amount:** 0.1 STX (100,000 microSTX)

---

#### `set-platform-fee`
*Admin only* - Update the platform fee percentage.

```clarity
(set-platform-fee u3)
```

**Parameters:**
- `new-fee` (uint): New fee percentage (max 20%)

**Returns:** `(ok true)` on success

---

### Read-Only Functions

#### `get-journalist`
Get profile information for a journalist.

```clarity
(get-journalist 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Returns:** Journalist profile or `none`

---

#### `get-tip`
Get details of a specific tip.

```clarity
(get-tip u0)
```

**Returns:** Tip details or `none`

---

#### `is-journalist`
Check if an address is a registered journalist.

```clarity
(is-journalist 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Returns:** `true` or `false`

---

#### `get-platform-fee-percentage`
Get the current platform fee percentage.

```clarity
(get-platform-fee-percentage)
```

**Returns:** Fee percentage (default: 5)

---

#### `calculate-fee`
Calculate the platform fee for a given amount.

```clarity
(calculate-fee u1000000)
```

**Returns:** Fee amount in microSTX

---

#### `get-tip-count`
Get the total number of tips sent on the platform.

```clarity
(get-tip-count)
```

**Returns:** Total tip count

---

## Data Structures

### Journalist Profile
```clarity
{
  name: (string-ascii 50),
  bio: (string-utf8 200),
  total-tips-received: uint,
  tip-count: uint,
  registered-at: uint
}
```

### Tip Record
```clarity
{
  from: principal,
  to: principal,
  amount: uint,
  message: (string-utf8 140),
  timestamp: uint
}
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-not-journalist` | User is not a registered journalist |
| u101 | `err-already-registered` | Journalist already registered |
| u102 | `err-invalid-amount` | Invalid tip amount (below minimum) |
| u103 | `err-not-authorized` | User not authorized for this action |
| u104 | `err-transfer-failed` | STX transfer failed |
| u105 | `err-journalist-not-found` | Journalist not found in registry |

## Deployment

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet with STX for deployment

### Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd newsnudge
```

2. **Test the contract**
```bash
clarinet test
```

3. **Deploy to testnet**
```bash
clarinet deploy --testnet
```

4. **Deploy to mainnet**
```bash
clarinet deploy --mainnet
```

## Usage Examples

### Example 1: Journalist Registration
```clarity
;; Register as a journalist
(contract-call? .NewsNudge register-journalist 
  "Sarah Johnson" 
  u"Investigative journalist covering environmental issues")
```

### Example 2: Sending a Tip
```clarity
;; Send 1 STX tip with a message
(contract-call? .NewsNudge send-tip 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  u1000000 
  u"Excellent reporting on the water crisis!")
```

### Example 3: Checking Journalist Stats
```clarity
;; Get journalist profile
(contract-call? .NewsNudge get-journalist 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Returns:
;; (some {
;;   name: "Sarah Johnson",
;;   bio: u"Investigative journalist covering environmental issues",
;;   total-tips-received: u5000000,
;;   tip-count: u12,
;;   registered-at: u10500
;; })
```

## Fee Structure

- **Platform Fee:** 5% (default, configurable by contract owner)
- **Minimum Tip:** 0.1 STX
- **Maximum Fee:** 20% (hard cap)

### Example Fee Calculation
For a 1 STX tip:
- Gross Amount: 1.0 STX
- Platform Fee (5%): 0.05 STX
- Journalist Receives: 0.95 STX

## Security Considerations

✅ **Implemented Safeguards:**
- Duplicate registration prevention
- Minimum tip amount enforcement
- Owner-only admin functions
- Maximum fee cap (20%)
- Transfer failure handling
- Input validation

⚠️ **Best Practices:**
- Always verify journalist address before sending tips
- Start with small test transactions
- Keep your private keys secure
- Verify contract address before interacting

## Roadmap

- [ ] Multi-currency support (other tokens)
- [ ] Subscription-based recurring tips
- [ ] Journalist verification system
- [ ] Tip matching campaigns
- [ ] Analytics dashboard
- [ ] Mobile app integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This smart contract is provided as-is. Users should conduct their own security audits before deploying to mainnet with real funds. The developers are not responsible for any losses incurred through the use of this contract.