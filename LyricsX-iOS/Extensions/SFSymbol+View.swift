//
//  SFSymbol+View.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import SFSafeSymbols

extension SFSymbol: View {
    public var body: some View {
        Image(systemName: rawValue)
    }
}

struct SFSymbol_Previews: PreviewProvider {
    static var previews: some View {
        SFSymbol.applelogo
    }
}
