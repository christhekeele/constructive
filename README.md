# 🛠️ Constructive

<!-- MODULEDOC BLURB -->

> **_Standard constructor and validation functions for Elixir structs._**

<!-- MODULEDOC BLURB -->

[![Version][hex-pm-version-badge]][hex-pm-versions]
[![Documentation][docs-badge]][docs]
[![License][hex-pm-license-badge]][hex-pm-package]
[![Benchmarks][benchmarks-badge]][benchmarks]
[![Dependencies][deps-badge]][deps]
[![Contributors][contributors-badge]][contributors]

|         👍         |                  [Test Suite][suite]                  |                   [Test Coverage][coverage]                    |
| :----------------: | :---------------------------------------------------: | :------------------------------------------------------------: |
| [Release][release] | [![Build Status][release-suite-badge]][release-suite] | [![Coverage Status][release-coverage-badge]][release-coverage] |
|  [Latest][latest]  |  [![Build Status][latest-suite-badge]][latest-suite]  |  [![Coverage Status][latest-coverage-badge]][latest-coverage]  |

## Installation

`Constructive` is distributed via [hex.pm][hex-pm], you can install it with your dependency manager of choice using the config provided on its [hex.pm package][hex-pm-package] listing.

<!-- MODULEDOC SNIPPET -->
<!--
  all hyperlinks in this snippet must be inline,
  rather than using markdown link references
-->

## Simple Usage

Simply use `Constructive` to get a version of `defstruct/2` that furnishes you with standard constructor and conversion functions, as shown in `Constructive.Usage.Simple`:

<!-- SIMPLE USAGE MODULE -->

```elixir
defmodule Simple do
  use Constructive

  @default_method :GET

  defstruct [:uri, method: @default_method]

  @moduledoc """
  A simple demonstration of the default Constructive APIs.

  Just using `defstruct` normally gives you
  `build/1`, `from_keywords/1`, `to_list/1`, `to_map/1`,
  and `assertive!` versions of all functions.

  ## Examples

  - `build/1` uses your `defstruct` signature
    like `[:uri, method: @default_method]`
    as a positional argument constructor:

        iex> Simple.build("https://example.com")
        {:ok, %Simple{uri: "https://example.com", method: :GET}}

        iex> Simple.build("https://example.com", :POST)
        {:ok, %Simple{uri: "https://example.com", method: :POST}}

  - `from_keywords/1` works like `Kernel.struct/2`,
    but returns an `:ok`/`:error` tuple to handle
    invalid fields explicitly:

        iex> Simple.from_keywords(uri: "https://example.com")
        {:ok, %Simple{uri: "https://example.com", method: :GET}}

        iex> Simple.from_keywords(urL: "https://example.com")
        {:error, [
          field: [
            invalid: :urL,
            valid: [:uri, :method],
            value: "https://example.com"
          ]
        ]}

  - `to_list/1` converts your struct into a keyword list:

        iex> %Simple{uri: "https://example.com", method: :GET}
        ...> |> Simple.to_list()
        [uri: "https://example.com", method: :GET]

  - `to_map/1` converts your struct into a map:

        iex> %Simple{uri: "https://example.com", method: :GET}
        ...> |> Simple.to_map()
        %{uri: "https://example.com", method: :GET}

  """
end
```

<!-- SIMPLE USAGE MODULE -->

## Struct Validation

Optionally, annotate your `defstruct` definition with a `Constructive.DSL.validate/1` handler for validation logic, and get rich creation and validation functions, as seen in `Constructive.Usage.Validation`:

<!-- STRUCT VALIDATE USAGE MODULE -->

