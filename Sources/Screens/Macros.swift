//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import SwiftUI

@attached(member, names: named(body), named(screenBody))
@attached(extension, conformances: SharedView)
public macro SharedView() = #externalMacro(module: "ScreensMacros", type: "SharedViewMacro")

@attached(member, names: named(body), named(path), named(ParamsKey), named(file), named(alias))
@attached(extension, conformances: Screen, ScreenURLDecodable)
public macro Screen(alias: String? = nil, path: String? = nil, params: String...) = #externalMacro(module: "ScreensMacros", type: "ScreenMacro")

//@attached(member, names: named(body))
//public macro Widget() = #externalMacro(module: "ScreensMacros", type: "WidgetMacro")

#endif
