//
//  Networking.swift
//  lycan
//
//  Created by George Smith on 13/01/2017.
//  Copyright © 2017 TreeDaveGeorgeNeil. All rights reserved.
//

//
//  Networking.swift
//  thomas-higgins
//
//  Created by George Smith on 16/11/2016.
//  Copyright © 2016 Thomas Higgins. All rights reserved.
//

import Foundation
import Alamofire


enum StatusCode : Int{
    case Success = 0
    case InvalidModel = 1 // provided model is not what the server requires.
    case ServerError = 3 // Request data is valId but there was a problem on the server
    case Forbidden = 6 // Request is for some data that does not belong to the authenticated user.
    case UndefinedError = 7 // No error defined, but one does indeed exist.
    
    static var count: Int {
        return self.UndefinedError.hashValue // NOTE: this is one less than the count due to the undefined error code.
    }
}

enum LycanRouter: URLRequestConvertible {
    static let baseURLString = "https://studa1bl57.execute-api.eu-west-1.amazonaws.com/Prod"
    
    //static let baseURLString = Settings.getBaseURL()
    static var oAuthToken: String?
    
    case JoinGame(String,String)
    case IsReady(String, Bool)
    case HostGame(String, String)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .JoinGame(_):
            return .post
        case .HostGame(_):
            return .post
        case .IsReady(_):
            return .post
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .JoinGame(let name, let gameName):
            return ["PlayerName":name,"GameName":gameName]
        case .HostGame(let gameHost, let playerName):
            return ["GameName":gameHost,"PlayerName":playerName]
        case .IsReady(let playerId, let isReadied):
            return ["PlayerId":playerId,"IsReady": isReadied]
        }
    }
    
    var path: String {
        switch self {
        case .JoinGame(let name):
            return "/JoinGame"
        case .IsReady(let playerId):
            return "/IsReady"
        case .HostGame(let name):
            return "/HostGame"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: LycanRouter.baseURLString)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        
        if self.method == .get {
            urlRequest.httpBody = nil
        } else {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: self.parameters, options: .prettyPrinted)
        }
        
        return urlRequest
        
    }
}

class Networking {
    
    // process a JSON response that only returns a status code.
    static func processJsonResponse(jsonResult: Result<AnyObject>, success: (_ statusCode: StatusCode) -> Void, failure: (_ error: Error?) -> Void) -> Void {
        if jsonResult.error != nil {
            failure(jsonResult.error!)
            return
        }
        if let responseData = jsonResult.value {
            let status = processStatusCode(responseData: responseData)
            success(status)
            return
        } else {
            //no error or data...
            failure(nil)
        }
    }
    
    static func processStatusCode(responseData: AnyObject) -> StatusCode {
        var status: StatusCode = StatusCode.ServerError
        if let remoteStatus = responseData["Status"] as? Int {
            if remoteStatus < StatusCode.count {
                status = StatusCode(rawValue: remoteStatus)!
            } else {
                status = StatusCode.UndefinedError
            }
        }
        return status
    }
    
}

extension Networking {
    static func hostGame(gameName: String, playerName: String,success: @escaping (_ results: JoinGameResponse) -> Void, failure: @escaping (_ error:Error?) -> Void) -> Void {
        let router = LycanRouter.HostGame(gameName,playerName)
        SessionManager.default.request(router).responseJSON { (data) in
            var response = JoinGameResponse()
            if let json = data.result.value as? [String: Any] {
                if let playerId = json["PlayerId"] as? String {
                    response.playerId = playerId
                }
                if let gameId = json["GameId"] as? String {
                    response.gameId = gameId
                }

                print(data)
                success(response)
            }
        }
    }
    
    static func joinGame(playerName: String,gameName:String, success: @escaping (_ results: JoinGameResponse) -> Void, failure: @escaping (_ error:Error?) -> Void) -> Void {
        let router = LycanRouter.JoinGame(playerName, gameName)
        print(router.urlRequest)
        SessionManager.default.request(router).responseJSON { (data) in
            var response = JoinGameResponse()
            if let json = data.result.value as? [String: Any] {
                if let playerId = json["PlayerId"] as? String {
                    response.playerId = playerId
                }
                if let gameId = json["GameId"] as? String {
                    response.gameId = gameId
                }
        
                print(data)
                success(response)
            }
        }
    }
    
    
    static func isReady(playerId: String,isReadied: Bool, success: @escaping (_ results: IsReadyResponse) -> Void, failure: @escaping (_ error:Error?) -> Void) -> Void {
        let router = LycanRouter.IsReady(playerId, isReadied)
        SessionManager.default.request(router).responseJSON { (data) in
            
            let response = IsReadyResponse()
            if let json = data.result.value as? [String: Any] {
                
                if let players = json["Players"] as? [[String: Any]] {
                    for play in players {
                        let player = ConnectedPlayer(color: Networking.generateRandomColor())
                        if let playerId = play["PlayerId"] as? String {
                            player.id = playerId
                        }
                        if let name = play["Name"] as? String {
                            player.name = name
                        }
                        if let ready = play["IsReady"] as? Bool {
                            player.isReady = ready
                        }
                        if let npc = play["IsNPC"] as? Bool {
                            player.isNPC = npc
                        }
                        if let type = play["PlayerType"] as? Int {
                            player.playerType = PlayerType(rawValue: type)
                        }
                        response.players.append(player)
                    }
                }
                if let state = json["GameState"] as? Int {
                    response.gameState = GameState(rawValue: state)
                }
                if let type = json["PlayerType"] as? Int {
                    response.playerType = PlayerType(rawValue: type)
                }
                
                print(data)
                success(response)
            }

        }
    }
    
    //TODO: MOVE THIS ELSEWHERE
    static func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
