defmodule Constructive.Error do
  @moduledoc """
  Error raised by assertive `Constructive`-generated functions.

  `Constructive` functions have a so-called `assertive!` variant,
  suffixed with an exclamation mark (`!`), to indicate that they
  throw errors rather than wrapping results in an `:ok`/`:error` two-tuple.

  This is the error those `Constructive`-generated functions throw when
  using `assertive!` variants.

  This module also exposes a `format/2` function for prettifying non-assertive
  `Constructive` error tuple responses into human-readable text.

  ## Other Errors

  Note that it is quite possible for `Constructive`-generated functions
  to raise other errors when used impropertly, especially:

  - `UndefinedFunctionError`:
    for the wrong number of arguments to a constructor function
  - `FunctionClauseError`:
    when passing field names that do not exist on the struct to field validation functions
  - `Constructive.Handler.Error`:
    when a struct implementor has returned an unexpected value from a handler
  """

  @typedoc "A struct-implementor provided annotation describing a problem"
  @type detail :: any()

  @type problem_type :: :field | :constructing | :parsing | :validating | :deconstructing
  @problem_types [:field, :constructing, :parsing, :validating, :deconstructing]

  @type field_problem ::
          {:field, invalid: term}
          | {:field, invalid: term, valid: [Constructive.field()]}
          | {:field, invalid: term, valid: [Constructive.field()], value: term}
          | {:field, missing: Constructive.field(), enforced: [Constructive.field()]}
  @type construction_problem ::
          {:constructing, input: Constructive.input()}
          | {:constructing, detail: detail, input: Constructive.input()}
          | {:constructing, details: [detail], input: Constructive.input()}
  @type parsing_problem ::
          {:parsing, field: Constructive.field(), input: Constructive.input(), struct: module}
          | {:parsing,
             field: Constructive.field(),
             detail: detail,
             input: Constructive.input(),
             struct: module}
          | {:parsing,
             field: Constructive.field(),
             details: [detail],
             input: Constructive.input(),
             struct: module}
  @type validation_problem ::
          {:validating, struct: struct}
          | {:validating, detail: detail, struct: struct}
          | {:validating, details: [detail], struct: struct}
          | {:validating, problems: [problem()], struct: struct}
          | {:validating,
             field: Constructive.field(), value: Constructive.value(), struct: module}
          | {:validating,
             field: Constructive.field(),
             detail: detail,
             value: Constructive.value(),
             struct: module}
          | {:validating,
             field: Constructive.field(),
             details: [detail],
             value: Constructive.value(),
             struct: module}
  @type deconstruction_problem ::
          {:deconstructing, struct: struct}
          | {:deconstructing, detail: detail, struct: struct}
          | {:deconstructing, details: [detail], struct: struct}

  @type problem ::
          field_problem()
          | construction_problem()
          | parsing_problem()
          | validation_problem()
          | deconstruction_problem()

  defexception [:problems, :context]

  @type t :: %__MODULE__{
          problems: [problem()],
          context: mfa()
        }

  @spec message(t()) :: binary
  @doc """
  Produces a human-readable message from the given `error`.
  """
  def message(%__MODULE__{} = error) do
    "error in #{format_mfa(error.context)}:\n#{format_problems(error.problems, 1)}"
  end

  @doc """
  Produces a human-readable message from common `Constructive` error responses.

  You can provide it:
    - an `{:error, [problem()]}` result tuple
    - a list of, or single, `t:problem/1`
  """
  def format(problems, indent \\ 0)

  def format({:error, problems}, indent) when indent >= 0 do
    "error: " <> format(problems, indent)
  end

  def format(problems, indent) when is_list(problems) and indent >= 0 do
    format_problems(problems, indent)
  end

  def format(problem, indent) when indent >= 0 do
    format_problem(problem, indent)
  end

  @indent "    "

  defp indentation(amount) when amount >= 0 do
    String.duplicate(@indent, amount)
  end

  defp indent_multiline(string, amount) when is_binary(string) and amount > 0 do
    indentation = indentation(amount)
    [indentation, String.replace(string, "\n", &[&1, indentation])] |> IO.iodata_to_binary()
  end

  defp format_mfa({module, function, arity}) do
    "`#{inspect(module)}.#{function}/#{arity}`"
  end

  defp format_problems(problems, indent) do
    problems |> Enum.map(&format_problem(&1, indent)) |> Enum.join("\n")
  end

  defp format_problem({type, info}, indent) when type in @problem_types do
    "#{format_problem(type, info, indent)}"
  end

  defp format_problem({type, info, details}, indent)
       when type in @problem_types and is_list(details) do
    "#{format_problem(type, info, indent)}: #{format_details(details, indent + 1)}"
  end

  defp format_problem({type, info, detail}, indent)
       when type in @problem_types do
    "#{format_problem(type, info, indent)}: #{format_detail(detail)}"
  end

  ####
  # Core building problems
  ##

  defp format_problem(:field, [invalid: other], indent) do
    "#{indentation(indent)}expected keyword pairs of `{:key, value}`, got non-keyword-pair `#{inspect(other)}`"
  end

  defp format_problem(:field, [missing: key, enforced: enforced_keys], indent)
       when is_atom(key) do
    "#{indentation(indent)}key `#{Macro.inspect_atom(:literal, key)}` must be given when building struct, keys `#{inspect(enforced_keys)}` are enforced"
  end

  defp format_problem(:field, [invalid: key, valid: valid_fields], indent)
       when is_atom(key) do
    "#{indentation(indent)}key `#{Macro.inspect_atom(:literal, key)}` not in valid fields: `#{inspect(valid_fields)}`"
  end

  defp format_problem(:field, [invalid: key, valid: valid_fields, value: value], indent)
       when is_atom(key) do
    "#{indentation(indent)}key `#{Macro.inspect_atom(:literal, key)}` in key/value pair `#{Macro.inspect_atom(:key, key)} #{value}` not in valid fields: `#{inspect(valid_fields)}`"
  end

  ####
  # Construction problems
  ##

  defp format_problem(:constructing, input, indent) do
    "#{indentation(indent)}constructing struct from input `#{inspect(input)}` failed"
  end

  ####
  # Field parsing problems
  ##

  defp format_problem(:parsing, [field: field, input: input, struct: struct_module], indent)
       when is_atom(field) do
    "#{indentation(indent)}parsing `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}` failed, given input: `#{inspect(input)}`"
  end

  defp format_problem(
         :parsing,
         [field: field, detail: detail, input: input, struct: struct_module],
         indent
       )
       when is_atom(field) do
    "#{indentation(indent)}parsing `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}` failed: #{format_detail(detail)}, given input: `#{inspect(input)}`"
  end

  defp format_problem(
         :parsing,
         [field: field, details: details, input: input, struct: struct_module],
         indent
       )
       when is_atom(field) do
    "#{indentation(indent)}parsing `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}` failed:\n#{format_details(details, indent + 1)}\n#{indentation(indent)}given input: `#{inspect(input)}`"
  end

  ####
  # Struct validation problems
  ##

  defp format_problem(:validating, [struct: struct], indent)
       when is_struct(struct) do
    "#{indentation(indent)}validation of struct failed, given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  defp format_problem(:validating, [detail: detail, struct: struct], indent)
       when is_struct(struct) do
    "#{indentation(indent)}validation of struct failed: #{format_detail(detail)}, given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  defp format_problem(:validating, [details: details, struct: struct], indent)
       when is_struct(struct) do
    "#{indentation(indent)}validation of struct failed:\n#{format_details(details, indent + 1)}\n#{indentation(indent)}given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  ####
  # Struct validation problems
  ##

  defp format_problem(:validating, [struct: struct], indent)
       when is_struct(struct) do
    "#{indentation(indent)}validation of struct failed, given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  defp format_problem(:validating, [detail: detail, struct: struct], indent)
       when is_struct(struct) do
    "#{indentation(indent)}validation of struct failed: #{format_detail(detail)}, given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  defp format_problem(:validating, [details: details, struct: struct], indent)
       when is_struct(struct) do
    "#{indentation(indent)}validation of struct failed:\n#{format_details(details, indent + 1)}\n#{indentation(indent)}given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  ####
  # Default validation by-field problems
  ##

  defp format_problem(:validating, [fields: problems, struct: struct], indent)
       when is_struct(struct) and is_list(problems) do
    child_problems =
      problems |> Enum.map(&format_problem(&1, indent + 1)) |> Enum.join("\n")

    "#{indentation(indent)}validation of struct fields failed:\n#{child_problems}\n#{indentation(indent)}given:\n#{indent_multiline(inspect(struct, pretty: true, width: 80), indent + 1)}"
  end

  ####
  # Struct field validation problems
  ##

  defp format_problem(:validating, [field: field, value: value, struct: struct_module], indent)
       when is_atom(field) do
    "#{indentation(indent)}validation of struct `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}` failed, given:\n#{indent_multiline(inspect(value, pretty: true, width: 80), indent + 1)}"
  end

  defp format_problem(
         :validating,
         [field: field, detail: detail, value: value, struct: struct_module],
         indent
       )
       when is_atom(field) do
    "#{indentation(indent)}validation of struct `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}` failed: #{format_detail(detail)}, given:\n#{indent_multiline(inspect(value, pretty: true, width: 80), indent + 1)}"
  end

  defp format_problem(
         :validating,
         [field: field, details: details, value: value, struct: struct_module],
         indent
       )
       when is_atom(field) do
    "#{indentation(indent)}validation of struct `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}` failed:\n#{format_details(details, indent + 1)}\n#{indentation(indent)}given:\n#{indent_multiline(inspect(value, pretty: true, width: 80), indent + 1)}"
  end

  ####
  # Deconstruction problems
  ##

  defp format_problem(:deconstructing, struct, indent) when is_struct(struct) do
    "#{indentation(indent)}deconstruction of struct #{inspect(struct)} failed"
  end

  defp format_detail(detail) do
    to_string(detail)
  end

  defp format_details([], _indent) do
    ""
  end

  defp format_details([detail | []], _indent) do
    format_detail(detail)
  end

  defp format_details(details, indent) when is_list(details) do
    details |> Enum.map(&format_detail/1) |> Enum.join("\n#{indentation(indent)}")
  end
