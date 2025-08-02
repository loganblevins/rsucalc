# RSU Calculator

> ⚠️ **AI-Generated Code Disclaimer**: This project was largely written by AI (Claude) and contains significant amounts of AI-generated code and documentation. While functional and tested, much of the content may be considered "AI slop" - use at your own discretion and verify calculations independently for any financial decisions.

A comprehensive RSU (Restricted Stock Unit) calculator providing **three distinct applications** from a single codebase: CLI tool, macOS app, and iOS app. Calculate vesting scenarios and determine required sale prices to achieve target net income.

## 🚀 **Complete Multi-Platform Solution**

This project transformed from a CLI-only tool into a **complete ecosystem** with three separate applications:

1. **🔧 CLI Tool** - Command-line interface for power users and automation
2. **💻 macOS App** - Native desktop experience with SwiftUI
3. **📱 iOS App** - Mobile calculations on-the-go

All applications share the same proven calculation engine while providing the optimal interface for each use case.

## 📋 **Project Architecture**

```
rsucalc/                                 # 🏠 Project Root Directory
├── 🔧 Swift Package (CLI + Core Logic)
│   ├── Package.swift                   # Swift Package configuration
│   ├── Sources/RSUCalculatorCore/      # Shared business logic
│   │   └── RSUCalculator.swift
│   ├── Sources/rsucalc-cli/           # CLI executable  
│   │   └── main.swift
│   └── Tests/rsucalcTests/            # Comprehensive test suite
│       └── RSUCalculatorTests.swift
│
├── 🎯 Xcode Project (GUI Apps)
│   └── RSUCalculatorUnified.xcodeproj/ # Multi-platform GUI project
│
└── 📱 SwiftUI Source Code
    └── RSUCalculatorGUI/               # GUI components (separate from package)
        ├── Shared/                     # Cross-platform SwiftUI application
        │   ├── RSUCalculatorApp.swift  # App entry point
        │   ├── ContentView.swift      # Platform-adaptive main view
        │   ├── RSUCalculatorViewModel.swift # Observable state management
        │   ├── RSUInputView.swift     # Input form interface
        │   ├── RSUResultsView.swift   # Results display interface
        │   └── Assets.xcassets/       # App assets
        └── macOS/                     # Platform-specific resources
            └── RSU_Calculator_macOS.entitlements
```

### **🏗️ Clean Separation Benefits**

- **✅ DRY Principle**: Single calculation engine shared across all apps
- **✅ Build System Isolation**: Swift Package (CLI) and Xcode (GUI) are completely separate
- **✅ Clear Boundaries**: Package manages CLI/core, Xcode references GUI source externally  
- **✅ Independent Development**: Work on CLI without affecting GUI project structure
- **✅ Maintainability**: Core logic changes automatically benefit all apps

## 🚀 **Installation & Usage**

### **🔧 CLI Tool (Swift Package Manager)**

```bash
# Clone repository
git clone <repository-url>
cd rsucalc

# Quick development usage
swift run rsucalc-cli --help

# Build for production
swift build -c release
# Executable will be at: .build/release/rsucalc-cli
```

### **🎯 GUI Applications (Xcode)**

```bash
# Open the unified Xcode project
open RSUCalculatorUnified.xcodeproj
```

**In Xcode:**
- Select **"RSU Calculator (macOS)"** scheme → Run macOS app ⌘R
- Select **"RSU Calculator (iOS)"** scheme → Run iOS app ⌘R

## 📱 **How to Use Each Application**

### **🔧 CLI Tool - Terminal Usage**

**Quick Help:**
```bash
swift run rsucalc-cli --help
```

**Development Usage:**
```bash
swift run rsucalc-cli [OPTIONS]
```

**Production Usage:**
```bash
./.build/release/rsucalc-cli [OPTIONS]
```

### **💻 macOS App - Desktop Experience**

- **Side-by-side layout** for easy input and results viewing
- **Native macOS interface** with proper keyboard navigation
- **Real-time validation** and calculation updates
- **Copy/paste support** for easy data entry

### **📱 iOS App - Mobile Convenience**

- **Tabbed interface** optimized for mobile screens  
- **Touch-friendly controls** with large input areas
- **Automatic layout adaptation** for different screen sizes
- **On-the-go calculations** when away from your computer

### **🎯 Xcode Scheme Information**

When you open `RSUCalculatorUnified.xcodeproj`, you'll see several schemes:

