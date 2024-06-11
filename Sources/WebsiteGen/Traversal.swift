import DequeModule
import DocumentationDB
import Foundation
import FrontEnd

/// Traverse all assets and symbols starting from a certain root node
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - root: asset to traverse
///   - visitor: documentation visitor to handle visits
public func traverse(ctx: GenerationContext, root: AnyAssetID, visitor: (TargetPath) -> Void) {
  var path = TargetPath(ctx: ctx)
  traverseAssets(ctx: ctx, root: root, visitor: visitor, path: &path)
}

/// Traverse an asset and its children
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - root: asset to traverse
///   - visitor: documentation visitor to handle visits
///   - path: call-stack path
private func traverseAssets(
  ctx: GenerationContext, root: AnyAssetID, visitor: (TargetPath) -> Void,
  path: inout TargetPath
) {
  // Visit
  path.push(asset: root)
  visitor(path)

  // Traverse
  switch root {
  case .folder(let id):
    // Traverse children
    let folder = ctx.documentation.assets.folders[id]!
    folder.children.filter { folder.documentation == nil || $0 != .article(folder.documentation!) }
      .forEach {
        child in traverseAssets(ctx: ctx, root: child, visitor: visitor, path: &path)
      }
    break
  case .sourceFile(let id):
    // Traverse children
    let sourceFile = ctx.documentation.assets.sourceFiles[id]!
    ctx.typedProgram.ast[sourceFile.translationUnit]!.decls.forEach {
      child in traverseSymbols(ctx: ctx, root: child, visitor: visitor, path: &path)
    }
    break
  default:
    // rest of the asset types have no children
    break
  }

  path.pop()
}

/// Traverse all symbols in a source-file and visit them
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - root: source-file to traverse symbols off
///   - visitor: documentation visitor to handle visits
///   - path: call-stack path
private func traverseSymbols(
  ctx: GenerationContext, root: AnyDeclID, visitor: (TargetPath) -> Void,
  path: inout TargetPath
) {
  // Visit
  path.push(decl: root)

  // Traverse
  switch root.kind {
  case AssociatedTypeDecl.self,
    AssociatedValueDecl.self,
    TypeAliasDecl.self,
    BindingDecl.self,
    OperatorDecl.self,
    FunctionDecl.self,
    MethodImpl.self,
    SubscriptImpl.self,
    InitializerDecl.self,
    MethodDecl.self,
    SubscriptDecl.self:
    visitor(path)
    break
  case TraitDecl.self:
    visitor(path)

    let id = TraitDecl.ID(root)!
    let decl = ctx.typedProgram.ast[id]!

    // Traverse children
    decl.members.forEach {
      child in traverseSymbols(ctx: ctx, root: child, visitor: visitor, path: &path)
    }
    break
  case ProductTypeDecl.self:
    visitor(path)

    let id = ProductTypeDecl.ID(root)!
    let decl = ctx.typedProgram.ast[id]!

    // Traverse children
    decl.members.forEach {
      child in traverseSymbols(ctx: ctx, root: child, visitor: visitor, path: &path)
    }
    break
  default:
    break
  }

  path.pop()
}
