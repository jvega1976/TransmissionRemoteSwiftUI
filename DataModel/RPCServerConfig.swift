//  Converted to Swift 5 by Swiftify v5.0.37171 - https://objectivec2swift.com/
//
//  RPCServerConfig.swift
//  Transmission Remote
//  Holds transmission remote rpc settings
//
//  Created by  on 7/11/19.
//

import Foundation
import Combine

let RPC_DEFAULT_PORT = 9091
let RPC_DEFAULT_PATH = "/transmission/rpc"
let RPC_DEFAULT_REFRESH_TIME = 10.0
let RPC_DEFAULT_REQUEST_TIMEOUT = 10.0
let RPC_DEFAULT_USE_SSL = false
let RPC_DEFAULT_NAME = "Diskstation"
let RPC_DEFAULT_HOST = "diskstation.johnnyvega.net"
let RPC_DEFAULT_SHOWFREESPACE = true
let RPC_DEFAULT_USER = "jvega"
let RPC_DEFAULT_PASSWORD = "Nmjcup0112*"



public class RPCServerConfig: NSObject, Codable, Identifiable, ObservableObject {
    
    public static var sharedConfig: RPCServerConfig?
    
    @Published var name: String = "" /* common server name */
    @Published var host: String = "" /* ip address of domain name of server */
    @Published var port: Int = 0 /* RPC port to connect to (default 8090) */
    @Published var rpcPath: String = "" /* rpc path (default /transmission/remote/rpc */
    @Published var userName: String = "" /* http basic auth user name */
    @Published var userPassword: String = "" /* http basic auth password */
    @Published var useSSL: Bool = false /* use https */
    @Published var defaultServer: Bool = false
    @Published var requireAuth: Bool = false
    @Published var showFreeSpace: Bool = false /* update free space on server info */
    @Published var refreshTimeout: TimeInterval = 0 /* refresh time in seconds */
    @Published var requestTimeout: TimeInterval = 0 /* request timeout to server in seconds */

    private enum CodingKeys: String,CodingKey {
        case name
        case host
        case port
        case rpcPath
        case userName
        case userPassword
        case useSSL
        case defaultServer
        case requireAuth
        case showFreeSpace
        case refreshTimeout
        case requestTimeout
    }
    
    public override init() {
        super.init()
        self.name = RPC_DEFAULT_NAME
        self.host = RPC_DEFAULT_HOST
        self.refreshTimeout = RPC_DEFAULT_REFRESH_TIME
        self.requestTimeout = RPC_DEFAULT_REQUEST_TIMEOUT
        self.port = RPC_DEFAULT_PORT
        self.rpcPath = RPC_DEFAULT_PATH
        self.useSSL = RPC_DEFAULT_USE_SSL
        self.showFreeSpace = RPC_DEFAULT_SHOWFREESPACE
        self.userName = RPC_DEFAULT_USER
        self.userPassword = RPC_DEFAULT_PASSWORD
    }
    
    public var id: String {
        return name
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.host = try values.decode(String.self, forKey: .host)
        self.port = try values.decode(Int.self, forKey: .port)
        self.rpcPath = try values.decode(String.self, forKey: .rpcPath)
        self.userName = try values.decode(String.self, forKey: .userName)
        self.userPassword = try values.decode(String.self, forKey: .userPassword)
        self.requireAuth = try values.decode(Bool.self, forKey: .requireAuth)
        self.useSSL = try values.decode(Bool.self, forKey: .useSSL)
        self.showFreeSpace = try values.decode(Bool.self, forKey: .showFreeSpace)
        self.defaultServer = try values.decode(Bool.self, forKey: .defaultServer)
        self.refreshTimeout = try values.decode(TimeInterval.self, forKey: .refreshTimeout)
        self.requestTimeout = try values.decode(TimeInterval.self, forKey: .requestTimeout)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
        try container.encode(rpcPath, forKey: .rpcPath)
        try container.encode(userName, forKey: .userName)
        try container.encode(userPassword, forKey: .userPassword)
        try container.encode(requireAuth, forKey: .requireAuth)
        try container.encode(useSSL, forKey: .useSSL)
        try container.encode(showFreeSpace, forKey: .showFreeSpace)
        try container.encode(defaultServer, forKey: .defaultServer)
        try container.encode(refreshTimeout, forKey: .refreshTimeout)
        try container.encode(requestTimeout, forKey: .requestTimeout)
    }
    
    public var configDescription: String {
        return "RPCServerConfig[\(useSSL ? "https" : "http")://\(host):\(port)\(rpcPath), refresh:\(refreshTimeout), request timeout: \(requestTimeout)]"
    }
    
    
    public var urlString: String {
        var rpcPath: String = ""
        if !(self.rpcPath.hasPrefix("/")) {
            rpcPath = "/\(self.rpcPath)"
        }
        else {
            rpcPath = self.rpcPath
        }
        return "\(useSSL ? "https" : "http")://\(host):\(port)\(rpcPath)"
    }
    
    
    public var configURL: URL? {
        let stringURL = "\(useSSL ? "https" : "http")://\(userName)\(!userPassword.isEmpty ? ":" : "")\(userPassword)@\(host)\(port != 0 ? ":" : "")\(port )\(rpcPath)"
        guard let theURL = URL(string: stringURL) else {return nil}
        return theURL
    }
    
    // MARK:- Equatable Protocol
    public override func isEqual(_ object: Any?) -> Bool {
        return self.urlString == (object as? RPCServerConfig)?.urlString
    }
    
    public static func == (lhs: RPCServerConfig, rhs: RPCServerConfig) -> Bool {
        return lhs.urlString == rhs.urlString
    }
    
    public static func != (lhs: RPCServerConfig, rhs: RPCServerConfig) -> Bool {
        return lhs.urlString != rhs.urlString
    }
    
}
