defmodule Constructive do
  @readme "README.md"
  @external_resource @readme
  @moduledoc_blurb @readme
                   |> File.read!()
                   |> String.split("<!-- MODULEDOC BLURB -->")
                   |> Enum.fetch!(1)
  @moduledoc_snippet @readme
                     |> File.read!()
                     |> String.split("<!-- MODULEDOC SNIPPET -->")
                     |> Enum.fetch!(1)

  @moduledoc """
  #{@moduledoc_blurb}

  > #### `use #{inspect(__MODULE__)}` {: .info}
  >
  > When you `use #{inspect(__MODULE__)}`, #{inspect(__MODULE__)} will
  > replace `Kernel.defstruct/1` with a backwards-compatible implementation
  > that will define standard functions for you.
  >
  > All functions are tested, documented, customizable via DSL,
  > and can have their documentation or functionality overridden.

  #{@moduledoc_snippet}
  """

  @type field :: atom()
  @type value :: any()
  @type input :: any()
  @type fields :: Keyword.t()

  import Kernel, except: [struct: 1, struct: 2, struct!: 1, struct!: 2]

  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      import Kernel, except: [defstruct: 1]
      import Constructive, only: [defstruct: 1, defstruct: 2]
    end
  end

  defmacro defstruct(fields, extensions \\ []) do
    module = __CALLER__.module

    dsl = Constructive.DSL.build(__CALLER__, fields, extensions)

    [
      # Standard defstruct
      quote location: :keep, generated: true do
        Kernel.defstruct(unquote(fields))
      end,
      # Standard functions
      Constructive.Core.Implementation.implement(module, dsl),
      Constructive.Core.Struct.Implementation.implement(module, dsl),
      # Optional custom parsing functions
      if(dsl.constructor,
        do: [
          Constructive.Construction.Implementation.implement(module, dsl)
        ]
      ),
      # Optional field parsing functions
      if(dsl.has_field_parsing?,
        do: [
          Constructive.Parsing.Field.Implementation.implement(module, dsl)
        ]
      ),
      # Optional validation functions
      if(dsl.has_validation?,
        do: [
          Constructive.Validation.Implementation.implement(module, dsl),
          Constructive.Validation.Struct.Implementation.implement(module, dsl)
        ]
      ),
      # Optional field validation functions
      if(dsl.has_field_validation?,
        do: [
          Constructive.Validation.Struct.Field.Implementation.implement(module, dsl)
        ]
      ),
      # Optional deconstructor functions
      if(dsl.deconstructor,
        do: [
          Constructive.Deconstruction.Struct.Implementation.implement(module, dsl)
        ]
      )
    ]
  end

  @doc """
  Drop-in replacement for `Kernel.struct/1` that is `Constructive`-aware.
  """
  def struct(construct)

  def struct(struct_module) when is_atom(struct_module) do
    if struct?(struct_module) do
    else
      Kernel.struct(struct_module)
    end
  end

  def struct(struct) when is_struct(struct) do
    if struct?(struct) do
    else
      Kernel.struct(struct)
    end
  end

  @doc """
  Drop-in replacement for `Kernel.struct/2` that is `Constructive`-aware.
  """
  def struct(construct, fields_or_input)

  def struct(struct_module, fields_or_input) when is_atom(struct_module) do
    if struct?(struct_module) do
    else
      Kernel.struct(struct_module, fields_or_input)
    end
  end

  def struct(struct, fields_or_input) when is_struct(struct) do
    if struct?(struct) do
    else
      Kernel.struct(struct, fields_or_input)
    end
  end

  @doc """
  Drop-in replacement for `Kernel.struct!/1` that is `Constructive`-aware.
  """
  def struct!(construct)

  def struct!(struct_module) when is_atom(struct_module) do
    if struct?(struct_module) do
    else
      Kernel.struct!(struct_module)
    end
  end

  def struct!(struct) when is_struct(struct) do
    if struct?(struct) do
    else
      Kernel.struct!(struct)
    end
  end

  @doc """
  Drop-in replacement for `Kernel.struct!/2` that is `Constructive`-aware.
  """
  def struct!(construct, fields_or_input)

  def struct!(struct_module, fields_or_input) when is_atom(struct_module) do
    if struct?(struct_module) do
    else
      Kernel.struct!(struct_module, fields_or_input)
    end
  end

  def struct!(struct, fields_or_input) when is_struct(struct) do
    if struct?(struct) do
    else
      Kernel.struct!(struct, fields_or_input)
    end
  end

  @doc """
  Returns `true` if `construct` is a `Constructive` struct module or instance.
  """
  def struct?(construct)

  def struct?(struct_module) when is_atom(struct_module) do
    if function_exported?(struct_module, :__struct__, 0) do
      struct_module |> Kernel.struct() |> struct?
    else
      false
    end
  end

  def struct?(struct) when is_struct(struct) do
    !!Constructive.Core.Struct.Protocol.impl_for(struct)
  end

  def struct?(_) do
    false
  end

  @doc """
  Returns `true` if `construct` (struct module or instance) uses `Constructive` for construction.
  """
  def construction?(construct)

  def construction?(struct_module) when is_atom(struct_module) do
    if function_exported?(struct_module, :__struct__, 0) do
      struct_module |> Kernel.struct() |> construction?
    else
      false
    end
  end

  def construction?(struct) when is_struct(struct) do
    !!Constructive.Construction.Struct.Protocol.impl_for(struct)
  end

  def construction?(_) do
    false
  end

  @doc """
  Returns `true` if `construct` (struct module or instance) uses `Constructive` for validation.
  """
  def validation?(construct)

  def validation?(struct_module) when is_atom(struct_module) do
    if function_exported?(struct_module, :__struct__, 0) do
      struct_module |> Kernel.struct() |> validation?
    else
      false
    end
  end

  def validation?(struct) when is_struct(struct) do
    !!Constructive.Validation.Struct.Protocol.impl_for(struct)
  end

  def validation?(_) do
    false
  end

  @doc """
  Returns `true` if `construct` (struct module or instance) uses `Constructive` for deconstruction.
  """
  def deconstruction?(construct)

  def deconstruction?(struct_module) when is_atom(struct_module) do
    if function_exported?(struct_module, :__struct__, 0) do
      struct_module |> Kernel.struct() |> deconstruction?
    else
      false
    end
  end

  def deconstruction?(struct) when is_struct(struct) do
    !!Constructive.Deconstruction.Struct.Protocol.impl_for(struct)
  end

  def deconstruction?(_) do
    false
  end
end
