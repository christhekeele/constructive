defmodule Constructive.Validation.Implementation do
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
      @behaviour Constructive.Validation.Behaviour

      unquote([
        create(module, dsl),
        create!(module, dsl),
        new(module, dsl),
        new!(module, dsl)
      ])
    end
  end

  @doc """

  """
  def create(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Validation.Behaviour
      def create(fields) do
        with {:ok, struct} <- from_keywords(fields) do
          validate(struct)
        end
      end

      defoverridable create: 1
    end
  end

  @doc """

  """
  def create!(module, _dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      @impl Constructive.Validation.Behaviour
      def create!(fields) do
        case create(fields) do
          {:ok, struct} when is_struct(struct, unquote(module)) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :create, 1}
        end
      end

      defoverridable create!: 1
    end
  end

  @doc """

  """
  def new(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def new(unquote_splicing(DSL.input_params(dsl, module))) do
        with {:ok, struct} <- build(unquote_splicing(DSL.input_args(dsl, module))) do
          validate(struct)
        end
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :new))
    end
  end

  @doc """

  """
  def new!(module, dsl = %DSL{}) when is_atom(module) do
    quote location: :keep, generated: true do
      @doc """

      """
      # @impl Constructive.Core.Behaviour
      def new!(unquote_splicing(DSL.input_params(dsl, module))) do
        case new(unquote_splicing(DSL.input_args(dsl, module))) do
          {:ok, struct} when is_struct(struct, __MODULE__) ->
            struct

          {:error, problems} when is_list(problems) ->
            raise Constructive.Error,
              problems: problems,
              context: {unquote(module), :new, 1}
        end
      end

      defoverridable unquote(DSL.overridable_arity(dsl, :new!))
    end
  end
end
