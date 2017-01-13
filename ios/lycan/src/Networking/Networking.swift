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
    
    case JoinGame(String)
    case IsReady(String)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .JoinGame(let name):
            return .post
        case .IsReady(let playerId):
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .JoinGame(let name):
            return "/JoinGame?name=\(name)"
        case .IsReady(let playerId):
            return "/IsReady?playerId=\(playerId)"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: LycanRouter.baseURLString)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        

        
        if self.method == .get {
            urlRequest.httpBody = nil
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
    
    static func joinGame(name: String, success: @escaping (_ results: JoinGameResponse) -> Void, failure: @escaping (_ error:Error?) -> Void) -> Void {
        let router = LycanRouter.JoinGame(name)
        
        SessionManager.default.request(router).responseJSON { (data) in
            print(data)
        }
        
//        SessionManager.default.request(router).responseObject { (response: DataResponse<JoinGameResponse>) in
//            if !response.result.isSuccess {
//                print(response.request!)
//                failure(nil)
//            }
//            
//            if let responseData = response.result.value {
//                success(responseData)
//            } else {
//                failure(nil)
//            }
//        }
    }
}
