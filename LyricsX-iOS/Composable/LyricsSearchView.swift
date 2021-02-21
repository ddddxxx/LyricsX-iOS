//
//  LyricsSearchView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import ComposableArchitecture
import LyricsCore
import LyricsXCore

struct LyricsSearchView: View {
    
    @EnvironmentObject
    var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>
    
    @State
    private var showCancelButton = false
    
    @State
    private var searchText = ""
    
    @Environment(\.presentationMode)
    var presentationMode
    
    var body: some View {
        if let searchingState = coreStore.searchingState {
            NavigationView {
                VStack {
                    SearchBar(searchText: $searchText, onCommit: {
                        coreStore.send(.searchingAction(.search(term: .keyword(searchText))))
                    }, onCancel: {
                        reloadSearchText()
                    }).onAppear {
                        reloadSearchText()
                    }
                    
                    List {
                        ForEach(searchingState.searchResultSorted, id:\.self) { lyrics in
                            VStack(alignment: .leading) {
                                Text(lyrics.idTags[.title] ?? "No Title")
                                    .font(.headline)
                                Text(lyrics.idTags[.artist] ?? "No Artist")
                                    .font(.subheadline)
                            }.onTapGesture {
                                coreStore.send(.searchingAction(.setCurrentLyrics(lyrics)))
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .navigationBarTitle(Text("Search"))
                    .resignKeyboardOnDragGesture()
                }
            }
        }
    }
    
    func reloadSearchText() {
        searchText = coreStore.searchingState?.searchTerm?.description ?? ""
    }
}

import LyricsService
import LyricsUIPreviewSupport

struct LyricsSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let viewStore = ViewStore(Store(initialState: PreviewResources.coreState, reducer: lyricsXCoreReducer, environment: .default))
        return LyricsSearchView()
            .environmentObject(viewStore)
    }
}
