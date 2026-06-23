# EngineKinematics.jl

Reciprocating engine kinematics

## Description

`EngineKinematics.jl` is a package developed in the context of undergraduate mechanical
engineering course on internal combustion engine simulation at the equilibrium thermodynamics
level, also known as 0-D models. It provides types for organizing and storing reciprocating
internal combustion engine core piston-in-cylinder mechanism parameters and related utility
calculations.

`EngineKinematics.jl` is primarily educational and isn't meant for research or production
scenarios.

Currently supported models are:

- `SimpleCR`: a `ℙ <: Base.IEEEFloat`-parametric model for simple crank-rod-piston mechanism.

## Common Design Choices

- All data fields are stored as plain `ℙ <: Base.IEEEFloat` types;
- It is _assumed_ that values are in SI units, i.e., lengths in $m$, volumes in $m^3$, etc.;
- Constructors may accept `Real` and `Quantity{Real}` arguments;
- Types are `functor`s that output commonly used derived quantities;
- Functor argument control whether implicit units are applied to the output.

Therefore typical usage consists in (1) instantiating, and (2) calling the models as functors.

## Examples

### Example 1 – `SimpleCR` engine kinematics from primitive dimensions

`SimpleCR` only stores (i) the crank radius $R$, (ii) the connecting-rod length $L$, (iii) the
piston diameter $D$, and (iv) the engine compression ratio $r$, so the simplest use is to
provide these quantities to a constructor:

```julia
julia> using EngineKinematics

julia> CR = SimpleCR(0.08, 0.24, 0.16, 12)
SimpleCR{Float64}(0.08, 0.24, 0.16, 12.0)

julia> CR()
(R = 0.08, L = 0.24, D = 0.16, r = 12.0, S = 0.16, A = 0.020106192982974676, x0 = 0.014545454545454547, Vdu = 0.0032169908772759484, Vmin = 0.0002924537161159953, Vmax = 0.0035094445933919437, rLR = 3.0, rDS = 1.0)
```

When the `CR` object is called as a `function`, i.e., used as a `functor`, it outputs a named
tuple with the following fields: all the stored fields plus the stroke `S`, the cylinder
cross-section area `A`, the TDC piston-to-head gap `x0`, the piston displaced volume `Vdu`,
the combustion chamber minimum and maximum volumes `Vmin` and `Vmax`, the rod length to crank
radius ratio `rLR`, and the diameter to stroke ratio `rDS`.

Units are output whenever the functor `units` positional argument evaluates to `true` through
`Bool(units)`, meaning `CR(true)` and the shorter call `CR(1)` have the same effect:

```julia
julia> CR(1)
(R = 80.0 mm, L = 240.0 mm, D = 160.0 mm, r = 12.0, S = 160.0 mm, A = 201.06192982974676 cm^2, x0 = 14.545454545454547 mm, Vdu = 3.2169908772759483 L, Vmin = 0.2924537161159953 L, Vmax = 3.509444593391944 L, rLR = 3.0, rDS = 1.0)
```

It is worth noting that although values are internally stored under the conventions above of
plain floats with implied units, the unit-ed output makes use of "engineering" units, such as
$mm$ for parts linear dimensions, as well as $L$ (liters) for engine volumes, etc.

Arbitrary units of consistent dimensions can be specified upon construction:



## Author

Prof. C. Naaktgeboren, PhD. [Lattes](http://lattes.cnpq.br/8621139258082919).

Hermann von Helmholtz Energy Research Group
[DGP](http://dgp.cnpq.br/dgp/espelhogrupo/8462486184187645).

Federal University of Technology, Paraná
[(site)](https://www.utfpr.edu.br/english), Guarapuava Campus.

`NaaktgeborenC <dot!> PhD {at!} gmail [dot!] com`


## License

This project is [licensed](https://github.com/EduThermSci/EngineKinematics.jl/blob/main/LICENSE)
under the MIT license.


## Citations

How to cite this project:

```bibtex
@Misc{2026-NaaktgeborenC-EngineKinematics,
  author       = {C. Naaktgeboren},
  title        = {{EduThermSci/EngineKinematics.jl} -- Reciprocating engine kinematics},
  howpublished = {Online},
  year         = {2026},
  journal      = {GitHub repository},
  publisher    = {GitHub},
  url          = {https://github.com/EduThermSci/EngineKinematics.jl},
  note         = {pre-release 0.1.0 of 2026-06},
}
```

