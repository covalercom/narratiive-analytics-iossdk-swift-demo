import AdSupport
import AppTrackingTransparency
import WebKit

@objcMembers public class NarratiiveSDK: NSObject {
    static let NarratiiveSDKToken = "NarratiiveSDKToken"
    let webView = WKWebView(frame: .zero)
    
    var host: String?
    var hostKey: String?
    var idfa: String?
    var token: String?
    var ua: String?
    var isSending: Bool = false
    
    public var debugMode: Bool = false
    public var useIDFA: Bool = false
    
    private func log(_ msg: String) {
        if debugMode {
            print(msg)
        }
    }
    
    private func loadIDFA() {
        log("Loading IDFA from device...")
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized  {
                log("\t- IDFA NOT Authorized in IOS14+")                
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                log("\t- IDFA Tracking NOT Enabled")
            }
        }

        idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        log("\t- IDFA loaded: \(String(describing: idfa))")

        if idfa == "00000000-0000-0000-0000-000000000000" {
            idfa = nil
            log("\t- IDFA Zeroed. Possibly running in simulators or IDFA not allowed")
        }
    }
    
    private func loadToken() {
        log("Loading token from UserDefault...")
        token = UserDefaults.standard.string(forKey: NarratiiveSDK.NarratiiveSDKToken)
        
        if let token = token {
            log("\t- token loaded: \(token)")
        } else {
            log("\t- token NOT loaded.")
        }
    }
    
    private func getUserAgent(completion: @escaping (String) -> Void) {
        if let ua = ua {
            completion(ua)
        } else {
            self.log("Detecting User Agent...")
            
            webView.evaluateJavaScript("navigator.userAgent") {
                ua, error in
                if let ua = ua {
                    self.ua = ua as? String
                    self.log("\t- User Agent Detected: \(self.ua!)")
                } else {
                    self.ua = "iOS/0.0 (Mobile)"
                    self.log("\t- Failed detecting User Agent: \(String(describing: error)). Default to iOS/0.0 (Mobile)")
                }
                completion(self.ua!)
            }
        }
    }
    
    private func postJson(jsonDict: [String: Any?], urlString: String, completion: @escaping ([String: Any]?, Error?, Bool?) -> Void) {
        log("Making a POST request to \(urlString)...")
        
        getUserAgent() { userAgent in
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                
                self.log("\t- with data \( String(decoding: jsonData, as: UTF8.self))...")
                
                URLSession.shared.uploadTask(with: request, from: jsonData) {
                    data, response, error in
                    
                    var success = false
                    if let httpResponse = response as? HTTPURLResponse {
                        success = httpResponse.statusCode == 200 || httpResponse.statusCode == 202
                    }
                    
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(json, error, success)
                    } else {
                        completion(nil, error, success)
                    }
                    
                    
                }.resume()
                
            } catch let error {
                self.log("\t- POST request failed with error: \(error)...")
                completion(nil, error, false)
            }
        }
    }
    
    private func createToken(completion: @escaping () -> Void) {
        log("Creating a new Token...")
        guard host != nil, hostKey != nil else {
            log("\t- Missing host or hostKey, abort.")
            return
        }
        
        let json = [
            "host": host,
            "hostKey": hostKey,
            "idfa": idfa
        ]
        
        postJson(jsonDict: json, urlString: "https://collector.effectivemeasure.net/app/tokens") {
            data, error, success in
            
            if let error = error {
                self.log("\t- Request failed. Error : \(error)")
            }
            
            if let data = data, let success = success {
                if success && data["token"] != nil {
                    let newToken = data["token"] as? String
                    self.token = newToken
                    self.log("\t- Token created: \(String(describing: newToken))")
                    self.saveToken()
                    completion()
                } else {
                    self.log("\t- Failed creating token: \(String(describing: error))")
                }
            }
        }
    }
    
    private func saveToken() {
        log("Saving token to UserDefault")
        if let token = token {
            log("\t- Token saved: \(token)")
            UserDefaults.standard.set(token, forKey: NarratiiveSDK.NarratiiveSDKToken)
        } else {
            log("\t- Error: token is missing")
        }
    }
    
    private func registerHit(path: String?) {
        log("Sending screen event with '\(path ?? "")'.")
        
        guard token != nil, host != nil, hostKey != nil else {
            log("\t- Failed. Missing token, host or hostKey")
            return
        }
        
        guard !isSending else {
            log("\t- Failed. Pending request exists")
            return
        }
        
        let json = [
            "host": host,
            "hostKey": hostKey,
            "token": token,
            "path": path,
            "agent": "ios"
        ]
        
        isSending = true
        postJson(jsonDict: json, urlString: "https://collector.effectivemeasure.net/app/hits") {
            data, error, success in
            
            if let error = error {
                self.log("\t- Request failed. Error : \(error)")
            }
            
            if let data = data, let success = success {
                if success && data["token"] != nil {
                    self.token = data["token"] as? String
                    self.log("\t- Event sent. New token received: \(self.token!)")
                    self.saveToken()
                } else {
                    let error = data["err"] as? String
                    self.log("\t- Event NOT sent. Error: \(error ?? "Unknown")")
                }
            }
            self.isSending = false
        }
    }
    
    static var sharedNarratiiveSDK: NarratiiveSDK = {
        let sdk = NarratiiveSDK()
        // More config here if required
        return sdk
    }()
    
    public class func sharedInstance() -> NarratiiveSDK? {
        return sharedNarratiiveSDK
    }
    
    public func setup(withHost: String, andHostKey: String) {
        log("Setting up instance with \(withHost) and \(andHostKey).")
        
        host = withHost
        hostKey = andHostKey
        
        if useIDFA {
            loadIDFA()
        }

        loadToken()
    }
    
    public func send(screenName: String) {
        if token != nil {
            registerHit(path: screenName)
        } else {
            createToken {
                self.registerHit(path: screenName)
            }
        }
    }
}
