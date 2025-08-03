import Foundation
import UIKit
import Solana

// MARK: - Example Usage of Wallet Connection and NFT Detection

class WalletNFTExample: WalletConnectionDelegate {
    private var solana: Solana!
    private var connectedAccount: WalletAccount?
    
    init() {
        setupSolana()
    }
    
    // MARK: - Setup
    
    private func setupSolana() {
        // Initialize Solana with RPC endpoint and API keys
        let endpoint = RPCEndpoint.mainnetBeta // or .testnet, .devnet
        let router = SolanaRouter(endpoint: endpoint)
        
        // Initialize with optional API keys for better rate limits
        solana = Solana(
            router: router,
            openSeaApiKey: "your_opensea_api_key_here", // Optional: Get from OpenSea
            magicEdenApiKey: "your_magiceden_api_key_here" // Optional: Get from Magic Eden
        )
        
        // Set delegate to receive wallet connection updates
        solana.walletManager.delegate = self
    }
    
    // MARK: - Wallet Connection Examples
    
    /// Example: Connect to Phantom Wallet
    func connectToPhantom() async {
        do {
            print("🔗 Connecting to Phantom wallet...")
            let account = try await solana.connectWallet(.phantom)
            connectedAccount = account
            print("✅ Connected to Phantom!")
            print("📍 Wallet Address: \(account.address)")
            print("🌐 Chain ID: \(account.chainId ?? "unknown")")
            
            // After connecting, fetch NFTs
            await fetchNFTsExample()
            
        } catch let error as WalletConnectionError {
            switch error {
            case .walletNotInstalled:
                print("❌ Phantom wallet is not installed")
                await openWalletInstallPage(.phantom)
            case .userRejected:
                print("❌ User rejected the connection")
            case .connectionFailed(let message):
                print("❌ Connection failed: \(message)")
            default:
                print("❌ Wallet connection error: \(error.localizedDescription)")
            }
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    /// Example: Connect to MetaMask Wallet
    func connectToMetaMask() async {
        do {
            print("🔗 Connecting to MetaMask wallet...")
            let account = try await solana.connectWallet(.metamask)
            connectedAccount = account
            print("✅ Connected to MetaMask!")
            print("📍 Wallet Address: \(account.address)")
            print("🌐 Chain ID: \(account.chainId ?? "unknown")")
            
        } catch let error as WalletConnectionError {
            switch error {
            case .walletNotInstalled:
                print("❌ MetaMask wallet is not installed")
                await openWalletInstallPage(.metamask)
            case .userRejected:
                print("❌ User rejected the connection")
            case .connectionFailed(let message):
                print("❌ Connection failed: \(message)")
            default:
                print("❌ Wallet connection error: \(error.localizedDescription)")
            }
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    /// Example: Disconnect wallet
    func disconnectWallet() async {
        do {
            try await solana.disconnectWallet()
            connectedAccount = nil
            print("🔌 Wallet disconnected")
        } catch {
            print("❌ Failed to disconnect: \(error)")
        }
    }
    
    // MARK: - NFT Detection Examples
    
    /// Example: Fetch NFTs from connected wallet
    func fetchNFTsExample() async {
        guard let account = connectedAccount else {
            print("❌ No wallet connected")
            return
        }
        
        do {
            print("🔍 Fetching NFTs for wallet: \(account.address)")
            
            // Fetch NFTs from all supported marketplaces
            let nftResponse = try await solana.getNFTs(for: account.address, limit: 10)
            
            print("🎨 Found \(nftResponse.nfts.count) NFTs:")
            for nft in nftResponse.nfts {
                print("  • \(nft.name ?? "Unnamed NFT") from \(nft.marketplace.name)")
                print("    Contract: \(nft.contractAddress)")
                print("    Token ID: \(nft.tokenId)")
                if let collection = nft.collection {
                    print("    Collection: \(collection.name)")
                }
                if let price = nft.currentPrice {
                    print("    Price: \(price.amount) \(price.currency)")
                }
                print("")
            }
            
            if nftResponse.hasMore {
                print("📄 More NFTs available. Total count: \(nftResponse.totalCount)")
            }
            
        } catch let error as NFTError {
            switch error {
            case .invalidWalletAddress:
                print("❌ Invalid wallet address")
            case .networkError(let networkError):
                print("❌ Network error: \(networkError.localizedDescription)")
            case .rateLimitExceeded:
                print("❌ Rate limit exceeded. Please wait before trying again.")
            case .unauthorized:
                print("❌ API key required or invalid")
            default:
                print("❌ NFT fetch error: \(error.localizedDescription)")
            }
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    /// Example: Fetch NFTs from specific marketplace
    func fetchNFTsFromMarketplace() async {
        guard let account = connectedAccount else {
            print("❌ No wallet connected")
            return
        }
        
        do {
            // Fetch only from Magic Eden (Solana NFTs)
            print("🔍 Fetching NFTs from Magic Eden...")
            let nftResponse = try await solana.getNFTs(
                for: account.address,
                marketplace: .magicEden,
                limit: 5
            )
            
            print("🎨 Found \(nftResponse.nfts.count) NFTs on Magic Eden:")
            for nft in nftResponse.nfts {
                print("  • \(nft.name ?? "Unnamed NFT")")
                print("    Attributes: \(nft.attributes.count) traits")
            }
            
        } catch {
            print("❌ Failed to fetch NFTs from Magic Eden: \(error)")
        }
    }
    
    /// Example: Get specific NFT metadata
    func fetchSpecificNFT() async {
        do {
            // Example: Fetch a specific NFT from OpenSea
            let nft = try await solana.getNFTMetadata(
                contractAddress: "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D", // Bored Ape Yacht Club
                tokenId: "1",
                marketplace: .openSea
            )
            
            print("🎨 NFT Details:")
            print("  Name: \(nft.name ?? "Unknown")")
            print("  Description: \(nft.description ?? "No description")")
            print("  Image: \(nft.imageUrl ?? "No image")")
            print("  Attributes: \(nft.attributes.count) traits")
            
            for attribute in nft.attributes {
                print("    \(attribute.traitType): \(attribute.value)")
            }
            
        } catch {
            print("❌ Failed to fetch specific NFT: \(error)")
        }
    }
    
    /// Example: Fetch NFTs from a collection
    func fetchCollectionNFTs() async {
        do {
            // Example: Fetch NFTs from Bored Ape Yacht Club collection
            let nfts = try await solana.getCollectionNFTs(
                collectionSlug: "boredapeyachtclub",
                marketplace: .openSea,
                limit: 5
            )
            
            print("🎨 Collection NFTs:")
            for nft in nfts {
                print("  • \(nft.name ?? "Unnamed") - Token ID: \(nft.tokenId)")
            }
            
        } catch {
            print("❌ Failed to fetch collection NFTs: \(error)")
        }
    }
    
    // MARK: - Transaction Examples
    
    /// Example: Sign a transaction with connected wallet
    func signTransactionExample() async {
        guard let account = connectedAccount else {
            print("❌ No wallet connected")
            return
        }
        
        do {
            // Create a simple SOL transfer transaction (example)
            let fromPublicKey = try PublicKey(string: account.address)
            let toPublicKey = try PublicKey(string: "11111111111111111111111111111112") // System program
            
            let instruction = SystemProgram.transfer(
                from: fromPublicKey,
                to: toPublicKey,
                lamports: 1000000 // 0.001 SOL
            )
            
            let transaction = Transaction(
                feePayer: fromPublicKey,
                instructions: [instruction],
                recentBlockhash: "11111111111111111111111111111111" // Should be fetched from RPC
            )
            
            print("📝 Signing transaction...")
            let signature = try await solana.walletManager.signTransaction(transaction: transaction)
            print("✅ Transaction signed! Signature: \(signature)")
            
        } catch {
            print("❌ Failed to sign transaction: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func openWalletInstallPage(_ walletType: WalletType) async {
        await MainActor.run {
            guard let url = URL(string: walletType.universalLink) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - WalletConnectionDelegate
    
    func walletConnectionDidChange(state: WalletConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .disconnected:
                print("🔌 Wallet disconnected")
            case .connecting:
                print("🔗 Connecting to wallet...")
            case .connected(let account):
                print("✅ Wallet connected: \(account.address)")
            case .failed(let error):
                print("❌ Wallet connection failed: \(error.localizedDescription)")
            }
        }
    }
    
    func walletDidReceiveTransaction(signature: String, success: Bool) {
        DispatchQueue.main.async {
            if success {
                print("✅ Transaction successful: \(signature)")
            } else {
                print("❌ Transaction failed")
            }
        }
    }
    
    func walletConnectionDidFail(error: Error) {
        DispatchQueue.main.async {
            print("❌ Wallet connection failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Usage in SwiftUI or UIKit

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
struct WalletNFTExampleView: View {
    @StateObject private var example = WalletNFTExample()
    @State private var isConnected = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Wallet & NFT Integration")
                .font(.title)
                .padding()
            
            if !isConnected {
                VStack(spacing: 15) {
                    Button("Connect Phantom Wallet") {
                        Task {
                            await example.connectToPhantom()
                            isConnected = example.connectedAccount != nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Connect MetaMask Wallet") {
                        Task {
                            await example.connectToMetaMask()
                            isConnected = example.connectedAccount != nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 15) {
                    Text("Wallet Connected!")
                        .foregroundColor(.green)
                    
                    if let account = example.connectedAccount {
                        Text("Address: \(String(account.address.prefix(8)))...")
                            .font(.caption)
                            .monospaced()
                    }
                    
                    Button("Fetch My NFTs") {
                        Task {
                            await example.fetchNFTsExample()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Sign Transaction") {
                        Task {
                            await example.signTransactionExample()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Disconnect") {
                        Task {
                            await example.disconnectWallet()
                            isConnected = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}
#endif