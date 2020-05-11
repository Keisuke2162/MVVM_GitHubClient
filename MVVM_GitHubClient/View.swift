//
//  View.swift
//  MVVM_GitHubClient
//
//  Created by 植田圭祐 on 2020/05/11.
//  Copyright © 2020 Keisuke Ueda. All rights reserved.
//

import Foundation
import UIKit

//View
//Cellの定義

final class TimeLineCell: UITableViewCell {
    
    //アイコン用
    private var iconView: UIImageView!
    
    private var nickNameeLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        iconView = UIImageView()
        iconView.clipsToBounds = true
        contentView.addSubview(iconView)
        
        nickNameeLabel = UILabel()
        nickNameeLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(nickNameeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.frame = CGRect(x: 15, y: 15, width: 45, height: 45)
        iconView.layer.cornerRadius = iconView.frame.width / 2
        
        nickNameeLabel.frame = CGRect(x: iconView.frame.maxX + 15,
                                      y: iconView.frame.origin.y,
                                      width: contentView.frame.width - iconView.frame.maxX - 15 * 2,
                                      height: 15)
    }
    
    //ユーザー名をセット
    func setNickName(nickName: String) {
        nickNameeLabel.text = nickName
    }
    
    //アイコンをセット
    func setIcon(icon: UIImage) {
        iconView.image = icon
    }
}
