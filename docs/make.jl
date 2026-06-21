using EngineKinematics
using Documenter

DocMeta.setdocmeta!(EngineKinematics, :DocTestSetup, :(using EngineKinematics); recursive=true)

makedocs(;
    modules=[EngineKinematics],
    authors="C. Naaktgeboren",
    sitename="EngineKinematics.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
