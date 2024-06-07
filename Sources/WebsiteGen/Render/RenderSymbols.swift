import DocumentationDB
import Foundation
import FrontEnd
import MarkdownKit
import OrderedCollections

typealias nameAndContent = (name: String, summary: String)
typealias nameAndContentArray = [nameAndContent]

/// Get the members of a declaration
/// - Parameters:
///   - referringFrom:
///   - decls: array of declaration IDs
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
/// - Returns: dictionary with keys as section names and values as arrays of tuples containing name (as an HTML string, including url) and summary of the member
func prepareMembersData(referringFrom: AnyTargetID, decls: [AnyDeclID], ctx: GenerationContext)
  -> [OrderedDictionary<String, nameAndContentArray>.Element]
{
  // the order of the buckets is what determines the order of the sections in the page
  var buckets: OrderedDictionary<String, nameAndContentArray> = [
    "Associated Types": [],
    "Associated Values": [],
    "Type Aliases": [],
    "Bindings": [],
    "Operators": [],
    "Functions": [],
    "Methods": [],
    "Method Implementations": [],
    "Subscripts": [],
    "Subscript Implementations": [],
    "Initializers": [],
    "Traits": [],
    "Product Types": [],
  ]
  let _ = decls.map { declId in
    let (name, summary, key) = getMemberNameAndSummary(
      ctx: ctx, of: declId, referringFrom: referringFrom)
    buckets[key, default: []].append((name: name, summary: summary))
  }
  return buckets.filter { !$0.value.isEmpty }.map { $0 }
}

/// Get the name and summary of a member
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: member declaration to get name and summary of
/// - Returns: name, summary of the member, and key of the section it belongs to in prepareMembersData
func getMemberNameAndSummary(ctx: GenerationContext, of: AnyDeclID, referringFrom: AnyTargetID) -> (
  name: String, summary: String, key: String
) {
  var name: String
  var summary: Block?
  var key: String

  switch of.kind {
  // TODO Mark needs to implement this
  // case AssociatedTypeDecl.self:
  //     name = ctx.renderers.inline.renderAssociatedTypeDecl(AssociatedTypeDecl.ID(of)!)
  //     let docID = AssociatedTypeDecl.ID(of)!
  //     summary = ctx.documentation.symbols.associatedTypeDocs[docID]?.common.summary
  //     key = "Associated Types"
  // TODO Mark needs to implement this
  // case AssociatedValueDecl.self:
  //     name = ctx.renderers.inline.renderAssociatedValueDecl(AssociatedValueDecl.ID(of)!)
  //     let docID = AssociatedValueDecl.ID(of)!
  //     summary = ctx.documentation.symbols.associatedValueDocs[docID]?.common.summary
  //     key = "Associated Values"
  case TypeAliasDecl.self:
    name = ctx.renderers.inline.renderTypeAliasDecl(TypeAliasDecl.ID(of)!)
    let docID = TypeAliasDecl.ID(of)!
    summary = ctx.documentation.symbols.typeAliasDocs[docID]?.common.summary
    key = "Type Aliases"
  case BindingDecl.self:
    name = ctx.renderers.inline.renderBindingDecl(BindingDecl.ID(of)!)
    let docID = BindingDecl.ID(of)!
    summary = ctx.documentation.symbols.bindingDocs[docID]?.common.summary
    key = "Bindings"
  // TODO Mark needs to implement this
  // case OperatorDecl.self:
  //     name = ctx.renderers.inline.renderOperatorDecl(OperatorDecl.ID(of)!)
  //     let docID = OperatorDecl.ID(of)!
  //     summary = ctx.documentation.symbols.operatorDocs[docID]?.documentation.summary
  //     key = "Operators"
  case FunctionDecl.self:
    name = ctx.renderers.inline.renderFunctionDecl(FunctionDecl.ID(of)!)
    let docID = FunctionDecl.ID(of)!
    summary = ctx.documentation.symbols.functionDocs[docID]?.documentation.common.summary
    key = "Functions"
  case MethodDecl.self:
    name = ctx.renderers.inline.renderMethodDecl(MethodDecl.ID(of)!)
    let docID = MethodDecl.ID(of)!
    summary = ctx.documentation.symbols.methodDeclDocs[docID]?.documentation.common.summary
    key = "Methods"
  // not expected to be used, needed for exhaustive switch
  case MethodImpl.self:
    fatalError("Method implementation should not be rendered")
  case SubscriptDecl.self:
    name = ctx.renderers.inline.renderSubscriptDecl(SubscriptDecl.ID(of)!)
    let docID = SubscriptDecl.ID(of)!
    summary =
      ctx.documentation.symbols.subscriptDeclDocs[docID]?.documentation.generalDescription.summary
    key = "Subscripts"
  // not expected to be used, needed for exhaustive switch
  case SubscriptImpl.self:
    fatalError("Subscript implementation should not be rendered")
  case InitializerDecl.self:
    name = ctx.renderers.inline.renderInitializerDecl(InitializerDecl.ID(of)!)
    let docID = InitializerDecl.ID(of)!
    summary = ctx.documentation.symbols.initializerDocs[docID]?.common.summary
    key = "Initializers"
  case TraitDecl.self:
    name = ctx.renderers.inline.renderTraitDecl(TraitDecl.ID(of)!)
    let docID = TraitDecl.ID(of)!
    summary = ctx.documentation.symbols.traitDocs[docID]?.common.summary
    key = "Traits"
  case ProductTypeDecl.self:
    name = ctx.renderers.inline.renderProductTypeDecl(
      ctx, ProductTypeDecl.ID(of)!, referringFrom)
    let docID = ProductTypeDecl.ID(of)!
    summary = ctx.documentation.symbols.productTypeDocs[docID]?.generalDescription.summary
    key = "Product Types"
  default:
    name = ""
    key = ""
  }

  if let summary = summary {
    return (name, HtmlGenerator.standard.generate(doc: summary), key)
  } else {
    return (name, "", key)
  }
}

