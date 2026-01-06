defmodule Constructive.Validation.Struct.Field.Implementation do
  @moduledoc """
  Dependencies: none
  Uses: none
  """

  alias Constructive.DSL
  alias DSL.Field
  alias DSL.Property

  defmacro __using__(opts \\ []) do
    {module, opts} = Keyword.pop!(opts, :for)
    {dsl, opts} = Keyword.pop!(opts, :dsl)
    [] = opts
    implement(module, dsl)
  end

  def implement(module, dsl = %DSL{}) do
    quote location: :keep, generated: true do
      @behaviour Constructive.Validation.Struct.Field.Behaviour

      unquote([
        valid?(module, dsl),
        validate(module, dsl),
        validate!(module, dsl)
      ])

      defimpl Constructive.Validation.Struct.Field.Protocol do
        def valid?(struct, field) when is_struct(struct, __MODULE__) do
          @protocol.valid?(struct, field)
        end

        def validate(struct, field) when is_struct(struct, __MODULE__) do
          @protocol.validate(struct, field)
        end

        def validate!(struct, field) when is_struct(struct, __MODULE__) do
          @protocol.validate!(struct, field)
        end
      end
    end
  end

  @doc """

  """
  def valid?(module, dsl = %DSL{}) when is_atom(module) do
    field_names = DSL.field_names(dsl.fields)

    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Validation.Struct.Field.Behaviour
      def valid?(struct_or_field, field_or_value)

      def valid?(struct = %unquote(module){}, field)
          when field in unquote(field_names) do
        case validate(struct, field) do
          {:ok, _value} ->
            true

          {:error, problems} when is_list(problems) ->
            false
        end
      end

      def valid?(field, value)
          when field in unquote(field_names) do
        case validate(field, value) do
          {:ok, _value} ->
            true

          {:error, problems} when is_list(problems) ->
            false
        end
      end

      defoverridable valid?: 2
    end
  end

  @doc """

  """
  def validate(module, dsl = %DSL{}) when is_atom(module) do
    [
      quote location: :keep, generated: true do
        @doc """

        """
        @impl Constructive.Validation.Struct.Field.Behaviour
        def validate(struct_or_field, field_or_value)
      end
    ] ++
      for field = %Field{property: %Property{}} <- dsl.fields do
        if field.validate do
          {:fn, _, [fallback_clause]} =
            quote location: :keep, generated: true do
              fn other ->
                raise Constructive.Handler.Error,
                  problem:
                    {:validating, :unhandled_case,
                     struct: unquote(module), field: unquote(field.property.name)},
                  context: {__MODULE__, :validate, 2}
              end
            end

          validate_field_with_fallback =
            :lists.reverse([fallback_clause | :lists.reverse(field.validate)])

          field_validated =
            quote location: :keep, generated: true do
              case value do
                unquote(validate_field_with_fallback)
              end
            end

          quote location: :keep, generated: true do
            def validate(
                  %unquote(module){{unquote(field.property.name), value}},
                  unquote(field.property.name)
                ) do
              validate(unquote(field.property.name), value)
            end

            def validate(unquote(field.property.name), value) do
              case unquote(field_validated) do
                :ok ->
                  {:ok, value}

                :error ->
                  {:error,
                   [
                     {:validating,
                      field: unquote(field.property.name), value: value, struct: unquote(module)}
                   ]}

                {:error, details} when is_list(details) ->
                  {:error,
                   [
                     {:validating,
                      field: unquote(field.property.name),
                      details: details,
                      value: value,
                      struct: unquote(module)}
                   ]}

                {:error, detail} ->
                  {:error,
                   [
                     {:validating,
                      field: unquote(field.property.name),
                      detail: detail,
                      value: value,
                      struct: unquote(module)}
                   ]}

                other ->
                  raise Constructive.Handler.Error,
                    problem:
                      {:validating, :unexpected_return, struct: unquote(module), validated: other},
                    context: {__MODULE__, :validate, 1}
              end
            end
          end
        else
          quote location: :keep, generated: true do
            def validate(
                  %unquote(module){{unquote(field.property.name), value}},
                  unquote(field.property.name)
                ) do
              validate(unquote(field.property.name), value)
            end

            def validate(unquote(field.property.name), value) do
              {:ok, value}
            end
          end
        end
      end ++
      [
        quote location: :keep, generated: true do
          defoverridable validate: 2
        end
      ]
  end

  def validate!(module, dsl = %DSL{}) when is_atom(module) do
    field_names = DSL.field_names(dsl.fields)

    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Validation.Struct.Field.Behaviour
      def validate!(struct_or_field, field_or_value)

      def validate!(struct = %unquote(module){}, field)
          when field in unquote(field_names) do
        case validate(struct, field) do
          {:ok, value} ->
            value

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :validate, 2}
        end
      end

      def validate!(field, value)
          when field in unquote(field_names) do
        case validate(field, value) do
          {:ok, value} ->
            value

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :validate, 2}
        end
      end

      defoverridable validate!: 2
    end
  end
end