#### **✅ Use These Schemes:**
- **`RSU Calculator (macOS)`** - Your macOS SwiftUI app
- **`RSU Calculator (iOS)`** - Your iOS SwiftUI app

#### **ℹ️ Auto-Generated (Usually Ignore):**
- **`rsucalc-cli`** - CLI scheme (not properly configured for Xcode)
- **`rsucalc-Package`** - Entire Swift Package build  
- **`RSUCalculatorCore`** - Core library only

**Recommendation:** Use the first two schemes for GUI development, and `swift run rsucalc-cli` in terminal for CLI usage.

### Required Options

- `--vcd-price, -v`: VCD (Vesting Commencement Date) price per share
- `--vesting-shares, -s`: Number of shares vesting
- `--vest-day-price, -p`: Share price on vest day
- `--medicare-rate, -m`: Medicare tax rate (as decimal, e.g., 0.0145 for 1.45%)
- `--social-security-rate, -o`: Social Security tax rate (as decimal, e.g., 0.062 for 6.2%)
- `--federal-rate, -r`: Federal tax rate (as decimal, e.g., 0.22 for 22%)
- `--salt-rate, -t`: SALT (State and Local Tax) rate (as decimal, e.g., 0.05 for 5%)
- `--shares-sold-for-taxes, -x`: Number of shares sold for tax withholding
- `--tax-sale-price, -a`: Price per share when sold for taxes

### Optional Flags

- `--include-capital-gains, -c`: Include short-term capital gains tax calculation (uses federal + SALT rates)
- `--include-net-investment-tax, -n`: Include 3.8% Net Investment Income Tax (NIIT) on capital gains for high-income earners

### Examples

**Development:**
```bash
swift run rsucalc-cli \
  --vcd-price 100.00 \
  --vesting-shares 100 \
  --vest-day-price 120.00 \
  --medicare-rate 0.0145 \
  --social-security-rate 0.062 \
  --federal-rate 0.22 \
  --salt-rate 0.05 \
  --shares-sold-for-taxes 25 \
  --tax-sale-price 120.00 \
  --include-capital-gains \
  --include-net-investment-tax
```

**Production:**
```bash
./.build/release/rsucalc-cli \
  --vcd-price 100.00 \
  --vesting-shares 100 \
  --vest-day-price 120.00 \
  --medicare-rate 0.0145 \
  --social-security-rate 0.062 \
  --federal-rate 0.22 \
  --salt-rate 0.05 \
  --shares-sold-for-taxes 25 \
  --tax-sale-price 120.00 \
  --include-capital-gains \
  --include-net-investment-tax
```

**Short options:**
```bash
swift run rsucalc-cli -v 100.00 -s 100 -p 120.00 -m 0.0145 -o 0.062 -r 0.22 -t 0.05 -x 25 -a 120.00 -c -n
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
- Calculation breakdown with individual tax components
- Tax sale proceeds and cash distribution
- Required sale price for remaining shares
- Capital gains analysis (when enabled)
- Comparison with vest day price (premium/discount analysis)

## Tax Rate Examples

Common tax rates (enter as decimals):

- **Medicare**: 1.45% = 0.0145
- **Social Security**: 6.2% = 0.062
- **Federal**: 22% = 0.22, 24% = 0.24, 32% = 0.32
- **SALT**: 5% = 0.05, 9.3% = 0.093
- **Capital Gains**: Uses your federal + SALT rates for short-term capital gains (marginal federal income tax rate + SALT rate)

### Capital Gains Tax

The calculator can account for short-term capital gains tax when the required sale price is higher than the vest day price. This is important because:

- **Cost basis**: Vest day price (not VCD price)
- **Capital gain**: Sale price - Vest day price
- **Tax rate**: Uses your marginal federal income tax rate + SALT rate
- **Tax impact**: Can significantly increase the required sale price

Use the `--include-capital-gains` flag when you expect to sell above the vest day price.

### Net Investment Income Tax (NIIT)

High-income earners may be subject to an additional 3.8% Net Investment Income Tax (NIIT) on capital gains. The calculator can include this tax:

- **When it applies**: Only when capital gains are present (sale price > vest day price)
- **Tax rate**: Additional 3.8% on top of federal + SALT capital gains rates
- **Total rate**: Federal rate + SALT rate + 3.8% NIIT
- **Example**: 22% federal + 5% SALT + 3.8% NIIT = 30.8% total capital gains rate

Use the `--include-net-investment-tax` flag along with `--include-capital-gains` for high-income earners.

## Use Cases

- **Planning**: Determine if you need to wait for a higher price to achieve your target net income
- **Decision Making**: Compare different vesting scenarios
- **Tax Planning**: Understand the impact of tax withholding on your net proceeds

## ✅ **Verification & Testing**

### **🧪 Running Tests**

The project includes **comprehensive unit tests**:

```bash
# Run all tests
swift test

