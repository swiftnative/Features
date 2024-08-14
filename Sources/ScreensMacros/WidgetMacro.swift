import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics


struct WidgetMacro: MemberMacro {

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
               widgetBody
            }
            """

    return [bodyDecl]
  }
}

