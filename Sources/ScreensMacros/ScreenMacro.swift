import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ScreenMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {

    let conformance =  try ExtensionDeclSyntax("extension \(type): Screen {}")

    if case let .argumentList(arguments) = node.arguments, arguments.contains(where: { $0.label?.text == "path" }) {
      let conformanceDecodable =  try ExtensionDeclSyntax("extension \(type): ScreenURLDecodable {}")
      return [conformance, conformanceDecodable]
    } else {
      return [conformance]
    }
  }
}

extension ScreenMacro: MemberMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard declaration.asProtocol(NamedDeclSyntax.self) != nil else {
      return []
    }

    var declarations: [DeclSyntax] = []

    var alias: ExprSyntax = "nil"
    var params: [ExprSyntax] = []
    var hasPath: Bool = false

    if case let .argumentList(arguments) = node.arguments {

      for argument in arguments {
        switch argument.label?.text {
        case "alias":
          alias = argument.expression
          let declaration: DeclSyntax =
          """
            public static let alias = \(argument.expression)
          """
          declarations.append(declaration)
        case "path":
          hasPath = true
          let declaration: DeclSyntax =
          """
            public static let path = \(argument.expression)
          """
          declarations.append(declaration)
        case "params":
          params.append(argument.expression)
        default:
          params.append(argument.expression)
        }
      }
    }

    if hasPath {
      let cases = params.map { "case \($0.as(StringLiteralExprSyntax.self)!.segments)" }.joined(separator: "\n")
      let declaration: DeclSyntax
      if cases.isEmpty {
        declaration =
      """
        typealias ParamsKey = EmptyKeys
      """
      } else {
        declaration =
      """
        enum ParamsKey: String, CaseIterable {
        \(raw: cases)
        }
      """
      }
      declarations.append(declaration)
    }

    let fileDecl: DeclSyntax =
            """
            public static let file: StaticString = #file
            """
    declarations.append(fileDecl)

    let bodyDecl: DeclSyntax =
            """
            public var body: some View {
               screenBody
                  .modifier(ScreenModifier(Self.self, alias: \(alias)))
            }
            """
    declarations.append(bodyDecl)

    return declarations
  }
}
