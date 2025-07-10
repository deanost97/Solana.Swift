import SwiftUI

// MARK: - ProfileView
struct ProfileView: View {
    @EnvironmentObject var walletManager: RealWalletManager
    @State private var showingSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Crypto User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Premium Member")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account Statistics")
                            .font(.headline)
                        
                        HStack {
                            StatCard(
                                title: "Connected Wallets",
                                value: "\(walletManager.connectedWallets.count)",
                                icon: "wallet.pass"
                            )
                            
                            StatCard(
                                title: "Virtual Cards",
                                value: "\(walletManager.virtualCards.count)",
                                icon: "creditcard"
                            )
                        }
                        
                        HStack {
                            StatCard(
                                title: "Total Transactions",
                                value: "\(walletManager.transactions.count)",
                                icon: "list.bullet"
                            )
                            
                            StatCard(
                                title: "Total Spent",
                                value: "$\(String(format: "%.2f", totalSpent))",
                                icon: "dollarsign.circle"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Menu Options
                    VStack(spacing: 0) {
                        ProfileMenuItem(
                            icon: "gear",
                            title: "Settings",
                            subtitle: "App preferences and security"
                        ) {
                            showingSettings = true
                        }
                        
                        Divider()
                        
                        ProfileMenuItem(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            subtitle: "Get help with your account"
                        ) {
                            // Open support
                        }
                        
                        Divider()
                        
                        ProfileMenuItem(
                            icon: "info.circle",
                            title: "About",
                            subtitle: "App version and information"
                        ) {
                            showingAbout = true
                        }
                        
                        Divider()
                        
                        ProfileMenuItem(
                            icon: "shield.checkered",
                            title: "Security",
                            subtitle: "Manage your security settings"
                        ) {
                            // Open security settings
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Version Info
                    VStack(spacing: 8) {
                        Text("CryptoWallet v1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Built with ❤️ for secure crypto spending")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var totalSpent: Double {
        walletManager.transactions.reduce(0) { $0 + $1.amount }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var biometricEnabled = true
    @State private var notificationsEnabled = true
    @State private var autoLockEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section("Security") {
                    Toggle("Biometric Authentication", isOn: $biometricEnabled)
                    Toggle("Auto-Lock", isOn: $autoLockEnabled)
                }
                
                Section("Notifications") {
                    Toggle("Transaction Alerts", isOn: $notificationsEnabled)
                }
                
                Section("Data") {
                    Button("Export Transaction History") {
                        // Export functionality
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear Cache") {
                        // Clear cache
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "wallet.pass")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("CryptoWallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("A secure and easy way to spend your cryptocurrency using virtual cards connected to your real crypto wallets.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                        
                        FeatureRow(icon: "link", text: "Connect real crypto wallets")
                        FeatureRow(icon: "creditcard", text: "Generate virtual spending cards")
                        FeatureRow(icon: "shield", text: "Secure transactions")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Real-time balance tracking")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
        }
    }
}