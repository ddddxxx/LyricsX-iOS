//
//  LyricsView.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import SwiftUI
import UIKit
import LyricsCore

public struct LyricsView: UIViewControllerRepresentable {
    
    public class Coordinator {
        let isAutoScrollEnabled: Binding<Bool>
        init(parent: LyricsView) {
            self.isAutoScrollEnabled = parent.$isAutoScrollEnabled
        }
    }
    
    public let lyrics: Lyrics?
    public var currentLineIndex: Int?
    
    @Binding public var isAutoScrollEnabled: Bool
    
    public init(lyrics: Lyrics?, isAutoScrollEnabled: Binding<Bool>) {
        self.lyrics = lyrics
        self._isAutoScrollEnabled = isAutoScrollEnabled
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<LyricsView>) -> LyricsTableViewController {
        let vc = LyricsTableViewController(style: .plain)
        vc.delegate = context.coordinator
        vc.lyrics = lyrics
        return vc
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func updateUIViewController(_ uiViewController: LyricsTableViewController, context: UIViewControllerRepresentableContext<LyricsView>) {
        let reload = uiViewController.lyrics !== lyrics
        uiViewController.lyrics = lyrics
        uiViewController.moveFocus(to: currentLineIndex)
        if isAutoScrollEnabled {
            uiViewController.scrollToSelectedRow(animated: !reload)
        }
    }
    
    public func moveFocus(to index: Int?) -> Self {
        var view = self
        view.currentLineIndex = index
        return view
    }
}

extension LyricsView.Coordinator: LyricsTableViewControllerDelegate {
    
    func lyricsViewWillBeginDragging(_ lyricsView: LyricsTableViewController) {
        isAutoScrollEnabled.wrappedValue = false
    }
    
    func lyricsViewDidEndDragging(_ lyricsView: LyricsTableViewController) {}
}

// MARK: - TableView

protocol LyricsTableViewControllerDelegate: AnyObject {
    func lyricsViewWillBeginDragging(_ lyricsView: LyricsTableViewController)
    func lyricsViewDidEndDragging(_ lyricsView: LyricsTableViewController)
}

public class LyricsTableViewController: UITableViewController {
    
    weak var delegate: LyricsTableViewControllerDelegate?
    
    var lyrics: Lyrics? {
        didSet {
            if oldValue !== lyrics {
                tableView.reloadData()
            }
        }
    }
    
    func moveFocus(to lineIndex: Int?) {
        guard let lineIndex = lineIndex else {
            if let prev = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: prev, animated: false)
            }
            return
        }
        let indexPath = IndexPath(row: lineIndex, section: 0)
        guard indexPath != tableView.indexPathForSelectedRow else { return }
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    func scrollToSelectedRow(animated: Bool) {
        tableView.scrollToNearestSelectedRow(at: .middle, animated: animated)
    }
    
    // MARK: LifeCycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(LyricsTableViewCell.self, forCellReuseIdentifier: LyricsTableViewCell.reuseIdentifier)
    }
    
    override public func viewDidLayoutSubviews() {
        guard tableView.numberOfSections > 0 else { return }
        let rows = tableView.numberOfRows(inSection: 0)
        guard rows > 0 else { return }
        let halfHeight = tableView.bounds.height / 2
        var inset = UIEdgeInsets(top: halfHeight, left: 0, bottom: halfHeight, right: 0)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            inset.top -= cell.bounds.height / 2
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: rows - 1, section: 0)) {
            inset.bottom -= cell.bounds.height / 2
        }
        tableView.contentInset = inset
    }
    
    // MARK: UITableViewDelegate
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lyrics = self.lyrics else { return 0 }
        return lyrics.lines.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let lyrics = self.lyrics else { fatalError() }
        let lyricsLine = lyrics.lines[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LyricsTableViewCell.reuseIdentifier, for: indexPath) as! LyricsTableViewCell
        cell.config(lyricsLine: lyricsLine, enableTranslation: true)
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.lyricsViewWillBeginDragging(self)
    }
    
    public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.lyricsViewDidEndDragging(self)
    }
}

// MARK: - Cell

class LyricsTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "LyricsTableViewCell"
    
    private let lyricsLabel = UILabel()
    private let translationLabel = UILabel()
    
    private var lyricsLabelBottomConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .blue
        lyricsLabel.font = .preferredFont(forTextStyle: .headline)
        translationLabel.font = .preferredFont(forTextStyle: .body)
        lyricsLabel.numberOfLines = 0
        translationLabel.numberOfLines = 0
        lyricsLabel.translatesAutoresizingMaskIntoConstraints = false
        translationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lyricsLabel)
        contentView.addSubview(translationLabel)
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        let margins = contentView.layoutMarginsGuide
        lyricsLabel.topAnchor.constraint(equalTo: margins.topAnchor).activate()
        lyricsLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).activate()
        lyricsLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).activate()
        lyricsLabelBottomConstraint = lyricsLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).withPriority(.required)
        translationLabel.topAnchor.constraint(equalTo: lyricsLabel.bottomAnchor, constant: 4).activate()
        translationLabel.leadingAnchor.constraint(equalTo: lyricsLabel.leadingAnchor).activate()
        translationLabel.trailingAnchor.constraint(equalTo: lyricsLabel.trailingAnchor).activate()
        translationLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).withPriority(.init(500)).activate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(lyricsLine: LyricsLine, enableTranslation: Bool) {
        lyricsLabel.text = lyricsLine.content
        guard enableTranslation, let translation = lyricsLine.attachments.translation() else {
            lyricsLabelBottomConstraint?.isActive = true
            translationLabel.isHidden = true
            return
        }
        lyricsLabelBottomConstraint?.isActive = false
        translationLabel.isHidden = false
        translationLabel.text = translation
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // TODO: configure
        let textColor: UIColor = selected ? .white : .gray
        lyricsLabel.textColor = textColor
        translationLabel.textColor = textColor
    }
}

// MARK: - Preview

struct LyricsView_Previews: PreviewProvider {
    static var previews: some View {
        let lrcStr = String(data: NSDataAsset(name: "LyricsSample")!.data, encoding: .utf8)!
        let lrc = Lyrics(lrcStr)!
        return LyricsView(lyrics: lrc, isAutoScrollEnabled: .constant(true))
    }
}
