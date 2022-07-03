//
//  ResponseDocuments.swift
//  
//
//  Created by Cory Loken on 7/1/22.
//



import Foundation

public enum ParseError: Error {
  case attribute(String)
  case data(String)
}

public struct ResponseDocuments<T: Modelable>: Documents {
  public var data: [T]
  public var included: [T]  
  public var meta: Dictionary<String, Any>
  
  public init(from jsonData: Data) throws {
    guard let decodedData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { throw ParseError.data("Parse Error") }
    let d = decodedData["data"] as? [Dictionary<String, Any>] ?? []
    let decoder = JSONDecoder()

    data = try! decoder.decode([T].self, from: JSONSerialization.data(withJSONObject:  d.map { flatten(document: $0) }))
    included = decodedData["included"] as? [T] ?? []
    meta = decodedData["meta"] as? Dictionary<String, Any> ?? [:]
  }
  
//  enum CodingKeys: String, CodingKey {
//    case data, included, meta
//  }
//  
//  public init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
//    data.
////    data = try container.decode([Dictionary<String, Any>].self, forKey: .data)
////    included = try container.decode([Dictionary<String, Any>.self], forKey: .included)
//
//  }
  
  public func encode(to encoder: Encoder) throws {
    
  }
}
