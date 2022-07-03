//
//  Model.swift
//
//  Created by Cory Loken on 7/9/20.
//

import Foundation

public struct Store {}

struct Collection<T: Modelable> {
  var data = [T]()
  
  init(from data: [T]) {
    self.data = data
  }
}

// TODO: The purpose of this is to stoe related models for fast lookup
// Swift 5.7 makes this easier so not implemeting for now.
struct Included<T: Modelable> {
  @discardableResult
  init(from included: [T]) {
//    for include in included {
//      let id = include.id
//      let type = T.type
      
//        switch type {
//        case "users":
//          do {
//            Store.users[id] == nil ?
//              Store.users[id] = try User(from: include) :
//              Store.users[id]?.refresh(from: include)
//          } catch {
//            print("WTF")
//          }
//        default: print("Do nothing")
//        }
//    }
  }
}
