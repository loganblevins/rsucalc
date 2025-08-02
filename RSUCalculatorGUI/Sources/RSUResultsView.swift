import SwiftUI
import RSUCalculatorCore

struct RSUResultsView: View {
    @ObservedObject var viewModel: RSUCalculatorViewModel
    
    var body: some View {
        ScrollView {
            if let result = viewModel.calculationResult {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading) {
                        Text("Calculation Results")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("RSU vesting scenario analysis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                    
                    // Required Sale Price - Main Result
                    ResultCard(
                        title: "Required Sale Price",
                        value: viewModel.formatAsCurrency(result.requiredSalePrice),
                        subtitle: recommendationText(for: result),
                        color: recommendationColor(for: result),
                        icon: "dollarsign.circle.fill"
                    )
                    
                    // Input Summary
                    GroupBox("Input Summary") {
                        VStack(spacing: 12) {
                            ResultRow(label: "Vesting Shares", value: "\(result.vestingShares)")
                            ResultRow(label: "VCD Price", value: viewModel.formatAsCurrency(result.vcdPrice))
                            ResultRow(label: "Vest Day Price", value: viewModel.formatAsCurrency(result.vestDayPrice))
                            ResultRow(label: "Tax Sale Price", value: viewModel.formatAsCurrency(result.taxSalePrice))
                            ResultRow(label: "Shares Sold for Taxes", value: "\(result.sharesSoldForTaxes)")
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Tax Information
                    GroupBox("Tax Breakdown") {
                        VStack(spacing: 12) {
                            ResultRow(
                                label: "Total Tax Rate",
                                value: "\(viewModel.formatAsPercentage(result.totalTaxRate))%"
                            )
                            Divider()
                            ResultRow(label: "Federal Tax", value: viewModel.formatAsCurrency(result.federalTax))
                            ResultRow(label: "Social Security", value: viewModel.formatAsCurrency(result.socialSecurityTax))
                            ResultRow(label: "Medicare Tax", value: viewModel.formatAsCurrency(result.medicareTax))
                            ResultRow(label: "SALT Tax", value: viewModel.formatAsCurrency(result.saltTax))
                            Divider()
                            ResultRow(
                                label: "Total Taxes",
                                value: viewModel.formatAsCurrency(result.taxAmount),
                                isHighlighted: true
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Financial Breakdown
                    GroupBox("Financial Breakdown") {
                        VStack(spacing: 12) {
                            ResultRow(
                                label: "Gross Income (VCD)",
                                value: viewModel.formatAsCurrency(result.grossIncomeVCD)
                            )
                            ResultRow(
                                label: "Gross Income (Vest Day)",
                                value: viewModel.formatAsCurrency(result.grossIncomeVestDay)
                            )
                            Divider()
                            ResultRow(
                                label: "Tax Sale Proceeds",
                                value: viewModel.formatAsCurrency(result.taxSaleProceeds)
                            )
                            ResultRow(
                                label: "Cash Distribution",
                                value: viewModel.formatAsCurrency(result.cashDistribution)
                            )
                            ResultRow(
                                label: "Remaining Shares",
                                value: "\(result.sharesAfterTaxSale)"
                            )
                            Divider()
                            ResultRow(
                                label: "Target Net Income",
                                value: viewModel.formatAsCurrency(result.netIncomeTarget),
                                isHighlighted: true
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Capital Gains (if applicable)
                    if let capitalGainsTax = result.capitalGainsTax {
                        GroupBox("Capital Gains Analysis") {
                            VStack(spacing: 12) {
                                Text("Capital gains tax applies (selling above vest price)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ResultRow(
                                    label: "Capital Gains Tax",
                                    value: viewModel.formatAsCurrency(capitalGainsTax)
                                )
                                
                                if let niitTax = result.niitTax {
                                    ResultRow(
                                        label: "NIIT (3.8%)",
                                        value: viewModel.formatAsCurrency(niitTax)
                                    )
                                    ResultRow(
                                        label: "Total Cap Gains + NIIT",
                                        value: viewModel.formatAsCurrency(capitalGainsTax + niitTax),
                                        isHighlighted: true
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Price Comparison
                    let priceDifference = result.requiredSalePrice - result.vestDayPrice
                    GroupBox("Price Comparison") {
                        VStack(spacing: 12) {
                            ResultRow(
                                label: "Vest Day Price",
                                value: viewModel.formatAsCurrency(result.vestDayPrice)
                            )
                            ResultRow(
                                label: "Required Sale Price",
                                value: viewModel.formatAsCurrency(result.requiredSalePrice),
                                isHighlighted: true
                            )
                            Divider()
                            
                            HStack {
                                Text("Price Difference")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(priceDifference >= 0 ? "+" : "")\(viewModel.formatAsCurrency(abs(priceDifference)))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(priceDifference >= 0 ? .orange : .green)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
        }
    }
    
    private func recommendationText(for result: RSUCalculationResult) -> String {
        if result.requiredSalePrice > result.vestDayPrice {
            let premium = result.requiredSalePrice - result.vestDayPrice
            return "WAIT for higher price (+\(viewModel.formatAsCurrency(premium))/share premium needed)"
        } else if result.requiredSalePrice < result.vestDayPrice {
            let discount = result.vestDayPrice - result.requiredSalePrice
            return "SELL NOW (can accept up to \(viewModel.formatAsCurrency(discount))/share discount)"
        } else {
            return "SELL at vest day price (perfect match)"
        }
    }
    
    private func recommendationColor(for result: RSUCalculationResult) -> Color {
        if result.requiredSalePrice > result.vestDayPrice {
            return .orange
        } else if result.requiredSalePrice < result.vestDayPrice {
            return .green
        } else {
            return .blue
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    let isHighlighted: Bool
    
    init(label: String, value: String, isHighlighted: Bool = false) {
        self.label = label
        self.value = value
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(isHighlighted ? .subheadline : .subheadline)
                .fontWeight(isHighlighted ? .medium : .regular)
            Spacer()
            Text(value)
                .font(isHighlighted ? .subheadline : .subheadline)
                .fontWeight(isHighlighted ? .semibold : .regular)
                .foregroundColor(isHighlighted ? .primary : .secondary)
        }
    }
}