/// Render the associated-type page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: associated-type declaration to render page of
///   - with: parsed associated-type documentation string
///
/// - Returns: contents of the rendered page
public func renderAssociatedTypePage(
  ctx: GenerationContext, of: AssociatedTypeDecl.ID, with doc: AssociatedTypeDocumentation?
) throws -> String {
  let decl: AssociatedTypeDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  // TODO address the case where the function has no name
  args["name"] = decl.identifier.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = decl.identifier.value
  args["pageType"] = "Associated Type"
  args["declarationPreview"] = decl.site.text  // todo

  if let doc = doc {
    // Summary
    if let summary = doc.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["seeAlso"] = doc.common.seeAlso.map { HtmlGenerator.standard.generate(doc: $0) }
  }

  return try ctx.stencil.renderTemplate(name: "associated_type_layout.html", context: args)
}

/// Render the associated-value page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: associated-value declaration to render page of
///   - with: parsed associated-value documentation string
///
/// - Returns: contents of the rendered page
public func renderAssociatedValuePage(
  ctx: GenerationContext, of: AssociatedValueDecl.ID, with doc: AssociatedValueDocumentation?
) throws -> String {
  let decl: AssociatedValueDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  args["name"] = decl.identifier.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = decl.identifier.value
  args["pageType"] = "Associated Value"
  args["declarationPreview"] = decl.site.text  // todo

  if let doc = doc {
    // Summary
    if let summary = doc.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["seeAlso"] = doc.common.seeAlso.map { HtmlGenerator.standard.generate(doc: $0) }
  }

  return try ctx.stencil.renderTemplate(name: "associated_value_layout.html", context: args)
}

/// Render the type-alias page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: type-alias declaration to render page of
///   - with: parsed type-alias documentation string
///
/// - Returns: contents of the rendered page
public func renderTypeAliasPage(
  ctx: GenerationContext, of: TypeAliasDecl.ID, with doc: TypeAliasDocumentation?
) throws -> String {
  let decl: TypeAliasDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]
  args["name"] = decl.identifier.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderTypeAliasDecl(of)
  args["pageType"] = "Type Alias"
  args["declarationPreview"] = ctx.renderers.block.renderTypeAliasDecl(of)

  if let doc = doc {
    // Summary
    if let summary = doc.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }
  }
  return try ctx.stencil.renderTemplate(name: "type_alias_layout.html", context: args)
}

