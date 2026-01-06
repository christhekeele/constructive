defprotocol Constructive.Construction.Struct.Protocol do
  @moduledoc false
  # Required since parsing has no concrete struct function associated
  #  and we check proto impl in Constructive.predicates?
  def __constructive_construction?(struct)
end

defprotocol Constructive.Construction.Protocol do
  @moduledoc """
  Protocol for parsing input to `Constructive` structs.

  You can check if `SomeStruct` uses `Constructive` parsing by calling
  `Constructive.parsing?(SomeStruct)`, or
  if an instance of `SomeStruct` uses `Constructive` parsing by calling
  `Constructive.parsing?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  through functions on the `SomeStruct` module directly.
  """

  @doc """
  Converts arbitrary `input` into a keyword list of `fields` suitable
  for `Constructive.Module.Protocol.new/2`.

  Returns `{:ok, fields}` if parsing succeeds,
  otherwise returns `{:error, [problem]}`.
  """
  @spec parse(struct_module :: atom(), Constructive.input()) :: fields :: keyword()
  def parse(struct_module, input)

  @doc """
  Converts arbitrary `input` into a keyword list of `fields` suitable
  for `Constructive.Module.Protocol.new/2`.

  Returns `fields` if parsing succeeds,
  otherwise raises a `Constructive.Error`.
  """
  @spec parse!(struct_module :: atom(), Constructive.input()) :: fields :: keyword()
  def parse!(struct_module, input)
end

defimpl Constructive.Construction.Protocol, for: Atom do
  def parse(struct_module, fields \\ [])
      when is_list(fields) do
    if Constructive.struct?(struct_module) do
      apply(struct_module, :parse, fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def parse!(struct_module, fields \\ [])
      when is_list(fields) do
    if Constructive.struct?(struct_module) do
      apply(struct_module, :parse!, fields)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end
end
