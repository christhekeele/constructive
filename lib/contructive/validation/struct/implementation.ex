defmodule Constructive.Validation.Struct.Implementation do
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
      @behaviour Constructive.Validation.Struct.Behaviour

      unquote([
        valid?(module, dsl),
        validate(module, dsl),
        validate!(module, dsl)
      ])

      defimpl Constructive.Validation.Struct.Protocol do
        def valid?(struct) when is_struct(struct, __MODULE__) do
          @protocol.valid?(struct)
        end

        def validate(struct) when is_struct(struct, __MODULE__) do
          @protocol.validate(struct)
        end

        def validate!(struct) when is_struct(struct, __MODULE__) do
          @protocol.validate!(struct)
        end
      end
    end
  end

  @doc """

  """
  def valid?(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Validation.Struct.Behaviour
      def valid?(struct = %unquote(module){}) do
        case validate(struct) do
          {:ok, ^struct} ->
            true

          {:error, problems} when is_list(problems) ->
            false
        end
      end

      defoverridable valid?: 1
    end
  end

  @doc """

  """
  def validate(module, dsl = %DSL{}) when is_atom(module) do
    # struct = Macro.var(:struct, module)

    [
      if dsl.has_field_validation? do
        validated =
          quote location: :keep, generated: true do
            unquote(DSL.validatable_field_names(dsl.fields))
            |> Enum.map(&validate(struct, &1))
            |> Enum.reduce(:ok, fn
              {:ok, _value}, result ->
                result

              {:error, problems}, :ok when is_list(problems) ->
                {:error, fields: problems}

              {:error, more_problems}, {:error, problems: problems}
              when is_list(more_problems) ->
                {:error, fields: problems ++ more_problems}
            end)
          end

        quote location: :keep, generated: true do
          @doc """

          """
          @impl Constructive.Validation.Struct.Behaviour

          def validate(struct = %unquote(module){}) do
            case unquote(validated) do
              :ok ->
                {:ok, struct}

              :error ->
                {:error, [{:validating, struct: struct}]}

              {:error, fields: problems} when is_list(problems) ->
                {:error, [{:validating, fields: problems, struct: struct}]}

              {:error, details} when is_list(details) ->
                {:error, [{:validating, details: details, struct: struct}]}

              {:error, detail} ->
                {:error, [{:validating, detail: detail, struct: struct}]}

              other ->
                raise Constructive.Handler.Error,
                  problem: {:validating, :unexpected_return, struct: struct, validated: other},
                  context: {__MODULE__, :validate, 1}
            end
          end

          defoverridable validate: 1
        end
      end
    ] ++
      [
        if dsl.validate do
          {:fn, _, [fallback_clause]} =
            quote location: :keep, generated: true do
              fn other ->
                raise Constructive.Handler.Error,
                  problem: {:validating, :unhandled_case, struct: struct},
                  context: {__MODULE__, :validate, 1}
              end
            end

          validate_with_fallback =
            :lists.reverse([fallback_clause | :lists.reverse(dsl.validate)])

          validated =
            quote location: :keep, generated: true do
              case struct do
                unquote(validate_with_fallback)
              end
            end

          quote location: :keep, generated: true do
            @doc """

            """
            @impl Constructive.Validation.Struct.Behaviour
            def validate(struct = %unquote(module){}) do
              case unquote(validated) do
                :ok ->
                  {:ok, struct}

                :error ->
                  {:error, [{:validating, struct: struct}]}

                {:error, fields: problems} when is_list(problems) ->
                  {:error, [{:validating, fields: problems, struct: struct}]}

                {:error, details} when is_list(details) ->
                  {:error, [{:validating, details: details, struct: struct}]}

                {:error, detail} ->
                  {:error, [{:validating, detail: detail, struct: struct}]}

                other ->
                  raise Constructive.Handler.Error,
                    problem: {:validating, :unexpected_return, struct: struct, validated: other},
                    context: {__MODULE__, :validate, 1}
              end
            end

            defoverridable validate: 1
          end
        end
      ]
  end

  def validate!(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @impl Constructive.Core.Struct.Protocol
      @doc """

      """
      @impl Constructive.Validation.Struct.Behaviour
      def validate!(struct = %unquote(module){}) do
        case validate(struct) do
          {:ok, struct} when is_struct(struct, __MODULE__) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :validate, 1}
        end
      end

      defoverridable validate!: 1
    end
  end
end
