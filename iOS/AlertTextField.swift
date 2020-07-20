//
//  AlertView.swift
//  iOS_1
//
//  Created by Johnny Vega Sosa on 6/27/20.
//

import SwiftUI

class AlertManager: ObservableObject {

    @Published var alert: AlertTextField!
    @Published var display: Bool = false
    
    init() {
        
    }
}

struct AlertTextField {
    
    @State var title: Text
    @Binding var textField: String
    @State var buttons: Array<Button>


    struct Button: Identifiable {
        var label: String
        var action: () -> Void
        
        public static func custom(label: String, action: @escaping () -> Void ) -> Button {
           return Button(label: label, action: action)
        }
        public static func ok(action: @escaping ()->Void = { }) -> Button  {
            return Button(label: "OK", action: action)
        }
        public static func cancel(action: @escaping ()->Void = {  }) -> Button  {
            return Button( label: "Cancel", action: action)
        }
        
        var id: String {
            return label
        }
    }
}


struct AlertView: View, Equatable {

    @Environment(\.presentationMode) private var presentationMode
    @Binding var isPresented: Bool
    @State var alert: AlertTextField
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    func dismiss() {
        self.isPresented.toggle()
        self.presentationMode.wrappedValue.dismiss()
    }
   
    var body: some View {
        VStack(alignment: .leading) {
            alert.title
                .font(.body)
                .padding(.leading)
            Spacer()
            TextField("", text: self.alert.$textField)
                .padding(.horizontal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
            HStack {
                Spacer()
                ForEach(self.alert.buttons) { button in
                    Button(button.label) {
                        button.action()
                        dismiss()
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .padding(.vertical)
        .background(Color.init(.sRGB, white: colorScheme == .light ? 0.85 : 0.2, opacity: 1))
        .cornerRadius(15)
        .shadow(color: Color(.sRGB, white: colorScheme == .light ? 0 : 1 , opacity: 0.5), radius: 5)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    static func == (lhs: AlertView, rhs: AlertView) -> Bool {
        lhs.alert.textField == rhs.alert.textField
    }
}


struct AlertView_Previews: PreviewProvider {

    @State static var theText: String = "This is the text"

    static var alert: AlertTextField = {
        let custom: AlertTextField.Button = .custom(label: "Custom", action: {
            print("Action Button 2")
        })
        let buttons: Array<AlertTextField.Button> = [.ok(action: { print("Action Button 1")  }),custom,.cancel()]
        let alert = AlertTextField(title: Text("Alert Title") , textField: $theText, buttons: buttons)
        return alert
    }()
    
    static var appStateCompact: AppState = {
       let state = AppState()
        state.sizeIsCompact = true
        return state
    }()
    
    static var appState:AppState = {
        let state = AppState()
        state.sizeIsCompact = false
        return state
    }()
    
    @State static var isPresented: Bool = true

    static var previews: some View {
       
        Group {
            AlertView(isPresented: $isPresented, alert: alert)
                .environmentObject(appStateCompact)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
                //.preferredColorScheme(.dark)
                //.environment(\.colorScheme, .dark)
                
            
            AlertView(isPresented: $isPresented, alert: alert)
                .preferredColorScheme(.dark)
            .environmentObject(appState)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (10.5-inch)"))
                .environment(\.colorScheme, .dark)
        }
    }
}




struct AlertTextField_Library: LibraryContentProvider {
    @Binding var text: String
    var views: [LibraryItem] {
        return [LibraryItem(AlertTextField(title: Text("The Alert Title"), textField: $text, buttons: [.custom(label: "Button 1", action: { }), .ok(action: {  }), .cancel()]), title: "AlertTextField", category: .control)] // <2>
    }
}
