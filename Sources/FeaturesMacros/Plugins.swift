//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FeaturesPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SharedFeatureMacro.self
    ]
}
