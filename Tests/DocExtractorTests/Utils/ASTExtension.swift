import FrontEnd

extension AST {

  func resolveProductType(by name: String) -> ProductTypeDecl.ID? {
    struct ASTWalker: ASTWalkObserver {
      var result: ProductTypeDecl.ID?
      let targetName: String

      mutating func willEnter(_ id: AnyNodeID, in ast: AST) -> Bool {
        if let d = ProductTypeDecl.ID(id), ast[d].baseName == targetName {
          result = d
          return false
        }
        return true
      }
    }

    var walker = ASTWalker(result: nil, targetName: name)
    for m in modules {
      walk(m, notifying: &walker)
    }
    return walker.result
  }

  func resolveTypeAlias(by name: String) -> TypeAliasDecl.ID? {
    struct ASTWalker: ASTWalkObserver {
      var result: TypeAliasDecl.ID?
      let targetName: String

      mutating func willEnter(_ id: AnyNodeID, in ast: AST) -> Bool {
        if let d = TypeAliasDecl.ID(id), ast[d].baseName == targetName {
          result = d
          return false
        }
        return true
      }
    }

    var walker = ASTWalker(result: nil, targetName: name)
    for m in modules {
      walk(m, notifying: &walker)
    }
    return walker.result
  }

  init(fromSingleSourceFile: SourceFile, diagnostics: inout DiagnosticSet) {
    self.init(ConditionalCompilationFactors())
    let sourceFile = fromSingleSourceFile
    let _ = try! makeModule(
      "RootModule",
      sourceCode: [sourceFile],
      builtinModuleAccess: true,
      diagnostics: &diagnostics
    )
  }
}