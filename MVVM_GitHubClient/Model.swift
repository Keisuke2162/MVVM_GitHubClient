//
//  File.swift
//  MVVM_GitHubClient
//
//  Created by 植田圭祐 on 2020/05/11.
//  Copyright © 2020 Keisuke Ueda. All rights reserved.
//


import Foundation
import UIKit

final class User{
    let id: Int
    let name: String
    let iconUrl: String
    let webURL: String
    
    init(attributes: [String: Any]) {
        id = attributes["id"] as! Int
        name = attributes["login"] as! String
        iconUrl = attributes["avatar_url"] as! String
        webURL = attributes["html_url"] as! String
    }
}


//エラーハンドリングのクロージャ
enum APIError: Error, CustomStringConvertible {
    case unknown
    case invalidURL
    case invalidResponse
    
    var description: String {
        switch self {
        case .unknown: return "不明なエラー"
        case .invalidURL: return "無効なURL"
        case .invalidResponse: return "フォーマットが無効なレスポンス"
        }
    }
}



/*使い方
 let api = API()
 api.getUsers(sccess: { (users) in
    
    戻り値：[User]
 
 }) { (error) in
    
    戻り値：Error
 
 }
*/

class API {
    
    func getUsers(success: @escaping ([User]) -> Void,
                  failure: @escaping (Error) -> Void) {
        
        let requestURL = URL(string: "https://api.github.com/users")
        
        //URLとして無効だった場合、APIErrorにエラー処理を任せる
        guard let url = requestURL else {
            failure(APIError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) {(data, reaponse, error) in
            
            //errorがあればエラーを返す（APIErrorではなく普通のエラー）
            if let error = error {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }
            
            //データがなかったらunknownエラーを返す
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            
            //レスポンスの方が不正だったらinvalidReaponseエラーを返す
            guard
                let jsonOptional = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonOptional as? [[String: Any]]
                else {
                    DispatchQueue.main.async {
                        failure(APIError.invalidResponse)
                    }
                    return
            }
            
            
            //jsonからUserを作成して配列[User]に追加し、最後にクロージャで配列を返す
            var users = [User]()
            for j in json {
                let user = User(attributes: j)
                users.append(user)
            }
            
            DispatchQueue.main.async {
                success(users)
            }
        }
        
        task.resume()
    }
}


/*
 let imageDownloader = ImageDownloder()
 let imageURL = URL(string: URL)
 
 imageDownloader.downloadImage(imageURL: imageURL,
                               success: { (image) in
 
    リクエスト成功：　戻り値　UIImagae
 }) { (error) in
 
    リスエスト失敗   戻り値　Error
 }
 
*/

final class ImageDownloader {
    
    //UIImageのキャッシュ用
    var cacheImage: UIImage?
    
    func downloadImage(imageURL: String,
                       success: @escaping (UIImage) -> Void,
                       failure: @escaping (Error) -> Void) {
        
        //キャッシュされている画像があればClosureで返す
        if let cacheImage = cacheImage {
            success(cacheImage)
        }
        
        
        //リクエスト作成
        var request = URLRequest(url: URL(string: imageURL)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, reaponse, error) in
            
            //errorがあれば返す
            if let error = error {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }
            
            //データ無ければUnknownエラー
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            
            //受け取ったデータからUIImageを生成、できなければUnknownエラーを返す
            guard let imageFormData = UIImage(data: data) else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            
            //ここまで来れば成功。UIImageを返す
            DispatchQueue.main.async {
                success(imageFormData)
            }
            
            //画像をキャッシュ
            self.cacheImage = imageFormData
        }
        task.resume()
    }
}
