import Foundation
import UIKit

#if canImport(UIKit)
public class WalletConnectionManager: WalletConnectionProtocol {
    public private(set) var connectionState: WalletConnectionState = .disconnected
    public weak var delegate: WalletConnectionDelegate?
    
    private var currentAccount: WalletAccount?
    private let urlSession: URLSession
    
    public init() {
        self.urlSession = URLSession.shared
    }
    
    // MARK: - Wallet Connection
    
    public func connect(walletType: WalletType) async throws -> WalletAccount {
        delegate?.walletConnectionDidChange(state: .connecting)
        connectionState = .connecting
        
        // Check if wallet is installed
        guard isWalletInstalled(walletType: walletType) else {
            let error = WalletConnectionError.walletNotInstalled(walletType)
            connectionState = .failed(error)
            delegate?.walletConnectionDidFail(error: error)
            throw error
        }
        
        do {
            let account = try await performWalletConnection(walletType: walletType)
            currentAccount = account
            connectionState = .connected(account)
            delegate?.walletConnectionDidChange(state: connectionState)
            return account
        } catch {
            connectionState = .failed(error)
            delegate?.walletConnectionDidFail(error: error)
            throw error
        }
    }
    
    public func disconnect() async throws {
        currentAccount = nil
        connectionState = .disconnected
        delegate?.walletConnectionDidChange(state: .disconnected)
    }
    
    public func signTransaction(transaction: Transaction) async throws -> String {
        guard case .connected(let account) = connectionState else {
            throw WalletConnectionError.connectionFailed("No wallet connected")
        }
        
        do {
            let signature = try await performTransactionSigning(transaction: transaction, walletType: account.walletType)
            delegate?.walletDidReceiveTransaction(signature: signature, success: true)
            return signature
        } catch {
            delegate?.walletDidReceiveTransaction(signature: "", success: false)
            throw error
        }
    }
    
    public func signMessage(message: String) async throws -> String {
        guard case .connected(let account) = connectionState else {
            throw WalletConnectionError.connectionFailed("No wallet connected")
        }
        
        return try await performMessageSigning(message: message, walletType: account.walletType)
    }
    