```elixir
defmodule Validation do
  use Constructive

  @default_method :GET
  @allowed_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
    POST
    PUT
    PATCH
    DELETE
  ]a

  defstruct [:uri, method: @default_method] do
    validate do
      struct when struct.method in @allowed_methods -> :ok
      _ -> {:error, "method not allowed"}
    end
  end

  @moduledoc """
  A demonstration of the `Constructive` validation APIs.

  Using `defstruct` with a `Constructive.DSL.validate/1` handler
  now also gives you `new/1`, `create/1`, `valid?/1`, `validate/1`,
  and `assertive!` versions of all non-predicate functions.

  ## Examples

  - `new/1` uses your `defstruct` signature
    like `[:uri, method: @default_method]`
    as a positional argument constructor,
    and ensures the result passes validation:

        iex> Validation.new("https://example.com")
        {:ok, %Validation{uri: "https://example.com", method: :GET}}

        iex> Validation.new("https://example.com", :POST)
        {:ok, %Validation{uri: "https://example.com", method: :POST}}

        iex> Validation.new("https://example.com", :BAD_METHOD)
        {:error, [
          validating: [
            detail: "method not allowed",
            struct: %Constructive.Usage.Validation{
              uri: "https://example.com",
              method: :BAD_METHOD
            }
          ]
        ]}

  - `create/1` works like `Kernel.struct/2`,
    but returns an `:ok`/`:error` tuple to handle
    invalid fields explicitly,
    and ensures the result passes validation:

        iex> Validation.create(uri: "https://example.com")
        {:ok, %Validation{uri: "https://example.com", method: :GET}}

        iex> Validation.create(urL: "https://example.com", method: :POST)
        {:error, [
          field: [
            invalid: :urL,
            valid: [:uri, :method],
            value: "https://example.com"
          ]
        ]}

        iex> Validation.create(uri: "https://example.com", method: :BAD_METHOD)
        {:error, [
          validating: [
            detail: "method not allowed",
            struct: %Constructive.Usage.Validation{
              uri: "https://example.com",
              method: :BAD_METHOD
            }
          ]
        ]}

  - `valid?/1` checks validity of an existing struct:

        iex> %Validation{uri: "https://example.com", method: :GET}
        ...> |> Validation.valid?()
        true

        iex> %Validation{uri: "https://example.com", method: :BAD_METHOD}
        ...> |> Validation.valid?()
        false

  - `validate/1` returns the struct if it is valid:

        iex> %Validation{uri: "https://example.com", method: :GET}
        ...> |> Validation.validate()
        {:ok, %Constructive.Usage.Validation{uri: "https://example.com", method: :GET}}

        iex> %Validation{uri: "https://example.com", method: :BAD_METHOD}
        ...> |> Validation.validate()
        {:error, [
          validating: [
            detail: "method not allowed",
            struct: %Constructive.Usage.Validation{
              uri: "https://example.com",
              method: :BAD_METHOD
            }
          ]
        ]}

  """
end
```

<!-- STRUCT VALIDATE USAGE MODULE -->

## Field Validation

The last example defines a struct-wide validator, which can be useful when you have validation logic that depends on the state of multiple fields. However, you'll notice that it was only really checking one field for validity—often you only need to consider fields as valid individually.

You can instead provide field-specific validation logic with a `Constructive.DSL.validate/2` handler, and get all the validation functions for free, in addition to some new per-field ones, as seen in `Constructive.Usage.FieldValidation`:

<!-- FIELD VALIDATE USAGE MODULE -->

