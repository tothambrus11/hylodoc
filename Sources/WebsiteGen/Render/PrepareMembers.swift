import FrontEnd
import MarkdownKit
import OrderedCollections

typealias nameAndContent = (name: String, summary: String)
typealias nameAndContentArray = [nameAndContent]

/// Get the members of a declaration
/// - Parameters:
///   - referringFrom:
///   - decls: array of declaration IDs
///   - context: context for page generation, containing documentation database, ast and typed program
/// - Returns: dictionary with keys as section names and values as arrays of tuples containing name (as an HTML string, including url) and summary of the member
func prepareMembersData(
  _ context: GenerationContext, referringFrom: AnyTargetID, decls: [AnyDeclID]
)
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
    if let (name, summary, key) = getMemberNameAndSummary(
      context,
      of: declId,
      referringFrom: referringFrom
    ) {
      buckets[key, default: []].append((name: name, summary: summary))
    }
  }
  return buckets.filter { !$0.value.isEmpty }.map { $0 }
}

/// Get the name and summary of a member
/// - Parameters:
///   - context: context for page generation, containing documentation database, ast and typed program
///   - of: member declaration to get name and summary of
/// - Returns: name, summary of the member, and key of the section it belongs to in prepareMembersData
func getMemberNameAndSummary(
  _ context: GenerationContext, of: AnyDeclID, referringFrom: AnyTargetID
)
  -> (
    name: String, summary: String, key: String
  )?
{
  var name: String
  var summary: Block?
  var key: String

  switch of.kind {
  // TODO Mark needs to implement this
  // case AssociatedTypeDecl.self:
  //     name = InlineSymbolDeclRenderer.renderAssociatedTypeDecl(AssociatedTypeDecl.ID(of)!)
  //     let docID = AssociatedTypeDecl.ID(of)!
  //     summary = context.documentation.documentation.symbols.associatedTypeDocs[docID]?.common.summary
  //     key = "Associated Types"
  // TODO Mark needs to implement this
  // case AssociatedValueDecl.self:
  //     name = InlineSymbolDeclRenderer.renderAssociatedValueDecl(AssociatedValueDecl.ID(of)!)
  //     let docID = AssociatedValueDecl.ID(of)!
  //     summary = context.documentation.documentation.symbols.associatedValueDocs[docID]?.common.summary
  //     key = "Associated Values"
  case TypeAliasDecl.self:
    let docID = TypeAliasDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderTypeAliasDecl(context.documentation, docID, referringFrom)
    summary = context.documentation.documentation.symbols.typeAliasDocs[docID]?.common.summary
    key = "Type Aliases"
  case BindingDecl.self:
    let docID = BindingDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderBindingDecl(context.documentation, docID, referringFrom)
    summary = context.documentation.documentation.symbols.bindingDocs[docID]?.common.summary
    key = "Bindings"
  // TODO Mark needs to implement this
  // case OperatorDecl.self:
  //     name = InlineSymbolDeclRenderer.renderOperatorDecl(OperatorDecl.ID(of)!)
  //     let docID = OperatorDecl.ID(of)!
  //     summary = context.documentation.documentation.symbols.operatorDocs[docID]?.documentation.summary
  //     key = "Operators"
  case FunctionDecl.self:
    let docID = FunctionDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderFunctionDecl(context.documentation, docID, referringFrom)
    summary =
      context.documentation.documentation.symbols.functionDocs[docID]?.documentation.common.common
      .summary
    key = "Functions"
  case MethodDecl.self:
    let docID = MethodDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderMethodDecl(context.documentation, docID, referringFrom)
    summary =
      context.documentation.documentation.symbols.methodDeclDocs[docID]?.documentation.common.common
      .summary
    key = "Methods"
  // not expected to be used, needed for exhaustive switch
  case MethodImpl.self:
    // fatalError("Method implementation should not be rendered")
    return nil
  case SubscriptDecl.self:
    let docID = SubscriptDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderSubscriptDecl(context.documentation, docID, referringFrom)
    summary =
      context.documentation.documentation.symbols.subscriptDeclDocs[docID]?.documentation.common
      .common
      .summary
    key = "Subscripts"
  // not expected to be used, needed for exhaustive switch
  case SubscriptImpl.self:
    // fatalError("Subscript implementation should not be rendered")
    return nil
  case InitializerDecl.self:
    let docID = InitializerDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderInitializerDecl(
      context.documentation, docID, referringFrom)
    summary =
      context.documentation.documentation.symbols.initializerDocs[docID]?.documentation.common
      .common
      .summary
    key = "Initializers"
  case TraitDecl.self:
    let docID = TraitDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderTraitDecl(context.documentation, docID, referringFrom)
    summary = context.documentation.documentation.symbols.traitDocs[docID]?.common.summary
    key = "Traits"
  case ProductTypeDecl.self:
    let docID = ProductTypeDecl.ID(of)!
    name = InlineSymbolDeclRenderer.renderProductTypeDecl(
      context.documentation, docID, referringFrom)
    summary = context.documentation.documentation.symbols.productTypeDocs[docID]?.common.summary
    key = "Product Types"
  default:
    return nil
  }

  if let summary = summary {
    return (name, context.htmlGenerator.generate(doc: summary), key)
  } else {
    return (name, "", key)
  }
}