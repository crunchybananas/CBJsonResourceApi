//
//  Document.swift
//  
//
//  Created by Cory Loken on 7/2/22.
//

public protocol Document {
  associatedtype T
  
  var data: T { get set }
  var included: [T] { get set }
  var meta: Dictionary<String, Any> { get set }
}

public protocol Documents {
  associatedtype T

  var data: [T] { get set }
  var included: [T] { get set }
  var meta: Dictionary<String, Any> { get set }
}

/// Flattens a JR document to a single object for codable.
func flatten(document: [String: Any]) -> [String: Any] {
  var d = document["attributes"] as! [String: Any]
  d["id"] = document["id"]
  d["type"] = document["type"]
  return d
}

