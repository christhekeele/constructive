defmodule Constructive.DSL do
  alias Constructive.DSL
  alias DSL.Property
  alias DSL.Field
  alias DSL.Constructor

  @moduledoc """

  """

  defstruct constructor: nil,
            validate: nil,
            fields: [],
            deconstructor: nil,
            enforced_keys: false,
            has_field_parsing?: false,
            has_validation?: false,
            has_field_validation?: false

  @type t :: %__MODULE__{
          constructor: Macro.t() | nil,
          validate: Macro.t() | nil,
          fields: [Field.t()],
          deconstructor: Macro.t() | nil,
          enforced_keys: [atom],
          has_field_parsing?: boolean,
          has_validation?: boolean,
          has_field_validation?: boolean
        }

  @dsls [construct: 1, validate: 1, validate: 2, deconstruct: 1]
  @dsl_calls Enum.map(@dsls, fn {fun, arity} -> "`#{inspect(__MODULE__)}.#{fun}/#{arity}`" end)

  @doc """

  """
  def construct(_code), do: :noop

  @doc """

  """
  def parse(_field, _code), do: :noop

  @doc """

  """
  def validate(_code), do: :noop

  @doc """

  """
  def validate(_field, _code), do: :noop

  @doc """

  """
  def deconstruct(_code), do: :noop

  @indent "    "

  defp indentation(amount) when amount >= 0 do
    String.duplicate(@indent, amount)
  end

  defp indent_multiline(string, amount) when is_binary(string) and amount > 0 do
    indentation = indentation(amount)
    [indentation, String.replace(string, "\n", &[&1, indentation])] |> IO.iodata_to_binary()
  end

  @doc false
  def inputs(dsl = %__MODULE__{}) do
    case dsl.constructor do
      constructor = %Constructor{} ->
        [constructor.input]

      _ ->
        dsl.fields |> Enum.map(& &1.property)
    end
  end

  @doc false
  def required_inputs(dsl = %__MODULE__{}) do
    dsl
    |> inputs
    |> Enum.filter(& &1.required?)
  end

  @doc false
  def overridable_arity(dsl, function_name)

  def overridable_arity(dsl = %__MODULE__{constructor: nil}, function_name) do
    for arity <- length(required_inputs(dsl))..length(inputs(dsl)) do
      {function_name, arity}
    end
  end

  def overridable_arity(%__MODULE__{}, function_name) do
    [{function_name, 1}]
  end

  @doc false
  def input_params(dsl = %__MODULE__{}, module) do
    dsl
    |> inputs
    |> Enum.map(fn property ->
      if property.required? do
        quote(do: unquote(Macro.var(property.name, module)))
      else
        quote(do: unquote(Macro.var(property.name, module)) \\ unquote(property.default))
      end
    end)
  end

  @doc false
  def input_args(dsl = %__MODULE__{}, module) do
    dsl
    |> inputs
    |> Enum.map(fn property ->
      quote(do: unquote(Macro.var(property.name, module)))
    end)
  end

  @doc false
  def input_keywords(dsl = %__MODULE__{}, module) do
    dsl
    |> inputs
    |> Enum.map(fn property ->
      quote(do: {unquote(property.name), unquote(Macro.var(property.name, module))})
    end)
  end

  @doc false
  def field_names(fields) do
    for field <- fields, do: field.property.name
  end

  @doc false
  def required_field_names(fields) do
    for field <- fields, field.property.required?, do: field.property.name
  end

  @doc false
  def optional_field_names(fields) do
    for field <- fields, !field.property.required?, do: field.property.name
  end

  @doc false
  def field_struct(fields, module) do
    quote(do: %unquote(module){unquote_splicing(field_keywords(fields, module))})
  end

  @doc false
  def field_keywords(fields, module) do
    fields
    |> Enum.map(fn field ->
      quote(do: {unquote(field.property.name), unquote(Macro.var(field.property.name, module))})
    end)
  end

  @doc false
  def parsable_fields(fields) do
    for field = %Field{property: %Property{}} <- fields, !!field.parse, do: field
  end

  @doc false
  def parsable_field_names(fields) do
    fields |> parsable_fields |> Enum.map(& &1.property.name)
  end

  @doc false
  def validatable_fields(fields) do
    for field = %Field{property: %Property{}} <- fields, !!field.validate, do: field
  end

  @doc false
  def validatable_field_names(fields) do
    fields |> validatable_fields |> Enum.map(& &1.property.name)
  end

  @doc false
  def no_parens_dsls(code) do
    Macro.postwalk(code, fn
      {dsl, meta, ast} when {dsl, length(ast)} in [{:defstruct, 2} | @dsls] ->
        {dsl, Keyword.put(meta, :no_parens, true), ast}

      other ->
        other
    end)
  end

  @doc """
  Extracts `#{inspect(__MODULE__)}` entities from a `Constructive.defstruct/2` call.
  """
  def build(env = %Macro.Env{}, original_fields, block) do
    block = no_parens_dsls(block)

    meta = [line: env.line]

    fields =
      expand_fields(
        original_fields,
        env,
        meta,
        {:defstruct, [no_parens: true], [original_fields, block]}
      )

    {construct_block, parse_blocks, validate_block, validate_blocks, deconstruct_block} =
      extract(env, original_fields, fields, block)

    constructor =
      case construct_block do
        {nil, {construct_meta, construct_code}} ->
          _construct_env = %Macro.Env{env | line: Keyword.get(construct_meta, :line, env.line)}

          %Constructor{
            input: %Property{
              name: :input,
              required?: true,
              default: nil
            },
            parse: add_context_to_variables(construct_code, env.module)
          }

        {[default: construct_default], {construct_meta, construct_code}} ->
          _construct_env = %Macro.Env{env | line: Keyword.get(construct_meta, :line, env.line)}

          %Constructor{
            input: %Property{
              name: :input,
              required?: false,
              default: construct_default
            },
            parse: add_context_to_variables(construct_code, env.module)
          }

        nil ->
          nil
      end

    fields =
      for {field, details} <- fields do
        parse =
          case Keyword.get(parse_blocks, field) do
            {parse_meta, parse_code} ->
              _parse_env = %Macro.Env{
                env
                | line: Keyword.get(parse_meta, :line, env.line)
              }

              add_context_to_variables(parse_code, env.module)

            _ ->
              nil
          end

        validate =
          case Keyword.get(validate_blocks, field) do
            {validate_meta, validate_code} ->
              _validate_env = %Macro.Env{
                env
                | line: Keyword.get(validate_meta, :line, env.line)
              }

              add_context_to_variables(validate_code, env.module)

            _ ->
              nil
          end

        %Field{
          property: %Property{
            name: field,
            required?: Keyword.fetch!(details, :required?),
            default: Keyword.fetch!(details, :default)
          },
          validate: validate,
          parse: parse
        }
      end

    validate =
      case validate_block do
        {validate_meta, validate_code} ->
          _validate_env = %Macro.Env{env | line: Keyword.get(validate_meta, :line, env.line)}

          add_context_to_variables(validate_code, env.module)

        nil ->
          nil
      end

    deconstructor =
      case deconstruct_block do
        {deconstruct_meta, deconstruct_code} ->
          _deconstruct_env = %Macro.Env{
            env
            | line: Keyword.get(deconstruct_meta, :line, env.line)
          }

          add_context_to_variables(deconstruct_code, env.module)

        nil ->
          nil
      end

    if deconstructor && !constructor do
      raise CompileError,
        file: env.file,
        line: Keyword.get(meta, :line, env.line),
        description:
          "got a `Constructive.DSL.deconstruct/1` block but no `Constructive.DSL.construct/2` block in `defstruct/2`, got none to match:" <>
            "\n  #{Macro.to_string({:deconstruct, [no_parens: true], [do: {:__block__, [], deconstructor}]})}"
    end

    dsl = %__MODULE__{
      constructor: constructor,
      fields: fields,
      validate: validate,
      deconstructor: deconstructor
    }

    has_field_validation? = Enum.any?(validatable_fields(dsl.fields))
    has_field_parsing? = Enum.any?(parsable_fields(dsl.fields))

    dsl = %DSL{
      dsl
      | has_field_parsing?: has_field_parsing?,
        has_validation?: !!dsl.validate or has_field_validation?,
        has_field_validation?: has_field_validation?
    }

    enforced_keys =
      case Module.get_attribute(env.module, :enforce_keys) do
        list when is_list(list) ->
          case field_names(dsl.fields) -- list do
            [] ->
              list

            bad_field_names ->
              raise CompileError,
                file: env.file,
                line: Keyword.get(meta, :line, env.line),
                description:
                  "expected only valid struct field names to be set in `@enforce_keys`, but was given keys `#{inspect(bad_field_names)}` not defined in`defstruct/2`:" <>
                    "\n  #{Macro.to_string({:defstruct, meta, [original_fields]})}"
          end

        nil ->
          []

        other ->
          raise CompileError,
            file: env.file,
            line: Keyword.get(meta, :line, env.line),
            description:
              "expected only a list of atom fields to be given to `@enforce_keys`, got:" <>
                "\n  #{Macro.to_string({:@, meta, [{:enforce_keys, meta, [other]}]})}"
      end

    dsl = %DSL{dsl | enforced_keys: enforced_keys}

    dsl
  end

  defp expand_fields(fields, env, meta, ast) when not is_list(fields) do
    raise CompileError,
      file: env.file,
      line: Keyword.get(meta, :line, env.line),
      description:
        "expected property in `defstruct/2` to be a list of fields, got:" <>
          "\n  #{Macro.to_string(ast)}"
  end

  defp expand_fields(fields, env, meta, ast) do
    # # Can't get working with @moduleattrs
    # if !Macro.quoted_literal?(Macro.expand(Macro.expand_literals(fields, env), env)) do
    #   raise CompileError,
    #     file: env.file,
    #     line: Keyword.get(meta, :line, env.line),
    #     description:
    #       "expected field list in `defstruct/2` to be a compile-time literal, got:" <>
    #         "\n  #{Macro.to_string(ast)}"
    # end

    fields
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn
      [{prev, _value}, field | []] when is_atom(field) and is_atom(prev) ->
        raise CompileError,
          file: env.file,
          line: Keyword.get(meta, :line, env.line),
          description:
            "expected required fields in `defstruct/2` to come before `optional: :default` pairs, got:" <>
              "\n  #{Macro.to_string(ast)}"

      [_, _ | []] ->
        :ok
    end)

    fields
    |> Enum.map(fn
      field when is_atom(field) ->
        {field, required?: true, default: nil}

      {field, default} when is_atom(field) ->
        {field, required?: false, default: default}

      _other ->
        raise CompileError,
          file: env.file,
          line: Keyword.get(meta, :line, env.line),
          description:
            "expected fields in `defstruct/2` to be either atom `:field` names or `field: :default` keyword pairs, got:" <>
              "\n  #{Macro.to_string(ast)}"
    end)
  end

  defp add_context_to_variables(code, new_context) do
    Macro.postwalk(code, fn
      {name, meta, context}
      when is_atom(name) and is_list(meta) and is_atom(context) ->
        {name, meta, new_context}

      other ->
        other
    end)
  end

  defp extract(_env, _original_fields, _fields, nil) do
    {nil, [], nil, [], nil}
  end

  defp extract(_env, _original_fields, _fields, []) do
    {nil, [], nil, [], nil}
  end

  defp extract(env, original_fields, fields, block) when is_list(block) do
    {meta, code} =
      extract_code_block(
        env,
        [],
        block,
        "expected final property to `defstruct` to be a multi-line `do` block of expressions," <>
          " got:" <>
          "\n  #{Macro.to_string({:defstruct, [no_parens: true], [original_fields, block]})}"
      )

    extract_code(env, meta, original_fields, fields, code)
  end

  defp extract_code(env, meta, original_fields, fields, code) do
    blocks =
      Enum.reduce(code, %{constructor: nil, parsers: [], validators: [], deconstructor: nil}, fn
        {:construct, meta, code}, acc ->
          if already_defined = Map.get(acc, :constructor) do
            {_already_defined_construct_meta, already_defined_construct_code} = already_defined

            raise CompileError,
              file: env.file,
              line: Keyword.get(meta, :line, env.line),
              description:
                "expected only one `Constructive.DSL.construct/2` block in `defstruct/2`, got multiple:" <>
                  "\n  #{Macro.to_string({:construct, [no_parens: true], [do: {:__block__, [], already_defined_construct_code}]})}" <>
                  "\n  #{Macro.to_string({:construct, [no_parens: true], [do: {:__block__, [], code}]})}"
          else
            Map.put(acc, :constructor, {meta, code})
          end

        {:parse, meta, code}, acc ->
          Map.put(acc, :parsers, [{meta, code} | Map.fetch!(acc, :parsers)])

        {:validate, meta, code}, acc ->
          Map.put(acc, :validators, [{meta, code} | Map.fetch!(acc, :validators)])

        {:deconstruct, meta, code}, acc ->
          if already_defined = Map.get(acc, :deconstructor) do
            {_already_defined_deconstruct_meta, already_defined_deconstruct_code} =
              already_defined

            raise CompileError,
              file: env.file,
              line: Keyword.get(meta, :line, env.line),
              description:
                "expected only one `Constructive.DSL.deconstruct/1` block in `defstruct/2`, got multiple:" <>
                  "\n  #{Macro.to_string({:deconstruct, [no_parens: true], [do: {:__block__, [], already_defined_deconstruct_code}]})}" <>
                  "\n  #{Macro.to_string({:deconstruct, [no_parens: true], [do: {:__block__, [], code}]})}"
          else
            Map.put(acc, :deconstructor, {meta, code})
          end

        other = {_node, meta, _stuff}, _acc ->
          raise CompileError,
            file: env.file,
            line: Keyword.get(meta, :line, env.line),
            description:
              "unexpected block in `defstruct/2`, expected only #{Enum.join(@dsl_calls, ",")}, got:" <>
                "\n#{indent_multiline(Macro.to_string(other), 1)}"
      end)

    construct_block = blocks |> Map.fetch!(:constructor)
    constructor = extract_construct_block(env, construct_block)

    :ok =
      case constructor do
        {[default: _default], {_env, _code}} ->
          # # Can't get working with @moduleattrs
          # if !Macro.quoted_literal?(Macro.expand(Macro.expand_literals(default, env), env)) do
          #   raise CompileError,
          #     file: env.file,
          #     line: Keyword.get(meta, :line, env.line),
          #     description:
          #       "expected field list in `defstruct/2` to be a compile-time literal, got:" <>
          #         "\n  #{Macro.to_string(ast)}"
          # else
          #   :ok
          # end
          :ok

        {nil, {_env, _code}} ->
          :ok

        {other, {env, code}} ->
          raise CompileError,
            file: env.file,
            line: Keyword.get(meta, :line, env.line),
            description:
              "unexpected first property given to `Constructive.DSL.construct/2` in `defstruct/2`, expected a keyword list with a `:default` value, got `#{Macro.to_string(other)}` in:" <>
                "\n  #{Macro.to_string({:construct, [no_parens: true], [other, [do: code]]})}"

        nil ->
          :ok
      end

    parse_blocks = blocks |> Map.fetch!(:parsers) |> :lists.reverse()
    field_parsers = extract_parse_blocks(env, parse_blocks)

    validate_blocks = blocks |> Map.fetch!(:validators) |> :lists.reverse()
    {validator, field_validators} = extract_validate_blocks(env, validate_blocks)

    for {field, {meta, field_validator}} <- field_validators do
      if !Keyword.get(fields, field) do
        raise CompileError,
          file: env.file,
          line: Keyword.get(meta, :line, env.line),
          description:
            "unexpected field validator in `defstruct/2`, got fields `#{inspect(original_fields)}` but attempted to define a `Constructive.DSL.validate/2` block for unknown field `#{inspect(field)}`: " <>
              "\n  #{Macro.to_string({:validate, [no_parens: true], [field, [do: field_validator]]})}"
      else
        :ok
      end
    end

    deconstruct_block = blocks |> Map.fetch!(:deconstructor)
    deconstructor = extract_deconstruct_block(env, deconstruct_block)

    {constructor, field_parsers, validator, field_validators, deconstructor}
  end

  defp extract_construct_block(_env, nil) do
    nil
  end

  defp extract_construct_block(env, {meta, block}) do
    {opts, code} =
      extract_construct_block_opts_and_code(
        env,
        meta,
        block
      )

    {opts, {meta, code}}
  end

  defp extract_construct_block_opts_and_code(env, meta, [opts, block]) do
    code =
      extract_clauses_block!(
        env,
        meta,
        block,
        "Property to `Constructive.DSL.construct/2` in `defstruct/2` must be a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:construct, [no_parens: true], [block]})}"
      )

    {opts, code}
  end

  defp extract_construct_block_opts_and_code(env, meta, [block]) do
    code =
      extract_clauses_block!(
        env,
        meta,
        block,
        "Property to `Constructive.DSL.construct/2` in `defstruct/2` must be a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:construct, [no_parens: true], [block]})}"
      )

    {nil, code}
  end

  defp extract_construct_block_opts_and_code(env, meta, other) do
    raise CompileError,
      file: env.file,
      line: Keyword.get(meta, :line, env.line),
      description:
        "Expected `Constructive.DSL.construct/2` in `defstruct/2` to only be given an optional keyword list with a `:default` and a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:construct, [no_parens: true], other})}"
  end

  defp extract_parse_blocks(env, parse_blocks) do
    parse_blocks
    |> Enum.reduce([], &extract_parse_block(env, &2, &1))
    |> :lists.reverse()
  end

  defp extract_parse_block(env, extracted_parse_blocks, {meta, parse_block}) do
    {name, code} = extract_parse_block_name_and_code(env, meta, parse_block)

    :ok =
      case Keyword.get(extracted_parse_blocks, name) do
        {already_defined_meta, already_defined_block} ->
          raise CompileError,
            file: env.file,
            line: Keyword.get(meta, :line, env.line),
            description:
              "expected only one `Constructive.DSL.parse/2` per field, #{name} already defined a validate block in `defstruct/2` on line #{Keyword.get(already_defined_meta, :line, env.line)}:" <>
                "\n  #{Macro.to_string(already_defined_block)}"

        _ ->
          :ok
      end

    [{name, {meta, code}} | extracted_parse_blocks]
  end

  defp extract_parse_block_name_and_code(env, meta, [name, block]) do
    code =
      extract_clauses_block!(
        env,
        meta,
        block,
        "expected final property to `Constructive.DSL.parse/2` in `defstruct/2` to be a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:parse, [no_parens: true], [name, block]})}"
      )

    {name, code}
  end

  defp extract_parse_block_name_and_code(env, meta, other) do
    raise CompileError,
      file: env.file,
      line: Keyword.get(meta, :line, env.line),
      description:
        "expected `Constructive.DSL.parse/2` in `defstruct/2` to be given a single atom field name and a code block, got:" <>
          "\n  #{Macro.to_string({:parse, [no_parens: true], other})}"
  end

  defp extract_validate_blocks(env, validate_blocks) do
    validate_blocks
    |> Enum.reduce([], &extract_validate_block(env, &2, &1))
    |> :lists.reverse()
    |> Keyword.pop(nil)
  end

  defp extract_validate_block(env, extracted_validate_blocks, {meta, validate_block}) do
    {name, code} = extract_validate_block_name_and_code(env, meta, validate_block)

    :ok =
      case Keyword.get(extracted_validate_blocks, name) do
        {already_defined_meta, already_defined_block} ->
          raise CompileError,
            file: env.file,
            line: Keyword.get(meta, :line, env.line),
            description:
              "expected only one `Constructive.DSL.validate/2` per field, #{name} already defined a validate block in `defstruct/2` on line #{Keyword.get(already_defined_meta, :line, env.line)}:" <>
                "\n  #{Macro.to_string(already_defined_block)}"

        _ ->
          :ok
      end

    [{name, {meta, code}} | extracted_validate_blocks]
  end

  defp extract_validate_block_name_and_code(env, meta, [block]) do
    code =
      extract_clauses_block!(
        env,
        meta,
        block,
        "expected final property to `Constructive.DSL.validate/2` in `defstruct/2` to be a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:validate, [no_parens: true], [block]})}"
      )

    {nil, code}
  end

  defp extract_validate_block_name_and_code(env, meta, [name, block]) do
    code =
      extract_clauses_block!(
        env,
        meta,
        block,
        "expected final property to `Constructive.DSL.validate/2` in `defstruct/2` to be a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:validate, [no_parens: true], [name, block]})}"
      )

    {name, code}
  end

  defp extract_validate_block_name_and_code(env, meta, other) do
    raise CompileError,
      file: env.file,
      line: Keyword.get(meta, :line, env.line),
      description:
        "expected `Constructive.DSL.validate/2` in `defstruct/2` to be given a single atom field name and a code block, got:" <>
          "\n  #{Macro.to_string({:validate, [no_parens: true], other})}"
  end

  defp extract_deconstruct_block(_env, nil) do
    nil
  end

  defp extract_deconstruct_block(env, {meta, block}) do
    code =
      extract_deconstruct_block_code(
        env,
        meta,
        block
      )

    {meta, code}
  end

  defp extract_deconstruct_block_code(env, meta, [block]) do
    code =
      extract_clauses_block!(
        env,
        meta,
        block,
        "Property to `Constructive.DSL.deconstruct/1` in `defstruct/2` must be a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:deconstruct, [no_parens: true], [block]})}"
      )

    code
  end

  defp extract_deconstruct_block_code(env, meta, other) do
    raise CompileError,
      file: env.file,
      line: Keyword.get(meta, :line, env.line),
      description:
        "Expected `Constructive.DSL.deconstruct/1` in `defstruct/2` to only be given a `do` block of `->` clauses, got:" <>
          "\n  #{Macro.to_string({:deconstruct, [no_parens: true], other})}"
  end

  defp extract_code_block(env, meta, block, error_description)
       when is_list(block) do
    {do_block, rest} = Keyword.pop(block, :do)

    if [] != rest do
      raise CompileError,
        file: env.file,
        line: Keyword.get(meta, :line, env.line),
        description: error_description
    end

    case do_block do
      {:__block__, meta, code} when is_list(code) ->
        {meta, code}

      code = {_node, _meta, _args} ->
        {meta, [code]}

      _ ->
        raise CompileError,
          file: env.file,
          line: Keyword.get(meta, :line, env.line),
          description: error_description
    end
  end

  defp extract_clauses_block!(env, meta, block, error_description)
       when is_list(block) do
    {do_clauses, rest} = Keyword.pop(block, :do)

    if [] != rest do
      raise CompileError,
        file: env.file,
        line: Keyword.get(meta, :line, env.line),
        description: error_description
    end

    if !do_clauses or not is_list(do_clauses) do
      raise CompileError,
        file: env.file,
        line: Keyword.get(meta, :line, env.line),
        description: error_description
    end

    for clause <- do_clauses do
      case clause do
        {:->, _meta, _code} ->
          :ok

        _other ->
          raise CompileError,
            file: env.file,
            line: Keyword.get(meta, :line, env.line),
            description: error_description
      end
    end

    do_clauses
  end

  defp extract_clauses_block!(env, meta, _other, error_description) do
    raise CompileError,
      file: env.file,
      line: Keyword.get(meta, :line, env.line),
      description: error_description
  end
end
