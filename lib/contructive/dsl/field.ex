defmodule Constructive.DSL.Field do
  defstruct [:property, :parse, :validate]

  @type t :: %__MODULE__{
          property: Constructive.DSL.Property.t(),
          parse: Macro.t() | nil,
          validate: Macro.t() | nil
        }
end
