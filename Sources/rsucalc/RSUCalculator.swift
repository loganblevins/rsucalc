import Foundation

struct RSUCalculationResult {
    let grossIncomeVCD: Decimal
    let grossIncomeVestDay: Decimal
    let totalTaxRate: Decimal
    let taxAmount: Decimal
    let federalTax: Decimal
    let socialSecurityTax: Decimal
    let medicareTax: Decimal
    let saltTax: Decimal
    let netIncomeTarget: Decimal
    let sharesAfterTaxSale: Int
    let taxSaleProceeds: Decimal
    let requiredSalePrice: Decimal
    let capitalGainsTax: Decimal?
    
    // Additional fields for clean testing
    let cashDistribution: Decimal
    let adjustedNetIncomeTarget: Decimal
    let originalNetIncomeTarget: Decimal
    let vestingShares: Int
    let sharesSoldForTaxes: Int
    let vcdPrice: Decimal
    let vestDayPrice: Decimal
    let taxSalePrice: Decimal
    let medicareRate: Decimal
    let socialSecurityRate: Decimal
    let federalRate: Decimal
    let saltRate: Decimal
}

final class RSUCalculator {
    
    /// Round a Decimal to 2 decimal places for currency display
    static func roundToCurrency(_ value: Decimal) -> Decimal {
        var rounded = Decimal()
        var input = value
        NSDecimalRound(&rounded, &input, 2, .bankers)
        return rounded
    }
    
    /// Calculate capital gains tax rate (federal + SALT + optional NIIT)
    private func calculateCapitalGainsRate(
        federalRate: Decimal,
        saltRate: Decimal,
        includeNetInvestmentTax: Bool
    ) -> Decimal {
        var capitalGainsRate = federalRate + saltRate
        if includeNetInvestmentTax {
            capitalGainsRate += Decimal(0.038) // 3.8% NIIT
        }
        return capitalGainsRate
    }
    
    /// Calculate the required sale price for remaining shares to achieve target net income
    /// 
    /// This calculation determines what price you need to sell your remaining shares at
    /// (after tax withholding shares are sold) to achieve the same net income you would
    /// have received if the vest day price equaled the VCD price.
    func calculateRequiredSalePrice(
        vcdPrice: Decimal,
        vestingShares: Int,
        vestDayPrice: Decimal,
        medicareRate: Decimal,
        socialSecurityRate: Decimal,
        federalRate: Decimal,
        saltRate: Decimal,
        sharesSoldForTaxes: Int,
        taxSalePrice: Decimal,
        includeCapitalGains: Bool = false,
        includeNetInvestmentTax: Bool = false
    ) -> RSUCalculationResult {
        
        // Step 1: Calculate gross income using VCD price (baseline scenario)
        let grossIncomeVCD = Decimal(vestingShares) * vcdPrice
        
        // Step 2: Calculate gross income using actual vest day price
        let grossIncomeVestDay = Decimal(vestingShares) * vestDayPrice
        
        // Step 3: Calculate total tax rate using precise individual components
        // Federal: 22%, Social Security: 6.2%, Medicare: 1.45%, SALT: varies
        // Note: Using Decimal for exact precision
        
        // Store raw unrounded values for accurate summation
        let federalTaxRaw = grossIncomeVestDay * federalRate
        let socialSecurityTaxRaw = grossIncomeVestDay * socialSecurityRate
        let medicareTaxRaw = grossIncomeVestDay * medicareRate
        let saltTaxRaw = grossIncomeVestDay * saltRate

        let roundedFederalTax = RSUCalculator.roundToCurrency(federalTaxRaw)
        let roundedSocialSecurityTax = RSUCalculator.roundToCurrency(socialSecurityTaxRaw)
        let roundedMedicareTax = RSUCalculator.roundToCurrency(medicareTaxRaw)
        let roundedSaltTax = RSUCalculator.roundToCurrency(saltTaxRaw)

        // Sum the raw values to avoid rounding errors
        let totalTaxAmount = roundedFederalTax + roundedSocialSecurityTax + roundedMedicareTax + roundedSaltTax

        // Calculate tax rate from raw values for accuracy
        let totalTaxRate = federalRate + socialSecurityRate + medicareRate + saltRate
        
        // Step 4: Total tax amount is already calculated above
        
        // Step 5: Calculate target net income (what you would get if vest day price = VCD price)
        let netIncomeTarget = grossIncomeVCD - (grossIncomeVCD * totalTaxRate)
        
        // Step 6: Calculate shares remaining after tax sale
        let sharesAfterTaxSale = vestingShares - sharesSoldForTaxes
        
        // Step 7: Calculate proceeds from tax sale
        let taxSaleProceeds = Decimal(sharesSoldForTaxes) * taxSalePrice
        
        // Step 8: Calculate cash distribution received (excess from tax sale after paying taxes)
        let roundedCashDistribution = RSUCalculator.roundToCurrency(taxSaleProceeds - totalTaxAmount)

        // Step 9: Calculate adjusted target net income (subtract cash already received)
        let adjustedNetIncomeTarget = netIncomeTarget - roundedCashDistribution

        // Step 10: Calculate required sale price for remaining shares
        // Formula: Adjusted Target Net Income / Remaining Shares
        var requiredSalePrice = sharesAfterTaxSale > 0 ? adjustedNetIncomeTarget / Decimal(sharesAfterTaxSale) : Decimal(0)
        
        // Step 11: Calculate capital gains rate once if needed
        let capitalGainsRate: Decimal? = includeCapitalGains ? calculateCapitalGainsRate(
            federalRate: federalRate,
            saltRate: saltRate,
            includeNetInvestmentTax: includeNetInvestmentTax
        ) : nil
        
        // Step 11a: Adjust for capital gains tax if applicable
        if let rate = capitalGainsRate, requiredSalePrice > vestDayPrice {
            // If sale price > vest day price, there's a capital gain
            // Short-term capital gains are taxed at your marginal federal income tax rate + SALT rate
            // High-income earners may also be subject to 3.8% Net Investment Income Tax (NIIT)
            
            // We need to account for capital gains tax on the profit
            // Simple approach: targetNetPerShare = salePrice - (salePrice - vestDayPrice) * capitalGainsRate
            // Solving for salePrice: salePrice = (targetNetPerShare - vestDayPrice * capitalGainsRate) / (1 - capitalGainsRate)
            let targetNetPerShare = adjustedNetIncomeTarget / Decimal(sharesAfterTaxSale)
            requiredSalePrice = (targetNetPerShare - vestDayPrice * rate) / (Decimal(1) - rate)
        }
        
        // Step 11b: Calculate capital gains tax amount if applicable
        let capitalGainsTax: Decimal?
        
        if let rate = capitalGainsRate, requiredSalePrice > vestDayPrice {
            let profitPerShare = requiredSalePrice - vestDayPrice
            capitalGainsTax = profitPerShare * rate * Decimal(sharesAfterTaxSale)
        } else {
            capitalGainsTax = nil
        }
        
        // Apply currency rounding (2 decimal places) to calculated monetary values only
        // Keep input values precise to avoid affecting calculations
        let roundedGrossIncomeVCD = RSUCalculator.roundToCurrency(grossIncomeVCD)
        let roundedGrossIncomeVestDay = RSUCalculator.roundToCurrency(grossIncomeVestDay)
        let roundedTaxSaleProceeds = RSUCalculator.roundToCurrency(taxSaleProceeds)
        let roundedNetIncomeTarget = RSUCalculator.roundToCurrency(netIncomeTarget)
        let roundedAdjustedNetIncomeTarget = RSUCalculator.roundToCurrency(adjustedNetIncomeTarget)
        let roundedRequiredSalePrice = RSUCalculator.roundToCurrency(requiredSalePrice)
        let roundedCapitalGainsTax = capitalGainsTax.map { RSUCalculator.roundToCurrency($0) }
        
        return RSUCalculationResult(
            grossIncomeVCD: roundedGrossIncomeVCD,
            grossIncomeVestDay: roundedGrossIncomeVestDay,
            totalTaxRate: totalTaxRate,
            taxAmount: totalTaxAmount,
            federalTax: roundedFederalTax,
            socialSecurityTax: roundedSocialSecurityTax,
            medicareTax: roundedMedicareTax,
            saltTax: roundedSaltTax,
            netIncomeTarget: roundedAdjustedNetIncomeTarget,
            sharesAfterTaxSale: sharesAfterTaxSale,
            taxSaleProceeds: roundedTaxSaleProceeds,
            requiredSalePrice: roundedRequiredSalePrice,
            capitalGainsTax: roundedCapitalGainsTax,
            cashDistribution: roundedCashDistribution,
            adjustedNetIncomeTarget: roundedAdjustedNetIncomeTarget,
            originalNetIncomeTarget: roundedNetIncomeTarget,
            vestingShares: vestingShares,
            sharesSoldForTaxes: sharesSoldForTaxes,
            vcdPrice: vcdPrice,  // Keep original precision for input values
            vestDayPrice: vestDayPrice,  // Keep original precision for input values
            taxSalePrice: taxSalePrice,  // Keep original precision for input values
            medicareRate: medicareRate,
            socialSecurityRate: socialSecurityRate,
            federalRate: federalRate,
            saltRate: saltRate
        )
    }
    
