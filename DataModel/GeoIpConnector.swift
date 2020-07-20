//
//  GeoIpConnector.swift
//  Transmission Remote
//
//  Created by  on 7/28/19.
//

import Foundation

private let FREEGEOIP_HOST = "http://ip-api.com/json/"
private let GOOGLE_HOST = "https://maps.googleaips.com/maps/api/geocode/json"
private let GOOGLE_KEY = "AIzaSyCif5kPXiTNQ-u259_Wumr-kT54RhS7LAk"

class GeoIpConnector {
    
    private var session: URLSession?

    private static var infoCache: [String : [String:AnyHashable]]? = nil

    func getInfoForIp(_ ip: String, responseHandler handler: @escaping (_ error: String?, _ dict: [String : AnyHashable]?) -> Void) {
        if GeoIpConnector.infoCache == nil {
            GeoIpConnector.infoCache = [ : ]
        }

        // check this info in chache
        if GeoIpConnector.infoCache![ip] != nil {
            handler(nil, GeoIpConnector.infoCache![ip])
            return
        }

        if isGrayIP(ip) {
            let errDesc = NSLocalizedString("This ip belongs to some private net and location can not be detected", comment: "")
            handler(errDesc, nil)
            return
        }

        let urlStr = "\(FREEGEOIP_HOST)\(ip)"

        var r: URLRequest? = nil
        if let url = URL(string: urlStr) {
            r = URLRequest(url: url)
        }

        var task: URLSessionDataTask? = nil
        if let r = r {
            task = session?.dataTask(with: r, completionHandler: { data, response, error in
                if error != nil {
                    let errDesc = NSLocalizedString("Can't get info for this ip\n\(error?.localizedDescription ?? "")", comment: "")
                    handler(errDesc, nil)
                } else {
                    let res = response as? HTTPURLResponse

                    if res?.statusCode == 200 {
                        if data != nil {
                            var json: [String : AnyHashable]? = nil
                            do {
                                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyHashable]
                                GeoIpConnector.infoCache![ip] = json
                                handler(nil, json)
                            } catch {
                                handler(error.localizedDescription,nil)
                            }
                        }
                    } else {
                        let errDesc = String(format: NSLocalizedString("Can't get info for this ip, server error: %i\n%@", comment: ""), res?.statusCode ?? 0, HTTPURLResponse.localizedString(forStatusCode: res?.statusCode ?? 0))

                        handler(errDesc, nil)
                    }
                }
            })
        }

        task?.resume()
    }

    func googleReverseGeoCoding(forLatitude lat: Double, longtitude lng: Double, responseHandler handler: @escaping (_ error: String?, _ dict: [AnyHashable : Any]?) -> Void) {
        let urStr = "\(GOOGLE_HOST)?latlng=\(lat),\(lng)&key=\(GOOGLE_KEY)"
        var r: URLRequest? = nil
        if let url = URL(string: urStr) {
            r = URLRequest(url: url)
        }

        var task: URLSessionDataTask? = nil
        if let r = r {
            task = session?.dataTask(with: r, completionHandler: { data, response, error in
                if error != nil {
                    DispatchQueue.main.async(execute: {
                        handler(error?.localizedDescription, nil)
                    })
                } else {
                    let res = response as? HTTPURLResponse

                    if res?.statusCode == 200 {
                        var json: [AnyHashable : Any]? = nil
                        do {
                            if let data = data {
                                json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                            }
                        } catch {
                        }

                        DispatchQueue.main.async(execute: {
                            handler(nil, json)
                        })
                    } else {
                        // signal error here
                        DispatchQueue.main.async(execute: {
                            handler("Can not get info", nil)
                        })
                    }
                }
            })
        }

        task?.resume()
    }

    init() {

        session = URLSession.shared
    }

    func isGrayIP(_ ip: String) -> Bool {
        let components = ip.components(separatedBy: ".")
        if components.count == 4 {
            let firstNum = Int(components[0]) ?? 0
            let secondNum = Int(components[1]) ?? 0

            if firstNum == 127 || firstNum == 10 || (firstNum == 192 && secondNum == 168) || (firstNum == 169 && secondNum == 264) || (firstNum == 172 && (secondNum >= 16 && secondNum <= 32)) {
                return true
            }
        }

        return false
    }
}


