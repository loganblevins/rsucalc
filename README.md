# RSU Calculator CLI

A command-line tool for calculating RSU (Restricted Stock Unit) vesting scenarios and determining required sale prices to achieve target net income.

## Overview

This tool helps you calculate what price you need to sell your remaining RSU shares at (after tax withholding shares are sold) to achieve the same net income you would have received if the vest day price equaled your VCD (Vesting Commencement Date) price.

## Installation

1. Clone this repository
2. Build the project:
   ```bash
   swift build -c release
   ```
3. The executable will be available at `.build/release/rsucalc`

## Usage

```bash
./rsucalc [OPTIONS]
```

### Required Options

- `--vcd-price, -v`: VCD (Vesting Commencement Date) price per share
- `--vesting-shares, -s`: Number of shares vesting
- `--vest-day-price, -p`: Share price on vest day
- `--fica-rate, -f`: FICA tax rate (as decimal, e.g., 0.0765 for 7.65%)
- `--federal-rate, -r`: Federal tax rate (as decimal, e.g., 0.22 for 22%)
- `--state-rate, -t`: State tax rate (as decimal, e.g., 0.05 for 5%)
- `--shares-sold-for-taxes, -x`: Number of shares sold for tax withholding
- `--tax-sale-price, -a`: Price per share when sold for taxes
- `--include-capital-gains, -c`: Include short-term capital gains tax calculation (uses federal tax rate)

### Example

```bash
./rsucalc \
  --vcd-price 100.00 \
  --vesting-shares 100 \
  --vest-day-price 120.00 \
  --fica-rate 0.0765 \
  --federal-rate 0.22 \
  --state-rate 0.05 \
  --shares-sold-for-taxes 25 \
  --tax-sale-price 120.00 \
  --include-capital-gains
```

Or using short options:

```bash
./rsucalc -v 100.00 -s 100 -p 120.00 -f 0.0765 -r 0.22 -t 0.05 -x 25 -a 120.00 -c
```

## How It Works

The calculator performs the following steps:

1. **Baseline Calculation**: Calculates what your net income would be if vest day price = VCD price
2. **Actual Scenario**: Calculates your actual gross income using the vest day price
3. **Tax Calculation**: Determines taxes based on the actual vest day price
4. **Tax Sale Impact**: Accounts for shares sold for tax withholding and their proceeds
5. **Required Price**: Calculates what price you need to sell remaining shares at to achieve your target net income

## Output

The tool provides detailed output including:

- Input parameters summary
- Calculation breakdown
- Required sale price for remaining shares
- Comparison with vest day price (premium/discount analysis)

## Tax Rate Examples

Common tax rates (enter as decimals):

- **FICA**: 7.65% = 0.0765
- **Federal**: 22% = 0.22, 24% = 0.24, 32% = 0.32
- **State**: 5% = 0.05, 9.3% = 0.093
- **Capital Gains**: Uses your federal + state tax rates (short-term capital gains are taxed at marginal federal income tax rate + state tax rate)

### Capital Gains Tax

The calculator can account for short-term capital gains tax when the required sale price is higher than the vest day price. This is important because:

- **Cost basis**: Vest day price (not VCD price)
- **Capital gain**: Sale price - Vest day price
- **Tax rate**: Uses your marginal federal income tax rate + state tax rate
- **Tax impact**: Can significantly increase the required sale price

Use the `--include-capital-gains` flag when you expect to sell above the vest day price.

## Use Cases

- **Planning**: Determine if you need to wait for a higher price to achieve your target net income
- **Decision Making**: Compare different vesting scenarios
- **Tax Planning**: Understand the impact of tax withholding on your net proceeds

## Testing

The project includes comprehensive unit tests to ensure calculation accuracy and handle edge cases.

### Running Tests

```bash
# Run all tests
swift test

# Run with verbose output
./run-tests.sh

# Run specific test
swift test --filter testRealWorldScenario
```

### Test Coverage

The test suite covers:
- ✅ Basic calculation scenarios
- ✅ Real-world RSU scenarios
- ✅ Edge cases (zero taxes, all shares sold, etc.)
- ✅ Large numbers and precision
- ✅ Input validation
- ✅ Mathematical consistency
- ✅ Performance with large datasets
- ✅ Capital gains tax calculations (federal + state rates)
- ✅ Capital gains edge cases (no profit, losses, zero state tax)
- ✅ Capital gains mathematical consistency

### Test Results

All tests should pass with 0 failures:
```
Test Suite 'RSUCalculatorTests' passed
Executed 27 tests, with 0 failures
```

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later 