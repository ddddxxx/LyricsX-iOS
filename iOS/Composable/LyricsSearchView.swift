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
    var searchQuery: String = ""
    
    mutating func syncSearchQuery() {
        searchQuery = searching.searchTerm?.description ?? ""
    }
    
    public static func reduce(state: inout LyricsSearchViewState, action: LyricsSearchViewAction, env: LyricsSearchViewEnvironment) -> Effect<LyricsSearchViewAction, Never> {
        struct CommitSearchID: Hashable {}
        switch action {
        case let .searchingAction(action):
            switch action {
            case .autoSearch:
                state.syncSearchQuery()
                return .none
            default:
                return .none
            }
            
        case .onAppear:
            state.syncSearchQuery()
            return .none
            
        case let .searchQueryChanged(query):
            state.searchQuery = query
            return Effect.merge(
                Effect(value: LyricsSearchViewAction.searchingAction(.clearPreviousSearch)),
                Effect(value: LyricsSearchViewAction.commitSearch)
                    .debounce(id: CommitSearchID(), for: 0.5, scheduler: env.mainQueue)
            )
            
        case .commitSearch:
            let action: LyricsSearchingAction = state.searchQuery.isEmpty ? .clearPreviousSearch : .search(term: .keyword(state.searchQuery))
            return Effect.merge(
                Effect.cancel(id: CommitSearchID()),
                Effect(value: LyricsSearchViewAction.searchingAction(action))
            )
            
        case .cancelSearch:
            state.syncSearchQuery()
            return Effect.cancel(id: CommitSearchID())
            
        case let .chooseLyrice(lyrics):
            return Effect(value: LyricsSearchViewAction.searchingAction(.setCurrentLyrics(lyrics)))
        }
    }
}

enum LyricsSearchViewAction: Equatable {
    case searchingAction(LyricsSearchingAction)
    case onAppear
    case searchQueryChanged(String)
    case commitSearch
    case cancelSearch
    case chooseLyrice(Lyrics)
}

struct LyricsSearchViewEnvironment {
    let searching: LyricsSearchingEnvironment
    
    var mainQueue: DispatchQueue {
        return searching.mainQueue
    }
}

struct LyricsSearchView: View {
    
    @ObservedObject
    var viewStore: ViewStore<LyricsSearchViewState, LyricsSearchViewAction>
    
    @State private var showCancelButton: Bool = false
    
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
                        
                        TextField("search", text: viewStore.binding(get: \.searchQuery, send: LyricsSearchViewAction.searchQueryChanged), onEditingChanged: { isEditing in
                            self.showCancelButton = true
                        }, onCommit: {
                            viewStore.send(.commitSearch)
                        }).foregroundColor(.primary)
                        
                        if !viewStore.searchQuery.isEmpty {
                            Button {
                                viewStore.send(.searchQueryChanged(""))
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
                            self.viewStore.send(.cancelSearch)
                            self.showCancelButton = false
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
                            viewStore.send(.chooseLyrice(lyrics))
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
import MusicPlayer

struct LyricsSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let state = LyricsSearchViewState(searching: LyricsSearchingState(track: MusicTrack(id: "0", title: "No Surprises", album: "OK Computer", artist: "Radiohead")))
        let reducer = Reducer(LyricsSearchingState.reduce)
            .pullback(
                state: \LyricsSearchViewState.searching,
                action: /LyricsSearchViewAction.searchingAction,
                environment: \LyricsSearchViewEnvironment.searching)
            .combined(with: Reducer(LyricsSearchViewState.reduce))
        
        let env = LyricsSearchingEnvironment(searchLyrics: LyricsProviders.Group().lyricsPublisher(request:))
        let store = Store(initialState: state, reducer: reducer, environment: LyricsSearchViewEnvironment(searching: env))
        return LyricsSearchView(store: store)
    }
}

// MARK: -

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
