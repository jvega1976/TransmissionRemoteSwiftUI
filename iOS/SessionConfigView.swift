//
//  SessionConfig.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 2/12/20.
//

import SwiftUI
import TransmissionRPC

struct AltDays {
    static let TR_SCHED_SUN =  (1 << 0)
    static let TR_SCHED_MON = (1 << 1)
    static let TR_SCHED_TUES = (1 << 2)
    static let TR_SCHED_WED = (1 << 3)
    static let TR_SCHED_THURS = (1 << 4)
    static let TR_SCHED_FRI = (1 << 5)
    static let TR_SCHED_SAT = (1 << 6)
    static let TR_SCHED_WEEKDAY = (TR_SCHED_MON | TR_SCHED_TUES | TR_SCHED_WED | TR_SCHED_THURS | TR_SCHED_FRI)
    static let TR_SCHED_WEEKEND = (TR_SCHED_SUN | TR_SCHED_SAT)
    static let TR_SCHED_ALL = (TR_SCHED_WEEKDAY | TR_SCHED_WEEKEND)
}

struct SessionConfigView: View {
    @EnvironmentObject var connector: RPCConnector
    @EnvironmentObject var sessionConfig: SessionConfig
    @Binding var displaySessionConfig: Bool
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var message: Message
    
    var body: some View {
        NavigationView {
        VStack {
            List {
                Section(header: Text("Download Directory")) {
                    TextField("Enter download location", text: self.$sessionConfig.downloadDir)
                        .padding(.top)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    HStack(alignment: .center, spacing: 20) {
                    Toggle("",isOn: $sessionConfig.incompletedDirEnabled)
                        .fixedSize()
                     Text("Incompleted Directory: ")
                    }
                    TextField("Enter Incompleted location", text: self.$sessionConfig.incompletedDir)
                        .padding(.bottom)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Section(header: Text("Queues")) {
                    HStack(alignment: .center, spacing: 20) {
                        Toggle("",isOn: $sessionConfig.downloadQueueEnabled)
                            .fixedSize()
                        if !appState.sizeIsCompact {
                            Text("Download with Maximum of: ")
                            Spacer()
                             Text("active transfers")
                        } else {
                            Text("Download queue size: ")
                            Spacer()
                        }
                       
                        TextField("2", value: $sessionConfig.downloadQueueSize, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.downloadQueueEnabled)
                        if !appState.sizeIsCompact {
                        Stepper("", value: $sessionConfig.downloadQueueSize)
                        .fixedSize()
                        .disabled(!sessionConfig.downloadQueueEnabled)
                           //.frame(width: 90)
                        }
                    }
                    .padding(.top)
                    HStack(alignment: .center, spacing: 20) {
                        Toggle("",isOn: $sessionConfig.seedQueueEnabled)
                            .fixedSize()
                        if !appState.sizeIsCompact {
                            Text("Seeding with Maximum of: ")
                            Spacer()
                            Text("active transfers")
                        } else {
                            Text("Seeding queue size: ")
                            Spacer()
                        }
                       
                        TextField("2", value: $sessionConfig.seedQueueSize, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.seedQueueEnabled)
                        if !appState.sizeIsCompact {
                        Stepper("", value: $sessionConfig.seedQueueSize)
                            .fixedSize()
                            .disabled(!sessionConfig.seedQueueEnabled)
                        }
                    }
                    HStack(alignment: .center, spacing: 20) {
                        Toggle("",isOn: $sessionConfig.queueStalledEnabled)
                            .fixedSize()
                        if !self.appState.sizeIsCompact {
                            Text("Transfer is inactive when inactive for: ")
                            Spacer()
                            Text("minutes")
                        } else {
                            Text("Torrent stalled when idle for (min): ")
                            Spacer()
                        }
                        TextField("2", value: $sessionConfig.queueStalledMinutes, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.queueStalledEnabled)
                        if !appState.sizeIsCompact {
                            Stepper("", value: $sessionConfig.queueStalledMinutes)
                                .fixedSize()
                                .disabled(!sessionConfig.queueStalledEnabled)
                        }
                    }
                    .padding(.bottom)
                }
                Section(header: Text("Global Bandwidth Limit")) {
                    HStack(alignment: .center, spacing: 10)  {
                        Toggle("",isOn: $sessionConfig.speedLimitDownEnabled)
                            .fixedSize()
                        if self.appState.sizeIsCompact {
                             Text("Download rate (KB/s): ")
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                                Spacer()
                        } else {
                            Text("Download rate: ")
                                .fixedSize()
                            Spacer()
                            Text("KB/s")
                        }
                        TextField("2", value: $sessionConfig.speedLimitDown, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.speedLimitDownEnabled)
                        if !appState.sizeIsCompact {
                            Stepper("", value: $sessionConfig.speedLimitDown, step: 10)
                                .fixedSize()
                            .disabled(!sessionConfig.speedLimitDownEnabled)
                        }
                    }
                    .padding(.top)
                    
                    HStack(alignment: .center, spacing: 10)  {
                        Toggle("",isOn: $sessionConfig.speedLimitUpEnabled)
                            .fixedSize()
                        if self.appState.sizeIsCompact {
                            Text("Upload rate (KB/s): ")
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                            Spacer()
                        } else {
                            Text("Upload rate: ")
                            Spacer()
                             Text("KB/s")
                        }
                        TextField("2", value: $sessionConfig.speedLimitUp, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.speedLimitUpEnabled)
                        if !appState.sizeIsCompact {
                        Stepper("", value: $sessionConfig.speedLimitUp,step: 10)
                           .fixedSize()
                        .disabled(!sessionConfig.speedLimitUpEnabled)
                        }
                    }
                    .padding(.bottom)
                }
                Section(header: Text("Speed Limit mode")) {
                    HStack(alignment: .center, spacing: 20)  {
                        if self.appState.sizeIsCompact {
                            Text("Download rate: ")
                            Spacer()
                        } else {
                            Text("Download rate: ")
                            Spacer()
                            Text("KB/s")
                        }
                        TextField("2", value: $sessionConfig.altSpeedDown, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                        Stepper("", value: $sessionConfig.altSpeedDown, step: 10)
                            .fixedSize()
                    }
                    .padding(.top)
                    HStack(alignment: .center, spacing: 20)  {
                        if self.appState.sizeIsCompact {
                            Text("Upload rate: ")
                            Spacer()
                        } else {
                            Text("Upload rate: ")
                            Spacer()
                            Text("KB/s")
                        }
                        TextField("2", value: $sessionConfig.altSpeedUp, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                        Stepper("", value: $sessionConfig.altSpeedUp, step: 10)
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.altSpeedEnabled)
                            .fixedSize()
                        Text("Schedule Speed Limit")
                            .fixedSize()
                    }
                    .padding(.bottom)
                    if sessionConfig.altSpeedEnabled {
                        SpeedLimitPicker()
                    }
                }
                Section(header: Text("Limits")) {
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.seedRatioLimited)
                            .fixedSize()
                        Text("Stop seeding at ratio: ")
                            .fixedSize()
                        Spacer()
                        TextField("2", value: $sessionConfig.seedRatioLimit, formatter: { let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            return formatter
                        }())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.seedRatioLimited)
                        if !self.appState.sizeIsCompact {
                            Stepper("", value: $sessionConfig.seedRatioLimit, step: 0.1)
                                .fixedSize()
                                .disabled(!sessionConfig.seedRatioLimited)
                        }
                    }
                        
                    .padding(.top)
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.idleSeedingLimitEnabled)
                            .fixedSize()
                        Text("Stop seeding when inactive for (min): ")
                        Spacer()
                        TextField("2", value: $sessionConfig.idleSeedingLimit, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                            .multilineTextAlignment(.trailing)
                            .disabled(!sessionConfig.idleSeedingLimitEnabled)
                        if !self.appState.sizeIsCompact {
                            Stepper("", value: $sessionConfig.idleSeedingLimit)
                                .fixedSize()
                            .disabled(!sessionConfig.idleSeedingLimitEnabled)
                        }
                    }
                    .padding(.bottom)
                }
                Section(header: Text("Adding Settings")) {
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.renamePartialFiles)
                            .fixedSize()
                        Text("Append .part to incomplete files")
                            .fixedSize()
                    }
                    .padding(.top)
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.startAddedTorrents)
                            .fixedSize()
                        Text("Start transfers when added")
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.trashOriginalTorrentFiles)
                            .fixedSize()
                        Text("Trash original torrent files")
                            .fixedSize()
                    }
                    .padding(.bottom)
                }
                Section(header: Text("Connections")) {
                    HStack(alignment: .center, spacing: 20)  {
                        Text("Global maximum connections:")
                            .fixedSize()
                        Spacer()
                        TextField("2", value: self.$sessionConfig.peerLimitGlobal, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                        if !self.appState.sizeIsCompact {
                            Stepper("", value: self.$sessionConfig.peerLimitGlobal, step: 100)
                                .fixedSize()
                        }
                    }
                    .padding(.top)
                    HStack(alignment: .center, spacing: 20)  {
                        if self.appState.sizeIsCompact {
                             Text("Max peers per torrent:")
                            .fixedSize()
                            Spacer()
                        } else {
                            Text("Maximum connections for new transfers:")
                                .fixedSize()
                        }
                        Spacer()
                        TextField("2", value: $sessionConfig.peerLimitPerTorrent, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                         if !self.appState.sizeIsCompact {
                            Stepper("", value: $sessionConfig.peerLimitPerTorrent, step: 100)
                                .fixedSize()
                        }
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.pexEnabled)
                            .fixedSize()
                         if self.appState.sizeIsCompact {
                            Text("Enable PEX (Peer Exchange)")
                                 .lineLimit(1)
                                .minimumScaleFactor(0.85)
                         } else {
                            Text("Use peer exchange (PEX) for public torrents")
                                .fixedSize()
                        }
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.dhtEnabled)
                            .fixedSize()
                        if self.appState.sizeIsCompact {
                            Text("Enable DHT (Distibuted Hash Table)")
                                 .lineLimit(1)
                                 .minimumScaleFactor(0.85)
                        } else {
                            Text("Use distributed hash table (DHT) for public torrents")
                                .fixedSize()
                        }
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.lpdEnabled)
                            .fixedSize()
                        if self.appState.sizeIsCompact {
                            Text("Enable LPD (Local Peer Descovery)")
                            .lineLimit(1)
                                 .minimumScaleFactor(0.85)
                        } else {
                            Text("Use local peer discovery for public torrents")
                                .fixedSize()
                        }
                    }
                    HStack(alignment: .center)  {
                        Text("Encryption:")
                        Spacer()
                        Picker("", selection: $sessionConfig.encryptionInt) {
                            Text("Required").tag(0)
                            Text("Preferred").tag(1)
                            Text("Tolerated").tag(2)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.bottom)
                }
                Section(header: Text("Network")) {
                    HStack(alignment: .center, spacing: 20)  {
                        Text("Peer listening port:")
                        Spacer()
                        TextField("2", value: $sessionConfig.peerPort, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .fixedSize()
                    }
                    .padding(.top)
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.peerPortRandomOnStart)
                            .fixedSize()
                        Text("Randomize port on launch")
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.portForfardingEnabled)
                            .fixedSize()
                        Text("Automatically map port")
                            .fixedSize()
                    }
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.utpEnabled)
                            .fixedSize()
                        Text("Enable Micro Transport Protocol (µTP)")
                             .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .padding(.bottom)
                }
                Section(header: Text("Script Management")) {
                    HStack(alignment: .center, spacing: 20)  {
                        Toggle("",isOn: $sessionConfig.scriptTorrentDoneEnabled)
                            .fixedSize()
                        Text("Execute script when download complete")
                             .lineLimit(1)
                             .minimumScaleFactor(0.85)
                    }
                    .padding(.top)
                    HStack(alignment: .center, spacing: self.appState.sizeIsCompact ? 10 : 20)  {
                        Text("Script filename:")
                        TextField("Script file location", text: $sessionConfig.scriptTorrentDoneFilename)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                     }
                     .padding(.bottom)
                }
            }
        }
        .onAppear(perform: {
            self.connector.getSessionConfig()
        })
        .overlay( Group {
            if !self.message.message.isEmpty {
                MessageView(inTorrentList: true)
            }
        }, alignment: .bottom)
        .padding([.horizontal], self.appState.sizeIsCompact ? 0 : nil)
            .navigationBarTitle(Text("Session Configuration"), displayMode: self.appState.sizeIsCompact ? .inline : .large)
            .navigationBarItems(leading: Button(action: {
                self.connector.getSessionConfig()
                self.displaySessionConfig = false }) {
                Text("Cancel")
                    .font(!self.appState.sizeIsCompact ? .title2 : nil)
                    .padding(.all, 5.0)
            } ,trailing:
                Button(action: {
                    if self.connector.saveSessionConfig() {
                        self.displaySessionConfig = false
                    }
                    }) {
                    Text("Apply")
                        .font(!self.appState.sizeIsCompact ? .title2 : nil)
                        .padding(.all, 5.0)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
            .cornerRadius(25)
            .shadow(color: Color(.sRGB, white: self.colorScheme == .light ? 0 : 1 , opacity: 0.33), radius: 10)
            .opacity(0.97)
    }
}

