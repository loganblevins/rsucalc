import Foundation
import ArgumentParser
import RSUCalculatorCore

struct DecimalArgument: ExpressibleByArgument {
    let value: Decimal
    
    init?(argument: String) {
        guard let decimal = Decimal(string: argument) else {
            return nil
        }
        self.value = decimal
    }
}

struct RSURunner: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rsucalc",
        abstract: "Calculate RSU vesting scenarios and required sale prices",
        version: "1.0.0"
    )
    
    /// Convert Decimal to formatted percentage string
    private func formatAsPercentage(_ value: Decimal) -> String {
        return String(format: "%.2f", NSDecimalNumber(decimal: value).doubleValue * 100)
    }
    
    /// Convert Decimal to formatted currency string with commas
    private func formatAsCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        
        let number = NSDecimalNumber(decimal: value)
        return formatter.string(from: number) ?? String(format: "%.2f", number.doubleValue)
    }
    
    @Option(name: [.customShort("v"), .customLong("vcd-price")], help: "VCD (Vesting Commencement Date) price per share")
    var vcdPrice: DecimalArgument
    
    @Option(name: [.customShort("s"), .customLong("vesting-shares")], help: "Number of shares vesting")
    var vestingShares: Int
    
    @Option(name: [.customShort("p"), .customLong("vest-day-price")], help: "Share price on vest day")
    var vestDayPrice: DecimalArgument
    
    @Option(name: [.customShort("m"), .customLong("medicare-rate")], help: "Medicare tax rate (as decimal, e.g., 0.0145 for 1.45%)")
    var medicareRate: DecimalArgument
    
    @Option(name: [.customShort("o"), .customLong("social-security-rate")], help: "Social Security tax rate (as decimal, e.g., 0.062 for 6.2%)")
    var socialSecurityRate: DecimalArgument
    
    @Option(name: [.customShort("r"), .customLong("federal-rate")], help: "Federal tax rate (as decimal, e.g., 0.22 for 22%)")
    var federalRate: DecimalArgument
    
    @Option(name: [.customShort("t"), .customLong("salt-rate")], help: "SALT (State and Local Tax) rate (as decimal, e.g., 0.05 for 5%)")
    var saltRate: DecimalArgument
    
    @Option(name: [.customShort("x"), .customLong("shares-sold-for-taxes")], help: "Number of shares sold for tax withholding")
    var sharesSoldForTaxes: Int
    
    @Option(name: [.customShort("a"), .customLong("tax-sale-price")], help: "Price per share when sold for taxes")
    var taxSalePrice: DecimalArgument
    
    @Flag(name: [.customShort("c"), .customLong("include-capital-gains")], help: "Include short-term capital gains tax calculation (uses federal + SALT rates)")
    var includeCapitalGains: Bool = false
        
    @Flag(name: [.customShort("n"), .customLong("include-net-investment-tax")], help: "Include 3.8% Net Investment Income Tax (NIIT) on capital gains for high-income earners")
    var includeNetInvestmentTax: Bool = false
    
    mutating func run() throws {
        let calculator = RSUCalculator()
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: vcdPrice.value,
            vestingShares: vestingShares,
            vestDayPrice: vestDayPrice.value,
            medicareRate: medicareRate.value,
            socialSecurityRate: socialSecurityRate.value,
            federalRate: federalRate.value,
            saltRate: saltRate.value,
            sharesSoldForTaxes: sharesSoldForTaxes,
            taxSalePrice: taxSalePrice.value,
            includeCapitalGains: includeCapitalGains,
            includeNetInvestmentTax: includeNetInvestmentTax
        )
        
        print("\n" + String(repeating: "=", count: 60))
        print("📊 RSU CALCULATOR RESULTS")
        print(String(repeating: "=", count: 60))
        
        // Section 1: Input Summary
        print("\n📋 INPUT SUMMARY")
        print(String(repeating: "-", count: 30))
        print("💰 Shares & Prices:")
        print("   • Vesting Shares: \(vestingShares)")
        print("   • VCD Price: $\(formatAsCurrency(result.vcdPrice))")
        print("   • Vest Day Price: $\(formatAsCurrency(result.vestDayPrice))")
        print("   • Tax Sale Price: $\(formatAsCurrency(result.taxSalePrice))")
        print("   • Shares Sold for Taxes: \(sharesSoldForTaxes)")
        
        print("\n📊 Tax Rates:")
        print("   • Federal: \(formatAsPercentage(federalRate.value))%")
        print("   • Social Security: \(formatAsPercentage(socialSecurityRate.value))%")
        print("   • Medicare: \(formatAsPercentage(medicareRate.value))%")
        print("   • SALT: \(formatAsPercentage(saltRate.value))%")
        print("   • Total: \(formatAsPercentage(result.totalTaxRate))%")
        
        // Section 2: Financial Breakdown
        print("\n💰 FINANCIAL BREAKDOWN")
        print(String(repeating: "-", count: 30))
        print("📈 Gross Income:")
        print("   • At VCD Price: $\(formatAsCurrency(result.grossIncomeVCD))")
        print("   • At Vest Price: $\(formatAsCurrency(result.grossIncomeVestDay))")
        
        print("\n🏦 Tax Breakdown:")
        print("   • Federal Tax: $\(formatAsCurrency(result.federalTax))")
        print("   • Social Security: $\(formatAsCurrency(result.socialSecurityTax))")
        print("   • Medicare Tax: $\(formatAsCurrency(result.medicareTax))")
        print("   • SALT Tax: $\(formatAsCurrency(result.saltTax))")
        print("   • TOTAL TAXES: $\(formatAsCurrency(result.taxAmount))")
        
        print("\n💸 Share Sale for Taxes:")
        print("   • Tax Sale Proceeds: $\(formatAsCurrency(result.taxSaleProceeds))")
        print("   • Cash Distribution: $\(formatAsCurrency(result.cashDistribution))")
        print("   • Remaining Shares: \(result.sharesAfterTaxSale)")
        
        print("\n🎯 Net Income Targets:")
        print("   • Original Target: $\(formatAsCurrency(result.originalNetIncomeTarget))")
        print("   • Adjusted Target: $\(formatAsCurrency(result.netIncomeTarget))")
        
        // Section 3: Price Analysis
        print("\n📊 PRICE ANALYSIS")
        print(String(repeating: "-", count: 30))
        
        if includeCapitalGains {
            if let capitalGainsTax = result.capitalGainsTax {
                print("✅ Capital gains tax applies (selling above vest price)")
                print("💰 Capital Gains Tax: $\(formatAsCurrency(capitalGainsTax))")
                
                if let niitTax = result.niitTax {
                    print("🏛️  NIIT (3.8%): $\(formatAsCurrency(niitTax))")
                    print("📊 Total Capital Gains + NIIT: $\(formatAsCurrency(capitalGainsTax + niitTax))")
                }
                
                // Calculate price scenario without capital gains for comparison
                let withoutCapGainsPrice = result.netIncomeTarget / Decimal(result.sharesAfterTaxSale)
                
                if includeNetInvestmentTax {
                    // Calculate WITH capital gains but WITHOUT NIIT
                    let resultWithoutNIIT = calculator.calculateRequiredSalePrice(
                        vcdPrice: vcdPrice.value,
                        vestingShares: vestingShares,
                        vestDayPrice: vestDayPrice.value,
                        medicareRate: medicareRate.value,
                        socialSecurityRate: socialSecurityRate.value,
                        federalRate: federalRate.value,
                        saltRate: saltRate.value,
                        sharesSoldForTaxes: sharesSoldForTaxes,
                        taxSalePrice: taxSalePrice.value,
                        includeCapitalGains: true,
                        includeNetInvestmentTax: false
                    )
                    
                    print("\n📈 PRICE SCENARIOS:")
                    print("   1️⃣  No Capital Gains: $\(formatAsCurrency(withoutCapGainsPrice))")
                    print("   2️⃣  + Capital Gains: $\(formatAsCurrency(resultWithoutNIIT.requiredSalePrice))")
                    print("   3️⃣  + Cap Gains + NIIT: $\(formatAsCurrency(result.requiredSalePrice))")
                    
                    print("\n💸 IMPACT ANALYSIS:")
                    print("   • Capital Gains: +$\(formatAsCurrency(resultWithoutNIIT.requiredSalePrice - withoutCapGainsPrice))/share")
                    print("   • NIIT (3.8%): +$\(formatAsCurrency(result.requiredSalePrice - resultWithoutNIIT.requiredSalePrice))/share")
                    print("   • TOTAL IMPACT: +$\(formatAsCurrency(result.requiredSalePrice - withoutCapGainsPrice))/share")
                } else {
                    print("\n📈 PRICE SCENARIOS:")
                    print("   1️⃣  No Capital Gains: $\(formatAsCurrency(withoutCapGainsPrice))")
                    print("   2️⃣  + Capital Gains: $\(formatAsCurrency(result.requiredSalePrice))")
                    
                    print("\n💸 IMPACT ANALYSIS:")
                    print("   • Capital Gains: +$\(formatAsCurrency(result.requiredSalePrice - withoutCapGainsPrice))/share")
                }
            } else {
                print("⚠️  No capital gains tax (selling at/below vest price)")
            }
        }
        
        // Section 4: Final Result
        print("\n🎯 FINAL RESULT")
        print(String(repeating: "-", count: 30))
        print("Target Net Income: $\(formatAsCurrency(result.netIncomeTarget))")
        print("Remaining Shares: \(result.sharesAfterTaxSale)")
        print("")
        print("💵 REQUIRED SALE PRICE: $\(formatAsCurrency(result.requiredSalePrice))")
        
        print("\n📋 RECOMMENDATION:")
        if result.requiredSalePrice > result.vestDayPrice {
            let premium = result.requiredSalePrice - result.vestDayPrice
            print("⬆️  WAIT for higher price (+$\(formatAsCurrency(premium))/share premium needed)")
        } else if result.requiredSalePrice < result.vestDayPrice {
            let discount = result.vestDayPrice - result.requiredSalePrice
            print("✅ SELL NOW (can accept up to $\(formatAsCurrency(discount))/share discount)")
        } else {
            print("✅ SELL at vest day price (perfect match)")
        }
        
        print("\n" + String(repeating: "=", count: 60))
    }
}

RSURunner.main()