defmodule Constructive.Validation.Behaviour do
  @callback create(keyword) ::
              {:ok, struct} | {:error, [Constructive.Error.problem()]}

  @callback create!(keyword) :: struct

  # Effectively varadic based on usage, cannot make into a callback
  # @callback new(Constructive.input()) ::
  #             {:ok, struct} | {:error, [Constructive.Error.problem()]}

  # @callback new!(Constructive.input()) :: struct
end
