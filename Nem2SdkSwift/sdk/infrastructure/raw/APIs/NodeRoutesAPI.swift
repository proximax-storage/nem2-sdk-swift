// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.
//
// NodeRoutesAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire



class NodeRoutesAPI {
    /**
     Get the node information
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getNodeInfo(completion: @escaping ((_ data: NodeInfoDTO?,_ error: Error?) -> Void)) {
        getNodeInfoWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error);
        }
    }


    /**
     Get the node information
     - GET /node/info
     - Supplies additional information about the application running on a [Node](https://nemtech.github.io/concepts/node.html).
     - examples: [{contentType=application/json, example={
  "port" : 7900,
  "roles" : 2,
  "host" : "api-node-0",
  "publicKey" : "EB6839C7E6BD0031FDD5F8CB5137E9BC950D7EE7756C46B767E68F3F58C24390",
  "networkIdentifier" : 144,
  "version" : 0,
  "friendlyName" : "api-node-0"
}}]

     - returns: RequestBuilder<NodeInfoDTO> 
     */
    class func getNodeInfoWithRequestBuilder() -> RequestBuilder<NodeInfoDTO> {
        let path = "/node/info"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil

        let url = NSURLComponents(string: URLString)


        let requestBuilder: RequestBuilder<NodeInfoDTO>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

    /**
     Get the node time
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getNodeTime(completion: @escaping ((_ data: NodeTimeDTO?,_ error: Error?) -> Void)) {
        getNodeTimeWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error);
        }
    }


    /**
     Get the node time
     - GET /node/time
     - Supplies additional information about the application running on a node.
     - examples: [{contentType=application/json, example={
  "communicationTimestamps" : {
    "receiveTimestamp" : "",
    "sendTimestamp" : ""
  }
}}]

     - returns: RequestBuilder<NodeTimeDTO> 
     */
    class func getNodeTimeWithRequestBuilder() -> RequestBuilder<NodeTimeDTO> {
        let path = "/node/time"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil

        let url = NSURLComponents(string: URLString)


        let requestBuilder: RequestBuilder<NodeTimeDTO>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

}
