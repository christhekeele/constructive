defmodule Constructive.Core.Struct.Implementation do
  @moduledoc """
  Dependencies: none
  Uses: if available, validation in update
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
      @behaviour Constructive.Core.Struct.Behaviour

      unquote([
        to_list(module, dsl),
        to_list!(module, dsl),
        to_map(module, dsl),
        to_map!(module, dsl)
      ])

      defimpl Constructive.Core.Struct.Protocol do
        # def replace(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
        #   @protocol.replace(struct, fields)
        # end

        # def replace!(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
        #   @protocol.replace!(struct, fields)
        # end

        # def to_input(struct) when is_struct(struct, __MODULE__) do
        #   @protocol.to_input(struct)
        # end

        def to_list(struct) when is_struct(struct, __MODULE__) do
          @protocol.to_list(struct)
        end

        def to_list!(struct) when is_struct(struct, __MODULE__) do
          @protocol.to_list!(struct)
        end

        def to_map(struct) when is_struct(struct, __MODULE__) do
          @protocol.to_map(struct)
        end

        def to_map!(struct) when is_struct(struct, __MODULE__) do
          @protocol.to_map!(struct)
        end

        # def update(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
        #   @protocol.update(struct, fields)
        # end

        # def update!(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
        #   @protocol.update!(struct, fields)
        # end
      end
    end
  end

  # @doc """

  # """
  # def replace(module, _dsl) when is_atom(module) do
  #   quote location: :keep, generated: true do
  #     @impl Constructive.Core.Struct.Behaviour
  #     @doc """

  #     """
  #     def replace(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
  #       __MODULE__
  #       |> struct!(fields)
  #     end

  #     defoverridable replace: 2
  #   end
  # end

  # @doc """

  # """
  # def replace!(module, _dsl) when is_atom(module) do
  #   quote location: :keep, generated: true do
  #     @impl Constructive.Core.Struct.Behaviour
  #     @doc """

  #     """
  #     def replace!(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
  #       case replace(struct, fields) do
  #         {:ok, struct} when is_struct(struct, __MODULE__) ->
  #           struct

  #         {:error, problems} when is_list(problems) ->
  #           raise Constructive.Error,
  #             problems: problems,
  #             context: {unquote(module), :replace, 1}
  #       end
  #     end

  #     defoverridable replace!: 2
  #   end
  # end

  # def update(module, _dsl) when is_atom(module) do
  #   quote location: :keep, generated: true do
  #     @impl Constructive.Core.Struct.Behaviour
  #     @doc """

  #     """
  #     def update(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
  #       __MODULE__
  #       |> struct!(fields)
  #     end

  #     defoverridable update: 2
  #   end
  # end

  # def update!(module, _dsl) when is_atom(module) do
  #   quote location: :keep, generated: true do
  #     @impl Constructive.Core.Struct.Behaviour
  #     @doc """

  #     """
  #     def update!(struct, fields) when is_struct(struct, __MODULE__) and is_list(fields) do
  #       case update(struct, fields) do
  #         {:ok, struct} when is_struct(struct, __MODULE__) ->
  #           struct

  #         {:error, problems} when is_list(problems) ->
  #           raise Constructive.Error,
  #             problems: problems,
  #             context: {unquote(module), :update, 2}
  #       end
  #     end

  #     defoverridable update!: 2
  #   end
  # end

  @doc """

  """
  def to_list(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Core.Struct.Behaviour
      def to_list(unquote(DSL.field_struct(dsl.fields, module))) do
        unquote(DSL.field_keywords(dsl.fields, module))
      end

      defoverridable to_list: 1
    end
  end

  @doc """

  """
  def to_list!(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Core.Struct.Behaviour
      def to_list!(struct) do
        case to_list(struct) do
          {:ok, struct} when is_struct(struct, __MODULE__) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :to_list, 2}
        end
      end

      defoverridable to_list!: 1
    end
  end

  @doc """

  """
  def to_map(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Core.Struct.Behaviour
      def to_map(unquote(DSL.field_struct(dsl.fields, module))) do
        %{unquote_splicing(DSL.field_keywords(dsl.fields, module))}
      end

      defoverridable to_map: 1
    end
  end

  @doc """

  """
  def to_map!(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Core.Struct.Behaviour
      def to_map!(struct) do
        case to_map(struct) do
          {:ok, struct} when is_struct(struct, __MODULE__) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :to_map, 2}
        end
      end

      defoverridable to_map!: 1
    end
  end
end
