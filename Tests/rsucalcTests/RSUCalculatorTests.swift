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
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxAmount).doubleValue, 13566.37, accuracy: 0.01)
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
        XCTAssertEqual(NSDecimalNumber(decimal: result.requiredSalePrice).doubleValue, NSDecimalNumber(decimal: result.netIncomeTarget / Decimal(result.sharesAfterTaxSale)).doubleValue, accuracy: 0.01)
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
    
    func testPerformanceComprehensive() {
        measure {
            // Test 1: Large numbers without capital gains
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
            
            // Test 2: With capital gains
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
            
            // Test 3: With capital gains + NIIT
            _ = calculator.calculateRequiredSalePrice(
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
        
        // Capital gains tax should exist and include NIIT
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertTrue(result.capitalGainsTax! > 0)
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
        
        // Capital gains tax should exist and include NIIT but no SALT
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertTrue(result.capitalGainsTax! > 0)
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
        
        // Capital gains tax should exist when no NIIT
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertTrue(result.capitalGainsTax! > 0)
    }
    

    

    
    // MARK: - Real-World Case Tests
    
    func testRealWorldCase1() {
        // Case 1: High price scenario
        // Market Value: $49,424.70 (551 shares @ $89.70)
        // Tax Sale: 166 shares @ $91.4334 = $15,177.94
        // Total Tax: $14,654.42
        // Cash Distribution: $523.52
        // Shares Issued: 385
        
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 64.62,
            vestingShares: 551,
            vestDayPrice: 89.70,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 166,
            taxSalePrice: 91.4334
        )
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 551)
        XCTAssertEqual(result.sharesSoldForTaxes, 166)
        XCTAssertEqual(result.sharesAfterTaxSale, 385)
        XCTAssertEqual(result.vcdPrice, 64.62)
        XCTAssertEqual(result.vestDayPrice, 89.70)
        XCTAssertEqual(result.taxSalePrice, 91.4334)
        XCTAssertEqual(result.medicareRate, 0.0145)
        XCTAssertEqual(result.socialSecurityRate, 0.062)
        XCTAssertEqual(result.federalRate, 0.22)
        XCTAssertEqual(result.saltRate, 0.0)
        
        // Test calculated values with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVCD).doubleValue, 35605.62, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVestDay).doubleValue, 49424.70, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.totalTaxRate).doubleValue, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxAmount).doubleValue, 14654.42, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxSaleProceeds).doubleValue, 15177.94, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.cashDistribution).doubleValue, 523.52, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.originalNetIncomeTarget).doubleValue, 25048.55, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.adjustedNetIncomeTarget).doubleValue, 24525.03, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.federalTax).doubleValue, 10873.43, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.medicareTax).doubleValue, 716.66, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.socialSecurityTax).doubleValue, 3064.33, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.saltTax).doubleValue, 0.0, accuracy: 0.01)
    }
    
    func testRealWorldCase2() {
        // Case 2: Lower price scenario
        // Market Value: $45,755.04 (551 shares @ $83.04)
        // Tax Sale: 193 shares @ $70.3279 = $13,573.28
        // Total Tax: $13,566.37
        // Cash Distribution: $6.91
        // Shares Issued: 358
        
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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 551)
        XCTAssertEqual(result.sharesSoldForTaxes, 193)
        XCTAssertEqual(result.sharesAfterTaxSale, 358)
        XCTAssertEqual(result.vcdPrice, 64.62)
        XCTAssertEqual(result.vestDayPrice, 83.04)
        XCTAssertEqual(result.taxSalePrice, 70.3279)
        XCTAssertEqual(result.medicareRate, 0.0145)
        XCTAssertEqual(result.socialSecurityRate, 0.062)
        XCTAssertEqual(result.federalRate, 0.22)
        XCTAssertEqual(result.saltRate, 0.0)
        
        // Test calculated values with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVCD).doubleValue, 35605.62, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVestDay).doubleValue, 45755.04, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.totalTaxRate).doubleValue, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxAmount).doubleValue, 13566.37, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxSaleProceeds).doubleValue, 13573.28, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.cashDistribution).doubleValue, 6.91, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.originalNetIncomeTarget).doubleValue, 25048.55, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.adjustedNetIncomeTarget).doubleValue, 25041.63, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.federalTax).doubleValue, 10066.11, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.medicareTax).doubleValue, 663.45, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.socialSecurityTax).doubleValue, 2836.81, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.saltTax).doubleValue, 0.0, accuracy: 0.01)
    }
    
    func testRealWorldCase3() {
        // Case 3: Much lower price scenario
        // Market Value: $31,594.34 (551 shares @ $57.34)
        // Tax Sale: 167 shares @ $56.3886 = $9,416.90
        // Total Tax: $9,367.72
        // Cash Distribution: $49.18
        // Shares Issued: 384
        
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 64.62,
            vestingShares: 551,
            vestDayPrice: 57.34,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 167,
            taxSalePrice: 56.3886
        )
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 551)
        XCTAssertEqual(result.sharesSoldForTaxes, 167)
        XCTAssertEqual(result.sharesAfterTaxSale, 384)
        XCTAssertEqual(result.vcdPrice, 64.62)
        XCTAssertEqual(result.vestDayPrice, 57.34)
        XCTAssertEqual(result.taxSalePrice, 56.3886)
        XCTAssertEqual(result.medicareRate, 0.0145)
        XCTAssertEqual(result.socialSecurityRate, 0.062)
        XCTAssertEqual(result.federalRate, 0.22)
        XCTAssertEqual(result.saltRate, 0.0)
        
        // Test calculated values with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVCD).doubleValue, 35605.62, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVestDay).doubleValue, 31594.34, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.totalTaxRate).doubleValue, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxAmount).doubleValue, 9367.72, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxSaleProceeds).doubleValue, 9416.90, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.cashDistribution).doubleValue, 49.18, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.originalNetIncomeTarget).doubleValue, 25048.55, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.adjustedNetIncomeTarget).doubleValue, 24999.37, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.federalTax).doubleValue, 6950.75, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.medicareTax).doubleValue, 458.12, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.socialSecurityTax).doubleValue, 1958.85, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.saltTax).doubleValue, 0.0, accuracy: 0.01)
    }
    
    func testRealWorldCase4() {
        // Case 4: Small award scenario (63 shares)
        // Market Value: $3,612.42 (63 shares @ $57.340000)
        // Tax Sale: 19 shares @ $56.392400 = $1,071.46  
        // Total Tax: $1,071.08
        // Cash Distribution: $0.38
        // Shares Issued: 44
        // Federal Tax: $794.73 (22%), Medicare: $52.38 (1.45%), Social Security: $223.97 (6.2%)
        
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 68.45,
            vestingShares: 63,
            vestDayPrice: 57.340000,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 19,
            taxSalePrice: 56.392400
        )
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 63)
        XCTAssertEqual(result.sharesSoldForTaxes, 19)
        XCTAssertEqual(result.sharesAfterTaxSale, 44)
        XCTAssertEqual(result.vcdPrice, 68.45)
        XCTAssertEqual(result.vestDayPrice, 57.340000)
        XCTAssertEqual(result.taxSalePrice, 56.392400)
        XCTAssertEqual(result.medicareRate, 0.0145)
        XCTAssertEqual(result.socialSecurityRate, 0.062)
        XCTAssertEqual(result.federalRate, 0.22)
        XCTAssertEqual(result.saltRate, 0.0)
        
        // Test calculated values with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVCD).doubleValue, 4312.35, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.grossIncomeVestDay).doubleValue, 3612.42, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.totalTaxRate).doubleValue, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxAmount).doubleValue, 1071.08, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.taxSaleProceeds).doubleValue, 1071.46, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.cashDistribution).doubleValue, 0.38, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.originalNetIncomeTarget).doubleValue, 3033.74, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.adjustedNetIncomeTarget).doubleValue, 3033.36, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(NSDecimalNumber(decimal: result.federalTax).doubleValue, 794.73, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.medicareTax).doubleValue, 52.38, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.socialSecurityTax).doubleValue, 223.97, accuracy: 0.01)
        XCTAssertEqual(NSDecimalNumber(decimal: result.saltTax).doubleValue, 0.0, accuracy: 0.01)
    }
    
    func testRealWorldCasesWithDifferentVCDPrices() {
        // Test all four cases with different VCD prices to simulate real scenarios
        // where the VCD price differs from the vest day price
        
        // Case 1 with VCD price = $100 (higher than vest day price)
        let result1 = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 551,
            vestDayPrice: 89.70,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 166,
            taxSalePrice: 91.4334
        )
        
        XCTAssertEqual(result1.grossIncomeVCD, 55100.0, accuracy: 0.01)
        XCTAssertEqual(result1.grossIncomeVestDay, 49424.70, accuracy: 0.01)
        XCTAssertEqual(result1.sharesAfterTaxSale, 385)
        
        // Case 2 with VCD price = $70 (lower than vest day price)
        let result2 = calculator.calculateRequiredSalePrice(
            vcdPrice: 70.0,
            vestingShares: 551,
            vestDayPrice: 83.04,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 193,
            taxSalePrice: 70.3279
        )
        
        XCTAssertEqual(result2.grossIncomeVCD, 38570.0, accuracy: 0.01)
        XCTAssertEqual(result2.grossIncomeVestDay, 45755.04, accuracy: 0.01)
        XCTAssertEqual(result2.sharesAfterTaxSale, 358)
        
        // Case 3 with VCD price = $80 (higher than vest day price)
        let result3 = calculator.calculateRequiredSalePrice(
            vcdPrice: 80.0,
            vestingShares: 551,
            vestDayPrice: 57.34,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 167,
            taxSalePrice: 56.3886
        )
        
        XCTAssertEqual(result3.grossIncomeVCD, 44080.0, accuracy: 0.01)
        XCTAssertEqual(result3.grossIncomeVestDay, 31594.34, accuracy: 0.01)
        XCTAssertEqual(result3.sharesAfterTaxSale, 384)
        
        // Case 4 with VCD price = $50 (lower than vest day price)
        let result4 = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 63,
            vestDayPrice: 57.34,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 19,
            taxSalePrice: 56.3924
        )
        
        XCTAssertEqual(result4.grossIncomeVCD, 3150.0, accuracy: 0.01)
        XCTAssertEqual(result4.grossIncomeVestDay, 3612.42, accuracy: 0.01)
        XCTAssertEqual(result4.sharesAfterTaxSale, 44)
    }
    
    func testRealWorldCasesWithCapitalGains() {
        // Test real-world cases with capital gains enabled
        // Case 1: VCD price = $80, vest day price = $89.70 (profit scenario)
        
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 80.0,
            vestingShares: 551,
            vestDayPrice: 89.70,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 166,
            taxSalePrice: 91.4334,
            includeCapitalGains: true
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 44080.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 49424.70, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 385)
        
        // Check if capital gains tax should be applied (only if required sale price > vest day price)
        if result.requiredSalePrice > Decimal(89.70) {
            XCTAssertNotNil(result.capitalGainsTax)
            
            // Capital gains rate should be federal only = 22% (no SALT)
            let profitPerShare = result.requiredSalePrice - Decimal(89.70)
            let expectedCapitalGainsTax = profitPerShare * Decimal(0.22) * Decimal(385)
            XCTAssertEqual(NSDecimalNumber(decimal: result.capitalGainsTax!).doubleValue, NSDecimalNumber(decimal: expectedCapitalGainsTax).doubleValue, accuracy: 0.01)
        } else {
            XCTAssertNil(result.capitalGainsTax)
        }
    }
    
    func testRealWorldCasesWithNetInvestmentTax() {
        // Test real-world cases with both capital gains and NIIT enabled
        // Case 2: VCD price = $90, vest day price = $83.04 (loss scenario, but required sale price may be higher)
        
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 90.0,
            vestingShares: 551,
            vestDayPrice: 83.04,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0,
            sharesSoldForTaxes: 193,
            taxSalePrice: 70.3279,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 49590.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 45755.04, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 358)
        
        // If required sale price > vest day price, capital gains tax should be applied with NIIT
        if result.requiredSalePrice > Decimal(83.04) {
            XCTAssertNotNil(result.capitalGainsTax)
            
            // Capital gains tax should exist with NIIT
            XCTAssertTrue(result.capitalGainsTax! > 0)
        }
    }
    

    

    

    
    func testMathematicalConsistencyWithCleanData() {
        // Test that all mathematical relationships hold true with the enhanced result struct
        
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
        
        // Test input parameters are preserved
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 25)
        XCTAssertEqual(result.vcdPrice, 100.0)
        XCTAssertEqual(result.vestDayPrice, 120.0)
        XCTAssertEqual(result.taxSalePrice, 120.0)
        XCTAssertEqual(result.medicareRate, 0.0145)
        XCTAssertEqual(result.socialSecurityRate, 0.062)
        XCTAssertEqual(result.federalRate, 0.22)
        XCTAssertEqual(result.saltRate, 0.05)
        
        // Test calculated values
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 12000.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 75)
        XCTAssertEqual(result.taxSaleProceeds, 3000.0, accuracy: 0.01)
        
        // Test tax calculations
        XCTAssertEqual(result.federalTax, 2640.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 174.0, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 744.0, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 600.0, accuracy: 0.01)
        XCTAssertEqual(result.taxAmount, 4158.0, accuracy: 0.01)
        
        // Test cash distribution
        XCTAssertEqual(result.cashDistribution, -1158.0, accuracy: 0.01) // Negative because tax > proceeds
        
        // Test net income targets
        XCTAssertEqual(result.originalNetIncomeTarget, 6535.0, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 7693.0, accuracy: 0.01)
        
        // Test required sale price
        XCTAssertEqual(result.requiredSalePrice, 102.57, accuracy: 0.01)
    }
} 
