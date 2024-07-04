import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SharedFeatureMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    [try ExtensionDeclSyntax("extension \(type): SharedFeature {}")]
  }
}

extension SharedFeatureMacro: MemberMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.asProtocol(NamedDeclSyntax.self) != nil else {
      return []
    }

    let bodyDecl: DeclSyntax =
      """
      public var body: some View {
        if let featureBody = self as? (any FeatureBody) {
          return AnyView(featureBody.featureBody)
        } else {
          return AnyView(placeholderBody)
        }
      }
      """

    return [
      bodyDecl
    ]
  }
}
