//
//  QueryParameters.swift
//
//  Created by Cory Loken on 7/9/20.
//


/// Container for query parameters on JR Request
public struct QueryParameters: Encodable {
  public init(page: QueryParameters.Page = Page(limit: 20, offset: 0), filter: [String : String]? = nil, include: String? = nil, sort: String? = nil, isPublic: Bool? = nil, path: String? = nil) {
    self.page = page
    self.filter = filter
    self.include = include
    self.sort = sort
    self.isPublic = isPublic
    self.path = path
  }
  
  /// Stores paging information about the collection
  public struct Page: Encodable {
    public init(limit: Int = 20, offset: Int = 0) {
      self.limit = limit
      self.offset = offset
    }
    
    public var limit: Int
    public var offset: Int
  }

  /// Pagination
  public var page = Page(limit: 20, offset: 0)
  public var filter: [String: String]? = nil
  public var include: String? = nil
  public var sort: String? = nil
  
  // Used to construct url (isPublic could be auto encoded eventually)
  public var isPublic: Bool? = nil
  public var path: String? = nil
 
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(page, forKey: .page)
    
    if filter != nil && filter != [:] {
      try container.encode(filter, forKey: .filter)
    }
    if include != nil && include != "" {
      try container.encode(include, forKey: .include)
    }
    
    if sort != nil && sort != "" {
      try container.encode(sort, forKey: .sort)
    }
  }
  
  public mutating func merge(query: QueryParameters) {
    self.page = query.page
    
    if let filter = query.filter { self.filter = filter }
    if let sort = query.sort { self.sort = sort }
    if let path = query.path { self.path = path }
    if let include = query.include { self.include = include }
    if let isPublic = query.isPublic { self.isPublic = isPublic }
  }
  
  public enum CodingKeys: String, CodingKey {
    case page, search, filter, include, sort
  }
}
