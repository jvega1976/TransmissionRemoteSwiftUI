//
//  Pieces.swift
//  TransmissionRemoteSwiftUI
//
//  Created by  on 3/5/20.
//

import SwiftUI
import TransmissionRPC

let BETWEEN = 1

struct Pieces: View {

    @ObservedObject var torrent: Torrent
    
    var body: some View {
        HStack(alignment:.center) {
            GeometryReader { g in
                let pAcross: Int = Int(ceil(sqrt(Double(self.torrent.piecesCount))))
                let rectWidth: Int = Int(g.size.width)
                let pWidth: Int  = (rectWidth - (pAcross + 1) * BETWEEN) / pAcross
                let pExtraBorder = (rectWidth - ((pWidth + BETWEEN) * pAcross + BETWEEN)) / 2
                ForEach(self.torrent.pieces.bitMap , id: \.index) { piece in
                    let across: Int = piece.index % pAcross
                    let down: Int = piece.index / pAcross
                    Path { path in
                        path.addRect(CGRect(x: across * (pWidth + BETWEEN) + BETWEEN + pExtraBorder, y: (down + 1) * (pWidth + BETWEEN) - pExtraBorder, width: pWidth, height: pWidth))
                    }.fill(piece.bit ? Color.blue : Color.green)
                    .animation(Animation.linear.repeatCount(2, autoreverses: true))
                }.id(self.torrent.trId)
            }
        }
    }
}

struct Pieces_Previews: PreviewProvider {
    
    static let connector: RPCConnector = {
        let string = "/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////w=="
        let data = Data(base64Encoded: string) ?? Data()
        let torrent = torrentsPreview().first!
        torrent.piecesCount = 848
        let connector = RPCConnector()
        connector.torrent.pieces = data
        connector.torrent.piecesCount = 848
        
        return connector
    }()
    
    static var previews: some View {
        Pieces(torrent: connector.torrent)
            .environmentObject(connector)
            .preferredColorScheme(.dark)
            .frame(width: 400.0, height: 400.0)
            .previewDevice("iPad Pro (10.5-inch)")
            .environment(\.colorScheme, .dark)
    }
}
