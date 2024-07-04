import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(FeaturesMacros)
import FeaturesMacros

let testMacros: [String: Macro.Type] = [
    "features": SharedFeatureMacro.self,
]
#endif

final class FeaturesTests: XCTestCase {
    func testSharedFeature() throws {
        #if canImport(FeaturesMacros)
        assertMacroExpansion(
            """
            @SharedFeatureMacro
            struct A {}
            """,
            expandedSource: """
            struct A {}
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
