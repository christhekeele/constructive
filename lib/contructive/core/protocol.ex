defprotocol Constructive.Core.Protocol do
  @moduledoc """
  Protocol for agnosticly constructing `Constructive` structs.

  You can check if `SomeStruct` is `Constructive` by calling
  `Constructive.struct?(SomeStruct)`, or if
  an instance of `SomeStruct` is `Constructive` by calling
  `Constructive.struct?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  on the `SomeStruct` module directly.
  """

  @doc """
  Builds an instance of `struct_module` from `args`.

  Note that the resulting struct will not yet have been validated——
  see `Constructive.Validation.Struct.Protocol.validate/1`.

  Returns `{:ok, %struct_module{}}` if parsing input succeeds,
  otherwise returns `{:error, [problem]}`.
  """
  @spec build(module(), [Constructive.input()]) ::
          {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  def build(struct_module, args)

  @doc """
  Builds an instance of `struct_module` from `args`.

  Note that the resulting struct will not yet have been validated——
  see `Constructive.Validation.Struct.Protocol.validate!/1`.

  Returns a `%struct_module{}` if parsing input succeeds,
  otherwise raises a `Constructive.Error`.
  """
  @spec build!(module(), [Constructive.input()]) :: struct()
  def build!(struct_module, args)

  @doc """
  Builds an instance of `struct_module` from `keywords`.

  Note that the resulting struct will not yet have been validated——
  see `Constructive.Validation.Struct.Protocol.validate!/1`.

  Returns `{:ok, %struct_module{}}`. Equivalent to `{:ok, struct!(struct_module, keywords)}`.
  """
  @spec from_keywords(module(), keyword()) ::
          {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  def from_keywords(struct_module, keywords)

  @doc """
  Builds an instance of `struct_module` from `keywords`.

  Note that the resulting struct will not yet have been validated——
  see `Constructive.Validation.Struct.Protocol.validate!/1`.

  Returns a `%struct_module{}`. Equivalent to `struct(struct_module, keywords)`.
  """
  @spec from_keywords(module(), keyword) :: struct()
  def from_keywords!(struct_module, keywords)
end

defimpl Constructive.Core.Protocol, for: Atom do
  def build(struct_module, args) when is_list(args) do
    if Constructive.struct?(struct_module) do
      apply(struct_module, :build, args)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def build!(struct_module, args) when is_list(args) do
    if Constructive.struct?(struct_module) do
      apply(struct_module, :build!, args)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def from_keywords(struct_module, fields) when is_list(fields) do
    if Constructive.struct?(struct_module) do
      struct_module.from_keywords(fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def from_keywords!(struct_module, fields) when is_list(fields) do
    if Constructive.struct?(struct_module) do
      struct_module.from_keywords!(fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end
end
