target :lib do
  signature "sig"

  check "lib"

  configure_code_diagnostics do |hash|
    hash[Steep::Diagnostic::Ruby::FallbackAny] = nil
    hash[Steep::Diagnostic::Ruby::UnknownConstant] = :error
    hash[Steep::Diagnostic::Ruby::MethodDefinitionMissing] = nil
    hash[Steep::Diagnostic::Ruby::UnsupportedSyntax] = :hint
  end
end
