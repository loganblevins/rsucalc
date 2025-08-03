import XCTest
@testable import RSUCalculatorCore

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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 25)
        XCTAssertEqual(result.vcdPrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.vestDayPrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.taxSalePrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareRate, 0.0145, accuracy: 0.0001)
        XCTAssertEqual(result.socialSecurityRate, 0.062, accuracy: 0.0001)
        XCTAssertEqual(result.federalRate, 0.22, accuracy: 0.0001)
        XCTAssertEqual(result.saltRate, 0.05, accuracy: 0.0001)
        
        // Test calculated income fields
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 10000.0, accuracy: 0.01)
        
        // Test tax calculations
        XCTAssertEqual(result.totalTaxRate, 0.3465, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 3465.0, accuracy: 0.01)
        XCTAssertEqual(result.federalTax, 2200.0, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 620.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 145.0, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 500.0, accuracy: 0.01)
        
        // Test target and result calculations
        XCTAssertEqual(result.sharesAfterTaxSale, 75)
        XCTAssertEqual(result.taxSaleProceeds, 2500.0, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, -965.0, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 6535.0, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 7500.0, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 7500.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 20)
        XCTAssertEqual(result.vcdPrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.vestDayPrice, 120.0, accuracy: 0.01)
        XCTAssertEqual(result.taxSalePrice, 120.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareRate, 0.0145, accuracy: 0.0001)
        XCTAssertEqual(result.socialSecurityRate, 0.062, accuracy: 0.0001)
        XCTAssertEqual(result.federalRate, 0.22, accuracy: 0.0001)
        XCTAssertEqual(result.saltRate, 0.0, accuracy: 0.0001)
        
        // Test calculated income fields
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 12000.0, accuracy: 0.01)
        
        // Test tax calculations
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 3558.0, accuracy: 0.01)
        XCTAssertEqual(result.federalTax, 2640.0, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 744.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 174.0, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test target and result calculations
        XCTAssertEqual(result.sharesAfterTaxSale, 80)
        XCTAssertEqual(result.taxSaleProceeds, 2400.0, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, -1158.0, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 7035.0, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 8193.0, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 8193.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 102.41, accuracy: 0.01)
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 100)
        XCTAssertEqual(result.vcdPrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.vestDayPrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.taxSalePrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareRate, 0.0145, accuracy: 0.0001)
        XCTAssertEqual(result.socialSecurityRate, 0.062, accuracy: 0.0001)
        XCTAssertEqual(result.federalRate, 0.22, accuracy: 0.0001)
        XCTAssertEqual(result.saltRate, 0.05, accuracy: 0.0001)
        
        // Test calculated income fields
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 10000.0, accuracy: 0.01)
        
        // Test tax calculations
        XCTAssertEqual(result.totalTaxRate, 0.3465, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 3465.0, accuracy: 0.01)
        XCTAssertEqual(result.federalTax, 2200.0, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 620.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 145.0, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 500.0, accuracy: 0.01)
        
        // Test target and result calculations
        XCTAssertEqual(result.sharesAfterTaxSale, 0)
        XCTAssertEqual(result.taxSaleProceeds, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 6535.0, accuracy: 0.01) // All proceeds are cash since tax covered
        XCTAssertEqual(result.originalNetIncomeTarget, 6535.0, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 0.0, accuracy: 0.01) // All target met by cash
        XCTAssertEqual(result.netIncomeTarget, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 0.0, accuracy: 0.01) // No shares left to sell
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        XCTAssertEqual(result.requiredSalePrice, result.netIncomeTarget / Decimal(result.sharesAfterTaxSale), accuracy: 0.01)
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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 25)
        XCTAssertEqual(result.vcdPrice, 100.0, accuracy: 0.01)
        XCTAssertEqual(result.vestDayPrice, 80.0, accuracy: 0.01)
        XCTAssertEqual(result.taxSalePrice, 80.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareRate, 0.0145, accuracy: 0.0001)
        XCTAssertEqual(result.socialSecurityRate, 0.062, accuracy: 0.0001)
        XCTAssertEqual(result.federalRate, 0.22, accuracy: 0.0001)
        XCTAssertEqual(result.saltRate, 0.05, accuracy: 0.0001)
        
        // Test calculated income fields
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 8000.0, accuracy: 0.01)
        
        // Test tax calculations
        XCTAssertEqual(result.totalTaxRate, 0.3465, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 2772.0, accuracy: 0.01)
        XCTAssertEqual(result.federalTax, 1760.0, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 496.0, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 116.0, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 400.0, accuracy: 0.01)
        
        // Test target and result calculations
        XCTAssertEqual(result.sharesAfterTaxSale, 75)
        XCTAssertEqual(result.taxSaleProceeds, 2000.0, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, -772.0, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 6535.0, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 7307.0, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 7307.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 103.87, accuracy: 0.01)
        
        // Test capital gains (should be present with this scenario)
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertEqual(result.capitalGainsTax!, 483.41, accuracy: 0.01)
        XCTAssertNil(result.niitTax) // NIIT not enabled in this test
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
        XCTAssertEqual(result.requiredSalePrice, 105.18, accuracy: 0.01)
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
        // Capital gains tax should now be only federal + SALT (32% + 9.3% = 41.3%), not including NIIT
        // Original total was 838.74, NIIT portion would be 3.8% / (32% + 9.3% + 3.8%) = 70.67
        // So capital gains only should be 838.74 - 70.67 = 768.07
        XCTAssertEqual(result.capitalGainsTax!, 768.07, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 104.8, accuracy: 0.01)
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
        XCTAssertEqual(result.requiredSalePrice, 105.28, accuracy: 0.01)
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
        XCTAssertEqual(result.requiredSalePrice, 103.87, accuracy: 0.01)
    }
    
    // MARK: - NIIT Amount Verification Tests
    
    func testNIITAmountCalculation() {
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
        
        // Verify NIIT tax amount is calculated and not nil
        XCTAssertNotNil(result.niitTax)
        
        // Calculate expected NIIT: 3.8% of profit per share * shares after tax sale
        let profitPerShare = result.requiredSalePrice - Decimal(80.0)
        let expectedNIIT = profitPerShare * Decimal(0.038) * Decimal(75)
        
        XCTAssertEqual(result.niitTax!, expectedNIIT, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 105.18, accuracy: 0.01)
    }
    
    func testNIITAmountWhenDisabled() {
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
        
        // NIIT should be nil when not enabled
        XCTAssertNil(result.niitTax)
        XCTAssertEqual(result.requiredSalePrice, 103.87, accuracy: 0.01)
    }
    
    func testNIITAmountWhenNoCapitalGains() {
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
            includeCapitalGains: false,
            includeNetInvestmentTax: true
        )
        
        // NIIT should be nil when capital gains are disabled
        XCTAssertNil(result.niitTax)
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
    }
    
    func testNIITAmountWhenSellingAtVestPrice() {
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
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // NIIT should be nil when selling at vest price (no profit)
        XCTAssertNil(result.niitTax)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertEqual(result.requiredSalePrice, 100.0, accuracy: 0.01)
    }
    
    func testNIITAmountPrecisionHighValue() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 200.0,
            vestingShares: 1000,
            vestDayPrice: 155.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.05,
            sharesSoldForTaxes: 100,
            taxSalePrice: 155.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // Verify NIIT is calculated for high-value scenario
        XCTAssertNotNil(result.niitTax)
        
        // Verify NIIT is a reasonable portion of total capital gains
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertLessThan(result.niitTax!, result.capitalGainsTax!)
        
        // NIIT and capital gains are now calculated separately
        // Both should be 3.8% of the same profit base
        // So NIIT should be (3.8% / (22% + 5%)) * capitalGainsTax = (3.8% / 27%) * capitalGainsTax
        let capitalGainsRate = Decimal(0.22) + Decimal(0.05) // 27%
        let niitRate = Decimal(0.038) // 3.8%
        let expectedNIITRatio = niitRate / capitalGainsRate
        let expectedNIITFromCapitalGains = result.capitalGainsTax! * expectedNIITRatio
        XCTAssertEqual(result.niitTax!, expectedNIITFromCapitalGains, accuracy: 0.01)
        
        // Verify NIIT amount is positive and reasonable
        XCTAssertGreaterThan(result.niitTax!, Decimal(1000))
        XCTAssertLessThan(result.niitTax!, Decimal(5000))
        XCTAssertEqual(result.requiredSalePrice, 202.22, accuracy: 0.01)
    }
    
    func testNIITAmountWithZeroSALT() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 150.0,
            vestingShares: 500,
            vestDayPrice: 120.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.22,
            saltRate: 0.0, // No SALT tax
            sharesSoldForTaxes: 50,
            taxSalePrice: 120.0,
            includeCapitalGains: true,
            includeNetInvestmentTax: true
        )
        
        // Verify NIIT is calculated even with zero SALT
        XCTAssertNotNil(result.niitTax)
        
        // NIIT and capital gains are now calculated separately on the same profit base
        // Capital gains = 22% of profit, NIIT = 3.8% of profit
        // So NIIT should be (3.8% / 22%) * capitalGainsTax
        let capitalGainsRate = Decimal(0.22) // 22% (federal only, no SALT)
        let niitRate = Decimal(0.038) // 3.8%
        let expectedNIITRatio = niitRate / capitalGainsRate
        let expectedNIITFromCapitalGains = result.capitalGainsTax! * expectedNIITRatio
        XCTAssertEqual(result.niitTax!, expectedNIITFromCapitalGains, accuracy: 0.01)
        
        // Verify NIIT amount is positive and reasonable for this scenario
        XCTAssertGreaterThan(result.niitTax!, Decimal(400))
        XCTAssertLessThan(result.niitTax!, Decimal(800))
        XCTAssertEqual(result.requiredSalePrice, 151.6, accuracy: 0.01)
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
        XCTAssertEqual(result.grossIncomeVCD, 35605.62, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 49424.70, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(result.taxAmount, 14654.42, accuracy: 0.01)
        XCTAssertEqual(result.taxSaleProceeds, 15177.94, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 523.52, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 25048.55, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 24525.03, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(result.federalTax, 10873.43, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 716.66, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 3064.33, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test result fields
        XCTAssertEqual(result.netIncomeTarget, 24525.03, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 63.70, accuracy: 0.01)
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        XCTAssertEqual(result.grossIncomeVCD, 35605.62, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 45755.04, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(result.taxAmount, 13566.37, accuracy: 0.01)
        XCTAssertEqual(result.taxSaleProceeds, 13573.28, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 6.91, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 25048.55, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 25041.63, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(result.federalTax, 10066.11, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 663.45, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 2836.81, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test result fields
        XCTAssertEqual(result.netIncomeTarget, 25041.63, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 69.95, accuracy: 0.01)
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        XCTAssertEqual(result.grossIncomeVCD, 35605.62, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 31594.34, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(result.taxAmount, 9367.72, accuracy: 0.01)
        XCTAssertEqual(result.taxSaleProceeds, 9416.90, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 49.18, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 25048.55, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 24999.37, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(result.federalTax, 6950.75, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 458.12, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 1958.85, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test result fields
        XCTAssertEqual(result.netIncomeTarget, 24999.37, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 65.10, accuracy: 0.01)
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        XCTAssertEqual(result.grossIncomeVCD, 4312.35, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 3612.42, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001) // 22% + 6.2% + 1.45% = 29.65%
        XCTAssertEqual(result.taxAmount, 1071.08, accuracy: 0.01)
        XCTAssertEqual(result.taxSaleProceeds, 1071.46, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 0.38, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 3033.74, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 3033.36, accuracy: 0.01)
        
        // Test individual tax components with cent-level precision
        XCTAssertEqual(result.federalTax, 794.73, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 52.38, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 223.97, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test result fields
        XCTAssertEqual(result.netIncomeTarget, 3033.36, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 68.94, accuracy: 0.01)
        
        // Test optional fields (should be nil for non-capital gains scenario)
        XCTAssertNil(result.capitalGainsTax)
        XCTAssertNil(result.niitTax)
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
        XCTAssertEqual(result1.requiredSalePrice, 99.32, accuracy: 0.01)
        
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
        XCTAssertEqual(result2.requiredSalePrice, 75.77, accuracy: 0.01)
        
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
        XCTAssertEqual(result3.requiredSalePrice, 80.63, accuracy: 0.01)
        
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
        XCTAssertEqual(result4.requiredSalePrice, 50.36, accuracy: 0.01)
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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 551)
        XCTAssertEqual(result.sharesSoldForTaxes, 166)
        XCTAssertEqual(result.vcdPrice, 80.0, accuracy: 0.01)
        XCTAssertEqual(result.vestDayPrice, 89.70, accuracy: 0.01)
        XCTAssertEqual(result.taxSalePrice, 91.4334, accuracy: 0.01)
        XCTAssertEqual(result.medicareRate, 0.0145, accuracy: 0.0001)
        XCTAssertEqual(result.socialSecurityRate, 0.062, accuracy: 0.0001)
        XCTAssertEqual(result.federalRate, 0.22, accuracy: 0.0001)
        XCTAssertEqual(result.saltRate, 0.0, accuracy: 0.0001)
        
        // Test calculated income and tax fields
        XCTAssertEqual(result.grossIncomeVCD, 44080.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 49424.70, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 14654.42, accuracy: 0.01)
        XCTAssertEqual(result.federalTax, 10873.43, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 3064.33, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 716.66, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test target and result calculations
        XCTAssertEqual(result.sharesAfterTaxSale, 385)
        XCTAssertEqual(result.taxSaleProceeds, 15177.94, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 523.52, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 31010.28, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 30486.76, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 30486.76, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 79.19, accuracy: 0.01)
        
        // Check if capital gains tax should be applied (only if required sale price > vest day price)
        if result.requiredSalePrice > Decimal(89.70) {
            XCTAssertNotNil(result.capitalGainsTax)
            
            // Capital gains rate should be federal only = 22% (no SALT)
            let profitPerShare = result.requiredSalePrice - Decimal(89.70)
            let expectedCapitalGainsTax = profitPerShare * Decimal(0.22) * Decimal(385)
            XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.01)
        } else {
            XCTAssertNil(result.capitalGainsTax)
        }
        
        // NIIT should be nil since includeNetInvestmentTax is not enabled
        XCTAssertNil(result.niitTax)
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
        
        // Test input parameters
        XCTAssertEqual(result.vestingShares, 551)
        XCTAssertEqual(result.sharesSoldForTaxes, 193)
        XCTAssertEqual(result.vcdPrice, 90.0, accuracy: 0.01)
        XCTAssertEqual(result.vestDayPrice, 83.04, accuracy: 0.01)
        XCTAssertEqual(result.taxSalePrice, 70.3279, accuracy: 0.01)
        XCTAssertEqual(result.medicareRate, 0.0145, accuracy: 0.0001)
        XCTAssertEqual(result.socialSecurityRate, 0.062, accuracy: 0.0001)
        XCTAssertEqual(result.federalRate, 0.22, accuracy: 0.0001)
        XCTAssertEqual(result.saltRate, 0.0, accuracy: 0.0001)
        
        // Test calculated income fields
        XCTAssertEqual(result.grossIncomeVCD, 49590.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 45755.04, accuracy: 0.01)
        
        // Test tax calculations
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 13566.37, accuracy: 0.01)
        XCTAssertEqual(result.federalTax, 10066.11, accuracy: 0.01)
        XCTAssertEqual(result.socialSecurityTax, 2836.81, accuracy: 0.01)
        XCTAssertEqual(result.medicareTax, 663.45, accuracy: 0.01)
        XCTAssertEqual(result.saltTax, 0.0, accuracy: 0.01)
        
        // Test target and result calculations
        XCTAssertEqual(result.sharesAfterTaxSale, 358)
        XCTAssertEqual(result.taxSaleProceeds, 13573.28, accuracy: 0.01)
        XCTAssertEqual(result.cashDistribution, 6.91, accuracy: 0.01)
        XCTAssertEqual(result.originalNetIncomeTarget, 34886.56, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 34879.65, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 34879.65, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 102.43, accuracy: 0.01)
        
        // Test capital gains and NIIT (should be present since required sale price > vest day price)
        XCTAssertNotNil(result.capitalGainsTax)
        XCTAssertEqual(result.capitalGainsTax!, 1527.35, accuracy: 0.01)
        XCTAssertNotNil(result.niitTax)
        XCTAssertEqual(result.niitTax!, 263.81, accuracy: 0.01)
    }

    // MARK: - Mathematical Consistency Tests
    
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
    
    // MARK: - Tax Sale Price Impact Tests
    
    func testTaxSaleSurplusScenario() {
        // Test scenario where tax sale proceeds exceed tax amount, creating positive cash distribution
        // Based on CLI testing: High tax sale price should reduce required sale price
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 100,
            vestDayPrice: 75.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.24,
            saltRate: 0.08,
            sharesSoldForTaxes: 30,
            taxSalePrice: 120.0  // High price creates surplus
        )
        
        // Test basic parameters
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 30)
        XCTAssertEqual(result.sharesAfterTaxSale, 70)
        XCTAssertEqual(result.taxSalePrice, 120.0)
        
        // Test calculated values
        XCTAssertEqual(result.grossIncomeVCD, 5000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 7500.0, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.3965, accuracy: 0.0001) // 24% + 6.2% + 1.45% + 8% = 39.65%
        XCTAssertEqual(result.taxAmount, 2973.75, accuracy: 0.01)
        XCTAssertEqual(result.taxSaleProceeds, 3600.0, accuracy: 0.01) // 30 × $120
        
        // Test surplus cash distribution (key behavior)
        XCTAssertEqual(result.cashDistribution, 626.25, accuracy: 0.01) // $3600 - $2973.75 = $626.25
        XCTAssertTrue(result.cashDistribution > 0, "Should have positive cash distribution due to surplus")
        
        // Test that surplus reduces the required sale price target
        XCTAssertEqual(result.originalNetIncomeTarget, 3017.50, accuracy: 0.01) // 60% of $5025 vest income
        XCTAssertEqual(result.adjustedNetIncomeTarget, 2391.25, accuracy: 0.01) // Reduced due to surplus
        XCTAssertEqual(result.requiredSalePrice, 34.16, accuracy: 0.01)
        
        // Verify no capital gains (selling below vest price)
        XCTAssertTrue(result.requiredSalePrice < result.vestDayPrice, "Should be selling below vest price")
    }
    
    func testTaxSaleShortfallScenario() {
        // Test scenario where tax sale proceeds are insufficient, creating negative cash distribution
        // Lower tax sale price should increase required sale price
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 100,
            vestDayPrice: 75.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.24,
            saltRate: 0.08,
            sharesSoldForTaxes: 30,
            taxSalePrice: 76.0  // Lower price creates shortfall
        )
        
        // Test basic parameters
        XCTAssertEqual(result.vestingShares, 100)
        XCTAssertEqual(result.sharesSoldForTaxes, 30)
        XCTAssertEqual(result.sharesAfterTaxSale, 70)
        XCTAssertEqual(result.taxSalePrice, 76.0)
        
        // Test calculated values
        XCTAssertEqual(result.grossIncomeVCD, 5000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 7500.0, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.3965, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 2973.75, accuracy: 0.01)
        XCTAssertEqual(result.taxSaleProceeds, 2280.0, accuracy: 0.01) // 30 × $76
        
        // Test shortfall cash distribution (key behavior)
        XCTAssertEqual(result.cashDistribution, -693.75, accuracy: 0.01) // $2280 - $2973.75 = -$693.75
        XCTAssertTrue(result.cashDistribution < 0, "Should have negative cash distribution due to shortfall")
        
        // Test that shortfall increases the required sale price target
        XCTAssertEqual(result.originalNetIncomeTarget, 3017.50, accuracy: 0.01)
        XCTAssertEqual(result.adjustedNetIncomeTarget, 3711.25, accuracy: 0.01) // Increased due to shortfall
        XCTAssertEqual(result.requiredSalePrice, 53.02, accuracy: 0.01)
        
        // Verify still no capital gains (selling below vest price, but higher than surplus case)
        XCTAssertTrue(result.requiredSalePrice < result.vestDayPrice, "Should be selling below vest price")
        XCTAssertTrue(result.requiredSalePrice > 34.16, "Should be higher than surplus scenario")
    }
    
    func testExtremeHighTaxSalePriceScenario() {
        // Test with extremely high tax sale price to validate edge case behavior
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 100,
            vestDayPrice: 75.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.24,
            saltRate: 0.08,
            sharesSoldForTaxes: 30,
            taxSalePrice: 200.0  // Extremely high price
        )
        
        // Test that extreme surplus works correctly
        XCTAssertEqual(result.taxSaleProceeds, 6000.0, accuracy: 0.01) // 30 × $200
        XCTAssertEqual(result.cashDistribution, 3026.25, accuracy: 0.01) // $6000 - $2973.75
        XCTAssertTrue(result.cashDistribution > 3000, "Should have very large surplus")
        
        // Test that required sale price becomes very low (might be negative in extreme surplus cases)
        XCTAssertTrue(result.requiredSalePrice < 20.0, "Should be very low due to large surplus")
        // In extreme surplus cases, the calculator might return negative prices (mathematical result)
        // This is expected behavior when surplus far exceeds remaining share needs
    }
    
    func testExtremelyLowTaxSalePriceScenario() {
        // Test with extremely low tax sale price to validate edge case behavior
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 100,
            vestDayPrice: 75.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.24,
            saltRate: 0.08,
            sharesSoldForTaxes: 30,
            taxSalePrice: 20.0  // Extremely low price
        )
        
        // Test that extreme shortfall works correctly
        XCTAssertEqual(result.taxSaleProceeds, 600.0, accuracy: 0.01) // 30 × $20
        XCTAssertEqual(result.cashDistribution, -2373.75, accuracy: 0.01) // $600 - $2973.75
        XCTAssertTrue(result.cashDistribution < -2000, "Should have very large shortfall")
        
        // Test that required sale price increases significantly
        XCTAssertTrue(result.requiredSalePrice > 75.0, "Should exceed vest day price due to large shortfall")
        XCTAssertTrue(result.requiredSalePrice < 150.0, "Should still be reasonable")
    }
    
    func testCapitalGainsBoundaryCondition() {
        // Test the exact boundary where required sale price equals vest day price
        // This should be the threshold between capital gains vs no capital gains
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 80.0,
            vestingShares: 100,
            vestDayPrice: 75.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.12,
            saltRate: 0.05,
            sharesSoldForTaxes: 30,
            taxSalePrice: 76.0,
            includeCapitalGains: true
        )
        
        // Test input parameters
        XCTAssertEqual(result.vcdPrice, 80.0)
        XCTAssertEqual(result.vestDayPrice, 75.0)
        XCTAssertTrue(result.vcdPrice > result.vestDayPrice, "VCD price should be higher than vest price")
        
        // Test that this scenario triggers capital gains (required sale > vest price)
        XCTAssertTrue(result.requiredSalePrice > result.vestDayPrice, "Should require selling above vest price")
        XCTAssertNotNil(result.capitalGainsTax, "Should have capital gains tax")
        XCTAssertTrue(result.capitalGainsTax! > 0, "Capital gains tax should be positive")
        
        // Test capital gains calculation
        let priceGain = result.requiredSalePrice - result.vestDayPrice
        let expectedCapitalGain = priceGain * Decimal(result.sharesAfterTaxSale)
        let taxRate = result.federalRate + result.saltRate
        let expectedCapitalGainsTax = expectedCapitalGain * taxRate
        XCTAssertEqual(result.capitalGainsTax!, expectedCapitalGainsTax, accuracy: 0.05)
        
        // If NIIT is included, test that too
        if let niitTax = result.niitTax {
            let expectedNIIT = expectedCapitalGain * Decimal(0.038) // 3.8% NIIT rate
            XCTAssertEqual(niitTax, expectedNIIT, accuracy: 0.01)
        }
        
        // Test the boundary behavior: small change in parameters should flip capital gains on/off
        let resultWithoutCapitalGains = calculator.calculateRequiredSalePrice(
            vcdPrice: 80.0,
            vestingShares: 100,
            vestDayPrice: 75.0,
            medicareRate: 0.0145,
            socialSecurityRate: 0.062,
            federalRate: 0.12,
            saltRate: 0.05,
            sharesSoldForTaxes: 30,
            taxSalePrice: 76.0,
            includeCapitalGains: false
        )
        
        XCTAssertTrue(result.requiredSalePrice > resultWithoutCapitalGains.requiredSalePrice, 
                     "Capital gains should increase required sale price")
    }
} 
