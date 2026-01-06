defprotocol Constructive.Core.Struct.Protocol do
  @moduledoc """
  Protocol for interacting agnosticly with `Constructive` structs.

  You can check if `SomeStruct` is `Constructive` by calling
  `Constructive.struct?(SomeStruct)`, or if
  an instance of `SomeStruct` is `Constructive` by calling
  `Constructive.struct?(%SomeStruct{})`.

  If so, you can interact with these helpers generically
  through the functions in this protocol, or, preferentially,
  on the `SomeStruct` module directly.
  """

  #   @doc """
  #   Replaces values in a `struct` with keyword `fields`.
  #   Equivalent to `struct(struct, ...fields)`.

  #   Note that the resulting struct will not yet have been validated——
  #   see `Constructive.Core.Struct.Protocol.validate/1`.

  #   Returns `{:ok, struct` fields are valid,
  #   otherwise returns `{:error, [problem]}`.
  #   """
  #   @spec replace(struct(), Constructive.fields()) ::
  #           {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  #   def replace(struct, fields \\ [])

  #   @doc """
  #   Replaces values in a `struct` with keyword `fields`.
  #   Equivalent to `struct!(struct, ...fields)`.

  #   Note that the resulting struct will not yet have been validated——
  #   see `Constructive.Core.Struct.Protocol.validate!/1`.

  #   Returns a `%struct_module{}` fields are valid,
  #   otherwise raises a `Constructive.Error`.
  #   """
  #   @spec replace(struct(), Constructive.fields()) :: struct()
  #   def replace!(struct, fields \\ [])

  #   @doc """
  #   Updates a `struct` with `input` fields and validates result.

  #   Returns `{:ok, struct` if parsing and validation succeeds,
  #   otherwise returns `{:error, [problem]}`.
  #   """
  #   @spec update(struct(), Constructive.input()) ::
  #           {:ok, struct()} | {:error, [Constructive.Error.problem()]}
  #   def update(struct, input \\ [])

  #   @doc """
  #   Updates a `struct` with `input` fields and validates result.

  #   Returns a `struct` if parsing and validation succeeds,
  #   otherwise raises a `Constructive.Error`.
  #   """
  #   @spec update!(struct(), Constructive.input()) :: struct()
  #   def update!(struct, input \\ [])

  @doc """
  Converts a `struct` into a keyword list of `fields` suitable for `struct/2`.

  Raises if any invalid keys were found inserted into the `struct`.
  """
  @spec to_list(struct()) ::
          {:ok, Constructive.fields()} | {:error, [Constructive.Error.problem()]}
  def to_list(struct)

  @doc """
  Converts a `struct` into a keyword list of `fields` suitable for `struct/2`.

  Raises if any invalid keys were found inserted into the `struct`.
  """
  @spec to_list!(struct()) :: Constructive.fields()
  def to_list!(struct)

  @doc """
  Converts a `struct` into a map.

  Similar to `Map.from_struct/1`, except it omits any invalid struct keys.
  """
  @spec to_map(struct()) :: map()
  def to_map(struct)

  @doc """
  Converts a `struct` into a map.

  Similar to `Map.from_struct/1`, except raises on any invalid struct keys.
  """
  @spec to_map!(struct()) :: map()
  def to_map!(struct)
end
