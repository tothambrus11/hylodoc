import Foundation
import FrontEnd

public protocol SymbolStaticDeclRenderer {
  static func renderTraitDecl(
    _ typedProgram: TypedProgram, _ n: TraitDecl.ID
  ) -> String
  static func renderTypeAliasDecl(
    _ typedProgram: TypedProgram, _ n: TypeAliasDecl.ID
  ) -> String
  static func renderProductTypeDecl(
    _ typedProgram: TypedProgram, _ n: ProductTypeDecl.ID
  ) -> String
  static func renderBindingDecl(
    _ typedProgram: TypedProgram, _ n: BindingDecl.ID
  ) -> String
  static func renderInitializerDecl(
    _ typedProgram: TypedProgram, _ n: InitializerDecl.ID
  ) -> String
  static func renderFunctionDecl(
    _ typedProgram: TypedProgram, _ n: FunctionDecl.ID
  ) -> String
  static func renderMethodDecl(
    _ typedProgram: TypedProgram, _ n: MethodDecl.ID
  ) -> String
  static func renderSubscriptDecl(
    _ typedProgram: TypedProgram, _ n: SubscriptDecl.ID
  ) -> String
}

public struct SimpleSymbolDeclRenderer: SymbolStaticDeclRenderer {

  public static func renderTraitDecl(
    _ typedProgram: TypedProgram, _ n: TraitDecl.ID
  ) -> String {
    return renderSimpleTrait(typedProgram, n, true)
  }

  public static func renderTypeAliasDecl(
    _ typedProgram: TypedProgram, _ n: TypeAliasDecl.ID
  ) -> String {
    return renderSimpleTypeAlias(typedProgram, n, true)
  }

  public static func renderProductTypeDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.ProductTypeDecl.ID
  ) -> String {
    return renderSimpleProductType(typedProgram, n, true)
  }

  public static func renderBindingDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.BindingDecl.ID
  ) -> String {
    return renderSimpleBinding(typedProgram, n, true)
  }

  public static func renderInitializerDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.InitializerDecl.ID
  ) -> String {
    return renderSimpleInitializer(typedProgram, n, true)
  }

  public static func renderFunctionDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.FunctionDecl.ID
  ) -> String {
    return renderSimpleFunction(typedProgram, n, true)
  }

  public static func renderMethodDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.MethodDecl.ID
  ) -> String {
    return renderSimpleMethod(typedProgram, n, true)
  }

  public static func renderSubscriptDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.SubscriptDecl.ID
  ) -> String {
    return renderSimpleSubscript(typedProgram, n, true)
  }
}

public struct NavigationSymbolDecRenderer: SymbolStaticDeclRenderer {

  public static func renderTraitDecl(
    _ typedProgram: TypedProgram, _ n: TraitDecl.ID
  ) -> String {
    return renderSimpleTrait(typedProgram, n, false)
  }

  public static func renderTypeAliasDecl(
    _ typedProgram: TypedProgram, _ n: TypeAliasDecl.ID
  ) -> String {
    return renderSimpleTypeAlias(typedProgram, n, false)
  }

  public static func renderProductTypeDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.ProductTypeDecl.ID
  ) -> String {
    return renderSimpleProductType(typedProgram, n, false)
  }

  public static func renderBindingDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.BindingDecl.ID
  ) -> String {
    return renderSimpleBinding(typedProgram, n, false)
  }

  public static func renderInitializerDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.InitializerDecl.ID
  ) -> String {
    return renderSimpleInitializer(typedProgram, n, false)
  }

  public static func renderFunctionDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.FunctionDecl.ID
  ) -> String {
    return renderSimpleFunction(typedProgram, n, false)
  }

  public static func renderMethodDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.MethodDecl.ID
  ) -> String {
    return renderSimpleMethod(typedProgram, n, false)
  }

  public static func renderSubscriptDecl(
    _ typedProgram: TypedProgram, _ n: FrontEnd.SubscriptDecl.ID
  ) -> String {
    return renderSimpleSubscript(typedProgram, n, false)
  }
}
