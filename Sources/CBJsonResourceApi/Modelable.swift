//
//  Modelable.swift
//
//  Created by Cory Loken on 7/9/20.
//

import Alamofire
import Swift
import Foundation

public protocol Modelable: Identifiable, Codable {
  static var rootUrl: String {get}
  /// Make everything generic
  associatedtype T
  /// A model should always know how to handle a json source
//  init(from dictionary: Dictionary<String, Any>) throws
  /// Implements how a model will be persisted to the server
  static func create<T: Modelable>(_ model: T, query: QueryParameters) async throws -> T
  /// Call after a create or update to merge changes from the server
  func refresh(from json: Dictionary<String, Any>)
  /// Finds a single record of type with optional paging parameters
  static func find<T: Modelable>(id: String, query: QueryParameters) async throws -> T
  /// Finds all records of type with optional paging parameters
  static func find<T: Modelable>(query: QueryParameters) async throws -> ([T], [String: Any])
  /// Deletes a single record by type and id
  static func delete(type: String, id: String) async throws
  /// Updates a single record
  static func update<T: Modelable>(_ model: T, query: QueryParameters) async throws -> T
  /// What goes at the end of the apis root url
  static var queryPath: String {get}
  /// The encoded value to be passed to url.
  var json: Dictionary<String, Any> {get}
  /// Implement this as an app level extension
  static func networkError(_ error: AFError)
  
  func asDocument() -> Dictionary<String, Any>
  static func authToken() -> String
  static var type: String { get }
}

/// Default getters for a modelable object
extension Modelable {
  static var rootUrl: URL {
    URL(string: rootUrl)!
  }
  
  /// Default headers sent to server. In theory these could be converted to a config, but not sure why.
  public static func headers(isPublic: Bool = false) -> HTTPHeaders {
    return ["Accept": "application/vnd.api+json;version=1",
            "Content-Type": "application/vnd.api+json;version=1",
            "Authorization": isPublic ? "Public" : authToken()
    ]
  }
}

/// Default methods for a modelable object
extension Modelable {
  public var json: Dictionary<String, Any> {
    print("Attempted to serialize model without specifying `json` var in \(T.self)")
    return Dictionary<String, Any>()
  }
  
  /// Default implementation to persist a new model to the server.
  public static func create<T: Modelable>(_ model: T, query: QueryParameters = QueryParameters()) async throws -> T {
    let url = rootUrl.appendingPathComponent(T.queryPath)
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    
    if query.include != nil && !query.include!.isEmpty {
      components?.queryItems = [URLQueryItem(name: "include", value: query.include)]
    }
    
    let task = AF.request(components!.url!, method: .post, parameters: model.asDocument(), encoding: JSONEncoding.default, headers: headers(isPublic: query.isPublic ?? false))
      .validate()
      .serializingData()
    do {
      let document = try ResponseDocument<T>(from: try await task.value)
      Included(from: document.included)
      return document.data
    } catch {
      throw error
    }
  }
  
  /// Default implementation to find models from the server. .
  public static func find<T: Modelable>(query: QueryParameters = QueryParameters()) async throws -> ([T], [String: Any]) {
    let url = query.path == nil ? rootUrl.appendingPathComponent(T.queryPath) : rootUrl.appendingPathComponent(query.path!)

    let task = AF.request(url, method: .get, parameters: query, headers: headers(isPublic: query.isPublic ?? false))
      .validate()
      .serializingData()
    do {
      let documents = try ResponseDocuments<T>(from: await task.value)
      Included(from: documents.included)
      let collection: Collection<T> = Collection(from: documents.data)
      return (collection.data, documents.meta)
    } catch {
      throw error
    }
  }
  
  /// Default implementation to find single model from the server. .
  public static func find<T: Modelable>(id: String, query: QueryParameters = QueryParameters()) async throws -> T {
    let url = rootUrl.appendingPathComponent(T.queryPath).appendingPathComponent(id)
    
    let task = AF.request(url, method: .get, parameters: query, headers: headers(isPublic: query.isPublic ?? false))
      .validate()
      .serializingData()
    do {
      let document = try ResponseDocument<T>(from: try await task.value)
      Included(from: document.included)
      return document.data
    } catch {
      throw error
    }
  }
  
  // TODO: Figure out how to use T rather than a parameter of type
  // Will require refactor to view and we can use something similar to update.
  public static func delete(type: String, id: String) async throws {
    let url = rootUrl.appendingPathComponent("\(type)/\(id)")
    
    let task = AF.request(url, method: .delete, headers: headers())
      .validate()
      .serializingData()
    do {
      _ = try await task.value
    } catch {
      throw error
    }
  }
  
  public static func update<T: Modelable>(_ model: T, query: QueryParameters = QueryParameters()) async throws -> T {
    guard let id = model.id as? String else { throw ParseError.attribute("No Id found") }
    let url = rootUrl.appendingPathComponent(T.queryPath).appendingPathComponent(id)
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    
    if query.include != nil && !query.include!.isEmpty {
      components?.queryItems = [URLQueryItem(name: "include", value: query.include)]
    }
    
    let task = AF.request(components!.url!, method: .put, parameters: model, encoder: JSONParameterEncoder.default, headers: headers(isPublic: query.isPublic ?? false))
      .validate()
      .serializingData()

    do {
      let document = try ResponseDocument<T>(from: await task.value)
      Included(from: document.included)
      return model
    } catch {
      throw error
    }
  }
  
  func extractRelationshipId(dictionary: Dictionary<String,Any>, relationship: String) -> String? {
    guard let relationships = dictionary["relationships"] as? Dictionary<String, Any>,
          let avatar = relationships[relationship] as? Dictionary<String, Any>,
          let data = avatar["data"] as? Dictionary<String, Any>,
          let id = data["id"] as? String else { return nil }
    return id
  }
}
