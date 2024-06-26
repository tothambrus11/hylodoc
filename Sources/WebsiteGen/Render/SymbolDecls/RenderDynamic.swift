import Foundation
import FrontEnd

func renderDetailedTrait(
  _ ctx: DocumentationContext, _ n: TraitDecl.ID, _ inline: Bool
)
  -> String
{
  let trait = ctx.typedProgram.ast[n]
  let identifier = trait.identifier.value
  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  let result = wrapLink("\(wrapKeyword("trait")) \(identifier)", href: symbolUrl)

  return result
}

func renderDetailedTypeAlias(
  _ ctx: DocumentationContext, _ n: TypeAliasDecl.ID, _ inline: Bool
)
  -> String
{
  let typeAlias = ctx.typedProgram.ast[n]
  let identifier = typeAlias.identifier.value
  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  var result = wrapLink("\(wrapKeyword("typealias")) \(identifier)", href: symbolUrl)

  if let wrappedType = renderDetailedType(ctx, typeAlias.aliasedType) {
    result += " = \(wrappedType)"
  }

  return result
}

func renderDetailedProductType(
  _ ctx: DocumentationContext, _ n: ProductTypeDecl.ID,
  _ inline: Bool
)
  -> String
{
  let productType = ctx.typedProgram.ast[n]
  let identifier = productType.identifier.value
  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  var result = wrapLink("\(wrapKeyword("type")) \(identifier)", href: symbolUrl)
  let baseLength = productType.baseName.count + 8

  if !productType.conformances.isEmpty {
    result += " : "

    let nameExpr = productType.conformances[0]
    result += renderDetailedType(ctx, AnyExprID(nameExpr))!

    for i in (1..<productType.conformances.count) {
      result += ","
      result += inline ? " " : "\n\(wrapIndentation(baseLength))"

      let nameExpr = productType.conformances[i]
      result += renderDetailedType(ctx, AnyExprID(nameExpr))!
    }
  }

  return result
}

func renderDetailedBinding(
  _ ctx: DocumentationContext, _ n: BindingDecl.ID, _ inline: Bool
) -> String {
  let binding = ctx.typedProgram.ast[n]
  let bindingPattern = ctx.typedProgram.ast[binding.pattern]

  let subpattern = ctx.typedProgram.ast[NamePattern.ID(bindingPattern.subpattern)]!
  let variable = ctx.typedProgram.ast[subpattern.decl]

  let introducer = String(describing: bindingPattern.introducer.value)
  var result = ""

  if binding.isStatic {
    result += "\(wrapKeyword("static")) "
  }

  let identifier = variable.baseName
  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  result += "\(wrapKeyword(introducer)) \(identifier)"
  result = wrapLink(result, href: symbolUrl)

  if let typeWrapped = renderDetailedType(ctx, bindingPattern.annotation) {
    result += ": \(typeWrapped)"
  }

  return result
}

func renderDetailedInitializer(
  _ ctx: DocumentationContext, _ n: InitializerDecl.ID, _ inline: Bool
)
  -> String
{
  let initializer = ctx.typedProgram.ast[n]
  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  var result = wrapLink(wrapKeyword("init"), href: symbolUrl)
  result += "(\(renderDetailedParams(ctx, initializer.parameters, inline)))"

  return result
}

func renderDetailedFunction(
  _ ctx: DocumentationContext, _ n: FunctionDecl.ID, _ inline: Bool
)
  -> String
{
  let function = ctx.typedProgram.ast[n]
  let identifier = function.identifier!.value
  var result = ""

  if function.isStatic {
    result += "\(wrapKeyword("static")) "
  }

  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  result += "\(wrapKeyword("fun")) \(identifier)"
  result = wrapLink(result, href: symbolUrl)
  result += "(\(renderDetailedParams(ctx, function.parameters, inline)))"

  if let output = renderDetailedType(ctx, function.output) {
    result += " -> \(output)"
  }

  let effect =
    function.receiverEffect != nil ? String(describing: function.receiverEffect!.value) : "let"

  result += " { \(wrapKeyword(effect)) }"

  return result
}

