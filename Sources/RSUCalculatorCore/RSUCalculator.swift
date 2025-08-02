import Foundation

public struct RSUCalculationResult {
    public let grossIncomeVCD: Decimal
    public let grossIncomeVestDay: Decimal
    public let totalTaxRate: Decimal
    public let taxAmount: Decimal
    public let federalTax: Decimal
    public let socialSecurityTax: Decimal
    public let medicareTax: Decimal
    public let saltTax: Decimal
    public let netIncomeTarget: Decimal
    public let sharesAfterTaxSale: Int
    public let taxSaleProceeds: Decimal
    public let requiredSalePrice: Decimal
    public let capitalGainsTax: Decimal?
    public let niitTax: Decimal?
    
    // Additional fields for clean testing
    public let cashDistribution: Decimal
    public let adjustedNetIncomeTarget: Decimal
    public let originalNetIncomeTarget: Decimal
    public let vestingShares: Int
    public let sharesSoldForTaxes: Int
    public let vcdPrice: Decimal
    public let vestDayPrice: Decimal
    public let taxSalePrice: Decimal
    public let medicareRate: Decimal
    public let socialSecurityRate: Decimal
    public let federalRate: Decimal
    public let saltRate: Decimal
    
    public init(
        grossIncomeVCD: Decimal,
        grossIncomeVestDay: Decimal,
        totalTaxRate: Decimal,
        taxAmount: Decimal,
        federalTax: Decimal,
        socialSecurityTax: Decimal,
        medicareTax: Decimal,
        saltTax: Decimal,
        netIncomeTarget: Decimal,
        sharesAfterTaxSale: Int,
        taxSaleProceeds: Decimal,
        requiredSalePrice: Decimal,
        capitalGainsTax: Decimal?,
        niitTax: Decimal?,
        cashDistribution: Decimal,
        adjustedNetIncomeTarget: Decimal,
        originalNetIncomeTarget: Decimal,
        vestingShares: Int,
        sharesSoldForTaxes: Int,
        vcdPrice: Decimal,
        vestDayPrice: Decimal,
        taxSalePrice: Decimal,
        medicareRate: Decimal,
        socialSecurityRate: Decimal,
        federalRate: Decimal,
        saltRate: Decimal
    ) {
        self.grossIncomeVCD = grossIncomeVCD
        self.grossIncomeVestDay = grossIncomeVestDay
        self.totalTaxRate = totalTaxRate
        self.taxAmount = taxAmount
        self.federalTax = federalTax
        self.socialSecurityTax = socialSecurityTax
        self.medicareTax = medicareTax
        self.saltTax = saltTax
        self.netIncomeTarget = netIncomeTarget
        self.sharesAfterTaxSale = sharesAfterTaxSale
        self.taxSaleProceeds = taxSaleProceeds
        self.requiredSalePrice = requiredSalePrice
        self.capitalGainsTax = capitalGainsTax
        self.niitTax = niitTax
        self.cashDistribution = cashDistribution
        self.adjustedNetIncomeTarget = adjustedNetIncomeTarget
        self.originalNetIncomeTarget = originalNetIncomeTarget
        self.vestingShares = vestingShares
        self.sharesSoldForTaxes = sharesSoldForTaxes
        self.vcdPrice = vcdPrice
        self.vestDayPrice = vestDayPrice
        self.taxSalePrice = taxSalePrice
        self.medicareRate = medicareRate
        self.socialSecurityRate = socialSecurityRate
        self.federalRate = federalRate
        self.saltRate = saltRate
    }
}

struct TaxCalculation {
    let federalTax: Decimal
    let socialSecurityTax: Decimal
    let medicareTax: Decimal
    let saltTax: Decimal
    let capitalGainsTax: Decimal?
    let niitTax: Decimal?
    
    var totalRegularTax: Decimal {
        return federalTax + socialSecurityTax + medicareTax + saltTax
    }
    
    var totalCapitalGainsTax: Decimal {
        return (capitalGainsTax ?? 0) + (niitTax ?? 0)
    }
    
    var totalTax: Decimal {
        return totalRegularTax + totalCapitalGainsTax
    }
}

public final class RSUCalculator {
    
    public init() {}
    
    /// Round a Decimal to 2 decimal places for currency display
    public static func roundToCurrency(_ value: Decimal) -> Decimal {
        var rounded = Decimal()
        var input = value
        NSDecimalRound(&rounded, &input, 2, .bankers)
        return rounded
    }
    