/// Render the binding page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: binding declaration to render page of
///   - with: parsed binding documentation string
///
/// - Returns: contents of the rendered page
public func renderBindingPage(
  ctx: GenerationContext, of: BindingDecl.ID, with doc: BindingDocumentation?
) throws -> String {
  let decl: BindingDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  args["name"] = "binding"
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderBindingDecl(of)
  args["pageType"] = decl.isStatic ? "Static Binding" : "Binding"
  args["declarationPreview"] = ctx.renderers.block.renderBindingDecl(of)

  if let doc = doc {
    if let summary = doc.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }
    if let block = doc.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["invariants"] = doc.invariants.map { HtmlGenerator.standard.generate(doc: $0.description) }

    args["seeAlso"] = doc.common.seeAlso.map { HtmlGenerator.standard.generate(doc: $0) }
  }
  return try ctx.stencil.renderTemplate(name: "binding_layout.html", context: args)
}

/// Render the operator page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: operator declaration to render page of
///   - with: parsed operator documentation string
///
/// - Returns: contents of the rendered page
public func renderOperatorPage(
  ctx: GenerationContext, of: OperatorDecl.ID, with doc: OperatorDocumentation?
) throws -> String {
  let decl: OperatorDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  // TODO address the case where the function has no name
  args["name"] = decl.name.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = decl.site.text  // todo
  args["pageType"] = "Operator Introducer"
  args["declarationPreview"] = decl.site.text  // todo

  if let doc = doc {
    // Summary
    if let summary = doc.documentation.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.documentation.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }
    args["seeAlso"] = doc.documentation.seeAlso.map { HtmlGenerator.standard.generate(doc: $0) }
  }

  return try ctx.stencil.renderTemplate(name: "operator_layout.html", context: args)
}

