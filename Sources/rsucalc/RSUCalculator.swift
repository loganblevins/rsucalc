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
        medicareRate: Double,
        socialSecurityRate: Double,
        federalRate: Double,
        saltRate: Double,
        sharesSoldForTaxes: Int,
        taxSalePrice: Double,
        includeCapitalGains: Bool = false,
        includeNetInvestmentTax: Bool = false
    ) -> RSUCalculationResult {
        
        // Step 1: Calculate gross income using VCD price (baseline scenario)
        let grossIncomeVCD = Double(vestingShares) * vcdPrice
        
        // Step 2: Calculate gross income using actual vest day price
        let grossIncomeVestDay = Double(vestingShares) * vestDayPrice
        
        // Step 3: Calculate total tax rate using precise individual components
        // Federal: 22%, Social Security: 6.2%, Medicare: 1.45%, SALT: varies
        let federalTax = ceil(grossIncomeVestDay * federalRate * 100) / 100
        let socialSecurityTax = ceil(grossIncomeVestDay * socialSecurityRate * 100) / 100
        let medicareTax = ceil(grossIncomeVestDay * medicareRate * 100) / 100
        let saltTax = ceil(grossIncomeVestDay * saltRate * 100) / 100
        let totalTaxAmount = federalTax + socialSecurityTax + medicareTax + saltTax
        let totalTaxRate = totalTaxAmount / grossIncomeVestDay
        
        // Step 4: Calculate tax amount based on vest day price using precise components
        let taxAmount = totalTaxAmount
        
        // Step 5: Calculate target net income (what you would get if vest day price = VCD price)
        let netIncomeTarget = grossIncomeVCD - (grossIncomeVCD * totalTaxRate)
        
        // Step 6: Calculate shares remaining after tax sale
        let sharesAfterTaxSale = vestingShares - sharesSoldForTaxes
        
        // Step 7: Calculate proceeds from tax sale
        let taxSaleProceeds = Double(sharesSoldForTaxes) * taxSalePrice
        
        // Step 8: Calculate cash distribution received (excess from tax sale after paying taxes)
        let cashDistribution = taxSaleProceeds - taxAmount
        
        // Step 9: Calculate adjusted target net income (subtract cash already received)
        let adjustedNetIncomeTarget = netIncomeTarget - cashDistribution
        
        // Step 10: Calculate required sale price for remaining shares
        // Formula: Adjusted Target Net Income / Remaining Shares
        var requiredSalePrice = sharesAfterTaxSale > 0 ? adjustedNetIncomeTarget / Double(sharesAfterTaxSale) : 0.0
        
        // Step 11: Adjust for capital gains tax if applicable
        if includeCapitalGains && requiredSalePrice > vestDayPrice {
            // If sale price > vest day price, there's a capital gain
            // Short-term capital gains are taxed at your marginal federal income tax rate + SALT rate
            // High-income earners may also be subject to 3.8% Net Investment Income Tax (NIIT)
            var capitalGainsRate = federalRate + saltRate
            if includeNetInvestmentTax {
                capitalGainsRate += 0.038 // 3.8% NIIT
            }
            
            // We need to account for capital gains tax on the profit
            // Simple approach: targetNetPerShare = salePrice - (salePrice - vestDayPrice) * capitalGainsRate
            // Solving for salePrice: salePrice = (targetNetPerShare - vestDayPrice * capitalGainsRate) / (1 - capitalGainsRate)
            let targetNetPerShare = adjustedNetIncomeTarget / Double(sharesAfterTaxSale)
            requiredSalePrice = (targetNetPerShare - vestDayPrice * capitalGainsRate) / (1 - capitalGainsRate)
        }
        
        // Calculate capital gains tax if applicable
        let capitalGainsTax: Double?
        let netAfterCapitalGains: Double?
        
        if includeCapitalGains && requiredSalePrice > vestDayPrice {
            let profitPerShare = requiredSalePrice - vestDayPrice
            var capitalGainsRate = federalRate + saltRate
            if includeNetInvestmentTax {
                capitalGainsRate += 0.038 // 3.8% NIIT
            }
            capitalGainsTax = profitPerShare * capitalGainsRate * Double(sharesAfterTaxSale)
            netAfterCapitalGains = adjustedNetIncomeTarget - capitalGainsTax!
        } else {
            capitalGainsTax = nil
            netAfterCapitalGains = nil
        }
        
        return RSUCalculationResult(
            grossIncomeVCD: grossIncomeVCD,
            grossIncomeVestDay: grossIncomeVestDay,
            totalTaxRate: totalTaxRate,
            taxAmount: taxAmount,
            netIncomeTarget: adjustedNetIncomeTarget,
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
        medicareRate: Double,
        socialSecurityRate: Double,
        federalRate: Double,
        saltRate: Double,
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
        
        if medicareRate < 0 || medicareRate > 1 {
            errors.append("Medicare rate must be between 0 and 1")
        }
        
        if socialSecurityRate < 0 || socialSecurityRate > 1 {
            errors.append("Social Security rate must be between 0 and 1")
        }
        
        if federalRate < 0 || federalRate > 1 {
            errors.append("Federal tax rate must be between 0 and 1")
        }
        
        if saltRate < 0 || saltRate > 1 {
            errors.append("SALT rate must be between 0 and 1")
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
        
        let totalTaxRate = medicareRate + socialSecurityRate + federalRate + saltRate
        if totalTaxRate > 1 {
            errors.append("Total tax rate cannot exceed 100%")
        }
        
        return errors
    }
}
