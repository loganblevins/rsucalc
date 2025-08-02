import SwiftUI

#if os(iOS)
import UIKit
#endif

struct RSUInputView: View {
    @ObservedObject var viewModel: RSUCalculatorViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                #if os(macOS)
                // Header - only show on macOS since iOS has navigation title
                VStack(alignment: .leading) {
                    Text("RSU Calculator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Calculate your required sale price for RSU vesting scenarios")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
                #endif
                
                // Validation Errors
                if !viewModel.validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.validationErrors, id: \.self) { error in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Share Information
                GroupBox("Share Information") {
                    VStack(spacing: 16) {
                        InputField(
                            title: "VCD Price",
                            subtitle: "Vesting Commencement Date price per share",
                            text: $viewModel.vcdPrice,
                            keyboardType: .decimalPad,
                            prefix: "$"
                        )
                        
                        InputField(
                            title: "Vesting Shares",
                            subtitle: "Number of shares vesting",
                            text: $viewModel.vestingShares,
                            keyboardType: .numberPad
                        )
                        
                        InputField(
                            title: "Vest Day Price",
                            subtitle: "Share price on vest day",
                            text: $viewModel.vestDayPrice,
                            keyboardType: .decimalPad,
                            prefix: "$"
                        )
                        
                        InputField(
                            title: "Shares Sold for Taxes",
                            subtitle: "Number of shares sold for tax withholding",
                            text: $viewModel.sharesSoldForTaxes,
                            keyboardType: .numberPad
                        )
                        
                        InputField(
                            title: "Tax Sale Price",
                            subtitle: "Price per share when sold for taxes",
                            text: $viewModel.taxSalePrice,
                            keyboardType: .decimalPad,
                            prefix: "$"
                        )
                    }
                    .padding(.vertical, 8)
                }
                
                // Tax Rates
                GroupBox("Tax Rates") {
                    VStack(spacing: 16) {
                        InputField(
                            title: "Federal Tax Rate",
                            subtitle: "As decimal (e.g., 0.22 for 22%)",
                            text: $viewModel.federalRate,
                            keyboardType: .decimalPad
                        )
                        
                        InputField(
                            title: "Social Security Rate",
                            subtitle: "As decimal (e.g., 0.062 for 6.2%)",
                            text: $viewModel.socialSecurityRate,
                            keyboardType: .decimalPad
                        )
                        
                        InputField(
                            title: "Medicare Rate",
                            subtitle: "As decimal (e.g., 0.0145 for 1.45%)",
                            text: $viewModel.medicareRate,
                            keyboardType: .decimalPad
                        )
                        
                        InputField(
                            title: "SALT Rate",
                            subtitle: "State and Local Tax rate as decimal",
                            text: $viewModel.saltRate,
                            keyboardType: .decimalPad
                        )
                    }
                    .padding(.vertical, 8)
                }
                
                // Capital Gains Options
                GroupBox("Capital Gains Options") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $viewModel.includeCapitalGains) {
                            VStack(alignment: .leading) {
                                Text("Include Capital Gains Tax")
                                    .font(.subheadline)
                                Text("Short-term capital gains tax calculation")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if viewModel.includeCapitalGains {
                            Toggle(isOn: $viewModel.includeNetInvestmentTax) {
                                VStack(alignment: .leading) {
                                    Text("Include NIIT")
                                        .font(.subheadline)
                                    Text("3.8% Net Investment Income Tax for high earners")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Calculate Button
                VStack(spacing: 12) {
                    Button(action: viewModel.calculateRSU) {
                        HStack {
                            Image(systemName: "calculator")
                            Text("Calculate Required Sale Price")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    if viewModel.hasCalculated {
                        Button(action: viewModel.resetCalculation) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct InputField: View {
    let title: String
    let subtitle: String
    @Binding var text: String
    let keyboardType: KeyboardType
    let prefix: String?
    
    enum KeyboardType {
        case `default`, numberPad, decimalPad
        
        #if os(iOS)
        var uiKeyboardType: UIKeyboardType {
            switch self {
            case .default: return .default
            case .numberPad: return .numberPad
            case .decimalPad: return .decimalPad
            }
        }
        #endif
    }
    
    init(title: String, subtitle: String, text: Binding<String>, keyboardType: KeyboardType = .default, prefix: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self._text = text
        self.keyboardType = keyboardType
        self.prefix = prefix
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if let prefix = prefix {
                    Text(prefix)
                        .foregroundColor(.secondary)
                }
                
                TextField(title, text: $text)
                    #if os(iOS)
                    .keyboardType(keyboardType.uiKeyboardType)
                    #endif
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}