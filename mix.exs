defmodule Constructive.Mix.Project do
  use Mix.Project

  @version "VERSION" |> File.read!() |> String.trim() |> Version.parse!()

  @name "Constructive"
  @description "Standard construction and validation for Elixir structs"
  @authors ["Chris Keele"]
  @maintainers ["Chris Keele"]
  @licenses ["MIT"]

  @release_branch "release"

  @github_url "https://github.com/christhekeele/constructive"
  @homepage_url @github_url

  def project,
    do: [
      app: :constructive,
      description: @description,
      version: Version.to_string(@version),
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]

  def application, do: [extra_applications: [:logger]]

  def cli do
    [
      preferred_envs: [
        do: :docs,
        docs: :docs,
        "hex.publish": :docs,
        test: :test
      ]
    ]
  end

  defp deps,
    do: [
      {:ex_doc, "~> 0.34", only: :docs, runtime: false, warn_if_outdated: true}
    ]

  defp docs,
    do: [
      # Metadata
      name: @name,
      authors: @authors,
      source_ref: @release_branch,
      source_url: @github_url,
      homepage_url: @homepage_url,
      # Files and Layout
      # extra_section: "OVERVIEW",
      main: @name,
      # logo: "docs/img/logo.png",
      # cover: "docs/img/cover.png",
      redirects: %{},
      extras: [
        # # Guides
        # "docs/guides/usage.livemd": [filename: "guide-usage", title: "Using Matcha"],
        # "docs/guides/usage/filtering-and-mapping.livemd": [
        #   filename: "guide-filtering-and-mapping",
        #   title: "...for Filtering/Mapping"
        # ],
        # "docs/guides/usage/tables.livemd": [
        #   filename: "guide-tables",
        #   title: "...for ETS/DETS/Mnesia"
        # ],
        # "docs/guides/usage/tracing.livemd": [
        #   filename: "guide-tracing",
        #   title: "...for Tracing"
        # ],
        # "docs/guides/adoption.livemd": [filename: "guide-adoption", title: "Adopting Matcha"],
        # # Cheatsheets
        # "docs/cheatsheets/adoption.cheatmd": [
        #   filename: "cheatsheet-adoption",
        #   title: "Adoption Cheatsheet"
        # ],
        # "docs/cheatsheets/tables.cheatmd": [
        #   filename: "cheatsheet-tables",
        #   title: "Tables Cheatsheet"
        # ],
        # "docs/cheatsheets/tracing.cheatmd": [
        #   filename: "cheatsheet-tracing",
        #   title: "Tracing Cheatsheet"
        # ],
        # Reference
        # "CHANGELOG.md": [filename: "changelog", title: "Changelog"],
        # "CONTRIBUTING.md": [filename: "contributing", title: "Contributing"],
        # "CONTRIBUTORS.md": [filename: "contributors", title: "Contributors"],
        "LICENSE.md": [filename: "license", title: "License"]
      ],
      groups_for_extras: [
        Guides: ~r|docs/guides|,
        Cheatsheets: ~r|docs/cheatsheets|,
        Reference: [
          # "CHANGELOG.md",
          # "CONTRIBUTING.md",
          # "CONTRIBUTORS.md",
          "LICENSE.md"
        ]
      ],
      groups_for_modules: [
        Examples: [
          Constructive.Usage.Simple,
          Constructive.Usage.Validation,
          Constructive.Usage.FieldValidation,
          Constructive.Usage.Constructor,
          Constructive.Usage.Deconstructor,
          Constructive.Usage.Full
        ],
        Exceptions: [
          Constructive.Error,
          Constructive.Handler.Error
        ],
        DSL: [
          Constructive.DSL,
          Constructive.DSL.Property,
          Constructive.DSL.Field,
          Constructive.DSL.Constructor
        ],
        Core: [
          Constructive.Core.Behaviour,
          Constructive.Core.Implementation,
          Constructive.Core.Protocol,
          Constructive.Core.Struct.Behaviour,
          Constructive.Core.Struct.Implementation,
          Constructive.Core.Struct.Protocol
        ],
        Extensions: [
          Constructive.Construction.Behaviour,
          Constructive.Construction.Implementation,
          Constructive.Construction.Protocol,
          Constructive.Validation.Behaviour,
          Constructive.Validation.Implementation,
          Constructive.Validation.Protocol,
          Constructive.Validation.Struct.Behaviour,
          Constructive.Validation.Struct.Implementation,
          Constructive.Validation.Struct.Protocol,
          Constructive.Validation.Struct.Field.Behaviour,
          Constructive.Validation.Struct.Field.Implementation,
          Constructive.Validation.Struct.Field.Protocol,
          Constructive.Deconstruction.Struct.Behaviour,
          Constructive.Deconstruction.Struct.Implementation,
          Constructive.Deconstruction.Struct.Protocol
        ]
      ],
      nest_modules_by_prefix: [
        Constructive.Core,
        Constructive.Construction,
        Constructive.Validation,
        Constructive.Validation.Struct.Field,
        Constructive.Deconstruction
      ],
      before_closing_body_tag: &before_closing_body_tag/1
    ]

  defp before_closing_body_tag(_),
    do: """
    <script>
      function mermaidLoaded() {
        mermaid.initialize({
          startOnLoad: false,
          theme: document.body.className.includes("dark") ? "dark" : "default"
        });
        let id = 0;
        for (const codeEl of document.querySelectorAll("pre code.mermaid")) {
          const preEl = codeEl.parentElement;
          const graphDefinition = codeEl.textContent;
          const graphEl = document.createElement("div");
          const graphId = "mermaid-graph-" + id++;
          mermaid.render(graphId, graphDefinition).then(({svg, bindFunctions}) => {
            graphEl.innerHTML = svg;
            bindFunctions?.(graphEl);
            preEl.insertAdjacentElement("afterend", graphEl);
            preEl.remove();
          });
        }
      }
    </script>
    <script async src="https://unpkg.com/mermaid@11.4.1/dist/mermaid.min.js" onload="mermaidLoaded();"></script>
    """

  # Hex.pm information
  defp package,
    do: [
      maintainers: @maintainers,
      licenses: @licenses,
      links: %{
        Home: @homepage_url,
        GitHub: @github_url
      },
      files: [
        "lib",
        "mix.exs",
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        "LICENSE.md",
        "README.md",
        "VERSION"
      ]
    ]
end
