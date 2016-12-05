//
//  URLQueryBuilder.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: keep or ditch this class?

import Foundation

class URLQueryBuilder {
    
    // public function
    func buildAndSendQuery(
        _ host: String,
        path: String,
        query: String,
        method: String,
        queryItems: [URLQueryItem],
        headerItems: [String: String]?,
        resultsHander: @escaping ((Bool, NSDictionary)->Void)
        ) {
        
        let url = buildURLQuery(host, path: path, query: query, queryItems: queryItems)
        let request = buildRequest(url, method: method, headerItems: headerItems)
        performSessionTask(request as URLRequest, completionHander: resultsHander)
        
    }
    
    fileprivate func buildURLQuery(_ host: String, path: String, query: String, queryItems: [URLQueryItem]) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.query = query
        components.queryItems = [URLQueryItem]()
        
        for items in queryItems {
            components.queryItems?.append(items)
        }
        
        return components.url!
    }
    
    fileprivate func buildRequest (_ url: URL, method: String, headerItems: [String: String]?) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(url: url)
            
        request.httpMethod = method
    
        if (headerItems != nil) {
            for items in headerItems! {
                request.addValue(items.0, forHTTPHeaderField: items.1)
            }
        }
        return request
    }
    
    fileprivate func performSessionTask(_ request: URLRequest, completionHander: @escaping ((Bool, NSDictionary)->Void)) {
        
        var returnDict = [String: AnyObject]()
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            returnDict["data"] = data as AnyObject?
            returnDict["response"] = response
            returnDict["error"] = error as AnyObject?
            
            guard (error == nil) else {
                completionHander(false, returnDict as NSDictionary)
                return
            }
            
            
            completionHander(true, returnDict as NSDictionary)
        }) 
        task.resume()
    }
}
