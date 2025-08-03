import Foundation

// MARK: - Wallet Types
public enum WalletType: String, CaseIterable {
    case phantom = "phantom"
    case metamask = "metamask"
    
    var name: String {
        switch self {
        case .phantom:
            return "Phantom"
        case .metamask:
            return "MetaMask"
        }
    }
    
    var deepLinkScheme: String {
        switch self {
        case .phantom:
            return "phantom://"
        case .metamask:
            return "metamask://"
        }
    }
    
    var universalLink: String {
        switch self {
        case .phantom:
            return "https://phantom.app"
        case .metamask:
            return "https://metamask.app.link"
        }
    }
}

// MARK: - Wallet Connection State
public enum WalletConnectionState {
    case disconnected
    case connecting
    case connected(WalletAccount)
    case failed(Error)
}

// MARK: - Wallet Account
public struct WalletAccount {
    public let address: String
    public let walletType: WalletType
    public let publicKey: PublicKey?
    public let chainId: String?
    
    public init(address: String, walletType: WalletType, publicKey: PublicKey? = nil, chainId: String? = nil) {
        self.address = address
        self.walletType = walletType
        self.publicKey = publicKey
        self.chainId = chainId
    }
}

// MARK: - Wallet Connection Protocol
public protocol WalletConnectionProtocol: AnyObject {
    var connectionState: WalletConnectionState { get }
    var delegate: WalletConnectionDelegate? { get set }
    
    func connect(walletType: WalletType) async throws -> WalletAccount
    func disconnect() async throws
    func signTransaction(transaction: Transaction) async throws -> String
    func signMessage(message: String) async throws -> String
    func isWalletInstalled(walletType: WalletType) -> Bool
}

// MARK: - Wallet Connection Delegate
public protocol WalletConnectionDelegate: AnyObject {
    func walletConnectionDidChange(state: WalletConnectionState)
    func walletDidReceiveTransaction(signature: String, success: Bool)
    func walletConnectionDidFail(error: Error)
}

// MARK: - Wallet Connection Request
public struct WalletConnectionRequest {
    public let walletType: WalletType
    public let dappUrl: String
    public let dappIcon: String?
    public let dappName: String
    public let cluster: String // mainnet-beta, testnet, devnet
    
    public init(walletType: WalletType, dappUrl: String, dappIcon: String? = nil, dappName: String, cluster: String = "mainnet-beta") {
        self.walletType = walletType
        self.dappUrl = dappUrl
        self.dappIcon = dappIcon
        self.dappName = dappName
        self.cluster = cluster
    }
}

// MARK: - Transaction Request
public struct WalletTransactionRequest {
    public let transaction: Transaction
    public let message: String?
    public let simulate: Bool
    
    public init(transaction: Transaction, message: String? = nil, simulate: Bool = false) {
        self.transaction = transaction
        self.message = message
        self.simulate = simulate
    }
}

// MARK: - Wallet Connection Error
public enum WalletConnectionError: LocalizedError {
    case walletNotInstalled(WalletType)
    case userRejected
    case connectionFailed(String)
    case transactionFailed(String)
    case invalidResponse
    case unsupportedWallet
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .walletNotInstalled(let type):
            return "\(type.name) wallet is not installed"
        case .userRejected:
            return "User rejected the connection request"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .transactionFailed(let message):
            return "Transaction failed: \(message)"
        case .invalidResponse:
            return "Invalid response from wallet"
        case .unsupportedWallet:
            return "Unsupported wallet type"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}