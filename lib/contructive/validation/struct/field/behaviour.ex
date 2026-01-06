defmodule Constructive.Validation.Struct.Field.Behaviour do
  @callback valid?(struct, Constructive.field()) :: boolean

  @callback validate(struct, Constructive.field()) ::
              {:ok, Constructive.value()}

  @callback validate!(struct, Constructive.field()) :: Constructive.value()
end
