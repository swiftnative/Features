import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ScreensMacros)
import FeaturesMacros

let testMacros: [String: Macro.Type] = [
    "screens": ScreenMacro.self,
]
#endif

final class ScreensTests: XCTestCase {
    func testSharedFeature() throws {
        #if canImport(ScreensMacros)
        assertMacroExpansion(
            """
            @Screen
            struct A {
              var screenBody: some View {
                Text("Screen")
              }
            }
            """,
            expandedSource: """
            struct A {
              var screenBody: some View {
                Text("Screen")
              }
              public var body: some View {
                screenBody
                  .modifier(ScreenModifier(Self.self, screenID: screenID))
              }
            }
            
            extesnion A: Screen {}
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

//@Screen
//struct TestScreen {
//
//}
