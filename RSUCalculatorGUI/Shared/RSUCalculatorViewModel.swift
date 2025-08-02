import Foundation
import RSUCalculatorCore

final class RSUCalculatorViewModel: ObservableObject {
    // Input fields
    @Published var vcdPrice: String = ""
    @Published var vestingShares: String = ""
    @Published var vestDayPrice: String = ""
    @Published var medicareRate: String = "0.0145"
    @Published var socialSecurityRate: String = "0.062"
    @Published var federalRate: String = "0.22"
    @Published var saltRate: String = "0.05"
    @Published var sharesSoldForTaxes: String = ""
    @Published var taxSalePrice: String = ""
    @Published var includeCapitalGains: Bool = false
    @Published var includeNetInvestmentTax: Bool = false
    
    // Results
    @Published var calculationResult: RSUCalculationResult?
    @Published var validationErrors: [String] = []
    @Published var hasCalculated: Bool = false
    
    private let calculator = RSUCalculator()
    
    func calculateRSU() {
        validationErrors.removeAll()
        
        // Parse inputs
        guard let vcdPriceDecimal = Decimal(string: vcdPrice),
              let vestingSharesInt = Int(vestingShares),
              let vestDayPriceDecimal = Decimal(string: vestDayPrice),
              let medicareRateDecimal = Decimal(string: medicareRate),
              let socialSecurityRateDecimal = Decimal(string: socialSecurityRate),
              let federalRateDecimal = Decimal(string: federalRate),
              let saltRateDecimal = Decimal(string: saltRate),
              let sharesSoldForTaxesInt = Int(sharesSoldForTaxes),
              let taxSalePriceDecimal = Decimal(string: taxSalePrice) else {
            validationErrors.append("Please ensure all fields have valid numeric values")
            return
        }
        
        // Validate inputs
        let errors = calculator.validateInputs(
            vcdPrice: vcdPriceDecimal,
            vestingShares: vestingSharesInt,
            vestDayPrice: vestDayPriceDecimal,
            medicareRate: medicareRateDecimal,
            socialSecurityRate: socialSecurityRateDecimal,
            federalRate: federalRateDecimal,
            saltRate: saltRateDecimal,
            sharesSoldForTaxes: sharesSoldForTaxesInt,
            taxSalePrice: taxSalePriceDecimal
        )
        
        if !errors.isEmpty {
            validationErrors = errors
            return
        }
        
        // Calculate
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: vcdPriceDecimal,
            vestingShares: vestingSharesInt,
            vestDayPrice: vestDayPriceDecimal,
            medicareRate: medicareRateDecimal,
            socialSecurityRate: socialSecurityRateDecimal,
            federalRate: federalRateDecimal,
            saltRate: saltRateDecimal,
            sharesSoldForTaxes: sharesSoldForTaxesInt,
            taxSalePrice: taxSalePriceDecimal,
            includeCapitalGains: includeCapitalGains,
            includeNetInvestmentTax: includeNetInvestmentTax
        )
        
        calculationResult = result
        hasCalculated = true
    }
    
    func resetCalculation() {
        calculationResult = nil
        validationErrors.removeAll()
        hasCalculated = false
    }
    
    // Helper methods for formatting
    func formatAsPercentage(_ value: Decimal) -> String {
        return String(format: "%.2f", NSDecimalNumber(decimal: value).doubleValue * 100)
    }
    
    func formatAsCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let number = NSDecimalNumber(decimal: value)
        return formatter.string(from: number) ?? String(format: "$%.2f", number.doubleValue)
    }
}