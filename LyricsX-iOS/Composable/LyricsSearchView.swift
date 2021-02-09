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

struct LyricsSearchViewState: Equatable {
    
    var searching: LyricsSearchingState
    
    public static func reduce(state: inout LyricsSearchViewState, action: LyricsSearchViewAction, env: LyricsSearchViewEnvironment) -> Effect<LyricsSearchViewAction, Never> {
        struct CommitSearchID: Hashable {}
        switch action {
        case .right(_):
            return .none
            
        case let .left(.searchQueryChanged(query)):
            return Effect.merge(
                Effect(value: LyricsSearchViewAction.right((.clearPreviousSearch))),
                Effect(value: LyricsSearchViewAction.left(.commitSearch(query)))
                    .debounce(id: CommitSearchID(), for: 0.5, scheduler: env.uiSchedular)
            )
            
        case let .left(.commitSearch(query)):
            let action: LyricsSearchingAction = query.isEmpty ? .clearPreviousSearch : .search(term: .keyword(query))
            return Effect.merge(
                Effect.cancel(id: CommitSearchID()),
                Effect(value: LyricsSearchViewAction.right(action))
            )
            
        case .left(.cancelSearch):
            return Effect.cancel(id: CommitSearchID())
        }
    }
}

enum LyricsSearchViewIsolatedAction: Equatable {
    case searchQueryChanged(String)
    case commitSearch(String)
    case cancelSearch
}

typealias LyricsSearchViewAction = Either<LyricsSearchViewIsolatedAction, LyricsSearchingAction>

typealias LyricsSearchViewEnvironment = LyricsSearchingEnvironment

struct LyricsSearchView: View {
    
    @ObservedObject
    var viewStore: ViewStore<LyricsSearchViewState, LyricsSearchViewAction>
    
    @State
    private var showCancelButton = false
    
    @State
    private var searchQuery = ""
    
    @Environment(\.presentationMode)
    var presentationMode
    
    init(store: Store<LyricsSearchViewState, LyricsSearchViewAction>) {
        viewStore = ViewStore(store)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search view
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        
                        TextField("search", text: $searchQuery, onEditingChanged: { isEditing in
                            self.showCancelButton = true
                            viewStore.send(.left(.searchQueryChanged(searchQuery)))
                        }, onCommit: {
                            viewStore.send(.left(.commitSearch(searchQuery)))
                        }).foregroundColor(.primary)
                        
                        if !searchQuery.isEmpty {
                            Button {
                                viewStore.send(.left(.searchQueryChanged("")))
                            } label: {
                                Image(systemName: "xmark.circle.fill")
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
                            viewStore.send(.left(.cancelSearch))
                            showCancelButton = false
                        }
                        .foregroundColor(Color(.systemBlue))
                    }
                }
                .padding(.horizontal)
                .navigationBarHidden(showCancelButton) // .animation(.default) // animation does not work properly
                
                List {
                    ForEach(viewStore.searching.searchResultSorted, id:\.self) { lyrics in
                        VStack(alignment: .leading) {
                            Text(lyrics.idTags[.title] ?? "No Title")
                                .font(.headline)
                            Text(lyrics.idTags[.artist] ?? "No Artist")
                                .font(.subheadline)
                        }.onTapGesture {
                            viewStore.send(.right(.setCurrentLyrics(lyrics)))
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

import LyricsService
import LyricsUIPreviewSupport

struct LyricsSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let state = LyricsSearchViewState(searching: LyricsSearchingState(track: PreviewResources.track))
        let reducer = Reducer(LyricsSearchingState.reduce)
            .pullback(
                state: \.searching,
                action: /LyricsSearchViewAction.right,
                environment: { $0 })
            .combined(with: Reducer(LyricsSearchViewState.reduce))
        let store = Store(initialState: state, reducer: reducer, environment: LyricsSearchViewEnvironment())
        return LyricsSearchView(store: store)
    }
}
