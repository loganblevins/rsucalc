import Foundation
import ArgumentParser

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
    
    /// Convert Decimal to formatted currency string
    private func formatAsCurrency(_ value: Decimal) -> String {
        return String(format: "%.2f", NSDecimalNumber(decimal: value).doubleValue)
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
    
    @Flag(name: [.customShort("c"), .customLong("include-capital-gains")], help: "Include short-term capital gains tax calculation (uses federal tax rate)")
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
        
        print("\n📊 RSU Calculator Results")
        print(String(repeating: "=", count: 50))
        
        print("\n📈 Input Parameters:")
        print("   VCD Price: $\(formatAsCurrency(result.vcdPrice))")
        print("   Vesting Shares: \(vestingShares)")
        print("   Vest Day Price: $\(formatAsCurrency(result.vestDayPrice))")
        print("   Medicare Rate: \(formatAsPercentage(medicareRate.value))%")
        print("   Social Security Rate: \(formatAsPercentage(socialSecurityRate.value))%")
        print("   Federal Rate: \(formatAsPercentage(federalRate.value))%")
        print("   SALT Rate: \(formatAsPercentage(saltRate.value))%")
        print("   Shares Sold for Taxes: \(sharesSoldForTaxes)")
        print("   Tax Sale Price: $\(formatAsCurrency(result.taxSalePrice))")
        
        print("\n💰 Calculation Breakdown:")
        print("   Gross Income (VCD Price): $\(result.grossIncomeVCD)")
        print("   Gross Income (Vest Day): $\(result.grossIncomeVestDay)")
        print("   Total Tax Rate: \(formatAsPercentage(result.totalTaxRate))%")
        print("   Tax Amount: $\(result.taxAmount)")
        print("   📊 Individual Tax Components:")
        print("      Federal Tax: $\(result.federalTax)")
        print("      Social Security Tax: $\(result.socialSecurityTax)")
        print("      Medicare Tax: $\(result.medicareTax)")
        print("      SALT Tax: $\(result.saltTax)")
        print("   Tax Sale Proceeds: $\(result.taxSaleProceeds)")
        print("   💰 Cash Distribution Received: $\(result.cashDistribution)")
        print("   Net Income Target (Original): $\(result.originalNetIncomeTarget)")
        print("   Net Income Target (Adjusted): $\(result.netIncomeTarget)")
        print("   Shares After Tax Sale: \(result.sharesAfterTaxSale)")
        
        if includeCapitalGains {
            print("   📊 Capital Gains Analysis:")
            if let capitalGainsTax = result.capitalGainsTax {
                print("   ✅ Capital gains tax applied (sale price > vest day price)")
                print("   💰 Capital Gains Tax: $\(capitalGainsTax)")
                
                // Calculate what the required sale price would be without capital gains
                let withoutCapGainsPrice = result.netIncomeTarget / Decimal(result.sharesAfterTaxSale)
                print("   📈 Required sale price WITH capital gains: $\(result.requiredSalePrice)")
                print("   📉 Required sale price WITHOUT capital gains: $\(formatAsCurrency(withoutCapGainsPrice))")
                print("   💸 Capital gains impact: +$\(formatAsCurrency(result.requiredSalePrice - withoutCapGainsPrice)) per share")
            } else {
                print("   ⚠️  Capital gains tax ignored (required sale price ≤ vest day price)")
                print("   📊 No profit to tax - selling at or below cost basis")
            }
        }
        
        print("\n🎯 Required Sale Price:")
        print("   To achieve your target net income of $\(result.netIncomeTarget)")
        print("   You need to sell your remaining \(result.sharesAfterTaxSale) shares at:")
        print("   💵 $\(result.requiredSalePrice) per share")
        
        print("\n📋 Summary:")
        if result.requiredSalePrice > result.vestDayPrice {
            print("   ⬆️  You need a higher sale price than vest day price")
            print("   📈 Required premium: $\(formatAsCurrency(result.requiredSalePrice - result.vestDayPrice)) per share")
        } else if result.requiredSalePrice < result.vestDayPrice {
            print("   ⬇️  You can sell below vest day price and still meet your target")
            print("   📉 Acceptable discount: $\(formatAsCurrency(result.vestDayPrice - result.requiredSalePrice)) per share")
        } else {
            print("   ✅ Required sale price equals vest day price")
        }
        
        print("\n" + String(repeating: "=", count: 50))
    }
}

RSURunner.main()
