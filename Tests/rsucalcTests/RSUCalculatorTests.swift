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
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.3465, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 3465.0, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 6535.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 75)
        XCTAssertEqual(result.taxSaleProceeds, 2500.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 87.13, accuracy: 0.01)
    }
    
    func testRealWorldScenario() {
        // Test with the real numbers provided by the user
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 64.62,
            vestingShares: 551,
            vestDayPrice: 83.04,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.0,
            sharesSoldForTaxes: 193,
            taxSalePrice: 70.3279
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 35605.62, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 45755.04, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, 13566.37, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, 25048.55, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 358)
        XCTAssertEqual(result.taxSaleProceeds, 13573.28, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 69.97, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func testZeroStateTax() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.0,
            sharesSoldForTaxes: 20,
            taxSalePrice: 120.0
        )
        
        XCTAssertEqual(result.totalTaxRate, 0.2965, accuracy: 0.0001)
        XCTAssertEqual(result.netIncomeTarget, 7035.0, accuracy: 0.01)
    }
    
    func testHighTaxRates() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            ficaRate: 0.0765,
            federalRate: 0.37,
            stateRate: 0.13,
            sharesSoldForTaxes: 50,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.totalTaxRate, 0.5765, accuracy: 0.0001)
        XCTAssertEqual(result.netIncomeTarget, 4235.0, accuracy: 0.01)
    }
    
    func testAllSharesSoldForTaxes() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 100.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
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
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 0,
            taxSalePrice: 100.0
        )
        
        XCTAssertEqual(result.sharesAfterTaxSale, 100)
        XCTAssertEqual(result.taxSaleProceeds, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 65.35, accuracy: 0.01)
    }
    
    func testVestDayPriceHigherThanVCD() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 150.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 150.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 15000.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 87.13, accuracy: 0.01)
    }
    
    func testVestDayPriceLowerThanVCD() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 80.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 80.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 10000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 8000.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 87.13, accuracy: 0.01)
    }
    
    // MARK: - Large Numbers
    
    func testLargeShareCount() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 50.0,
            vestingShares: 10000,
            vestDayPrice: 60.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 2500,
            taxSalePrice: 60.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 500000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 600000.0, accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 7500)
        XCTAssertEqual(result.requiredSalePrice, 43.57, accuracy: 0.01)
    }
    
    func testHighPricePerShare() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 1000.0,
            vestingShares: 100,
            vestDayPrice: 1200.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 1200.0
        )
        
        XCTAssertEqual(result.grossIncomeVCD, 100000.0, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 120000.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, 871.33, accuracy: 0.01)
    }
    
    // MARK: - Precision Tests
    
    func testPrecisionWithDecimals() {
        let result = calculator.calculateRequiredSalePrice(
            vcdPrice: 64.62,
            vestingShares: 551,
            vestDayPrice: 83.04,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.0,
            sharesSoldForTaxes: 193,
            taxSalePrice: 70.3279
        )
        
        // Test that we get the exact expected values with proper precision
        XCTAssertEqual(result.netIncomeTarget, 25048.5537, accuracy: 0.0001)
        XCTAssertEqual(result.requiredSalePrice, 69.97, accuracy: 0.01)
    }
    
    // MARK: - Input Validation Tests
    
    func testValidateInputsWithValidData() {
        let errors = calculator.validateInputs(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
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
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
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
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
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
            ficaRate: 1.5, // Invalid: > 1
            federalRate: -0.1, // Invalid: < 0
            stateRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        XCTAssertTrue(errors.contains("FICA rate must be between 0 and 1"))
        XCTAssertTrue(errors.contains("Federal tax rate must be between 0 and 1"))
    }
    
    func testValidateInputsWithTooManySharesSoldForTaxes() {
        let errors = calculator.validateInputs(
            vcdPrice: 100.0,
            vestingShares: 100,
            vestDayPrice: 120.0,
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
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
            ficaRate: 0.5,
            federalRate: 0.4,
            stateRate: 0.2, // Total = 110%
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
            ficaRate: 0.0765,
            federalRate: 0.22,
            stateRate: 0.05,
            sharesSoldForTaxes: 25,
            taxSalePrice: 120.0
        )
        
        // Verify mathematical relationships
        XCTAssertEqual(result.grossIncomeVCD, 100.0 * 100, accuracy: 0.01)
        XCTAssertEqual(result.grossIncomeVestDay, 120.0 * 100, accuracy: 0.01)
        XCTAssertEqual(result.totalTaxRate, 0.0765 + 0.22 + 0.05, accuracy: 0.0001)
        XCTAssertEqual(result.taxAmount, result.grossIncomeVestDay * result.totalTaxRate, accuracy: 0.01)
        XCTAssertEqual(result.netIncomeTarget, result.grossIncomeVCD * (1 - result.totalTaxRate), accuracy: 0.01)
        XCTAssertEqual(result.sharesAfterTaxSale, 100 - 25)
        XCTAssertEqual(result.taxSaleProceeds, 25.0 * 120.0, accuracy: 0.01)
        XCTAssertEqual(result.requiredSalePrice, result.netIncomeTarget / Double(result.sharesAfterTaxSale), accuracy: 0.01)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeNumbers() {
        measure {
            _ = calculator.calculateRequiredSalePrice(
                vcdPrice: 100.0,
                vestingShares: 100000,
                vestDayPrice: 120.0,
                ficaRate: 0.0765,
                federalRate: 0.22,
                stateRate: 0.05,
                sharesSoldForTaxes: 25000,
                taxSalePrice: 120.0
            )
        }
    }
} 