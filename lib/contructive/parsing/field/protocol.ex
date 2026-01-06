defprotocol Constructive.Parsing.Struct.Protocol do
  @moduledoc false
  # Required since parsing has no concrete struct function associated
  #  and we check proto impl in Constructive.predicates?
  def __constructive_parsing?(struct)
end

defprotocol Constructive.Parsing.Field.Protocol do
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
  Parses given `input` to `field` using the `struct_module`'s parser.

  Returns `{:ok, value}` if parsing succeeds,
  otherwise returns `{:error, [problem]}`.
  """
  @spec parse(struct_module :: atom, Constructive.field(), Constructive.input()) :: value :: any
  def parse(struct_module, field, input)

  @doc """
  Parses given `input` to `field` using the `struct_module`'s parser.

  Returns parsed `value` if parsing succeeds,
  otherwise raises a `Constructive.Error`.
  """
  @spec parse!(struct_module :: atom, Constructive.field(), Constructive.input()) :: value :: any
  def parse!(struct_module, field, input)
end

defimpl Constructive.Parsing.Field.Protocol, for: Atom do
  def parse(struct_module, field, value)
      when is_atom(field) do
    if Constructive.struct?(struct_module) do
      struct_module.parse(field, value)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end

  def parse!(struct_module, field, value)
      when is_atom(field) do
    if Constructive.struct?(struct_module) do
      struct_module.parse!(field, value)
    else
      raise Protocol.UndefinedError, protocol: @protocol, value: struct_module
    end
  end
end
