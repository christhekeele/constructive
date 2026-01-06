defmodule Constructive.Test do
  use ExUnit.Case

  require Constructive.Usage.Simple
  alias Constructive.Usage.Simple
  require Constructive.Usage.Validation
  alias Constructive.Usage.Validation
  require Constructive.Usage.FieldValidation
  alias Constructive.Usage.FieldValidation
  require Constructive.Usage.Constructor
  alias Constructive.Usage.Constructor
  require Constructive.Usage.FieldParser
  alias Constructive.Usage.FieldParser
  require Constructive.Usage.Deconstructor
  alias Constructive.Usage.Deconstructor
  require Constructive.Usage.Request
  alias Constructive.Usage.Request

  # doctest Constructive

  test "struct?/1 with modules" do
    refute Constructive.struct?(Foobar)
    refute Constructive.struct?(Module)
    refute Constructive.struct?(URI)
    assert Constructive.struct?(Simple)
  end

  test "struct?/1 with structs" do
    refute Constructive.struct?(%URI{})
    assert Constructive.struct?(%Simple{})
  end
end
