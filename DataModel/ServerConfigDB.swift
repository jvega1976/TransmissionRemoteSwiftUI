//
//  ServerConfigDB.swift
//  Transmission Remote
//
//  Created by Alexey Chechetkin on 24.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//
// singlton for getting rpc data config
import Foundation
import os
import Combine

let TR_URL_DEFAULTS = "TransmissionRemote"
let TR_URL_CONFIG_KEY = "URLConfigDB"
let TR_URL_ACTUAL_KEY = "ActualURL"
let TR_URL_CONFIG_NAME = "name"
let TR_URL_CONFIG_HOST = "host"
let TR_URL_CONFIG_PORT = "port"
let TR_URL_CONFIG_USER = "userName"
let TR_URL_CONFIG_PASS = "userPassword"
let TR_URL_CONFIG_SSL = "useSSL"
let TR_URL_CONFIG_AUTH = "requireAuth"
let TR_URL_CONFIG_SVR = "defaultServer"
let TR_URL_CONFIG_PATH = "rpcPath"
let TR_URL_CONFIG_FREE = "showFreeSpace"
let TR_URL_CONFIG_REFRESH = "refreshTimeOut"
let TR_URL_CONFIG_REQUEST = "requestTimeOut"


public class ServerConfigDB: NSObject, ObservableObject {
    
    @Published public var db = Array<RPCServerConfig>()

    public static var shared: ServerConfigDB = ServerConfigDB()
    
    let store = NSUbiquitousKeyValueStore.default
    
    let defaults = UserDefaults(suiteName: TR_URL_DEFAULTS)
    
    // closed init method
    public override init() {
        super.init()
        self.load()
    }
    
    
    private func load() {
        do {
            if let data = self.store.data(forKey: TR_URL_CONFIG_KEY) {
                let decoder = PropertyListDecoder()
                self.db = try decoder.decode([RPCServerConfig].self, from: data)
            } else {
                guard let data = self.defaults?.data(forKey: TR_URL_CONFIG_KEY) else {return}
                let decoder = PropertyListDecoder()
                self.db = try decoder.decode([RPCServerConfig].self, from: data)
            }
        } catch {
            os_log("%@",error.localizedDescription)
        }
    }
    
    
    var defaultConfig: RPCServerConfig? {
        return self.db.first(where: {
            $0.defaultServer
        })
    }
    
    
    func save() throws {
        let encoder = PropertyListEncoder()
        //encoder.outputFormat = .binary
        let data = try encoder.encode(db)
        self.store.set(data, forKey: TR_URL_CONFIG_KEY)
        self.defaults?.set(data, forKey: TR_URL_CONFIG_KEY)

        self.store.synchronize()
        self.defaults?.synchronize()
    }
    
}


