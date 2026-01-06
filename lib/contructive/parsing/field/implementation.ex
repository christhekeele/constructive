defmodule Constructive.Parsing.Field.Implementation do
  @moduledoc """
  Dependencies: Constructive.Core.Implementation
  Uses: none
  """

  alias Constructive.DSL
  alias Constructive.DSL.Field

  defmacro __using__(opts \\ []) do
    {module, opts} = Keyword.pop!(opts, :for)
    {dsl, opts} = Keyword.pop!(opts, :dsl)
    [] = opts
    implement(module, dsl)
  end

  def implement(module, dsl = %DSL{}) do
    quote location: :keep, generated: true do
      @behaviour Constructive.Parsing.Field.Behaviour

      unquote([
        parse(module, dsl),
        parse!(module, dsl)
      ])
    end
  end

  @doc """

  """
  def parse(module, dsl = %DSL{}) when is_atom(module) do
    [
      quote location: :keep, generated: true do
        @doc """

        """
        @impl Constructive.Parsing.Field.Behaviour
        def parse(field, input)
      end
    ] ++
      for field = %Field{} <- dsl.fields do
        if field.parse do
          {:fn, _, [fallback_clause]} =
            quote location: :keep, generated: true do
              fn other ->
                raise Constructive.Handler.Error,
                  problem:
                    {:parsing, :unhandled_case,
                     struct: unquote(module), field: unquote(field.property.name)},
                  context: {__MODULE__, :parse, 2}
              end
            end

          parse_field_with_fallback =
            :lists.reverse([fallback_clause | :lists.reverse(field.parse)])

          field_parsed =
            quote location: :keep, generated: true do
              case input do
                unquote(parse_field_with_fallback)
              end
            end

          quote location: :keep, generated: true do
            def parse(unquote(field.property.name), input) do
              case unquote(field_parsed) do
                {:ok, value} ->
                  {:ok, value}

                :error ->
                  {:error,
                   [
                     {:parsing,
                      field: unquote(field.property.name), input: input, struct: unquote(module)}
                   ]}

                {:error, details} when is_list(details) ->
                  {:error,
                   [
                     {:parsing,
                      field: unquote(field.property.name),
                      details: details,
                      input: input,
                      struct: unquote(module)}
                   ]}

                {:error, detail} ->
                  {:error,
                   [
                     {:parsing,
                      field: unquote(field.property.name),
                      detail: detail,
                      input: input,
                      struct: unquote(module)}
                   ]}

                other ->
                  raise Constructive.Handler.Error,
                    problem:
                      {:parsing, :unexpected_return, struct: unquote(module), parsed: other},
                    context: {__MODULE__, :parse, 1}
              end
            end
          end
        else
          quote location: :keep, generated: true do
            def parse(unquote(field.property.name), input) do
              {:ok, input}
            end
          end
        end
      end ++
      [
        quote location: :keep, generated: true do
          defoverridable parse: 2
        end
      ]
  end

  @doc """

  """
  def parse!(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Parsing.Field.Behaviour
      def parse!(field, input) do
        case parse(field, input) do
          {:ok, value} ->
            value

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :parse, 1}
        end
      end

      defoverridable parse!: 2
    end
  end
end
