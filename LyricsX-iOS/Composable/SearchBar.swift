//
//  SearchBar.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import SFSafeSymbols

// search bar with a clear button, a cancel button, and automatically hide navigation bar when searching
struct SearchBar: View {
    
    @Binding
    var searchText: String
    
    @State
    var showCancelButton = false
    
    var onCommit: () -> Void
    
    var onCancel: () -> Void
    
    init(searchText: Binding<String>, onCommit: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
        self._searchText = searchText
        self.onCommit = onCommit
        self.onCancel = onCancel
    }
    
    var body: some View {
        HStack {
            HStack {
                SFSymbol.magnifyingglass
                
                TextField("search", text: $searchText, onEditingChanged: { isEditing in
                    self.showCancelButton = true
                }, onCommit: {
                    onCommit()
                }).foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button(systemSymbol: .xmarkCircleFill) {
                        searchText = ""
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            
            if showCancelButton  {
                Button("Cancel") {
                    UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                    showCancelButton = false
                    onCancel()
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
        .navigationBarHidden(showCancelButton) // .animation(.default) // animation does not work properly
    }
}

struct SearchBar_Previews: PreviewProvider {
    
    @State
    static var searchText = "foo"
    
    static var previews: some View {
        SearchBar(searchText: $searchText)
            .previewLayout(.sizeThatFits)
    }
}
