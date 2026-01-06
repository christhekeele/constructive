defprotocol Constructive.Deconstruction.Struct.Protocol do
  @moduledoc """
  Protocol for taking data out of `Constructive` structs.

  You can check if `SomeStruct` uses `Constructive` deconstruction by calling
  `Constructive.deconstruction?(SomeStruct)`, or
  if an instance of `SomeStruct` uses `Constructive` deconstruction by calling
  `Constructive.deconstruction?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  through functions on the `SomeStruct` module directly.
  """

  @doc """
  Converts a `struct` into a keyword list of `input` suitable
  for `Constructive.Module.Protocol.new/2`.

  Returns `{:ok, input}` if deconstruction succeeds,
  otherwise returns `{:error, [problem]}`.
  """
  @spec to_input(struct()) :: Constructive.input()
  def to_input(struct)

  @doc """
  Converts a `struct` into a keyword list of `input` suitable
  for `Constructive.Module.Protocol.new/2`.

  Returns `input` if deconstruction succeeds,
  otherwise raises a `Constructive.Error`.
  """
  @spec to_input!(struct()) :: Constructive.input()
  def to_input!(struct)
end