```elixir
defmodule FieldValidation do
  use Constructive

  @default_method :GET
  @allowed_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
    POST
    PUT
    PATCH
    DELETE
  ]a

  defstruct [:uri, method: @default_method] do
    validate :method do
      method when method in @allowed_methods -> :ok
      _ -> {:error, "method not allowed"}
    end
  end

  @moduledoc """
  A demonstration of the `Constructive` field validation APIs.

  Using `defstruct` with a `Constructive.DSL.validate/2` handler
  now also gives you `valid?/2`, `validate/2`, and `validate!/2`
  functions to validate specific fields.

  Additionally, if no custom `validate` hook was provided,
  `Constructive` will build one for you that validates
  all fields individually, and aggregates the result.

  ## Examples

  - `valid?/2` checks the validity of a single struct field:

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.valid?(:uri)
        true

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.valid?(:method)
        true

        iex> %FieldValidation{uri: "https://example.com", method: :BAD_METHOD}
        ...> |> FieldValidation.valid?(:method)
        false

  - `valid?/2` can also be used without a struct:

        iex> FieldValidation.valid?(:uri, "https://example.com")
        true

        iex> FieldValidation.valid?(:method, :GET)
        true

        iex> FieldValidation.valid?(:method, :BAD_METHOD)
        false

  - `validate/2` returns the struct field if it is valid:

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.validate(:uri)
        {:ok, "https://example.com"}

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.validate(:method)
        {:ok, :GET}

        iex> %FieldValidation{uri: "https://example.com", method: :BAD_METHOD}
        ...> |> FieldValidation.validate(:method)
        {:error, [
          validating: [
            {:field, :method},
            {:detail, "method not allowed"},
            {:value, :BAD_METHOD},
            {:struct, Constructive.Usage.FieldValidation}
          ]
        ]}

  - `validate/2` can also be used without a struct:

        iex> FieldValidation.validate(:uri, "https://example.com")
        {:ok, "https://example.com"}

        iex> FieldValidation.validate(:method, :GET)
        {:ok, :GET}

        iex> FieldValidation.validate(:method, :BAD_METHOD)
        {:error, [
          validating: [
            {:field, :method},
            {:detail, "method not allowed"},
            {:value, :BAD_METHOD},
            {:struct, Constructive.Usage.FieldValidation}
          ]
        ]}

  - `validate!/2` raises if the struct field is invalid:

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.validate!(:uri)
        "https://example.com"

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.validate!(:method)
        :GET

        iex> %FieldValidation{uri: "https://example.com", method: :BAD_METHOD}
        ...> |> FieldValidation.validate!(:method)
        ** (Constructive.Error) error in `Constructive.Usage.FieldValidation.validate/2`:
            validation of struct `Constructive.Usage.FieldValidation` field `:method` failed: method not allowed, given:
                :BAD_METHOD

  - `validate!/2` can also be used without a struct:

        iex> FieldValidation.validate!(:uri, "https://example.com")
        "https://example.com"

        iex> FieldValidation.validate!(:method, :GET)
        :GET

        iex> FieldValidation.validate!(:method, :BAD_METHOD)
        ** (Constructive.Error) error in `Constructive.Usage.FieldValidation.validate/2`:
            validation of struct `Constructive.Usage.FieldValidation` field `:method` failed: method not allowed, given:
                :BAD_METHOD

  - `validate/1` and friends now use your field validators
    to determine validity:

        iex> %FieldValidation{uri: "https://example.com", method: :GET}
        ...> |> FieldValidation.validate()
        {:ok, %FieldValidation{uri: "https://example.com", method: :GET}}

        iex> %FieldValidation{uri: "https://example.com", method: :BAD_METHOD}
        ...> |> FieldValidation.validate()
        {:error, [
            validating: [fields: [
              validating: [
                field: :method,
                detail: "method not allowed",
                value: :BAD_METHOD,
                struct: Constructive.Usage.FieldValidation
              ]
            ],
            struct: %Constructive.Usage.FieldValidation{
              method: :BAD_METHOD,
              uri: "https://example.com"
            }
          ]
        ]}

  """
end
```

<!-- FIELD VALIDATE USAGE MODULE -->

## Custom Construction

If you want to provide custom parsing logic to the struct construction functions `Constructive` provides you, you can use the `Constructive.DSL.construct/1` handler to define your own method of handling input to produce keyword pairs.

In our example, if we wanted to build structs with `new(http_method: url)`,
we might do the below, which results in the module `Constructive.Usage.Constructor`. Note the requirement to return a keyword list aligned
with the ordering of the fields in `defstruct`:

<!-- CONSTRUCT USAGE MODULE -->

```elixir
defmodule Constructor do
  use Constructive

  @default_method :GET
  @allowed_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
    POST
    PUT
    PATCH
    DELETE
  ]a

  defstruct [:uri, method: @default_method] do
    construct do
      [{method, string} | []]
      when method in @allowed_methods and is_binary(string) ->
        with {:ok, uri} <- URI.new(string) do
          {:ok, uri: uri, method: method}
        end

      [{method, uri} | []]
      when method in @allowed_methods and is_struct(uri, URI) ->
        {:ok, uri: uri, method: method}

      other ->
        {:error, "expected a method: uri string or struct"}
    end

    validate :method do
      method when method in @allowed_methods -> :ok
      _ -> {:error, "method not allowed"}
    end
  end

  @moduledoc """
  A demonstration of the `Constructive` constructor APIs.

  Using `defstruct` with a `Constructive.DSL.construct/1` handler
  gives you full control of how the `build/1` function turns
  arguments into your struct. Of using `validate` hooks,
  `new/1` will use your custom logic as well.

  Additionally, a `Constructive` will define a `parse/1` function
  to allow you to execute your constructor logic without
  creating a struct.

  ## Examples

  - `build/1` now uses your custom constructor logic:

        iex> Constructor.build(GET: "https://example.com")
        {:ok, %Constructor{
          method: :GET,
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          }
        }}

        iex> Constructor.build(POST: "https://example.com")
        {:ok, %Constructor{
          method: :POST,
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          }
        }}

  - `new/1` also does, if you have paired it with validation:

        iex> Constructor.new(GET: "https://example.com")
        {:ok, %Constructor{
          method: :GET,
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          }
        }}

        iex> Constructor.new(POST: "https://example.com")
        {:ok, %Constructor{
          method: :POST,
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          }
        }}

  - `parse/1` lets you exercise the parsing logic in isolation:

        iex> Constructor.parse(GET: "https://example.com")
        {:ok, [
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          },
          method: :GET
        ]}

        iex> Constructor.parse(POST: "https://example.com")
        {:ok, [
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          },
          method: :POST
        ]}

  """
end
```