    /// Validate a tax rate is between 0 and 1
    private func validateTaxRate(_ rate: Decimal, name: String) -> String? {
        if rate < Decimal(0) || rate > Decimal(1) {
            return "\(name) rate must be between 0 and 1"
        }
        return nil
    }
    
    /// Validate input parameters for reasonable ranges
    func validateInputs(
        vcdPrice: Decimal,
        vestingShares: Int,
        vestDayPrice: Decimal,
        medicareRate: Decimal,
        socialSecurityRate: Decimal,
        federalRate: Decimal,
        saltRate: Decimal,
        sharesSoldForTaxes: Int,
        taxSalePrice: Decimal
    ) -> [String] {
        var errors: [String] = []
        
        // Price validations
        if vcdPrice <= Decimal(0) {
            errors.append("VCD price must be positive")
        }
        if vestDayPrice <= Decimal(0) {
            errors.append("Vest day price must be positive")
        }
        if taxSalePrice <= Decimal(0) {
            errors.append("Tax sale price must be positive")
        }
        
        // Share validations
        if vestingShares <= 0 {
            errors.append("Vesting shares must be positive")
        }
        if sharesSoldForTaxes < 0 {
            errors.append("Shares sold for taxes cannot be negative")
        }
        if sharesSoldForTaxes > vestingShares {
            errors.append("Shares sold for taxes cannot exceed vesting shares")
        }
        
        // Tax rate validations
        let taxRateValidations = [
            (medicareRate, "Medicare"),
            (socialSecurityRate, "Social Security"),
            (federalRate, "Federal tax"),
            (saltRate, "SALT")
        ]
        
        for (rate, name) in taxRateValidations {
            if let error = validateTaxRate(rate, name: name) {
                errors.append(error)
            }
        }
        
        // Total tax rate validation
        let totalTaxRate = medicareRate + socialSecurityRate + federalRate + saltRate
        if totalTaxRate > Decimal(1) {
            errors.append("Total tax rate cannot exceed 100%")
        }
        
        return errors
    }
}
