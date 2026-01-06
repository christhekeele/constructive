defmodule Constructive.Construction.Implementation do
  @moduledoc """
  Dependencies: Constructive.Core.Implementation
  Uses: Constructive.Parsing.Field.Implementation if available
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
      @behaviour Constructive.Construction.Behaviour

      unquote([
        parse(module, dsl),
        parse!(module, dsl)
      ])

      defimpl Constructive.Construction.Struct.Protocol do
        @doc false
        def __constructive_construction?(_struct), do: true
      end
    end
  end

  @doc """

  """
  def parse(module, dsl)

  def parse(module, dsl = %DSL{constructor: nil}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Construction.Behaviour
      def parse(unquote_splicing(DSL.input_params(dsl, module))) do
        struct(unquote(module), [unquote_splicing(DSL.input_keywords(dsl, module))]) |> to_list
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :parse))
    end
  end

  def parse(module, dsl = %DSL{constructor: constructor = %Constructor{}}) when is_atom(module) do
    input = Macro.var(:input, module)

    {:fn, _, [fallback_clause]} =
      quote location: :keep, generated: true do
        fn other ->
          raise Constructive.Handler.Error,
            problem: {:constructing, :unhandled_case, input: unquote(input)},
            context: {__MODULE__, :parse, 1}
        end
      end

    parse_with_fallback =
      :lists.reverse([fallback_clause | :lists.reverse(constructor.parse)])

    parsed =
      quote location: :keep, generated: true do
        case unquote(input) do
          unquote(parse_with_fallback)
        end
      end

    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Construction.Behaviour
      def parse(unquote(input)) do
        case unquote(parsed) do
          {:ok, list} when is_list(list) ->
            if Keyword.keyword?(list) do
              {:ok, list}
            else
              raise Constructive.Handler.Error,
                problem: {:constructing, :unexpected_return, input: unquote(input), parsed: list},
                context: {__MODULE__, :parse, 1}
            end

          :error ->
            {:error, [{:constructing, input: unquote_splicing(DSL.input_args(dsl, module))}]}

          {:error, details} when is_list(details) ->
            {:error,
             [
               {:constructing,
                details: details, input: unquote_splicing(DSL.input_args(dsl, module))}
             ]}

          {:error, detail} ->
            {:error,
             [
               {:constructing,
                detail: detail, input: unquote_splicing(DSL.input_args(dsl, module))}
             ]}

          other ->
            raise Constructive.Handler.Error,
              problem: {:parsing, :unexpected_return, input: unquote(input), parsed: other},
              context: {__MODULE__, :parse, 1}
        end
      end
    end
  end

  @doc """

  """
  def parse!(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Construction.Behaviour
      def parse!(unquote_splicing(DSL.input_params(dsl, module))) do
        case parse(unquote_splicing(DSL.input_params(dsl, module))) do
          {:ok, keywords} when is_list(keywords) ->
            keywords

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :parse, 1}
        end
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :parse!))
    end
  end
end
