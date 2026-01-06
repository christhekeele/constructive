defprotocol Constructive.Validation.Struct.Field.Protocol do
  @moduledoc """
  Protocol for validating `Constructive` struct fields.

  You can check if `SomeStruct` uses `Constructive` validation by calling
  `Constructive.validation?(SomeStruct)`, or
  if an instance of `SomeStruct` uses `Constructive` validation by calling
  `Constructive.validation?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  through functions on the `SomeStruct` module directly.
  """

  @doc """
  Returns whether or not a `field` of a `struct` is valid.
  """
  @spec valid?(struct(), Constructive.field()) :: boolean()
  def valid?(struct, field)

  @doc """
  Validates a `field` of a `struct`.

  Returns `{:ok, value}` if validation succeeds,
  otherwise returns `{:error, [problem]}`.
  """
  @spec validate(struct(), Constructive.field()) ::
          {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  def validate(struct, field)

  @doc """
  Validates a `field` of a `struct`.

  Returns `value` if validation succeeds,
  otherwise raises a `Constructive.Error`.
  """
  @spec validate!(struct(), Constructive.field()) :: struct()
  def validate!(struct, field)
end
