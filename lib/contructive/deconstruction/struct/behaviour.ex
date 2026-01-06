defmodule Constructive.Deconstruction.Struct.Behaviour do
  @callback to_input(struct) ::
              {:ok, Constructive.input()} | {:error, [Constructive.Error.problem()]}

  @callback to_input!(struct) :: Constructive.input()
end