end

defmodule Constructive.Handler.Error do
  @moduledoc """
  Error raised when a `Constructive` handler is incorrectly implemented.

  ## Resolution

  If you are the struct implementor, the error message contains hints on
  how to correct your handler. Consult corresponding documentation for
  the handler in question, and file a bug report with `Constructive`
  for clearer documentation if it is not helpful in resolving the issue.

  If you are not the struct implementor, you should file a bug report
  with the struct implementor including the full error message and stack trace
  so they can correct.

  ## Causes

  `Constructive.DSL` handlers are expected to return certain types and shapes
  to work as expected with the code `Constructive` generates. When that contract
  is broken, `Constructive` raises this exception.

  The most common cause is that a handler did not return an expected
  value, so `Constructive` does not know how to proceed. The error message
  directs to documentation for the offending handler so that the return can
  be corrected.

  The other cause is that the handler did not provide clauses with
  exhaustive matching, and a scenario snuck through its clauses: since
  `Constructive` generates the `case` blocks handler clauses are used in,
  it raises this exception type rather than letting a less-helpful
  `CaseClauseError` be emitted, so that these issues are more
  identifiable.

  All `Constructive`-generated code when possible uses `quote` blocks
  with `location: :keep` and hand-written Elixir (instead of hand-built AST)
  so that error stack traces should point you to the Elixir code your
  handler results are being used in, to aid in debugging.
  """

  defexception [:problem, :context]

  @type problem :: tuple
  @type t :: %__MODULE__{
          problem: problem,
          context: mfa
        }

  @spec message(t()) :: binary
  @doc """
  Produces a human-readable message from the given `error`.
  """
  def message(%__MODULE__{} = error) do
    "error in #{format_mfa(error.context)}: #{format_problem(error.context, error.problem, 1)}"
  end

  @indent "    "

  defp indentation(amount) when amount >= 0 do
    String.duplicate(@indent, amount)
  end

  defp indent_multiline(string, amount) when is_binary(string) and amount > 0 do
    indentation = indentation(amount)
    [indentation, String.replace(string, "\n", &[&1, indentation])] |> IO.iodata_to_binary()
  end

  defp format_mfa({module, function, arity}) do
    "`#{inspect(module)}.#{function}/#{arity}`"
  end

  ####
  # Construction problems
  ##

  defp format_problem(
         {module, _function, _arity},
         {:constructing, :unexpected_return, input: input, parsed: parsed},
         indent
       ) do
    "unexpected return value constructing #{inspect(module)} from input `#{inspect(input)}`, parser returned: #{inspect(parsed)}" <>
      "\n#{indentation(indent)}investigate the implementation given to `Constructive.defstruct/2`:" <>
      "\n#{indent_multiline(Macro.to_string({:construct, [], [[do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.construct/2`."
  end

  defp format_problem(
         {module, _function, _arity},
         {:constructing, :unhandled_case, input: input},
         indent
       ) do
    "unhandled case constructing #{inspect(module)} from input `#{inspect(input)}`" <>
      "\n#{indentation(indent)}add a catch-all clause that returns `:error` to the implementation of" <>
      "\n#{indent_multiline(Macro.to_string({:construct, [], [[do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.construct/2`."
  end

  ####
  # Field parsing problems
  ##

  defp format_problem(
         {module, _function, _arity},
         {:parsing, :unhandled_case, struct: struct, field: field},
         indent
       ) do
    "unhandled case parsing #{inspect(module)} struct `#{inspect(struct)}` field `#{Macro.inspect_atom(:literal, field)}`" <>
      "\n#{indentation(indent)}add a catch-all clause that returns `:error` to the implementation of" <>
      "\n#{indent_multiline(Macro.to_string({:parse, [], [field, [do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.parse/2`."
  end

  defp format_problem(
         {_module, _function, _arity},
         {:parsing, :unexpected_return, struct: struct_module, field: field, parsed: parsed},
         indent
       ) do
    "unexpected return value parsing struct `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}`, parsing returned: `#{inspect(parsed)}`" <>
      "\n#{indentation(indent)}investigate the implementation given to `Constructive.defstruct/2`:" <>
      "\n#{indent_multiline(Macro.to_string({:parse, [], [field, [do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.parse/2`."
  end

  ####
  # Validation problems
  ##

  defp format_problem(
         {module, _function, _arity},
         {:validating, :unhandled_case, struct: struct},
         indent
       ) do
    "unhandled case validating #{inspect(module)} struct `#{inspect(struct)}`" <>
      "\n#{indentation(indent)}add a catch-all clause that returns `:error` to the implementation of" <>
      "\n#{indent_multiline(Macro.to_string({:validate, [], [[do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.validate/1`."
  end

  defp format_problem(
         {_module, _function, _arity},
         {:validating, :unexpected_return, struct: struct_module, validated: validated},
         indent
       ) do
    "unexpected return value validating struct `#{inspect(struct_module)}`, validation returned: `#{inspect(validated)}`" <>
      "\n#{indentation(indent)}investigate the implementation given to `Constructive.defstruct/2`:" <>
      "\n#{indent_multiline(Macro.to_string({:validate, [], [[do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.validate/1`."
  end

  ####
  # Field validation problems
  ##

  defp format_problem(
         {module, _function, _arity},
         {:validating, :unhandled_case, struct: struct, field: field},
         indent
       ) do
    "unhandled case validating #{inspect(module)} struct `#{inspect(struct)}` field `#{Macro.inspect_atom(:literal, field)}`" <>
      "\n#{indentation(indent)}add a catch-all clause that returns `:error` to the implementation of" <>
      "\n#{indent_multiline(Macro.to_string({:validate, [], [field, [do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.validate/2`."
  end

  defp format_problem(
         {_module, _function, _arity},
         {:validating, :unexpected_return,
          struct: struct_module, field: field, validated: validated},
         indent
       ) do
    "unexpected return value validating struct `#{inspect(struct_module)}` field `#{Macro.inspect_atom(:literal, field)}`, validation returned: `#{inspect(validated)}`" <>
      "\n#{indentation(indent)}investigate the implementation given to `Constructive.defstruct/2`:" <>
      "\n#{indent_multiline(Macro.to_string({:validate, [], [field, [do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.validate/2`."
  end

  ####
  # Deconstruction problems
  ##

  defp format_problem(
         {module, _function, _arity},
         {:deconstructing, :unexpected_return, struct: struct, deconstructed: deconstructed},
         indent
       ) do
    "unexpected return value deconstructing #{inspect(module)} struct `#{inspect(struct)}`, deconstruction returned: #{inspect(deconstructed)}" <>
      "\n#{indentation(indent)}investigate the implementation given to `Constructive.defstruct/2`:" <>
      "\n#{indent_multiline(Macro.to_string({:deconstruct, [], [[do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.deconstruct/1`."
  end

  defp format_problem(
         {module, _function, _arity},
         {:deconstructing, :unhandled_case, struct: struct},
         indent
       ) do
    "unhandled case deconstructing #{inspect(module)} struct `#{inspect(struct)}`" <>
      "\n#{indentation(indent)}add a catch-all clause that returns `:error` to the implementation of" <>
      "\n#{indent_multiline(Macro.to_string({:deconstruct, [], [[do: :...]]}), indent + 1)}" <>
      "\n#{indentation(indent)}and consult the docs for `Constructive.DSL.deconstruct/1`."
  end
end