func renderDetailedMethod(
  _ ctx: DocumentationContext, _ n: MethodDecl.ID, _ inline: Bool
)
  -> String
{
  let method = ctx.typedProgram.ast[n]
  let identifier = method.identifier.value
  var result = ""

  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))

  result += wrapLink("\(wrapKeyword("fun")) \(identifier)", href: symbolUrl)
  result += "(\(renderDetailedParams(ctx, method.parameters, inline)))"

  if let output = renderDetailedType(ctx, method.output) {
    result += " -> \(output)"
  }

  result += " { "

  for (i, impl) in method.impls.enumerated() {
    let implementation = ctx.typedProgram.ast[impl]
    let effect = String(describing: implementation.introducer.value)

    result += wrapKeyword(effect)
    result += i < method.impls.count - 1 ? ", " : " "
  }

  result += "}"

  return result
}

func renderDetailedSubscript(
  _ ctx: DocumentationContext, _ n: SubscriptDecl.ID, _ inline: Bool
)
  -> String
{
  let sub: SubscriptDecl = ctx.typedProgram.ast[n]
  var result = ""

  if sub.isStatic {
    result += "\(wrapKeyword("static")) "
  }

  result += wrapKeyword(String(describing: sub.introducer.value))

  if let identifier = sub.identifier {
    result += " \(identifier.value)"
  }

  let symbolUrl = ctx.targetResolver.url(to: .decl(AnyDeclID(n)))
  result = wrapLink(result, href: symbolUrl)

  if sub.introducer.value == SubscriptDecl.Introducer.subscript {
    result += "(\(renderDetailedParams(ctx, sub.parameters, inline)))"
  }

  if let output = renderDetailedType(ctx, sub.output) {
    result += ": \(output)"
  }

  result += " { "

  for (i, impl) in sub.impls.enumerated() {
    let implementation = ctx.typedProgram.ast[impl]
    let effect = String(describing: implementation.introducer.value)

    result += wrapKeyword(effect)
    result += i < sub.impls.count - 1 ? ", " : " "
  }

  result += "}"

  return result
}

func renderDetailedParams(
  _ ctx: DocumentationContext, _ ns: [ParameterDecl.ID], _ inline: Bool
)
  -> String
{
  var result = ""

  for (i, p) in ns.enumerated() {
    if !inline && ns.count > 1 {
      result += "\n\(wrapIndentation(3))"
    }

    result += renderDetailedParam(ctx, p)

    if i < ns.count - 1 {
      result += ","

      if inline && i < ns.count - 1 {
        result += " "
      }
    }
  }

  if !inline && ns.count > 1 {
    result += "\n"
  }

  return result
}

func renderDetailedParam(
  _ ctx: DocumentationContext, _ n: ParameterDecl.ID
) -> String {
  let parameter = ctx.typedProgram.ast[n]
  let label = getParamLabel(parameter)
  let name = parameter.baseName
  let type = getParamType(ctx.typedProgram, parameter)
  let convention = getParamConvention(ctx.typedProgram, parameter)

  var result = label
  if name != label {
    result += " \(wrapName(name))"
  }

  if let typeWrapped = renderDetailedType(ctx, type) {
    result += ":"

    if convention != AccessEffect.let {
      result += " \(wrapKeyword(String(describing: convention)))"
    }

    result += " \(typeWrapped)"
  }

  return result
}

func renderDetailedType(
  _ ctx: DocumentationContext, _ type: AnyExprID?
)
  -> String?
{
  if let name = getTypeName(ctx.typedProgram, type) {
    var url: URL? = nil

    if let decl = getExprDecl(ctx.typedProgram, type) {
      url = ctx.targetResolver.url(to: .decl(AnyDeclID(decl)))
    }

    return wrapType(name, href: url)
  }

  return nil
}