struct SessionConfigView_Previews: PreviewProvider {
    private static let connector: RPCConnector = {
        let serverConfig = RPCServerConfig()
        let connector = RPCConnector(serverConfig: serverConfig)
        connector.session = try? RPCSession(withURL: connector.serverConfig!.configURL!, andTimeout: serverConfig.refreshTimeout)
        connector.getSessionConfig()
        return connector
    }()
    
    @State static var displayConfig: Bool = false
    
    static let appState: AppState  = {
        let o = AppState()
        o.sizeIsCompact = false
        return o
    }()
    
    static var previews: some View {
       
        Group {
            SessionConfigView(displaySessionConfig: $displayConfig)
                .environmentObject(connector)
                .environmentObject(connector.sessionConfig)
                .environmentObject( { () -> AppState in
                    let appState = AppState()
                                        appState.sizeIsCompact = true
                    return appState
                }())
                .environmentObject(connector.message)
                .previewDevice(PreviewDevice(stringLiteral: "iPhone 8 Plus"))
                .environment(\.colorScheme, .dark)
            
            
            SessionConfigView(displaySessionConfig: $displayConfig)
                .environmentObject(connector)
                .environmentObject(connector.sessionConfig)
                .environmentObject(appState)
                .environmentObject(connector.message)
                .previewDevice(PreviewDevice(stringLiteral: "iPad Pro (10.5-inch)"))
                
        }
    }
}