<!-- CONSTRUCT USAGE MODULE -->

## Custom Field Parsing

Custom constructors are expected to return a keyword list of struct data. Implementing the `Constructive.DSL.parse/2` handler allows for defining how to further parse each field, as well as generate a per-field `parse/2` function, as seen in `Constructive.Usage.FieldParser`. This field parser is applied whether or not a custom constructor is in play: it will also be applied by `from_keywords/1` and friends:

<!-- FIELD PARSE USAGE MODULE -->

```elixir
defmodule FieldParser do
  use Constructive

  @default_method :GET
  @allowed_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
    POST
    PUT
    PATCH
    DELETE
  ]a
  @display_allowed_methods (@allowed_methods
    |> Enum.map(&inspect/1)
    |> Enum.map(& "`" <> &1 <> "`")
    |> Enum.join(", ")
  )

  defstruct [:uri, method: @default_method] do
    parse :method do
      string when is_binary(string) ->
        try do
          {:ok, String.to_existing_atom(string)}
        rescue
          ArgumentError ->
            {:error, "method was not existing atom, got: `#{inspect(string)}`"}
        end

      atom when is_atom(atom) ->
        {:ok, atom}

      other ->
        {:error,
         "method must be string or atom in #{@display_allowed_methods}," <>
           " got: `#{inspect(other)}`"}
    end
  end

  @moduledoc """
  A demonstration of the `Constructive` field parser APIs.

  Using `defstruct` with a `Constructive.DSL.parse/2` handler
  allows `Constructive` to define `parse/2`, and use it
  automatically in constructor functions

  ## Examples

  - `parse/2` is now available for per-field parsing:

        iex> FieldParser.parse(:method, :GET)
        {:ok, :GET}

        iex> FieldParser.parse(:method, "QUERY")
        {:ok, :QUERY}

        iex> FieldParser.parse(:method, {:tuple})
        {:error, [parsing: [
          field: :method,
          detail: "method must be string or atom in `:HEAD`, `:OPTIONS`, `:CONNECT`, `:TRACE`, `:GET`, `:QUERY`, `:POST`, `:PUT`, `:PATCH`, `:DELETE`, got: `{:tuple}`",
          input: {:tuple},
          struct: Constructive.Usage.FieldParser
        ]]}

  """
