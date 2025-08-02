import SwiftUI
import RSUCalculatorCore

struct ContentView: View {
    @StateObject private var viewModel = RSUCalculatorViewModel()
    
    var body: some View {
        #if os(macOS)
        // macOS: Direct side-by-side layout without NavigationView
        HStack(spacing: 0) {
            RSUInputView(viewModel: viewModel)
                .frame(minWidth: 400, maxWidth: 500)
            
            Divider()
            
            if viewModel.hasCalculated {
                RSUResultsView(viewModel: viewModel)
                    .frame(minWidth: 600)
            } else {
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    Text("Enter your RSU details to see calculations")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        #else
        // iOS: Tab-based layout with individual navigation
        TabView {
            NavigationView {
                RSUInputView(viewModel: viewModel)
                    .navigationTitle("RSU Calculator")
                    .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "pencil.and.list.clipboard")
                Text("Input")
            }
            
            if viewModel.hasCalculated {
                NavigationView {
                    RSUResultsView(viewModel: viewModel)
                        .navigationTitle("Results")
                        .navigationBarTitleDisplayMode(.large)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("Results")
                }
            }
        }
        #endif
    }
}