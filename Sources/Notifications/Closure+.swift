//
// Created by Alexey Nenatyev on 2.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

/// Делает вызов call на инстансе instance с использованием слабой ссылки на instance
public func withWeak<Obj, Arg>( _ instance: Obj, call: @escaping (Obj) -> (Arg) -> Void ) -> (Arg) -> Void where Obj: AnyObject {
  { [weak instance] arg in
    guard let instance = instance else { return }

    let instanceFunc = call(instance)
    instanceFunc(arg)
  }
}
/// Делает асинхронный вызов call на инстансе instance с использованием слабой ссылки на instance
public func withWeak<Obj, Arg>( _ instance: Obj, call: @escaping (Obj) -> (Arg) async -> Void ) -> (Arg) -> Void where Obj: AnyObject {
  { [weak instance] arg in
    guard let instance = instance else { return }

    let instanceFunc = call(instance)
    Task {  await instanceFunc(arg) }
  }
}

/// Делает вызов call на инстансе instance с использованием слабой ссылки на instance
public func withWeak<Obj>( _ instance: Obj, call: @escaping (Obj) -> () -> Void ) -> () -> Void where Obj: AnyObject {
  { [weak instance]  in
    guard let instance = instance else { return }

    let instanceFunc = call(instance)
    instanceFunc()
  }
}
