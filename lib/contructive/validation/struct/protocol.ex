defprotocol Constructive.Validation.Struct.Protocol do
  @moduledoc """
  Protocol for validating `Constructive` structs.

  You can check if `SomeStruct` uses `Constructive` validation by calling
  `Constructive.validation?(SomeStruct)`, or
  if an instance of `SomeStruct` uses `Constructive` validation by calling
  `Constructive.validation?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  through functions on the `SomeStruct` module directly.
  """

  @doc """
  Returns whether or not a `struct` is valid.
  """
  @spec valid?(struct()) :: boolean()
  def valid?(struct)

  @doc """
  Validates a `struct`.

  Returns `{:ok, %struct{}}` if validation succeeds,
  otherwise returns `{:error, [problem]}`.
  """
  @spec validate(struct()) :: {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  def validate(struct)

  @doc """
  Validates a `struct`.

  Returns `%struct{}` if validation succeeds,
  otherwise raises a `Constructive.Error`.
  """
  @spec validate!(struct()) :: struct()
  def validate!(struct)
end
