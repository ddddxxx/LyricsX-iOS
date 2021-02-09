//
//  View+ResignKeyboard.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import UIKit

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

private struct ResignKeyboardOnDragGesture: ViewModifier {
    func body(content: Content) -> some View {
        content.gesture(
            DragGesture().onChanged{ _ in
                UIApplication.shared.endEditing(true)
            }
        )
    }
}
