using Documenter
using Impero

makedocs(
    pages = [
        "Impero" => "index.md",
    ],
    sitename = "Impero",
    format = Documenter.HTML(collapselevel = 1),
    modules = [Impero],
)

deploydocs(
    repo = "github.com/CliMA/Impero.jl",
)
