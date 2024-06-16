import DequeModule
import DocumentationDB
import Foundation
import FrontEnd
import MarkdownKit
import PathWrangler
import Stencil

/// Context containing all the information needed to generate all the pages
public struct GenerationContext {
  let documentation: DocumentationContext
  var stencilEnvironment: Environment
  let htmlGenerator: some HyloReferenceResolvingGenerator
  let exporter: Exporter

  var breadcrumb: Deque<BreadcrumbItem>
}

public func generateIndexAndTargetPages(
  documentation: DocumentationContext, exporter: Exporter
) throws {
  var context = GenerationContext(
    documentation: documentation,
    stencilEnvironment: createDefaultStencilEnvironment(),
    htmlGenerator: CustomHTMLGenerator(),
    exporter: exporter,
    breadcrumb: []
  )

  // Add name of the root to the breadcrumb stack
  context.breadcrumb.append(
    BreadcrumbItem(
      name: "Documentation",
      relativePath: RelativePath.current
    ))

  // Generate all targets from the found roots
  try documentation.targetResolver.rootTargets.forEach {
    try generatePageForAnyTarget(&context, of: $0)
  }

  try generateModuleIndex(&context)
}

/// Generate the page belonging to this target
func generatePageForAnyTarget(_ context: inout GenerationContext, of targetId: AnyTargetID) throws {
  guard let resolvedTarget: ResolvedTarget = context.documentation.targetResolver[targetId]
  else {
    return
  }

  // Push breadcrumb item on stack
  context.breadcrumb.append(
    BreadcrumbItem(
      name: resolvedTarget.simpleName,
      relativePath: resolvedTarget.relativePath
    ))

  switch targetId {
  case .asset(let assetId):
    try generatePageForAnyAsset(&context, resolvedTarget, of: assetId)
    break
  case .decl(let declId):
    try generatePageForAnyDecl(&context, resolvedTarget, of: declId)
    break
  case .empty:
    break
  }

  // Generate children
  try resolvedTarget.children.forEach { try generatePageForAnyTarget(&context, of: $0) }

  // Pop breadcrumb item from stack
  let _ = context.breadcrumb.popLast()
}

/// Generate the page belonging to this asset
func generatePageForAnyAsset(
  _ context: inout GenerationContext, _ resolvedTarget: ResolvedTarget, of assetId: AnyAssetID
)
  throws
{
  // Get context to render with
  let stencilContext =
    switch assetId {
    case .folder(let folderId):
      prepareFolderPage(context, of: folderId)
    case .article(let articleId):
      prepareArticlePage(context, of: articleId)
    case .sourceFile(let sourceFileId):
      prepareSourceFilePage(context, of: sourceFileId)
    default:
      fatalError("unexpected asset")
    }

  // Render page and export content
  let content = try renderPage(&context, stencilContext, of: .asset(assetId))
  try context.exporter.html(content, at: resolvedTarget.relativePath)
}

func generatePageForAnyDecl(
  _ context: inout GenerationContext, _ resolvedTarget: ResolvedTarget, of declId: AnyDeclID
)
  throws
{
  // Get context to render with
  let stencilContext =
    switch declId.kind {
    case AssociatedTypeDecl.self:
      try prepareAssociatedTypePage(context, of: AssociatedTypeDecl.ID(declId)!)
    case AssociatedValueDecl.self:
      try prepareAssociatedValuePage(context, of: AssociatedValueDecl.ID(declId)!)
    case TypeAliasDecl.self:
      try prepareTypeAliasPage(context, of: TypeAliasDecl.ID(declId)!)
    case BindingDecl.self:
      try prepareBindingPage(context, of: BindingDecl.ID(declId)!)
    case OperatorDecl.self:
      try prepareOperatorPage(context, of: OperatorDecl.ID(declId)!)
    case FunctionDecl.self:
      try prepareFunctionPage(context, of: FunctionDecl.ID(declId)!)
    case InitializerDecl.self:
      try prepareInitializerPage(context, of: InitializerDecl.ID(declId)!)
    case MethodDecl.self:
      try prepareMethodPage(context, of: MethodDecl.ID(declId)!)
    case SubscriptDecl.self:
      try prepareSubscriptPage(context, of: SubscriptDecl.ID(declId)!)
    case TraitDecl.self:
      try prepareTraitPage(context, of: TraitDecl.ID(declId)!)
    case ProductTypeDecl.self:
      try prepareProductTypePage(context, of: ProductTypeDecl.ID(declId)!)
    default:
      fatalError("unexpected decl")
    }

  // Render page and export content
  let content = try renderPage(&context, stencilContext, of: .decl(declId))
  try context.exporter.html(content, at: resolvedTarget.relativePath)
}

public func generateModuleIndex(_ context: inout GenerationContext) throws {
  var env: [String: Any] = [:]
  env["pageType"] = "Folder"

  // Article Content
  env["articleContent"] = context.htmlGenerator.generate(
    doc: .document([
      .paragraph(Text("Bellow you can find a list of the modules that have been documented"))
    ]))

  // Map children to an array of [(name, relativePath)]
  env["contents"] = context.documentation.documentation.modules
    .map { context.documentation.targetResolver[.asset(.folder($0.rootFolder))]! }
    .map { ($0.simpleName, $0.relativePath) }

  let content = try renderPage(
    &context,
    StencilContext(templateName: "folder_layout.html", context: env),
    of: .empty
  )
  try context.exporter.html(content, at: RelativePath.current)
}