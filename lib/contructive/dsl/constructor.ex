defmodule Constructive.DSL.Constructor do
  defstruct [:input, :parse]

  @type t :: %__MODULE__{
          input: Constructive.DSL.Property.t(),
          parse: Macro.t() | nil
        }
end
