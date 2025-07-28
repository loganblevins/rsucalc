import Foundation

struct RSUCalculationResult {
    let grossIncomeVCD: Double
    let grossIncomeVestDay: Double
    let totalTaxRate: Double
    let taxAmount: Double
    let netIncomeTarget: Double
    let sharesAfterTaxSale: Int
    let taxSaleProceeds: Double
    let requiredSalePrice: Double
    let capitalGainsTax: Double?
    let netAfterCapitalGains: Double?
}

final class RSUCalculator {
    
    /// Calculate the required sale price for remaining shares to achieve target net income
    /// 
    /// This calculation determines what price you need to sell your remaining shares at
    /// (after tax withholding shares are sold) to achieve the same net income you would
    /// have received if the vest day price equaled the VCD price.
    func calculateRequiredSalePrice(
        vcdPrice: Double,
        vestingShares: Int,
        vestDayPrice: Double,
        ficaRate: Double,
        federalRate: Double,
        stateRate: Double,
        sharesSoldForTaxes: Int,
        taxSalePrice: Double,
        includeCapitalGains: Bool = false
    ) -> RSUCalculationResult {
        
        // Step 1: Calculate gross income using VCD price (baseline scenario)
        let grossIncomeVCD = Double(vestingShares) * vcdPrice
        
        // Step 2: Calculate gross income using actual vest day price
        let grossIncomeVestDay = Double(vestingShares) * vestDayPrice
        
        // Step 3: Calculate total tax rate
        let totalTaxRate = ficaRate + federalRate + stateRate
        
        // Step 4: Calculate tax amount based on vest day price
        let taxAmount = grossIncomeVestDay * totalTaxRate
        
        // Step 5: Calculate target net income (what you would get if vest day price = VCD price)
        let netIncomeTarget = grossIncomeVCD - (grossIncomeVCD * totalTaxRate)
        
        // Step 6: Calculate shares remaining after tax sale
        let sharesAfterTaxSale = vestingShares - sharesSoldForTaxes
        
        // Step 7: Calculate proceeds from tax sale
        let taxSaleProceeds = Double(sharesSoldForTaxes) * taxSalePrice
        
        // Step 8: Calculate required sale price for remaining shares
        // Formula: Target Net Income / Remaining Shares
        // Note: Tax sale proceeds don't go to the user's bank account, so we don't subtract them
        var requiredSalePrice = sharesAfterTaxSale > 0 ? netIncomeTarget / Double(sharesAfterTaxSale) : 0.0
        
        // Step 9: Adjust for capital gains tax if applicable
        if includeCapitalGains && requiredSalePrice > vestDayPrice {
            // If sale price > vest day price, there's a capital gain
            // Short-term capital gains are taxed at your marginal federal income tax rate + state tax rate
            let capitalGainsRate = federalRate + stateRate
            
            // We need to account for capital gains tax on the profit
            // Simple approach: targetNetPerShare = salePrice - (salePrice - vestDayPrice) * capitalGainsRate
            // Solving for salePrice: salePrice = (targetNetPerShare - vestDayPrice * capitalGainsRate) / (1 - capitalGainsRate)
            let targetNetPerShare = netIncomeTarget / Double(sharesAfterTaxSale)
            requiredSalePrice = (targetNetPerShare - vestDayPrice * capitalGainsRate) / (1 - capitalGainsRate)
        }
        
        // Calculate capital gains tax if applicable
        let capitalGainsTax: Double?
        let netAfterCapitalGains: Double?
        
        if includeCapitalGains && requiredSalePrice > vestDayPrice {
            let profitPerShare = requiredSalePrice - vestDayPrice
            let capitalGainsRate = federalRate + stateRate
            capitalGainsTax = profitPerShare * capitalGainsRate * Double(sharesAfterTaxSale)
            netAfterCapitalGains = netIncomeTarget - capitalGainsTax!
        } else {
            capitalGainsTax = nil
            netAfterCapitalGains = nil
        }
        
        return RSUCalculationResult(
            grossIncomeVCD: grossIncomeVCD,
            grossIncomeVestDay: grossIncomeVestDay,
            totalTaxRate: totalTaxRate,
            taxAmount: taxAmount,
            netIncomeTarget: netIncomeTarget,
            sharesAfterTaxSale: sharesAfterTaxSale,
            taxSaleProceeds: taxSaleProceeds,
            requiredSalePrice: requiredSalePrice,
            capitalGainsTax: capitalGainsTax,
            netAfterCapitalGains: netAfterCapitalGains
        )
    }
    
    /// Validate input parameters for reasonable ranges
    func validateInputs(
        vcdPrice: Double,
        vestingShares: Int,
        vestDayPrice: Double,
        ficaRate: Double,
        federalRate: Double,
        stateRate: Double,
        sharesSoldForTaxes: Int,
        taxSalePrice: Double
    ) -> [String] {
        var errors: [String] = []
        
        if vcdPrice <= 0 {
            errors.append("VCD price must be positive")
        }
        
        if vestingShares <= 0 {
            errors.append("Vesting shares must be positive")
        }
        
        if vestDayPrice <= 0 {
            errors.append("Vest day price must be positive")
        }
        
        if ficaRate < 0 || ficaRate > 1 {
            errors.append("FICA rate must be between 0 and 1")
        }
        
        if federalRate < 0 || federalRate > 1 {
            errors.append("Federal tax rate must be between 0 and 1")
        }
        
        if stateRate < 0 || stateRate > 1 {
            errors.append("State tax rate must be between 0 and 1")
        }
        
        if sharesSoldForTaxes < 0 {
            errors.append("Shares sold for taxes cannot be negative")
        }
        
        if sharesSoldForTaxes > vestingShares {
            errors.append("Shares sold for taxes cannot exceed vesting shares")
        }
        
        if taxSalePrice <= 0 {
            errors.append("Tax sale price must be positive")
        }
        
        let totalTaxRate = ficaRate + federalRate + stateRate
        if totalTaxRate > 1 {
            errors.append("Total tax rate cannot exceed 100%")
        }
        
        return errors
    }
}
