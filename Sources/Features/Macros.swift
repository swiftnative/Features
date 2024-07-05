//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


@attached(member, names: named(body), named(featureBody))
@attached(extension, conformances: SharedFeature)
public macro SharedFeature() = #externalMacro(module: "FeaturesMacros", type: "SharedFeatureMacro")

@attached(member, names: named(body))
@attached(extension, conformances: Feature)
public macro Feature() = #externalMacro(module: "FeaturesMacros", type: "FeatureMacro")
