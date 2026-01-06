if Mix.env() in [:dev, :docs, :test] do
  defmodule Constructive.Usage do
    @moduledoc false

    @readme "README.md"
    @external_resource @readme

    @readme
    |> File.read!()
    |> String.split("<!-- SIMPLE USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)

    @readme
    |> File.read!()
    |> String.split("<!-- STRUCT VALIDATE USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)

    @readme
    |> File.read!()
    |> String.split("<!-- FIELD VALIDATE USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)

    @readme
    |> File.read!()
    |> String.split("<!-- CONSTRUCT USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)

    @readme
    |> File.read!()
    |> String.split("<!-- FIELD PARSE USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)

    @readme
    |> File.read!()
    |> String.split("<!-- DECONSTRUCT USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)

    @readme
    |> File.read!()
    |> String.split("<!-- FULL USAGE MODULE -->")
    |> Enum.fetch!(1)
    |> String.trim_leading()
    |> String.trim_leading("```elixir")
    |> String.trim_trailing()
    |> String.trim_trailing("```")
    |> Code.eval_string([], __ENV__)
  end
end

# defmodule SimpleUsage do
#   use Constructive

#   @default_method :GET

#   defstruct [:uri, method: @default_method]

#   @moduledoc """
#   A simple demonstration of the Constructive APIs.

#   ## Examples

#   """
# end
