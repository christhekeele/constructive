defmodule Constructive.Construction.Behaviour do
  @callback parse(Constructive.input()) ::
              {:ok, keyword} | {:error, [Constructive.Error.problem()]}

  @callback parse!(Constructive.input()) :: keyword
end
