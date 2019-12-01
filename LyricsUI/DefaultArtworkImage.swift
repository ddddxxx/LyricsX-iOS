//
//  DefaultArtworkImage
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import SwiftUI

public struct DefaultArtworkImage: View {
    
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
            Color.init(white: 0, opacity: 0.6)
        }
        .aspectRatio(1, contentMode: .fill)
    }
    
    public init() {}
}

struct DefaultArtworkImage_Previews: PreviewProvider {
    static var previews: some View {
        DefaultArtworkImage()
    }
}
