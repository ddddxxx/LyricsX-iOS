//
//  LyricsLineView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import LyricsCore

public struct LyricsLineView: View {
    
    public let line: LyricsLine
    
    public var showTranslation: Bool
    
    public init(line: LyricsLine, showTranslation: Bool) {
        self.line = line
        self.showTranslation = showTranslation
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(line.content)
                .font(Font.title.bold())
            if showTranslation,
               let trans = line.attachments.translation() {
                Text(trans)
                    .font(Font.title2.bold())
                    .opacity(0.5)
            }
        }
    }
}

struct LyricsLineView_Previews: PreviewProvider {
    
    static let line = LyricsLine(content: "I can eat glass and it doesn't hurt me.", position: 0, attachments: LyricsLine.Attachments(attachments: [.translation: LyricsLine.Attachments.PlainText("我能吞下玻璃而不伤身体。")]))
    
    static var previews: some View {
        LyricsLineView(line: line, showTranslation: true)
    }
}
