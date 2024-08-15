import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SharedViewMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    [try ExtensionDeclSyntax("extension \(type): SharedView {}")]
  }
}

extension DeclGroupSyntax {
  func hasAttribudte(name: String) -> Bool {
    attributes
       .contains { $0.as(AttributeSyntax.self)?.attributeName.description == name }
  }
}

extension SharedViewMacro: MemberMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    let bodyDecl: DeclSyntax

    if declaration.hasAttribudte(name: "Screen") {
      bodyDecl =
         """
         public var screenBody: some View {
          Group {
            if let sharedViewBody = self as? (any SharedViewBody) {
             AnyView(sharedViewBody.sharedBody)
            } else {
             AnyView(placeholderBody)
            }
          }
         }
         """
    } else {
      bodyDecl =
      """
      public var body: some View {
        if let sharedViewBody = self as? (any SharedViewBody) {
          return AnyView(sharedViewBody.sharedBody)
        } else {
          return AnyView(placeholderBody)
        }
      }
      """
    }
    
    return [ bodyDecl ]
  }
}