# Run specific test
swift test --filter testRealWorldScenario

# Build and test together
swift build -c release && swift test
```

### **🎯 Test Coverage**

The test suite ensures calculation accuracy across:
- ✅ **Basic calculation scenarios** - Core RSU calculations
- ✅ **Real-world RSU scenarios** - 4 different case studies  
- ✅ **Edge cases** - Zero taxes, all shares sold, etc.
- ✅ **Large numbers** - Precision handling with big datasets
- ✅ **Input validation** - Detailed error messages
- ✅ **Mathematical consistency** - Cross-validation of calculations
- ✅ **Performance benchmarks** - Speed tests with large datasets
- ✅ **Capital gains tax** - Federal + SALT rate calculations
- ✅ **Capital gains edge cases** - No profit, losses, zero SALT
- ✅ **Net Investment Income Tax (NIIT)** - High-income scenarios
- ✅ **NIIT combinations** - Various tax rate scenarios

### **🚀 Build Verification**

Before using any application, verify everything works:

```bash
# Verify CLI builds and tests pass
swift build -c release
swift test

# Verify CLI works
swift run rsucalc-cli --help

# Verify macOS app builds (in Xcode)
# Select "RSU Calculator (macOS)" scheme → Product → Build (⌘B)
```

## 🏗️ **Technical Architecture**

### **🔧 Core Library (`RSUCalculatorCore`)**

**Platform-agnostic business logic shared across all applications:**

- **`RSUCalculator`** - Main calculation engine with all RSU logic
- **`RSUCalculationResult`** - Comprehensive result data structure  
- **Input validation** - Detailed error handling and validation
- **Currency precision** - Proper rounding and financial calculations

### **💻 CLI Application (`rsucalc-cli`)**

**Built with Swift ArgumentParser for robust command-line interface:**

- **Comprehensive CLI** - All features accessible via command-line flags
- **Detailed output** - Formatted results with clear breakdowns
- **Production ready** - Suitable for scripts and automation
- **Development friendly** - Quick iteration with `swift run`

### **📱 SwiftUI Applications (Unified Project)**

**Cross-platform SwiftUI with platform-adaptive design:**

- **`RSUCalculatorViewModel`** - Observable state management with `@StateObject`
- **`RSUInputView`** - Form-based input with real-time validation  
- **`RSUResultsView`** - Comprehensive results display
- **`ContentView`** - Platform-adaptive layout (HStack for macOS, TabView for iOS)
- **Shared codebase** - Single SwiftUI implementation for both platforms

## 🛠️ **Development Workflow**

### **🔧 CLI Development (Swift Package Manager)**

```bash
# Build CLI tool
swift build --product rsucalc-cli

# Run tests  
swift test

# Build for release
swift build -c release

# Quick development
swift run rsucalc-cli --help
```

### **📱 GUI Development (Xcode)**

```bash
# Open unified project
open RSUCalculatorUnified.xcodeproj

# In Xcode:
# - Select target scheme (macOS or iOS)
# - Build with ⌘B  
# - Run with ⌘R
# - Test with ⌘U
```

### **🔄 Integration into Other Projects**

To integrate this calculator into your own project:

1. **Add dependency**: Include `RSUCalculatorCore` as a Swift Package dependency
2. **Import**: `import RSUCalculatorCore`  
3. **Use calculator**: Create `RSUCalculator` instance for calculations
4. **Optional UI**: Copy SwiftUI views for ready-made interface

## 📋 **Requirements**

- **macOS 13.0+** (for macOS app)
- **iOS 16.0+** (for iOS app)  
- **Swift 5.9+** (for all components)
- **Xcode 15.0+** (for GUI development)

## 🎉 **Final Summary**

You now have a **complete RSU Calculator ecosystem**:

1. **🔧 CLI Tool** - `swift run rsucalc-cli` for power users and automation
2. **💻 macOS App** - Native desktop experience with full GUI  
3. **📱 iOS App** - Mobile calculations with touch-optimized interface

All three applications share the same proven calculation engine, ensuring consistency while providing the optimal interface for each use case. The modular architecture makes it easy to maintain and extend! 🚀 