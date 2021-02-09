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
               // TODO: language code candidate
               let trans = line.attachments.translation() {
                Text(trans)
                    .font(Font.title2.bold())
            }
        }
    }
}

import LyricsUIPreviewSupport

struct LyricsLineView_Previews: PreviewProvider {
    
    static var previews: some View {
        return Group {
            LyricsLineView(
                line: PreviewResources.lyricsLine,
                showTranslation: true)
                    .previewLayout(.sizeThatFits)
            
            LyricsLineView(
                line: PreviewResources.lyricsLine,
                showTranslation: false)
                    .previewLayout(.sizeThatFits)
        }
    }
}