end
```

<!-- FIELD PARSE USAGE MODULE -->

## Custom Deconstruction

Finally, if you are making custom constructors, it is possible to provide an operation to `parse/1` that takes an instance of your struct and produces a list of arguments that can be parsed.

Implementing the `Constructive.DSL.deconstruct/1` handler allows a `to_input/1` function to be defined that does just that, as seen in `Constructive.Usage.Deconstructor`. Note that it is required to return input arguments wrapped in a list:

<!-- DECONSTRUCT USAGE MODULE -->

```elixir
defmodule Deconstructor do
  use Constructive

  @default_method :GET
  @allowed_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
    POST
    PUT
    PATCH
    DELETE
  ]a

  defstruct [:uri, method: @default_method] do
    construct do
      [{method, uri} | []]
      when method in @allowed_methods and is_struct(uri, URI) ->
        {:ok, uri: uri, method: method}

      [{method, string} | []]
      when method in @allowed_methods and is_binary(string) ->
        with {:ok, uri} <- URI.new(string) do
          {:ok, uri: uri, method: method}
        end

      other ->
        {:error, "expected a method: uri string or struct"}
    end

    deconstruct do
      struct -> {:ok, [[{struct.method, URI.to_string(struct.uri)}]]}
    end
  end

  @moduledoc """
  A demonstration of the `Constructive` deconstruct APIs.

  Using `defstruct` with a `Constructive.DSL.deconstruct/1` handler
  allows `Constructive` to define `to_input/1`, the opposite operation
  of `parse/1`.

  ## Examples

  - `to_input/1` is now available to unwind your custom constructor logic:

        iex> Deconstructor.build(GET: "https://example.com")
        {:ok, %Deconstructor{
          method: :GET,
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          }
        }}

        iex> Deconstructor.build!(POST: "https://example.com")
        ...> |> Deconstructor.to_input()
        {:ok, [[POST: "https://example.com"]]}

        iex> deconstructed = Deconstructor.build!(
        ...>   GET: "https://example.com"
        ...> ) |> Deconstructor.to_input!()
        iex> apply(Deconstructor, :build, deconstructed)
        {:ok, %Deconstructor{
          method: :GET,
          uri: %URI{
            scheme: "https",
            userinfo: nil,
            host: "example.com",
            port: 443,
            path: nil,
            query: nil,
            fragment: nil
          }
        }}

  """
end
```

<!-- DECONSTRUCT USAGE MODULE -->

## Full Usage

With all these options in play, you can annotate your `defstruct` definitions with construction, validation, and deconstruction logic, as shown in `Constructive.Usage.Full`.

This example uses custom constructors, both struct-wide and field-specific validators, and a deconstructor.

It overrides generated functions to customize the documentation, and makes use of the DSL-generated field validators and custom functions from within other DSL functions.

<!-- FULL USAGE MODULE -->

```elixir
defmodule Request do
  use Constructive

  @default_method :GET
  @allowed_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
    POST
    PUT
    PATCH
    DELETE
  ]a
  @display_allowed_methods (@allowed_methods
    |> Enum.map(&inspect/1)
    |> Enum.join(",")
  )
  @https_only_methods ~w[
    HEAD
    OPTIONS
    CONNECT
    TRACE
    GET
    QUERY
  ]a

  defstruct [:uri, method: @default_method] do
    construct do
      [{method, uri} | []]
      when method in @allowed_methods and is_struct(uri, URI) ->
        {:ok, uri: uri, method: method}

      [{method, string} | []]
      when method in @allowed_methods and is_binary(string) ->
        with {:ok, uri} <- URI.new(string) do
          {:ok, uri: uri, method: method}
        end

      [{method, uri} | []]
      when method in @allowed_methods ->
        {:error, "expected a uri string or `URI` struct"}

      [{method, _uri} | []]
      when method in @allowed_methods ->
        {:error, "expected method to be one of"}

      [{method, uri} | rest] ->
        {:error, "expected one `[METHOD: uri]` keyword to given, got more elements: `#{inspect(rest)}`"}

      other ->
        {:error, "expected keyword list with one `[METHOD: uri]` keyword to given, got: `#{inspect(other)}`"}
    end

    parse :method do
      string when is_binary(string) -> try do
          {:ok, String.to_existing_atom(string)}
        rescue ArgumentError ->
          {:error, "method was not existing atom, got: #{string}"}
        end
      atom when is_atom(atom) -> {:ok, atom}
      other -> {:error,
        "method must be string or atom in #{@display_allowed_methods},"
          <> " got: #{inspect(other)}"
        }
    end

    validate :method do
      method when method in @allowed_methods -> :ok
      method -> {:error,
        "expected method to be in: `#{@display_allowed_methods}`,"
          <> " got: `#{inspect(method)}`"
      }
    end

    validate :uri do
      uri when is_struct(uri, URI) ->
        with {:ok, uri} <- uri |> URI.to_string() |> URI.new() do
          :ok
        end

      _ ->
        {:error, "expected uri to be a valid `URI`"}
    end

    validate do
      request ->
        with {:ok, %{uri: uri = %URI{}}} <- super(request) do
          if uri.scheme != :https and request.method in @https_only_methods do
            {:error, "request method #{request.method} only allowed for https"}
          else
            :ok
          end
        end

      _ ->
        {:error, "`#{inspect(__MODULE__)}` uri must be a `URI`"}
    end

    deconstruct do
      struct -> {:ok, [[{struct.method, URI.to_string(struct.uri)}]]}
    end
  end

  @moduledoc """
  A full demonstration of the `Constructive` APIs.

  This module uses `Constructive` to make a struct with standard functions,
  that represents a request which:

  - is built using `build(METHOD: url)` syntax
    - where `url` can be a string or an already-parsed `URI`
  - only allows sending data to be performed over `https`

  ## Examples



  """