/// Render the function page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: function declaration to render page of
///   - with: parsed function documentation string
///
/// - Returns: contents of the rendered page
public func renderFunctionPage(
  ctx: GenerationContext, of: FunctionDecl.ID, with doc: FunctionDocumentation?
) throws -> String {
  let decl: FunctionDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  args["name"] = decl.site.text
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderFunctionDecl(of)
  args["pageType"] = "Function"
  args["declarationPreview"] = ctx.renderers.block.renderFunctionDecl(of)

  if let doc = doc {
    // Summary
    if let summary = doc.documentation.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.documentation.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["preconditions"] = doc.documentation.preconditions.map {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["postconditions"] = doc.documentation.postconditions.map {
      HtmlGenerator.standard.generate(doc: $0.description)
    }

    if let returns = doc.documentation.returns {
      switch returns {
      case .always(let block):
        args["returns"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["returns"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }
    if let throwsInfo = doc.documentation.throwsInfo {
      switch throwsInfo {
      case .generally(let block):
        args["throwsInfo"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["throwsInfo"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }

    args["parameters"] = doc.documentation.parameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["genericParameters"] = doc.documentation.genericParameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }

    args["seeAlso"] = doc.documentation.common.seeAlso.map {
      HtmlGenerator.standard.generate(doc: $0)
    }
  }

  return try ctx.stencil.renderTemplate(name: "function_layout.html", context: args)
}

/// Render the method page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: method declaration to render page of
///   - with: parsed method documentation string
///
/// - Returns: contents of the rendered page
public func renderMethodPage(
  ctx: GenerationContext, of: MethodDecl.ID, with doc: MethodDeclDocumentation?
) throws -> String {
  let decl: MethodDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  // TODO address the case where the function has no name
  args["name"] = decl.identifier.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderMethodDecl(of)
  args["pageType"] = "Method"
  args["declarationPreview"] = ctx.renderers.block.renderMethodDecl(of)

  if let doc = doc {
    // Summary
    if let summary = doc.documentation.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.documentation.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["preconditions"] = doc.documentation.preconditions.map {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["postconditions"] = doc.documentation.postconditions.map {
      HtmlGenerator.standard.generate(doc: $0.description)
    }

    if let returns = doc.documentation.returns {
      switch returns {
      case .always(let block):
        args["returns"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["returns"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }
    if let throwsInfo = doc.documentation.throwsInfo {
      switch throwsInfo {
      case .generally(let block):
        args["throwsInfo"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["throwsInfo"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }

    args["parameters"] = doc.documentation.parameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["genericParameters"] = doc.documentation.genericParameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }

    // args["members"] = decl.impls.map { member in getMembers(ctx: ctx, of: AnyDeclID(member)) }
    args["members"] = prepareMembersData(
      referringFrom: .symbol(AnyDeclID(of)), decls: decl.impls.map { member in AnyDeclID(member) },
      ctx: ctx)

    args["seeAlso"] = doc.documentation.common.seeAlso.map {
      HtmlGenerator.standard.generate(doc: $0)
    }
  }
  return try ctx.stencil.renderTemplate(name: "method_layout.html", context: args)
}

/// Render the method-implementation page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: method-implementation declaration to render page of
///   - with: parsed method-implementation documentation string
///
/// - Returns: contents of the rendered page
public func renderMethodImplementationPage(
  ctx: GenerationContext, of: MethodImpl.ID, with doc: MethodImplDocumentation?
) throws -> String {
  return ""
}

/// Render the subscript page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: subscript declaration to render page of
///   - with: parsed subscript documentation string
///
/// - Returns: contents of the rendered page
public func renderSubscriptPage(
  ctx: GenerationContext, of: SubscriptDecl.ID, with doc: SubscriptDeclDocumentation?
) throws -> String {
  let decl: SubscriptDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  args["name"] = decl.site.text

  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderSubscriptDecl(of)
  args["pageType"] = "Subscript"  // todo determine whether it's a subscript or property declaration, if it's the latter, we should display "Property"
  args["declarationPreview"] = ctx.renderers.block.renderSubscriptDecl(of)

  if let doc = doc {
    // Summary
    if let summary = doc.documentation.generalDescription.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.documentation.generalDescription.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    if let yields = doc.documentation.yields {
      switch yields {
      case .always(let block):
        args["yields"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["yields"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }
    if let throwsInfo = doc.documentation.throwsInfo {
      switch throwsInfo {
      case .generally(let block):
        args["throwsInfo"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["throwsInfo"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }

    args["parameters"] = doc.documentation.parameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["genericParameters"] = doc.documentation.genericParameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["seeAlso"] = doc.documentation.generalDescription.seeAlso.map {
      HtmlGenerator.standard.generate(doc: $0)
    }
  }
  // args["members"] = decl.impls.map { member in getMembers(ctx: ctx, of: AnyDeclID(member)) }
  args["members"] = prepareMembersData(
    referringFrom: .symbol(AnyDeclID(of)), decls: decl.impls.map { member in AnyDeclID(member) },
    ctx: ctx)

  return try ctx.stencil.renderTemplate(name: "subscript_layout.html", context: args)
}

/// Render the subscript-implementation page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: subscript-implementation declaration to render page of
///   - with: parsed subscript-implementation documentation string
///
/// - Returns: contents of the rendered page
public func renderSubscriptImplementationPage(
  ctx: GenerationContext, of: SubscriptImpl.ID, with doc: SubscriptImplDocumentation?
) throws -> String {
  return ""
}

/// Render the initializer page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: initializer declaration to render page of
///   - with: parsed initializer documentation string
///
/// - Returns: contents of the rendered page
public func renderInitializerPage(
  ctx: GenerationContext, of: InitializerDecl.ID, with doc: InitializerDocumentation?
) throws -> String {
  let decl: InitializerDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  // TODO address the case where the function has no name
  args["name"] = decl.site.text
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderInitializerDecl(of)
  args["pageType"] = "Initializer"
  args["declarationPreview"] = ctx.renderers.block.renderInitializerDecl(of)

  if let doc = doc {
    // Summary
    if let summary = doc.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    // Details
    if let block = doc.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["preconditions"] = doc.preconditions.map {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["postconditions"] = doc.postconditions.map {
      HtmlGenerator.standard.generate(doc: $0.description)
    }

    args["parameters"] = doc.parameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }
    args["genericParameters"] = doc.genericParameters.mapValues {
      HtmlGenerator.standard.generate(doc: $0.description)
    }

    if let throwsInfo = doc.throwsInfo {
      switch throwsInfo {
      case .generally(let block):
        args["throwsInfo"] = [HtmlGenerator.standard.generate(doc: block)]
      case .cases(let blocks):
        args["throwsInfo"] = blocks.map { HtmlGenerator.standard.generate(doc: $0) }
      }
    }

    args["seeAlso"] = doc.common.seeAlso.map { HtmlGenerator.standard.generate(doc: $0) }
  }
  return try ctx.stencil.renderTemplate(name: "initializer_layout.html", context: args)
}

/// Render the trait page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: trait declaration to render page of
///   - with: parsed trait documentation string
///
/// - Returns: contents of the rendered page
public func renderTraitPage(ctx: GenerationContext, of: TraitDecl.ID, with doc: TraitDocumentation?)
  throws -> String
{
  let decl: TraitDecl = ctx.typedProgram.ast[of]!

  var args: [String: Any] = [:]

  args["name"] = decl.identifier.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: .symbol(AnyDeclID(of)))

  args["pageTitle"] = ctx.renderers.simple.renderTraitDecl(of)
  args["pageType"] = "Trait"
  args["declarationPreview"] = ctx.renderers.block.renderTraitDecl(of)

  if let doc = doc {
    if let summary = doc.common.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    if let block = doc.common.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }

    args["invariants"] = doc.invariants.map { HtmlGenerator.standard.generate(doc: $0.description) }

    args["seeAlso"] = doc.common.seeAlso.map { HtmlGenerator.standard.generate(doc: $0) }
  }

  args["members"] = prepareMembersData(
    referringFrom: .symbol(AnyDeclID(of)), decls: decl.members, ctx: ctx)

  return try ctx.stencil.renderTemplate(name: "trait_layout.html", context: args)
}

/// Render the product-type page
///
/// - Parameters:
///   - ctx: context for page generation, containing documentation database, ast and stencil templating
///   - of: product-type declaration to render page of
///   - with: parsed product-type documentation string
///
/// - Returns: contents of the rendered page
public func renderProductTypePage(
  ctx: GenerationContext, of: ProductTypeDecl.ID, with doc: ProductTypeDocumentation?
) throws -> String {
  let decl: ProductTypeDecl = ctx.typedProgram.ast[of]!
  let target = AnyTargetID.symbol(AnyDeclID(of))

  var args: [String: Any] = [:]

  args["name"] = decl.identifier.value
  args["pathToRoot"] = ctx.urlResolver.pathToRoot(target: target)

  args["pageTitle"] = ctx.renderers.simple.renderProductTypeDecl(ctx, of, target)
  args["pageType"] = "Product Type"
  args["declarationPreview"] = ctx.renderers.block.renderProductTypeDecl(ctx, of, target)

  if let doc = doc {
    if let summary = doc.generalDescription.summary {
      args["summary"] = HtmlGenerator.standard.generate(doc: summary)
    }

    if let block = doc.generalDescription.description {
      args["details"] = HtmlGenerator.standard.generate(doc: block)
    }
    args["invariants"] = doc.invariants.map { HtmlGenerator.standard.generate(doc: $0.description) }
    args["seeAlso"] = doc.generalDescription.seeAlso.map {
      HtmlGenerator.standard.generate(doc: $0)
    }
  }

  args["members"] = prepareMembersData(
    referringFrom: .symbol(AnyDeclID(of)), decls: decl.members, ctx: ctx)

  return try ctx.stencil.renderTemplate(name: "product_type_layout.html", context: args)
}