struct SpeedLimitPicker: View {
    @EnvironmentObject var sessionConfig: SessionConfig
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if !self.appState.sizeIsCompact {
                HStack(alignment: .center, spacing: 20)  {
                    Picker(selection: $sessionConfig.altSpeedTimeDay, label: Text("")) {
                        Group {
                            Text("EveryDay").tag(AltDays.TR_SCHED_ALL)
                            Text("Weekdays").tag(AltDays.TR_SCHED_WEEKDAY)
                            Text("Weekends").tag(AltDays.TR_SCHED_WEEKEND)
                        }
                        Divider()
                        Group {
                            Text("Monday").tag(AltDays.TR_SCHED_MON)
                            Text("Tuesday").tag(AltDays.TR_SCHED_TUES)
                            Text("Wednesday").tag(AltDays.TR_SCHED_WED)
                            Text("Thursday").tag(AltDays.TR_SCHED_THURS)
                            Text("Friday").tag(AltDays.TR_SCHED_FRI)
                            Text("Saturday").tag(AltDays.TR_SCHED_SAT)
                            Text("Sunday").tag(AltDays.TR_SCHED_SUN)
                        }
                    }
                    .frame(width: 120)
                    Spacer()
                    DatePicker("",selection: $sessionConfig.altSpeedTimeBeginDate, displayedComponents: [.hourAndMinute])
                        .frame(width: 120)
                    Spacer()
                    DatePicker("",selection: $sessionConfig.altSpeedTimeEndDate, displayedComponents: [.hourAndMinute])
                        .frame(width: 120)
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Days: ")
                        .font(.callout)
                        .fontWeight(.bold)
                    Picker(selection: $sessionConfig.altSpeedTimeDay, label: Text("")) {
                        Group {
                            Text("EveryDay").tag(AltDays.TR_SCHED_ALL)
                            Text("Weekdays").tag(AltDays.TR_SCHED_WEEKDAY)
                            Text("Weekends").tag(AltDays.TR_SCHED_WEEKEND)
                        }
                        Divider()
                        Group {
                            Text("Monday").tag(AltDays.TR_SCHED_MON)
                            Text("Tuesday").tag(AltDays.TR_SCHED_TUES)
                            Text("Wednesday").tag(AltDays.TR_SCHED_WED)
                            Text("Thursday").tag(AltDays.TR_SCHED_THURS)
                            Text("Friday").tag(AltDays.TR_SCHED_FRI)
                            Text("Saturday").tag(AltDays.TR_SCHED_SAT)
                            Text("Sunday").tag(AltDays.TR_SCHED_SUN)
                        }
                    }
                    Text("From: ")
                     .font(.callout)
                     .fontWeight(.bold)
                    DatePicker("",selection: $sessionConfig.altSpeedTimeBeginDate, displayedComponents: [.hourAndMinute])
                    Text("To: ")
                     .font(.callout)
                     .fontWeight(.bold)
                    DatePicker("",selection: $sessionConfig.altSpeedTimeEndDate, displayedComponents: [.hourAndMinute])
                }
            }
        }
    }
}
