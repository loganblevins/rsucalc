import Foundation
import ArgumentParser

struct RSURunner: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rsucalc",
        abstract: "Calculate RSU vesting scenarios and required sale prices",
        version: "1.0.0"
    )
    
    @Option(name: [.customShort("v"), .customLong("vcd-price")], help: "VCD (Vesting Commencement Date) price per share")
    var vcdPrice: Double
    
    @Option(name: [.customShort("s"), .customLong("vesting-shares")], help: "Number of shares vesting")
    var vestingShares: Int
    
    @Option(name: [.customShort("p"), .customLong("vest-day-price")], help: "Share price on vest day")
    var vestDayPrice: Double
    
    @Option(name: [.customShort("m"), .customLong("medicare-rate")], help: "Medicare tax rate (as decimal, e.g., 0.0145 for 1.45%)")
    var medicareRate: Double
    
    @Option(name: [.customShort("s"), .customLong("social-security-rate")], help: "Social Security tax rate (as decimal, e.g., 0.062 for 6.2%)")
    var socialSecurityRate: Double
    
    @Option(name: [.customShort("r"), .customLong("federal-rate")], help: "Federal tax rate (as decimal, e.g., 0.22 for 22%)")
    var federalRate: Double
    
    @Option(name: [.customShort("t"), .customLong("salt-rate")], help: "SALT (State and Local Tax) rate (as decimal, e.g., 0.05 for 5%)")
    var saltRate: Double
    
    @Option(name: [.customShort("x"), .customLong("shares-sold-for-taxes")], help: "Number of shares sold for tax withholding")
    var sharesSoldForTaxes: Int
    
    @Option(name: [.customShort("a"), .customLong("tax-sale-price")], help: "Price per share when sold for taxes")
    var taxSalePrice: Double
    
    @Flag(name: [.customShort("c"), .customLong("include-capital-gains")], help: "Include short-term capital gains tax calculation (uses federal tax rate)")
    var includeCapitalGains: Bool = false
        
    @Flag(name: [.customShort("n"), .customLong("include-net-investment-tax")], help: "Include 3.8% Net Investment Income Tax (NIIT) on capital gains for high-income earners")
    var includeNetInvestmentTax: Bool = false
    
    mutating func run() throws {
        let calculator = RSUCalculator()
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: vcdPrice,
            vestingShares: vestingShares,
            vestDayPrice: vestDayPrice,
            medicareRate: medicareRate,
            socialSecurityRate: socialSecurityRate,
            federalRate: federalRate,
            saltRate: saltRate,
            sharesSoldForTaxes: sharesSoldForTaxes,
            taxSalePrice: taxSalePrice,
            includeCapitalGains: includeCapitalGains,
            includeNetInvestmentTax: includeNetInvestmentTax
        )
        
        print("\n📊 RSU Calculator Results")
        print(String(repeating: "=", count: 50))
        
        print("\n📈 Input Parameters:")
        print("   VCD Price: $\(String(format: "%.2f", vcdPrice))")
        print("   Vesting Shares: \(vestingShares)")
        print("   Vest Day Price: $\(String(format: "%.2f", vestDayPrice))")
        print("   Medicare Rate: \(String(format: "%.1f", medicareRate * 100))%")
        print("   Social Security Rate: \(String(format: "%.1f", socialSecurityRate * 100))%")
        print("   Federal Rate: \(String(format: "%.1f", federalRate * 100))%")
        print("   SALT Rate: \(String(format: "%.1f", saltRate * 100))%")
        print("   Shares Sold for Taxes: \(sharesSoldForTaxes)")
        print("   Tax Sale Price: $\(String(format: "%.2f", taxSalePrice))")
        
        print("\n💰 Calculation Breakdown:")
        print("   Gross Income (VCD Price): $\(String(format: "%.2f", result.grossIncomeVCD))")
        print("   Gross Income (Vest Day): $\(String(format: "%.2f", result.grossIncomeVestDay))")
        print("   Total Tax Rate: \(String(format: "%.1f", result.totalTaxRate * 100))%")
        print("   Tax Amount: $\(String(format: "%.2f", result.taxAmount))")
        print("   📊 Individual Tax Components:")
        print("      Federal Tax (22%): $\(String(format: "%.2f", round(result.grossIncomeVestDay * federalRate * 100) / 100))")
        print("      Social Security Tax (6.2%): $\(String(format: "%.2f", round(result.grossIncomeVestDay * socialSecurityRate * 100) / 100))")
        print("      Medicare Tax (1.45%): $\(String(format: "%.2f", round(result.grossIncomeVestDay * medicareRate * 100) / 100))")
        print("      SALT Tax (\(String(format: "%.1f", saltRate * 100))%): $\(String(format: "%.2f", round(result.grossIncomeVestDay * saltRate * 100) / 100))")
        print("   Tax Sale Proceeds: $\(String(format: "%.2f", result.taxSaleProceeds))")
        print("   💰 Cash Distribution Received: $\(String(format: "%.2f", result.taxSaleProceeds - result.taxAmount))")
        print("   Net Income Target (Original): $\(String(format: "%.2f", result.grossIncomeVCD - (result.grossIncomeVCD * result.totalTaxRate)))")
        print("   Net Income Target (Adjusted): $\(String(format: "%.2f", result.netIncomeTarget))")
        print("   Shares After Tax Sale: \(result.sharesAfterTaxSale)")
        
        if includeCapitalGains {
            print("   📊 Capital Gains Analysis:")
            if let capitalGainsTax = result.capitalGainsTax {
                print("   ✅ Capital gains tax applied (sale price > vest day price)")
                print("   💰 Capital Gains Tax: $\(String(format: "%.2f", capitalGainsTax))")
                
                // Calculate what the required sale price would be without capital gains
                let withoutCapGainsPrice = result.netIncomeTarget / Double(result.sharesAfterTaxSale)
                print("   📈 Required sale price WITH capital gains: $\(String(format: "%.2f", result.requiredSalePrice))")
                print("   📉 Required sale price WITHOUT capital gains: $\(String(format: "%.2f", withoutCapGainsPrice))")
                print("   💸 Capital gains impact: +$\(String(format: "%.2f", result.requiredSalePrice - withoutCapGainsPrice)) per share")
            } else {
                print("   ⚠️  Capital gains tax ignored (required sale price ≤ vest day price)")
                print("   📊 No profit to tax - selling at or below cost basis")
            }
        }
        
        print("\n🎯 Required Sale Price:")
        print("   To achieve your target net income of $\(String(format: "%.2f", result.netIncomeTarget))")
        print("   You need to sell your remaining \(result.sharesAfterTaxSale) shares at:")
        print("   💵 $\(String(format: "%.2f", result.requiredSalePrice)) per share")
        
        print("\n📋 Summary:")
        if result.requiredSalePrice > vestDayPrice {
            print("   ⬆️  You need a higher sale price than vest day price")
            print("   📈 Required premium: $\(String(format: "%.2f", result.requiredSalePrice - vestDayPrice)) per share")
        } else if result.requiredSalePrice < vestDayPrice {
            print("   ⬇️  You can sell below vest day price and still meet your target")
            print("   📉 Acceptable discount: $\(String(format: "%.2f", vestDayPrice - result.requiredSalePrice)) per share")
        } else {
            print("   ✅ Required sale price equals vest day price")
        }
        
        print("\n" + String(repeating: "=", count: 50))
    }
}

RSURunner.main()
