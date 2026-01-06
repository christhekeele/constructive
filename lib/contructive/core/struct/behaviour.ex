defmodule Constructive.Core.Struct.Behaviour do
  @callback to_list(struct) ::
              {:ok, Constructive.fields()} | {:error, [Constructive.Error.problem()]}

  @callback to_list!(struct) :: Constructive.fields()

  @callback to_map(struct) :: {:ok, map()} | {:error, [Constructive.Error.problem()]}

  @callback to_map!(struct) :: map()
end
