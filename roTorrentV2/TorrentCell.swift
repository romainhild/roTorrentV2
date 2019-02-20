//
//  TorrentCell.swift
//  roTorrent
//
//  Created by Romain Hild on 19/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import UIKit

class TorrentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var upLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var stateProgressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureForTorrent(_ torrent: Torrent) {
        nameLabel.text = torrent.name
        sizeLabel.text = "Size: " + ByteCountFormatter.string(fromByteCount: torrent.size, countStyle: ByteCountFormatter.CountStyle.file)
        ratioLabel.text = "Ratio: " + String(torrent.ratio)
        upLabel.text = "Up: " + ByteCountFormatter.string(fromByteCount: torrent.speedUP, countStyle: ByteCountFormatter.CountStyle.file)
        downLabel.text = "Dl : " + ByteCountFormatter.string(fromByteCount: torrent.speedDL, countStyle: ByteCountFormatter.CountStyle.file)
        stateProgressView.progress = Float(torrent.sizeCompleted)/Float(torrent.size)
        if let _ = torrent.message {
            stateProgressView.progressTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        } else if torrent.isActive == 0 {
            stateProgressView.progressTintColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        } else {
            stateProgressView.progressTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        }
    }
}
