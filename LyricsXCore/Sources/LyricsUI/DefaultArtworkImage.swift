//
//  DefaultArtworkImage.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct DefaultArtworkImage: View {
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.white
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.968627451, green: 0.4196078431, blue: 0.1098039216, alpha: 1)), Color(#colorLiteral(red: 0.9921568627, green: 1, blue: 0, alpha: 1))]),
                startPoint: .leading,
                endPoint: .trailing)
                .blendMode(.difference)
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0.9137254902, blue: 0.3725490196, alpha: 1)), Color(#colorLiteral(red: 0.4352941176, green: 0.9490196078, blue: 0, alpha: 1))]),
                startPoint: .bottom,
                endPoint: .top)
                .blendMode(.difference)
            Color.init(white: 0, opacity: 0.2)
        }
        .aspectRatio(contentMode: .fill)
    }
    
    public func dimmed() -> some View {
        return self.overlay(Color.init(white: 0, opacity: 0.5))
    }
}

struct DefaultArtworkImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DefaultArtworkImage()
                .previewLayout(.fixed(width: 100, height: 100))
            
            DefaultArtworkImage()
                .dimmed()
                .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}
