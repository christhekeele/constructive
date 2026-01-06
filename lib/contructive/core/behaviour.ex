defmodule Constructive.Core.Behaviour do
  # Effectively varadic based on usage, cannot make into a callback
  # @callback build(Constructive.input()) ::
  #             {:ok, struct} | {:error, [Constructive.Error.problem()]}

  # @callback build!(Constructive.input()) :: struct

  @callback from_keywords(keyword) ::
              {:ok, struct} | {:error, [Constructive.Error.problem()]}

  @callback from_keywords!(keyword) :: struct
end
