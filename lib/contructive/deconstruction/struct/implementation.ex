defmodule Constructive.Deconstruction.Struct.Implementation do
  @moduledoc """
  Dependencies: none
  Uses: none
  """

  alias Constructive.DSL

  defmacro __using__(opts \\ []) do
    {module, opts} = Keyword.pop!(opts, :for)
    {dsl, opts} = Keyword.pop!(opts, :dsl)
    [] = opts
    implement(module, dsl)
  end

  def implement(module, dsl = %DSL{}) do
    quote location: :keep, generated: true do
      @behaviour Constructive.Deconstruction.Struct.Behaviour

      unquote([
        to_input(module, dsl),
        to_input!(module, dsl)
      ])

      defimpl Constructive.Deconstruction.Struct.Protocol do
        def to_input(struct) do
          @protocol.to_input(struct)
        end

        def to_input!(struct) do
          @protocol.to_input!(struct)
        end
      end
    end
  end

  @doc """

  """
  def to_input(module, dsl)

  def to_input(module, dsl = %DSL{}) when is_atom(module) do
    struct = Macro.var(:struct, nil)

    {:fn, _, [fallback_clause]} =
      quote location: :keep, generated: true do
        fn other ->
          raise Constructive.Handler.Error,
            problem: {:deconstruct, :unhandled_case, struct: unquote(struct)},
            context: {__MODULE__, :to_input, 1}
        end
      end

    deconstruct_with_fallback =
      :lists.reverse([fallback_clause | :lists.reverse(dsl.deconstructor)])

    deconstructed =
      quote location: :keep, generated: true do
        case unquote(struct) do
          unquote(deconstruct_with_fallback)
        end
      end

    quote location: :keep, generated: true do
      @impl Constructive.Core.Struct.Protocol
      @doc """

      """
      @impl Constructive.Deconstruction.Struct.Behaviour
      def to_input(unquote(struct)) when is_struct(unquote(struct), __MODULE__) do
        case unquote(deconstructed) do
          {:ok, result} ->
            {:ok, result}

          :error ->
            {:error, [{:deconstructing, struct: unquote(struct)}]}

          {:error, details} when is_list(details) ->
            {:error, [{:deconstructing, struct: unquote(struct), details: details}]}

          {:error, detail} ->
            {:error, [{:deconstructing, struct: unquote(struct), detail: detail}]}

          other ->
            raise Constructive.Handler.Error,
              problem:
                {:deconstructing, :unexpected_return,
                 struct: unquote(struct), deconstructed: other},
              context: {__MODULE__, :to_input, 1}
        end
      end

      defoverridable to_input: 1
    end
  end

  def to_input!(module, _dsl) when is_atom(module) do
    quote location: :keep, generated: true do
      @impl Constructive.Core.Struct.Protocol
      @doc """

      """
      @impl Constructive.Deconstruction.Struct.Behaviour
      def to_input!(struct) when is_struct(struct, __MODULE__) do
        case to_input(struct) do
          {:ok, deconstructed} ->
            deconstructed

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :to_input, 2}
        end
      end

      defoverridable to_input!: 1
    end
  end
end
