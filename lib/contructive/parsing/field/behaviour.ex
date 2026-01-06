defmodule Constructive.Parsing.Field.Behaviour do
  @callback parse(Constructive.field(), Constructive.input()) ::
              {:ok, keyword} | {:error, [Constructive.Error.problem()]}

  @callback parse!(Constructive.field(), Constructive.input()) :: keyword
end
