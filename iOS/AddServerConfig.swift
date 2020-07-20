//
//  AddServerConfig.swift
//  Transmission Remote SwiftUI
//
//  Created by  on 1/22/20.
//

import SwiftUI


struct AddServerConfig: View {
    
    @ObservedObject var serverConfig: RPCServerConfig
    @Binding var isEditing: Bool
    @State var deleteAlert: Bool = false
    private var name: String!
    @Environment(\.presentationMode) var presentationMode
    
    init(serverConfig: RPCServerConfig,  isEditing: Binding<Bool>) {
        self.serverConfig = serverConfig
        self._isEditing = isEditing
        self.name = serverConfig.name
    }
    
    var body: some View {
        List{
            Section(header: Text("General")
                .font(.title)
                .padding(.bottom, 5.0)) {
                HStack(alignment: .center, spacing: 15) {
                    Image("World")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Text("Name: ")
                    TextField("Enter Name:", text: $serverConfig.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical)
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "checkmark.seal")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Toggle("Default Server: ", isOn: $serverConfig.defaultServer)
                }
                .padding(.bottom)
            }.paddingTorrent(.horizontal)
            Section(header: Text("RPC Settings")
                .font(.title)
                .padding(.vertical, 5.0)) {
                HStack(alignment: .center, spacing: 15) {
                    Image("iconComputer")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Text("Host: ")
                    Spacer()
                    TextField("Enter Host:", text: $serverConfig.host)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
                .padding(.top)
                HStack(alignment: .center, spacing: 15) {
                    Image("iconComputer")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Text("Port: ")
                    Spacer()
                    TextField("Enter Port", value: $serverConfig.port, formatter: NumberFormatter())
                        .multilineTextAlignment(.trailing) .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .center, spacing: 15) {
                    Image("iconLock")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Toggle(isOn: $serverConfig.useSSL) {
                        Text("Use SSL: ")
                    }
                }
                .padding(.bottom)
        }.paddingTorrent(.horizontal)
            Section(header: Text("Security Settings")
                .font(.title)
                .padding(.vertical, 5.0)) {
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "lock.shield")
                        .resizable()
                        .scaleEffect(0.9)
                        .formatPlayIcon(.blue)
                        .imageScale(.small)
                    Toggle(isOn: $serverConfig.requireAuth) {
                        Text("Require Authentication: ")
                    }
                }
                .padding(.top)
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "person")
                        .resizable()
                        .imageScale(.small)
                        .scaleEffect(0.9)
                        .formatPlayIcon(.blue)
                    Text("Username: ")
                    Spacer()
                    TextField("Enter username", text: $serverConfig.userName).textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(!serverConfig.requireAuth)
                }
                HStack(alignment: .center, spacing: 15) {
                    Image("iconKey")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Text("Password: ")
                    Spacer()
                    SecureField("Enter Password", text: $serverConfig.userPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(!serverConfig.requireAuth)
                }
                .padding(.bottom)
        }.paddingTorrent(.horizontal)
            Section(header: Text("Timeout Settings")
                .font(.title)
                .padding(.vertical, 5.0)) {
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "timer")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Text("Request Timeout: ")
                        .multilineTextAlignment(.trailing)
                    Spacer()
                    TextField("Request Timeout", value: $serverConfig.requestTimeout, formatter: NumberFormatter()).textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(width: 50.0, alignment: .trailing)
                    Stepper("", value: $serverConfig.requestTimeout)
                        .frame(width:80)
                }
                .padding(.top)
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "timer")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Text("Refresh Timeout: ")
                        .multilineTextAlignment(.trailing)
                    Spacer()
                    TextField("Refresh Timeout", value: $serverConfig.refreshTimeout, formatter: NumberFormatter()).textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(width: 50.0, alignment: .trailing)
                    Stepper("", value: $serverConfig.refreshTimeout)
                        .frame(width:80)
                }
                .padding(.bottom)
        }.paddingTorrent(.horizontal)
            Section(header: Text("Miscellaneous")
                .font(.title)
                .padding(.vertical, 5.0)) {
                HStack(alignment: .center, spacing: 15) {
                    Image("iconFreeSpace")
                        .resizable()
                        .formatPlayIcon(.blue)
                    Toggle(isOn: $serverConfig.showFreeSpace) {
                        Text("Show Free Space: ").font(.headline)
                    }
                }
                .padding(.top)
            }.paddingTorrent(.horizontal)
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Button(action: { self.deleteAlert.toggle() }) {
                    Text("Delete")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
                .foregroundColor(.red)
                Spacer()
            }
            Spacer()
        }
        .alert(isPresented: self.$deleteAlert, content: {
            Alert(title: Text("Are you sure you want to delete this Server?"), primaryButton: .default(Text("Delete"), action: { self.deleteServerConfig() }), secondaryButton: .cancel())
        })
        .navigationBarItems(trailing: Button(action: {
                self.addServerConfig() }, label: {
                Text("Save")
            }))
        .navigationBarTitle("Server Configuration")
    }
    
    func addServerConfig() {
        if self.isEditing {
            if let index = ServerConfigDB.shared.db.firstIndex(where: {$0.name == self.name }) {
                if self.serverConfig.defaultServer,
                    let defaultIndex = ServerConfigDB.shared.db.firstIndex(where: {$0.defaultServer}),
                    index != defaultIndex {
                    ServerConfigDB.shared.db[defaultIndex].defaultServer = false
                }
                ServerConfigDB.shared.db[index] = self.serverConfig
            } else {
                if !ServerConfigDB.shared.db.contains(serverConfig) {
                    if let defaultIndex = ServerConfigDB.shared.db.firstIndex(where: {$0.defaultServer}) {
                        ServerConfigDB.shared.db[defaultIndex].defaultServer = false
                    }
                    ServerConfigDB.shared.db.append(serverConfig)
                }
            }
        } else if !ServerConfigDB.shared.db.contains(serverConfig) {
            if let defaultIndex = ServerConfigDB.shared.db.firstIndex(where: {$0.defaultServer}) {
                ServerConfigDB.shared.db[defaultIndex].defaultServer = false
            }
            ServerConfigDB.shared.db.append(serverConfig)
        }
        do {
            try ServerConfigDB.shared.save()
        } catch {
            
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func deleteServerConfig() {
        ServerConfigDB.shared.db.removeAll(where: {$0 == serverConfig })
        do {
            try ServerConfigDB.shared.save()
        } catch {
            
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}


struct AddServerConfig_Previews: PreviewProvider {
    
    @State static var isEditing = true
    
    static var previews: some View {
        Group {
            AddServerConfig(serverConfig: RPCServerConfig(), isEditing: self.$isEditing )
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
                .environment(\.colorScheme, .dark)
            
            AddServerConfig(serverConfig: RPCServerConfig(), isEditing: self.$isEditing)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .environment(\.colorScheme, .dark)
        }
    }
    
}
