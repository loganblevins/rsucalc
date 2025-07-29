import XCTest
@testable import rsucalc

final class RSUCalculatorTests: XCTestCase {
    
    var calculator: RSUCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = RSUCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - Basic Calculation Tests
    
    func testBasicCalculation() {
        // Test case: VCD price = vest day price (no change)
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.3465, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 3465.0, accuracy: 0.01)
        // Cash distribution = 2500 - 3465 = -965 (negative means no cash received)
        // Adjusted target = 6535 - (-965) = 7500
        XCTAssertEqual(result.netIncomeTarget, 7500.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 75)
        XCTAssertEqual(result.taxSaleProceeds, 2500.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
    }
    
    func testRealWorldScenario() {
        // Test with the real numbers provided by the user
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 64.62,
            vestingShares: 551,
            vestDayPrice: 83.04,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 193,
            taxSalePrice: 70.3279
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 35605.62, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 45755.04, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 13566.38, accuracy: 0.01)
        // Cash distribution = 13573.28 - 13566.37 = 6.91
        // Adjusted target = 25048.55 - 6.91 = 25041.64
        XCTAssertEqual(result.netIncomeTarget, 25041.64, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 358)
        XCTAssertEqual(result.taxSaleProceeds, 13573.28, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 69.95, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func testZeroSALTTax() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 20,
            taxSalePrice: 120.0
        )
        
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        // Cash distribution = 2400 - 4447.5 = -2047.5 (negative means no cash received)
        // Adjusted target = 7035 - (-2047.5) = 9082.5
        XCTAssertEqual(result.netIncomeTarget, 8193.0, accuracy: 0.01)
    }
    
    func testHighTaxRates() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.37,
            saltRate: 0.13,
            sharesSoldForTaxes: 50,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.totalTaxRate, 0.5765, accuracy: 0.0001)
        // Cash distribution = 5000 - 5765 = -765 (negative means no cash received)
        // Adjusted target = 4235 - (-765) = 5000
        XCTAssertEqual(result.netIncomeTarget, 5000.0, accuracy: 0.01)
    }
    
    func testAllSharesSoldForTaxes() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 100,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.sharesAfterTaxSale, 0)
        XCTAssertEqual(result.taxSaleProceeds, 10000.0, accuracy: 0.01)
        // When no shares remain, required sale price should be 0 or handled appropriately
        XCTAssertEqual(result.requiredSalePrice, 0.0, accuracy: 0.01)
    }
    
    func testNoSharesSoldForTaxes() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 0,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.sharesAfterTaxSale, 100)
        XCTAssertEqual(result.taxSaleProceeds, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
    }
    
    func testVestDayPriceHigherThanVCD() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 150.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 150.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 15000.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 106.43, accuracy: 0.01)
    }
    
    func testVestDayPriceLowerThanVCD() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 8000.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 97.43, accuracy: 0.01)
    }
    
    // MARK: - Large Numbers
    
    func testLargeShareCount() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 10000,
            vestDayPrice: 60.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 2500,
            taxSalePrice: 60.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 500000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 600000.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 7500)
        XCTAssertEqual(result.requiredSalePrice, 51.29, accuracy: 0.01)
    }
    
    func testHighPricePerShare() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 1000.0,
            vestingShares: 100,
            vestDayPrice: 1200.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 1200.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 100000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 120000.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 1025.73, accuracy: 0.01)
    }
    
    // MARK: - Precision Tests
    
    func testPrecisionWithDecimals() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 64.62,
            vestingShares: 551,
            vestDayPrice: 83.04,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 193,
            taxSalePrice: 70.3279
        )
        
        // Test that we get the exact expected values with proper precision
        // Cash distribution = 13573.28 - 13566.38 = 6.90
        // Adjusted target = 25048.55 - 6.90 = 25041.64
        XCTAssertEqual(result.netIncomeTarget, 25041.64, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 69.95, accuracy: 0.01)
    }
    
    // MARK: - Input Validation Tests
    
    func testValidateInputsWithValidData() {
        let errors = calculator.validateInputs(
            
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.isEmpty, "Should have no validation errors for valid input")
    }
    
    func testValidateInputsWithNegativeVCDPrice() {
        let errors = calculator.validateInputs(
            
            vcdPrice: -100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.contains("VCD price must be positive"))
    }
    
    func testValidateInputsWithZeroVestingShares() {
        let errors = calculator.validateInputs(
            
            vcdPrice: 100.0,
            vestingShares: 0,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.contains("Vesting shares must be positive"))
    }
    
    func testValidateInputsWithInvalidTaxRates() {
        let errors = calculator.validateInputs(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 1.5, // Invalid: > 1
            socialSecurityRate: 0.062,
            federalRate: -0.1, // Invalid: < 0
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.contains("Medicare rate must be between 0 and 1"))
        XCTAssertTrue(errors.contains("Federal tax rate must be between 0 and 1"))
    }
    
    func testValidateInputsWithTooManySharesSoldForTaxes() {
        let errors = calculator.validateInputs(
            
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 150, // More than vesting shares
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.contains("Shares sold for taxes cannot exceed vesting shares"))
    }
    
    func testValidateInputsWithTotalTaxRateOver100() {
        let errors = calculator.validateInputs(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.5,
            socialSecurityRate: 0.062,
            federalRate: 0.4,
            saltRate: 0.2, // Total = 110%
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.contains("Total tax rate cannot exceed 100%"))
    }
    
    // MARK: - Mathematical Consistency Tests
    
    func testMathematicalConsistency() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        // Verify mathematical relationships
        XCTAssertEqual(result.grossIncomeVCD, 100.0 * 100, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 120.0 * 100, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.0765 + 0.22 + 0.05, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, result.grossIncomeVestDay * result.totalTaxRate, accuracy: 0.01)
        // Cash distribution = 3000 - 4158 = -1158 (negative means no cash received)
        // Adjusted target = 6535 - (-1158) = 7693
        XCTAssertEqual(result.netIncomeTarget, 7693.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 100 - 25)
        XCTAssertEqual(result.taxSaleProceeds, 25.0 * 120.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, result.netIncomeTarget / Double(result.sharesAfterTaxSale), accuracy: 0.01)
    }
    
    // MARK: - Capital Gains Tests
    
    func testCapitalGainsWithProfit() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 8000.0, accuracy: 0.01)
        // Cash distribution = 2000 - 2772 = -772 (negative means no cash received)
        // Adjusted target = 6535 - (-772) = 7307
        XCTAssertEqual(result.netIncomeTarget, 7307.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 75)
        XCTAssertEqual(result.requiredSalePrice, 103.87, accuracy: 0.01)
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertEqual(result.capitalGainsTax!, 483.41, accuracy: 0.01)
    }
    
    func testCapitalGainsWithoutProfit() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 100.0,
            includeCapitalGains: true
        )
        
        // When vest day price = VCD price, required sale price should be same as without capital gains
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
        XCTAssertNil(result.capitalGainsTax)
    }
    
    func testCapitalGainsWithLoss() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0,
            includeCapitalGains: true
        )
        
        // When vest day price > VCD price, required sale price should be lower
        // No capital gains tax should be applied since we're selling at a loss relative to vest day
        XCTAssertEqual(result.requiredSalePrice, 102.57, accuracy: 0.01)
        XCTAssertNil(result.capitalGainsTax)
    }
    
    func testCapitalGainsTaxRateCalculation() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.32, // Higher federal rate
            saltRate: 0.093,  // Higher SALT rate
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true
        )
        
        // With high tax rates, required sale price is above vest day price
        // So capital gains tax should be applied
        XCTAssertEqual(result.requiredSalePrice, 103.19, accuracy: 0.01)
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertEqual(result.capitalGainsTax!, 718.35, accuracy: 0.01)
    }
    
    func testCapitalGainsWithZeroSALTTax() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0, // No SALT
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true
        )
        
        // Capital gains rate should be federal only = 22% (no SALT)
        XCTAssertEqual(result.requiredSalePrice, 104.05, accuracy: 0.01)
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertEqual(result.capitalGainsTax!, 396.85, accuracy: 0.01)
    }
    
    func testCapitalGainsMathematicalConsistency() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true
        )
        
        // Verify the mathematical relationships
        let capitalGainsRate = 0.22 + 0.05 // federal + state
        let profitPerShare = result.requiredSalePrice - 80.0
        let expectedCapitalGainsTax = profitPerShare * capitalGainsRate * 75.0
        
        XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.01)
    }
    
    func testCapitalGainsDisabled() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: false
        )
        
        // Should be same as without capital gains flag
        XCTAssertEqual(result.requiredSalePrice, 97.43, accuracy: 0.01)
        XCTAssertNil(result.capitalGainsTax)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeNumbers() {
        measure {
            _ = calculator.calculateRequiredSalePrice(
                vcdPrice: 100.0,
                vestingShares: 100000,
                vestDayPrice: 120.0,
                medicareRate: 0.0145,
            socialSecurityRate: 0.062,
                federalRate: 0.22,
                saltRate: 0.05,
                sharesSoldForTaxes: 25000,
                taxSalePrice: 120.0
            )
        }
    }
    
    func testPerformanceWithCapitalGains() {
        measure {
            _ = calculator.calculateRequiredSalePrice(
                vcdPrice: 100.0,
                vestingShares: 10000,
                vestDayPrice: 80.0,
                medicareRate: 0.0145,
            socialSecurityRate: 0.062,
                federalRate: 0.22,
                saltRate: 0.05,
                sharesSoldForTaxes: 2500,
                taxSalePrice: 80.0,
                includeCapitalGains: true
            )
        }
    }
    
    // MARK: - Net Investment Income Tax Tests
    
    func testNetInvestmentTaxWithProfit() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        XCTAssertNotNil(result.capitalGainsTax)
        
        // Capital gains rate should be federal + state + NIIT = 22% + 5% + 3.8% = 30.8%
        let expectedCapitalGainsRate = 0.22 + 0.05 + 0.038
        let profitPerShare = result.requiredSalePrice - 80.0
        let expectedCapitalGainsTax = profitPerShare * expectedCapitalGainsRate * 75.0
        
        XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.01)
    }
    
    func testNetInvestmentTaxWithoutProfit() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.32,
            saltRate: 0.093,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // With high tax rates, required sale price is above vest day price
        // So capital gains tax should be applied
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertEqual(result.capitalGainsTax!, 838.74, accuracy: 0.01)
    }
    
    func testNetInvestmentTaxRateCalculation() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // Verify the required sale price is higher with NIIT than without
        let resultWithoutNIIT = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: false
        )
        
        XCTAssertGreaterThan(result.requiredSalePrice, resultWithoutNIIT.requiredSalePrice)
        XCTAssertGreaterThan(result.capitalGainsTax!, resultWithoutNIIT.capitalGainsTax!)
    }
    
    func testNetInvestmentTaxWithZeroSALTTax() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // Capital gains rate should be federal + NIIT = 22% + 3.8% = 25.8% (no SALT)
        let expectedCapitalGainsRate = 0.22 + 0.038
        let profitPerShare = result.requiredSalePrice - 80.0
        let expectedCapitalGainsTax = profitPerShare * expectedCapitalGainsRate * 75.0
        
        XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.01)
    }
    
    func testNetInvestmentTaxDisabled() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: false
        )
        
        // Should behave exactly like regular capital gains without NIIT
        XCTAssertNotNil(result.capitalGainsTax)
        
        // Capital gains rate should be federal + state = 22% + 5% = 27%
        let expectedCapitalGainsRate = 0.22 + 0.05
        let profitPerShare = result.requiredSalePrice - 80.0
        let expectedCapitalGainsTax = profitPerShare * expectedCapitalGainsRate * 75.0
        
        XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.01)
    }
    
    func testNetInvestmentTaxMathematicalConsistency() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // Verify mathematical consistency
        let profitPerShare = result.requiredSalePrice - 80.0
        let capitalGainsRate = 0.22 + 0.05 + 0.038
        let expectedCapitalGainsTax = profitPerShare * capitalGainsRate * 75.0
        
        XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.01)
    }
    
    func testPerformanceWithNetInvestmentTax() {
        measure {
            let result = calculator.calculateRequiredSalePrice(
                vcdPrice: 100.0,
                vestingShares: 1000,
                vestDayPrice: 80.0,
                medicareRate: 0.0145,
            socialSecurityRate: 0.062,
                federalRate: 0.22,
                saltRate: 0.05,
                sharesSoldForTaxes: 250,
                taxSalePrice: 80.0,
                includeCapitalGains: true,
                includeNetInvestmentTax: true
            )
            XCTAssertNotNil(result)
        }
    }
} 