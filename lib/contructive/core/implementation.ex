defmodule Constructive.Core.Implementation do
  @moduledoc """
  Dependencies: none
  Uses:
    if available, parser in from_keywords
    if available, constructor in build
    if available, validation in new
  """

  alias Constructive.DSL
  alias Constructive.DSL.Constructor

  defmacro __using__(opts \\ []) do
    {module, opts} = Keyword.pop!(opts, :for)
    {dsl, opts} = Keyword.pop!(opts, :dsl)
    [] = opts
    implement(module, dsl)
  end

  def implement(module, dsl = %DSL{}) do
    quote location: :keep, generated: true do
      @behaviour Constructive.Core.Behaviour
      unquote([
        build(module, dsl),
        build!(module, dsl),
        from_keywords(module, dsl),
        from_keywords!(module, dsl)
      ])
    end
  end

  @doc """

  """
  def build(module, dsl)

  def build(module, dsl = %DSL{constructor: %Constructor{}}) when is_atom(module) do
    input = Macro.var(:input, module)

    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def build(unquote(input)) do
        with {:ok, keywords} <- parse(unquote(input)) do
          from_keywords(keywords)
        end
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :build))
    end
  end

  def build(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def build(unquote_splicing(DSL.input_params(dsl, module))) do
        from_keywords(unquote(DSL.input_keywords(dsl, module)))
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :build))
    end
  end

  @doc """

  """
  def build!(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def build!(unquote_splicing(DSL.input_params(dsl, module))) do
        case build(unquote_splicing(DSL.input_args(dsl, module))) do
          {:ok, struct} when is_struct(struct, __MODULE__) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :build, unquote(length(DSL.input_params(dsl, module)))}
        end
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :build!))
    end
  end

  @doc """

  """
  def from_keywords(module, dsl = %DSL{}) when is_atom(module) do
    fields = Macro.var(:fields, module)
    problems = Macro.var(:problems, module)

    extract_problems_from_fields =
      quote location: :keep, generated: true do
        {extra, unquote(fields), missing} =
          for name <- unquote(DSL.field_names(dsl.fields)), reduce: {unquote(fields), [], []} do
            {remaining, valid, missing} ->
              if Keyword.has_key?(remaining, name) do
                {value, remaining} = Keyword.pop!(remaining, name)
                {remaining, [{name, value} | valid], missing}
              else
                if name in unquote(dsl.enforced_keys) do
                  {remaining, valid, [name | missing]}
                else
                  {remaining, valid, missing}
                end
              end
          end

        unquote(problems) =
          for other <- extra do
            case other do
              {key, value} when is_atom(key) ->
                {:field, invalid: key, valid: unquote(DSL.field_names(dsl.fields)), value: value}

              other ->
                {:field, invalid: other}
            end
          end ++
            for enforced_key <- missing do
              {:field, missing: enforced_key, enforced: unquote(dsl.enforced_keys)}
            end
      end

    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def from_keywords(unquote(fields)) when is_list(unquote(fields)) do
        unquote(extract_problems_from_fields)

        case unquote(problems) do
          [] ->
            {:ok, Kernel.struct!(unquote(module), unquote(fields))}

          problems ->
            {:error, problems}
        end
      end

      defoverridable from_keywords: 1
    end
  end

  @doc """

  """
  def from_keywords!(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def from_keywords!(fields) do
        case from_keywords(fields) do
          {:ok, struct} when is_struct(struct, unquote(module)) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :from_keywords, 1}
        end
      end

      defoverridable from_keywords!: 1
    end
  end
end
