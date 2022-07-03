//
//  ResponseDocument.swift
//  
//
//  Created by Cory Loken on 7/2/22.
//

import Foundation

public struct ResponseDocument<T: Modelable>: Document {  
  public var data: T
  public var included: [T]
  public var meta: Dictionary<String, Any>
  
  public init(from jsonData: Data) throws {
    guard let decodedData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { throw ParseError.data("Parse Error") }
    let d = decodedData["data"] as? [Dictionary<String, Any>] ?? []
    let decoder = JSONDecoder()
    data = try! decoder.decode(T.self, from: JSONSerialization.data(withJSONObject: d.map { flatten(document: $0) }))
        
    included = decodedData["included"] as? [T] ?? []
    meta = decodedData["meta"] as? Dictionary<String, Any> ?? [:]
  }
}
