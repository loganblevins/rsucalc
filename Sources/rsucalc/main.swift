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
    
    @Option(name: [.customShort("f"), .customLong("fica-rate")], help: "FICA tax rate (as decimal, e.g., 0.0765 for 7.65%)")
    var ficaRate: Double
    
    @Option(name: [.customShort("r"), .customLong("federal-rate")], help: "Federal tax rate (as decimal, e.g., 0.22 for 22%)")
    var federalRate: Double
    
    @Option(name: [.customShort("t"), .customLong("state-rate")], help: "State tax rate (as decimal, e.g., 0.05 for 5%)")
    var stateRate: Double
    
    @Option(name: [.customShort("x"), .customLong("shares-sold-for-taxes")], help: "Number of shares sold for tax withholding")
    var sharesSoldForTaxes: Int
    
    @Option(name: [.customShort("a"), .customLong("tax-sale-price")], help: "Price per share when sold for taxes")
    var taxSalePrice: Double
    
    mutating func run() throws {
        let calculator = RSUCalculator()
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: vcdPrice,
            vestingShares: vestingShares,
            vestDayPrice: vestDayPrice,
            ficaRate: ficaRate,
            federalRate: federalRate,
            stateRate: stateRate,
            sharesSoldForTaxes: sharesSoldForTaxes,
            taxSalePrice: taxSalePrice
        )
        
        print("\n📊 RSU Calculator Results")
        print(String(repeating: "=", count: 50))
        
        print("\n📈 Input Parameters:")
        print("   VCD Price: $\(String(format: "%.2f", vcdPrice))")
        print("   Vesting Shares: \(vestingShares)")
        print("   Vest Day Price: $\(String(format: "%.2f", vestDayPrice))")
        print("   FICA Rate: \(String(format: "%.1f", ficaRate * 100))%")
        print("   Federal Rate: \(String(format: "%.1f", federalRate * 100))%")
        print("   State Rate: \(String(format: "%.1f", stateRate * 100))%")
        print("   Shares Sold for Taxes: \(sharesSoldForTaxes)")
        print("   Tax Sale Price: $\(String(format: "%.2f", taxSalePrice))")
        
        print("\n💰 Calculation Breakdown:")
        print("   Gross Income (VCD Price): $\(String(format: "%.2f", result.grossIncomeVCD))")
        print("   Gross Income (Vest Day): $\(String(format: "%.2f", result.grossIncomeVestDay))")
        print("   Total Tax Rate: \(String(format: "%.1f", result.totalTaxRate * 100))%")
        print("   Tax Amount: $\(String(format: "%.2f", result.taxAmount))")
        print("   Net Income Target: $\(String(format: "%.2f", result.netIncomeTarget))")
        print("   Shares After Tax Sale: \(result.sharesAfterTaxSale)")
        print("   Tax Sale Proceeds: $\(String(format: "%.2f", result.taxSaleProceeds))")
        
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
