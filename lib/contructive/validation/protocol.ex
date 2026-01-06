defprotocol Constructive.Validation.Protocol do
  @moduledoc """
  Protocol for creating valid `Constructive` structs.

  You can check if `SomeStruct` uses `Constructive` validation by calling
  `Constructive.validation?(SomeStruct)`, or
  if an instance of `SomeStruct` uses `Constructive` validation by calling
  `Constructive.validation?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  through functions on the `SomeStruct` module directly.
  """

  @doc """
  Creates a valid instance of `struct_module` from `keywords`.

  Returns `{:ok, %struct_module{}}` if `keywords` and resulting `struct` are valid.
  """
  @spec create(module(), keyword()) ::
          {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  def create(struct_module, keywords)

  @doc """
  Creates a valid instance of `struct_module` from `keywords`.

  Returns `{:ok, %struct_module{}}` if `keywords` and resulting `struct` are valid.
  """
  @spec create(module(), keyword) :: struct()
  def create!(struct_module, keywords)

  @doc """
  Parses and validates a new instance of `struct_module` from `args`.

  Returns `{:ok, %struct_module{}}` if both steps succeed,
  otherwise returns `{:error, [problem]}`.

  Constructing a struct through this protocol's `new/3`
  is discouraged over combining other functions that operate
  exclusively on single-list keywords, like `build/2`,
  or by calling `struct_module.new(required, fields, optional)` directly.
  """
  @spec new(module(), [Constructive.input()]) ::
          {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  def new(struct_module, args)

  @doc """
  Parses and validates a new instance of `struct_module` from `args`.

  Returns `%struct_module{}` if both steps succeed,
  otherwise raises a `Constructive.Error`.

  Constructing a struct through this protocol's `new/3`
  is discouraged over combining other functions that operate
  exclusively on single-list keywords, like `build!/2`,
  or by calling `struct_module.new(required, fields, optional)` directly.
  """
  @spec new!(module(), [Constructive.input()]) :: struct()
  def new!(struct_module, args)
end

defimpl Constructive.Validation.Protocol, for: Atom do
  def create(struct_module, fields) when is_list(fields) do
    if Constructive.struct?(struct_module) do
      struct_module.create(fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def create!(struct_module, fields) when is_list(fields) do
    if Constructive.struct?(struct_module) do
      struct_module.create!(fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def new(struct_module, fields)
      when is_list(fields) do
    if Constructive.struct?(struct_module) do
      apply(struct_module, :new, fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def new!(struct_module, fields)
      when is_list(fields) do
    if Constructive.struct?(struct_module) do
      apply(struct_module, :new!, fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end
end
