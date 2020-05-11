//
//  ViewController.swift
//  MVVM_GitHubClient
//
//  Created by 植田圭祐 on 2020/05/11.
//  Copyright © 2020 Keisuke Ueda. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import WebKit

final class TimeLineViewController: UIViewController {
    
    fileprivate var viewModel: UserListViewModel!
    fileprivate var tableView: UITableView!
    fileprivate var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView作成
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimeLineCell.self, forCellReuseIdentifier: "TimelineCell")
        view.addSubview(tableView)
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlValueDidChange(sender:)), for: .valueChanged)
        
        
        //UserListViewModelをインスタンス化、通知受領時の処理を定義
        viewModel = UserListViewModel()
        viewModel.stateDidUpdate = {[weak self] state in
            switch state {
            case .loading:
                
                //ダウンロード中の場合、TableViewを操作不能にする
                self?.tableView.isUserInteractionEnabled = false
                break
            
            case .finish:
                
                //通信完了後、TableViewを操作可能にし、TableViewを更新、リフレッシュ終了処理
                self?.tableView.isUserInteractionEnabled = true
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                break
            
            case .error(let error):
                
                //errorの場合はTableViewを操作不能にし、リフレッシュ終了処理、Errorアラート発砲
                self?.tableView.isUserInteractionEnabled = false
                self?.refreshControl.endRefreshing()
                
                let alertController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                let aleraAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(aleraAction)
                self?.present(alertController, animated: true, completion: nil)
                
                break
            
            }
        }
        
        //ユーザー一覧の取得
        viewModel.getUsers()
    }
    
    @objc func refreshControlValueDidChange(sender: UIRefreshControl) {
        
        //リフレッシュ時にユーザー一覧を再取得
        viewModel.getUsers()
    }
}

extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userCount()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let timelineCell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell") as? TimeLineCell {
            
            //セルがあればセルのモデルに値をセット
            let cellViewModel = viewModel.cellViewModels[indexPath.row]
            
            timelineCell.setNickName(nickName: cellViewModel.nickName)
            
            cellViewModel.downloadImage(progress: { (progress) in
                switch progress{
                case .loading(let image):
                    timelineCell.setIcon(icon: image)
                    break
                
                case .finish(let image):
                    timelineCell.setIcon(icon: image)
                    break
                    
                case .error:
                    break
                }
            })
            return timelineCell
        }
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セルが選択されたらそのセルのモデル（UserCellViewModel）を取得して対象データのwebURLへ飛ばす
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let webURL = cellViewModel.webURL
        let webViewController = SFSafariViewController(url: webURL)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

