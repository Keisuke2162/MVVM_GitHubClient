//
//  ViewModel.swift
//  MVVM_GitHubClient
//
//  Created by 植田圭祐 on 2020/05/11.
//  Copyright © 2020 Keisuke Ueda. All rights reserved.
//

import Foundation
import UIKit


/*UserListViewModel
 APIクラスからuser配列を受け取る（APIリクエストを投げる指示）
 受け取ったuserの数だけセルを作成する（UserCellViewModel）
 TableView全体に対する通知を行う
 viewControllerに対してステータス情報を通知する（通信中、通信終了（成功）、エラー）
 TableViewの描画に必要な情報を出力（行数情報【セルのかず】）
*/

enum ViewModelState {
    case loading
    case finish
    case error(Error)
}

final class UserListViewModel {
    
    //ViewModeStateをClosureとしてプロパティで保持
    var stateDidUpdate: ((ViewModelState) -> Void)?
    
    //user配列
    private var users = [User]()
    
    //userCellViewModelh配列
    var cellViewModels = [UserCellViewModel]()
    
    //Modelにて定義したAPIクラス
    let api = API()
    
    //Userリストを取得
    func getUsers() {
        
        stateDidUpdate?(.loading)
        users.removeAll()
        
        api.getUsers(success: { (users) in
            //user一覧収集に成功したら配列に格納
            self.users.append(contentsOf: users)
            //格納された配列からひとつずつ取り出してCellを作成
            for user in users {
                let cellViewModel = UserCellViewModel(user: user)
                self.cellViewModels.append(cellViewModel)
                
                //通信終了通知を送る
                self.stateDidUpdate?(.finish)
            }
        }, failure: { (error) in
            
            //通信失敗 -> error通知を送る
            self.stateDidUpdate?(.error(error))
        })
    }
    
    
    //tableView表示に必要なアウトプットを作成
    //tableViewに必要なアウトプットは行数情報（セルのかず）
    func userCount() -> Int {
        return self.users.count
    }
}


/*UserCellViewModel
 各Cellに対するアウトプットを作成
 
 ImageDownloaderからユーザーのアイコン画像をダウンロード
 →ダウンロード中、ダウンロード終了（成功）、エラーの状態を保持
 　→Cellに反映させるアウトプット（ダウンロード中はグレーの画像）
 
*/

enum ImageDownloadProgress {
    case loading(UIImage)
    case finish(UIImage)
    case error
}

final class UserCellViewModel {
    //ユーザー変数
    private var user: User
    
    //ImageDownloader変数
    private let imageDownloader = ImageDownloader()
    
    //ダウンロード中判定変数
    private var isLoading: Bool = false
    
    
    //Cellに反映させる出力用データ
    var nickName: String {
        return user.name
    }
    
    //セル選択時に必要になるURL
    var webURL: URL {
        return URL(string: user.webURL)!
    }
    
    //init
    init(user: User) {
        self.user = user
    }
    
    //ImageDownloaderで画像をダウンロードし、結果をクロージャで返却
    func downloadImage(progress: @escaping (ImageDownloadProgress) -> Void) {
        
        //loading中だったら返す
        if isLoading {
            return
        }
        
        isLoading = true
        
        //グレーのUIImageを作成
        let loadingImage = UIImage(color: .gray, size: CGSize(width: 45, height: 45))!
        
        
        //.loadingをクロージャ で返す
        progress(.loading(loadingImage))
        
        //imageDownloaderを使って画像をダウンロード
        //引数はuer.iconURL
        //ダウンロード終了したら.finish,エラーだったら.errorをクロージャ で返す
        imageDownloader.downloadImage(imageURL: user.iconUrl,
                                      success: { (image) in
                                        progress(.finish(image))
                                        self.isLoading = false
        }, failure: { (error) in
            progress(.error)
            self.isLoading = false
        })
    }
}


extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
