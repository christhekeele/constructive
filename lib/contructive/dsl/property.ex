defmodule Constructive.DSL.Property do
  defstruct [:name, :required?, :default]

  @type t :: %__MODULE__{
          name: atom(),
          required?: boolean(),
          default: any()
        }
end
