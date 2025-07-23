# CharityLink - Next-Generation Transparent Donation Platform

## Overview

CharityLink is a revolutionary blockchain infrastructure that transforms charitable giving through automated transparency, real-time impact tracking, and community-driven accountability mechanisms. Built on the Stacks blockchain, it eliminates traditional charity opacity by creating an immutable ecosystem where every donation creates verifiable impact.

## Key Features

- **🔒 Automated Transparency**: Immutable donation records with complete audit trails
- **📊 Real-time Impact Tracking**: Milestone-based fund utilization monitoring
- **👥 Multi-tier Access Control**: Role-based permissions (Admin, Moderator, Beneficiary)
- **💰 Secure Fund Management**: STX-based donations with automatic allocation
- **🎯 Dynamic Milestone Validation**: Community-driven accountability for fund usage
- **🏛️ Governance Framework**: Multi-signature governance for critical decisions

## System Architecture

### Contract Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CharityLink Contract                     │
├─────────────────────────────────────────────────────────────┤
│  Access Control Layer                                      │
│  ├── Role Management (Admin, Moderator, Beneficiary)       │
│  └── Permission Validation                                 │
├─────────────────────────────────────────────────────────────┤
│  Core Modules                                              │
│  ├── Beneficiary Registry                                  │
│  ├── Donation Processing                                   │
│  └── Fund Utilization Oversight                           │
├─────────────────────────────────────────────────────────────┤
│  Data Storage                                              │
│  ├── Beneficiaries Map                                     │
│  ├── Donations Ledger                                      │
│  ├── Utilization Tracking                                  │
│  └── Role Assignments                                      │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Donors    │───▶│  Donations   │───▶│  Beneficiaries  │
└─────────────┘    └──────────────┘    └─────────────────┘
       │                   │                     │
       │                   ▼                     ▼
       │           ┌──────────────┐    ┌─────────────────┐
       │           │ Audit Trail  │    │   Utilization   │
       │           │   (Immutable)│    │   Milestones    │
       │           └──────────────┘    └─────────────────┘
       │                                        │
       │                                        ▼
       │                                ┌─────────────────┐
       └───────────────────────────────▶│   Impact        │
                                        │   Tracking      │
                                        └─────────────────┘
```

## Contract Modules

### 1. Access Control Management

- **Role-based permissions**: Three-tier system (Admin, Moderator, Beneficiary)
- **Owner privileges**: Contract deployment and critical operations
- **Security features**: Prevent privilege escalation and self-lockout

### 2. Beneficiary Registry

- **Registration system**: Moderator-level access required
- **Profile management**: Name, description, target amounts
- **Status tracking**: Active/inactive beneficiary states
- **Funding metrics**: Real-time donation tracking

### 3. Donation Processing

- **Secure transfers**: STX-based donations with validation
- **Automatic allocation**: Funds directly assigned to beneficiaries
- **Immutable records**: Complete transaction history
- **Timestamp tracking**: Block-height based audit trail

### 4. Fund Utilization Oversight

- **Milestone system**: Structured fund deployment tracking
- **Admin approval**: Required for fund utilization
- **Balance verification**: Ensure sufficient funds before approval
- **Status management**: Pending/approved utilization states

## Technical Specifications

### Smart Contract Details

- **Language**: Clarity (Stacks blockchain)
- **Clarity Version**: 3
- **Epoch**: 3.1
- **Network**: Stacks Mainnet/Testnet compatible

### Data Structures

#### Beneficiaries

```clarity
{
  name: (string-utf8 50),
  description: (string-utf8 255),
  target-amount: uint,
  received-amount: uint,
  status: (string-ascii 20)
}
```

#### Donations

```clarity
{
  donor: principal,
  beneficiary-id: uint,
  amount: uint,
  timestamp: uint
}
```

#### Utilization

```clarity
{
  beneficiary-id: uint,
  milestone: uint,
  description: (string-utf8 255),
  amount: uint,
  status: (string-ascii 20)
}
```

## Error Codes

| Code | Description |
|------|-------------|
| 100  | Not Authorized |
| 101  | Already Registered |
| 102  | Not Found |
| 103  | Insufficient Funds |
| 104  | Beneficiary Not Found |
| 105  | Utilization Not Found |
| 106  | Invalid Input |

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Node.js](https://nodejs.org/) (v16 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/fatima-idowu/charity-link.git
cd charity-link
```

2. Install dependencies:

```bash
npm install
```

3. Run tests:

```bash
npm test
```

4. Check contract syntax:

```bash
clarinet check
```

### Development Commands

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for continuous testing
npm run test:watch

# Check contract validity
clarinet check

# Start local devnet
clarinet integrate
```

## Usage Examples

### Registering a Beneficiary

```clarity
(contract-call? .charity-link register-beneficiary 
  u"Local Food Bank" 
  u"Providing meals for families in need" 
  u1000000) ;; 1 STX target
```

### Making a Donation

```clarity
(contract-call? .charity-link donate u1 u100000) ;; 0.1 STX to beneficiary ID 1
```

### Adding Fund Utilization

```clarity
(contract-call? .charity-link add-utilization 
  u1 
  u"Purchase food supplies for December" 
  u50000) ;; 0.05 STX utilization
```

### Approving Utilization

```clarity
(contract-call? .charity-link approve-utilization u1 u1) ;; Approve milestone 1 for beneficiary 1
```

## API Reference

### Public Functions

#### Access Control

- `set-role(user, role)` - Assign role to user (owner only)
- `remove-role(user)` - Revoke user permissions (owner only)

#### Beneficiary Management

- `register-beneficiary(name, description, target-amount)` - Register new beneficiary
- `get-beneficiary(id)` - Retrieve beneficiary details

#### Donation Processing

- `donate(beneficiary-id, amount)` - Process donation
- `get-donation-by-id(donation-id)` - Get donation details
- `get-donation-count()` - Get total donations

#### Fund Utilization

- `add-utilization(beneficiary-id, description, amount)` - Create utilization milestone
- `approve-utilization(beneficiary-id, milestone)` - Approve fund usage
- `get-utilization-by-id(utilization-id)` - Get utilization details
- `get-utilization-count()` - Get total utilizations

## Security Features

### Access Control

- **Role-based permissions**: Hierarchical access system
- **Owner protection**: Prevent privilege escalation and self-lockout
- **Input validation**: Comprehensive parameter checking

### Fund Security

- **Balance verification**: Ensure sufficient funds before operations
- **Immutable records**: Tamper-proof transaction history
- **Atomic operations**: All-or-nothing transaction processing

### Data Integrity

- **Type safety**: Clarity's built-in type system
- **Overflow protection**: Safe arithmetic operations
- **Validation checks**: Input sanitization and bounds checking

## Testing

The project includes comprehensive test coverage using Vitest and the Clarinet SDK:

```bash
# Run all tests
npm test

# Generate coverage report
npm run test:report

# Watch for changes
npm run test:watch
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## Roadmap

- [ ] Multi-signature wallet integration
- [ ] Enhanced reporting dashboard
- [ ] Mobile application development
- [ ] Integration with external charity verification systems
- [ ] Advanced analytics and impact metrics
- [ ] Cross-chain compatibility