end
```

<!-- FULL USAGE MODULE -->

As a result, you will get a standard set of functions for other libraries and application developers to interact with your structs.

### Documentation

Complete documentation, including guides, are hosted online on [hexdocs.pm][docs].

## Contributing

Contributions are welcome! Check out the [contributing guide][contributing] for more information, and suggestions on where to start.

<!-- LINKS & IMAGES -->

<!-- Hex -->

[hex-pm]: https://hex.pm
[hex-pm-package]: https://hex.pm/packages/constructive
[hex-pm-versions]: https://hex.pm/packages/constructive/versions
[hex-pm-version-badge]: https://img.shields.io/hexpm/v/constructive.svg?cacheSeconds=86400&style=flat-square
[hex-pm-downloads-badge]: https://img.shields.io/hexpm/dt/constructive.svg?cacheSeconds=86400&style=flat-square
[hex-pm-license-badge]: https://img.shields.io/badge/license-MIT-7D26CD.svg?cacheSeconds=86400&style=flat-square

<!-- Docs -->

[docs]: https://hexdocs.pm/constructive/index.html
[docs-guides]: https://hexdocs.pm/constructive/usage.html#content
[docs-badge]: https://img.shields.io/badge/documentation-online-purple?cacheSeconds=86400&style=flat-square

<!-- Deps -->

[deps]: https://hex.pm/packages/constructive
[deps-badge]: https://img.shields.io/badge/dependencies-0-blue?cacheSeconds=86400&style=flat-square

<!-- Benchmarks -->

[benchmarks]: https://christhekeele.github.io/constructive/bench
[benchmarks-badge]: https://img.shields.io/badge/benchmarks-online-2ab8b5?cacheSeconds=86400&style=flat-square

<!-- Contributors -->

[contributors]: https://hexdocs.pm/constructive/contributors.html
[contributors-badge]: https://img.shields.io/badge/contributors-%F0%9F%92%9C-lightgrey

<!-- Status -->

[suite]: https://github.com/christhekeele/constructive/actions?query=workflow%3A%22Test+Suite%22
[coverage]: https://coveralls.io/github/christhekeele/constructive

<!-- Release Status -->

[release]: https://github.com/christhekeele/constructive/tree/release
[release-suite]: https://github.com/christhekeele/constructive/actions?query=workflow%3A%22Test+Suite%22+branch%3Arelease
[release-suite-badge]: https://img.shields.io/github/actions/workflow/status/christhekeele/constructive/test-suite.yml?branch=release&cacheSeconds=86400&style=flat-square
[release-coverage]: https://coveralls.io/github/christhekeele/constructive?branch=release
[release-coverage-badge]: https://img.shields.io/coverallsCoverage/github/christhekeele/constructive?branch=release&cacheSeconds=86400&style=flat-square

<!-- Latest Status -->

[latest]: https://github.com/christhekeele/constructive/tree/latest
[latest-suite]: https://github.com/christhekeele/constructive/actions?query=workflow%3A%22Test+Suite%22+branch%3Alatest
[latest-suite-badge]: https://img.shields.io/github/actions/workflow/status/christhekeele/constructive/test-suite.yml?branch=latest&cacheSeconds=86400&style=flat-square
[latest-coverage]: https://coveralls.io/github/christhekeele/constructive?branch=latest
[latest-coverage-badge]: https://img.shields.io/coverallsCoverage/github/christhekeele/constructive?branch=latest&cacheSeconds=86400&style=flat-square

<!-- Other -->

[changelog]: https://hexdocs.pm/constructive/changelog.html
[test-matrix]: https://github.com/christhekeele/constructive/actions/workflows/test-matrix.yml
[test-edge]: https://github.com/christhekeele/constructive/actions/workflows/test-edge.yml
[contributing]: https://hexdocs.pm/constructive/contributing.html
