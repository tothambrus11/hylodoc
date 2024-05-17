import Foundation
import FrontEnd
import DocumentationDB

/// Render an arbitrary asset page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: asset to render page of
///
/// - Returns: the contents of the rendered page
public func renderAssetPage(ctx: GenerationContext, of: AnyAssetID) -> String {
    switch of {
    case .module(let id):
        let module = ctx.documentation.assetStore.modules[documentationId: id]!
        return renderModulePage(ctx: ctx, of: module)
    case .sourceFile(let id):
        let sourceFile = ctx.documentation.assetStore.sourceFiles[documentationId: id]!
        return renderSourceFilePage(ctx: ctx, of: sourceFile)
    case .article(let id):
        let article = ctx.documentation.assetStore.articles[id]!
        return renderArticlePage(ctx: ctx, of: article)
    case .otherFile(_):
        // Generic asset, like an image
        return ""
    }
}

/// Render an arbitrary symbol page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: symbol to render page of
///
/// - Returns: the contents of the rendered page
public func renderSymbolPage(ctx: GenerationContext, of: AnyDeclID) -> String {
    switch of.kind {
    case AssociatedTypeDecl.self:
        let id = AssociatedTypeDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.associatedTypeDocs[astNodeId: id]!
        return renderAssociatedTypePage(ctx: ctx, of: decl, with: declDoc)
    case AssociatedValueDecl.self:
        let id = AssociatedValueDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.associatedValueDocs[astNodeId: id]!
        return renderAssociatedValuePage(ctx: ctx, of: decl, with: declDoc)
    case TypeAliasDecl.self:
        let id = TypeAliasDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.TypeAliasDocs[astNodeId: id]!
        return renderTypeAliasPage(ctx: ctx, of: decl, with: declDoc)
    case BindingDecl.self:
        let id = BindingDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.BindingDocs[astNodeId: id]!
        return renderBindingPage(ctx: ctx, of: decl, with: declDoc)
    case OperatorDecl.self:
        let id = OperatorDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.operatorDocs[astNodeId: id]!
        return renderOperatorPage(ctx: ctx, of: decl, with: declDoc)
    case FunctionDecl.self:
        let id = FunctionDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.functionDocs[astNodeId: id]!
        return renderFunctionPage(ctx: ctx, of: decl, with: declDoc)
    case MethodDecl.self:
        let id = MethodDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.methodDeclDocs[astNodeId: id]!
        return renderMethodPage(ctx: ctx, of: decl, with: declDoc)
    case MethodImpl.self:
        let id = MethodImpl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.methodImplDocs[astNodeId: id]!
        return renderMethodImplementationPage(ctx: ctx, of: decl, with: declDoc)
    case SubscriptDecl.self:
        let id = SubscriptDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.subscriptDeclDocs[astNodeId: id]!
        return renderSubscriptPage(ctx: ctx, of: decl, with: declDoc)
    case SubscriptImpl.self:
        let id = SubscriptImpl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.subscriptImplDocs[astNodeId: id]!
        return renderSubscriptImplementationPage(ctx: ctx, of: decl, with: declDoc)
    case InitializerDecl.self:
        let id = InitializerDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.initializerDocs[astNodeId: id]!
        return renderInitializerPage(ctx: ctx, of: decl, with: declDoc)
    case TraitDecl.self:
        let id = TraitDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.traitDocs[astNodeId: id]!
        return renderTraitPage(ctx: ctx, of: decl, with: declDoc)
    case ProductTypeDecl.self:
        let id = ProductTypeDecl.ID(of)!
        let decl = ctx.typedProgram.ast[id]!
        
        // Render page
        let declDoc = ctx.documentation.symbols.productTypeDocs[astNodeId: id]!
        return renderProductTypePage(ctx: ctx, of: decl, with: declDoc)
    default:
        return ""
    }
}