    /// Calculate all taxes for a given income scenario
    private func calculateTaxes(
        grossIncome: Decimal,
        profitPerShare: Decimal?,
        sharesAfterTaxSale: Int,
        federalRate: Decimal,
        socialSecurityRate: Decimal,
        medicareRate: Decimal,
        saltRate: Decimal,
        includeCapitalGains: Bool,
        includeNetInvestmentTax: Bool
    ) -> TaxCalculation {
        // Calculate regular income taxes
        let federalTaxRaw = grossIncome * federalRate
        let socialSecurityTaxRaw = grossIncome * socialSecurityRate
        let medicareTaxRaw = grossIncome * medicareRate
        let saltTaxRaw = grossIncome * saltRate
        
        let federalTax = RSUCalculator.roundToCurrency(federalTaxRaw)
        let socialSecurityTax = RSUCalculator.roundToCurrency(socialSecurityTaxRaw)
        let medicareTax = RSUCalculator.roundToCurrency(medicareTaxRaw)
        let saltTax = RSUCalculator.roundToCurrency(saltTaxRaw)
        
        // Calculate capital gains and NIIT taxes if applicable
        var capitalGainsTax: Decimal? = nil
        var niitTax: Decimal? = nil
        
        if includeCapitalGains, let profit = profitPerShare, profit > 0 {
            // Short-term capital gains tax (federal + SALT rates, NIIT calculated separately)
            let capitalGainsRate = federalRate + saltRate
            capitalGainsTax = RSUCalculator.roundToCurrency(
                profit * capitalGainsRate * Decimal(sharesAfterTaxSale)
            )
            
            // NIIT tax (3.8% separately)
            if includeNetInvestmentTax {
                let niitRate = Decimal(0.038)
                niitTax = RSUCalculator.roundToCurrency(
                    profit * niitRate * Decimal(sharesAfterTaxSale)
                )
            }
        }
        
        return TaxCalculation(
            federalTax: federalTax,
            socialSecurityTax: socialSecurityTax,
            medicareTax: medicareTax,
            saltTax: saltTax,
            capitalGainsTax: capitalGainsTax,
            niitTax: niitTax
        )
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
    public func calculateRequiredSalePrice(
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
        
        // Step 3: Calculate initial taxes (without capital gains/NIIT)
        let initialTaxes = calculateTaxes(
            grossIncome: grossIncomeVestDay,
            profitPerShare: nil, // No capital gains yet
            sharesAfterTaxSale: 0, // Not needed for regular income taxes
            federalRate: federalRate,
            socialSecurityRate: socialSecurityRate,
            medicareRate: medicareRate,
            saltRate: saltRate,
            includeCapitalGains: false,
            includeNetInvestmentTax: false
        )
        
        let totalTaxAmount = initialTaxes.totalRegularTax
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
        
        // Step 11a: Adjust required sale price for capital gains tax if applicable
        if let rate = capitalGainsRate, requiredSalePrice > vestDayPrice {
            // If sale price > vest day price, there's a capital gain that will be taxed
            // RSUs held < 1 year: Short-term capital gains = marginal federal tax rate + SALT rate
            // High-income earners may also owe 3.8% Net Investment Income Tax (NIIT)
            
            // Adjust sale price to account for capital gains tax on the profit
            // Formula derivation: targetNetPerShare = salePrice - (salePrice - vestDayPrice) * capitalGainsRate
            // Solving for salePrice: salePrice = (targetNetPerShare - vestDayPrice * capitalGainsRate) / (1 - capitalGainsRate)
            let targetNetPerShare = adjustedNetIncomeTarget / Decimal(sharesAfterTaxSale)
            requiredSalePrice = (targetNetPerShare - vestDayPrice * rate) / (Decimal(1) - rate)
        }
        
        // Step 11b: Calculate final capital gains tax amounts for display purposes
        let profitPerShare = (capitalGainsRate != nil && requiredSalePrice > vestDayPrice) ? 
            requiredSalePrice - vestDayPrice : nil
        
        let finalTaxes = calculateTaxes(
            grossIncome: grossIncomeVestDay,
            profitPerShare: profitPerShare,
            sharesAfterTaxSale: sharesAfterTaxSale,
            federalRate: federalRate,
            socialSecurityRate: socialSecurityRate,
            medicareRate: medicareRate,
            saltRate: saltRate,
            includeCapitalGains: includeCapitalGains,
            includeNetInvestmentTax: includeNetInvestmentTax
        )
        
        let capitalGainsTax = finalTaxes.capitalGainsTax
        let niitTax = finalTaxes.niitTax
        
        // Apply currency rounding (2 decimal places) to calculated monetary values only
        // Keep input values precise to avoid affecting calculations
        let roundedGrossIncomeVCD = RSUCalculator.roundToCurrency(grossIncomeVCD)
        let roundedGrossIncomeVestDay = RSUCalculator.roundToCurrency(grossIncomeVestDay)
        let roundedTaxSaleProceeds = RSUCalculator.roundToCurrency(taxSaleProceeds)
        let roundedNetIncomeTarget = RSUCalculator.roundToCurrency(netIncomeTarget)
        let roundedAdjustedNetIncomeTarget = RSUCalculator.roundToCurrency(adjustedNetIncomeTarget)
        let roundedRequiredSalePrice = RSUCalculator.roundToCurrency(requiredSalePrice)
        return RSUCalculationResult(
            grossIncomeVCD: roundedGrossIncomeVCD,
            grossIncomeVestDay: roundedGrossIncomeVestDay,
            totalTaxRate: totalTaxRate,
            taxAmount: totalTaxAmount,
            federalTax: initialTaxes.federalTax,
            socialSecurityTax: initialTaxes.socialSecurityTax,
            medicareTax: initialTaxes.medicareTax,
            saltTax: initialTaxes.saltTax,
            netIncomeTarget: roundedAdjustedNetIncomeTarget,
            sharesAfterTaxSale: sharesAfterTaxSale,
            taxSaleProceeds: roundedTaxSaleProceeds,
            requiredSalePrice: roundedRequiredSalePrice,
            capitalGainsTax: capitalGainsTax,
            niitTax: niitTax,
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
    public func validateInputs(
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