//
//  SystemColor.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public extension Color {
    #if os(macOS)
    static let systemBackground = Color(.windowBackgroundColor)
    #elseif os(iOS)
    static let systemBackground = Color(.systemBackground)
    #endif
}