    public func isWalletInstalled(walletType: WalletType) -> Bool {
        guard let url = URL(string: walletType.deepLinkScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    // MARK: - Private Methods
    
    private func performWalletConnection(walletType: WalletType) async throws -> WalletAccount {
        switch walletType {
        case .phantom:
            return try await connectPhantom()
        case .metamask:
            return try await connectMetaMask()
        }
    }
    
    private func connectPhantom() async throws -> WalletAccount {
        // Generate connection request
        let dappUrl = "https://your-dapp.com" // Replace with your dApp URL
        let connectionRequest = WalletConnectionRequest(
            walletType: .phantom,
            dappUrl: dappUrl,
            dappName: "Your DApp Name", // Replace with your dApp name
            cluster: "mainnet-beta"
        )
        
        // Create deep link URL for Phantom
        let connectParams = [
            "dapp_encryption_public_key": generateRandomKey(),
            "cluster": connectionRequest.cluster,
            "app_url": connectionRequest.dappUrl,
            "redirect_link": "\(dappUrl)/phantom-connect"
        ]
        
        let queryString = connectParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let phantomURL = URL(string: "phantom://v1/connect?\(queryString)") else {
            throw WalletConnectionError.connectionFailed("Invalid Phantom URL")
        }
        
        // Open Phantom wallet
        await MainActor.run {
            UIApplication.shared.open(phantomURL)
        }
        
        // For demo purposes, simulate a successful connection
        // In a real implementation, you'd handle the redirect and parse the response
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Create mock account (replace with actual response parsing)
        let mockAddress = "11111111111111111111111111111112" // Replace with actual address from response
        let account = WalletAccount(
            address: mockAddress,
            walletType: .phantom,
            publicKey: try? PublicKey(string: mockAddress),
            chainId: "solana:mainnet"
        )
        
        return account
    }
    
    private func connectMetaMask() async throws -> WalletAccount {
        // Create deep link URL for MetaMask
        let dappUrl = "https://your-dapp.com" // Replace with your dApp URL
        let connectParams = [
            "channelId": UUID().uuidString,
            "pubkey": generateRandomKey(),
            "comm": "socket",
            "redirectLink": "\(dappUrl)/metamask-connect"
        ]
        
        let queryString = connectParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let metamaskURL = URL(string: "metamask://connect?\(queryString)") else {
            throw WalletConnectionError.connectionFailed("Invalid MetaMask URL")
        }
        
        // Open MetaMask wallet
        await MainActor.run {
            UIApplication.shared.open(metamaskURL)
        }
        
        // For demo purposes, simulate a successful connection
        // In a real implementation, you'd handle the redirect and parse the response
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Create mock account (replace with actual response parsing)
        let mockAddress = "0x742d35Cc6Ab7F0532f07C2c8F7aaF28E87628d57" // Replace with actual address from response
        let account = WalletAccount(
            address: mockAddress,
            walletType: .metamask,
            publicKey: nil, // MetaMask uses Ethereum addresses
            chainId: "ethereum:1"
        )
        
        return account
    }
    
    private func performTransactionSigning(transaction: Transaction, walletType: WalletType) async throws -> String {
        switch walletType {
        case .phantom:
            return try await signTransactionPhantom(transaction: transaction)
        case .metamask:
            return try await signTransactionMetaMask(transaction: transaction)
        }
    }
    
    private func signTransactionPhantom(transaction: Transaction) async throws -> String {
        // Convert transaction to base58 string for Phantom
        let serializedTransaction = try transaction.serialize()
        let base58Transaction = serializedTransaction.base58EncodedString
        
        let signParams = [
            "transaction": base58Transaction,
            "message": "Please sign this transaction"
        ]
        
        let queryString = signParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let phantomURL = URL(string: "phantom://v1/signTransaction?\(queryString)") else {
            throw WalletConnectionError.transactionFailed("Invalid Phantom transaction URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(phantomURL)
        }
        
        // Simulate successful signing (replace with actual response handling)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "mock_transaction_signature_\(UUID().uuidString)"
    }
    
    private func signTransactionMetaMask(transaction: Transaction) async throws -> String {
        // For MetaMask, you'd typically convert Solana transaction to Ethereum format
        // This is a simplified example
        let transactionData = [
            "to": "0x742d35Cc6Ab7F0532f07C2c8F7aaF28E87628d57",
            "value": "0x0",
            "data": "0x"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: transactionData)
        let base64Transaction = jsonData.base64EncodedString()
        
        let signParams = [
            "transaction": base64Transaction,
            "method": "eth_sendTransaction"
        ]
        
        let queryString = signParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let metamaskURL = URL(string: "metamask://sign?\(queryString)") else {
            throw WalletConnectionError.transactionFailed("Invalid MetaMask transaction URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(metamaskURL)
        }
        
        // Simulate successful signing (replace with actual response handling)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "0x\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
    }
    
    private func performMessageSigning(message: String, walletType: WalletType) async throws -> String {
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message
        
        let baseURL: String
        switch walletType {
        case .phantom:
            baseURL = "phantom://v1/signMessage"
        case .metamask:
            baseURL = "metamask://signMessage"
        }
        
        guard let signURL = URL(string: "\(baseURL)?message=\(encodedMessage)") else {
            throw WalletConnectionError.connectionFailed("Invalid message signing URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(signURL)
        }
        
        // Simulate successful signing (replace with actual response handling)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "mock_message_signature_\(UUID().uuidString)"
    }
    
    private func generateRandomKey() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<32).map { _ in characters.randomElement()! })
    }
}

// MARK: - URL Handling Extension
extension WalletConnectionManager {
    
    public func handleWalletResponse(url: URL) -> Bool {
        guard let scheme = url.scheme,
              let host = url.host else { return false }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        switch "\(scheme)://\(host)" {
        case "phantom-connect", "your-app://phantom-connect":
            handlePhantomResponse(queryItems: queryItems)
            return true
        case "metamask-connect", "your-app://metamask-connect":
            handleMetaMaskResponse(queryItems: queryItems)
            return true
        default:
            return false
        }
    }
    
    private func handlePhantomResponse(queryItems: [URLQueryItem]?) {
        // Parse Phantom response
        // This is where you'd handle the actual response from Phantom wallet
        // including error handling, public key extraction, etc.
    }
    
    private func handleMetaMaskResponse(queryItems: [URLQueryItem]?) {
        // Parse MetaMask response
        // This is where you'd handle the actual response from MetaMask wallet
        // including error handling, address extraction, etc.
    }
}
#endif