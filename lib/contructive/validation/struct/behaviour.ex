defmodule Constructive.Validation.Struct.Behaviour do
  @callback valid?(struct) :: boolean

  @callback validate(struct) :: {:ok, struct} | {:error, [Constructive.Error.problem()]}

  @callback validate!(struct) :: struct
end
