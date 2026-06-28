# SliderCrankGeometry.jl

Slider-crank geometry descriptors for internal combustion engines.

## Description

`SliderCrankGeometry.jl` is a package developed in the context of undergraduate mechanical
engineering course on internal combustion engine simulation at the equilibrium thermodynamics
level, also known as 0-D models. It provides types for organizing and storing reciprocating
internal combustion engine core piston-in-cylinder mechanism parameters and related utility
calculations.

Currently supported models are:

- `MonoCylinder{ℙ <: Base.IEEEFloat}`: a simple crank-rod-piston mechanism for mono-cylinder
  reciprocating engines.

## Common Design Choices

- All data fields are stored as plain `ℙ <: Base.IEEEFloat` types;
- It is _assumed_ that values are in SI units, i.e., lengths in $m$, volumes in $m^3$, etc.;
- Constructors accept _any_ combination of `Real` and `Quantity{<:Real}` arguments;
- Types are `functor`s that output commonly used derived quantities as `Base.Pairs`;
- Functor argument control whether implicit units are applied to the output.

Therefore typical usage consists in (1) instantiating, and (2) calling the models as functors.

## Examples

### Example 1 – `MonoCylinder` engine kinematics from primitive dimensions

`MonoCylinder` only stores (i) the crank radius $R$, (ii) the connecting-rod length $L$, (iii) the
piston diameter $D$, and (iv) the engine compression ratio $r$, so the simplest use is to
provide these quantities to a constructor:

```julia
julia> using SliderCrankGeometry

julia> MC = MonoCylinder(0.08, 0.24, 0.16, 12)
MonoCylinder{Float64}(0.08, 0.24, 0.16, 12.0)

julia> MC()
pairs(::NamedTuple) with 12 entries:
  :R    => 0.08
  :L    => 0.24
  :D    => 0.16
  :r    => 12.0
  :S    => 0.16
  :A    => 0.0201062
  :x0   => 0.0145455
  :Vdu  => 0.00321699
  :Vmin => 0.000292454
  :Vmax => 0.00350944
  :rLR  => 3.0
  :rDS  => 1.0
```

The `MonoCylinder` functor returns a `Base.Pairs`, which can be conveniently converted into `NamedTuple` with:

```julia
julia> (; MC()...)
(R = 0.08, L = 0.24, D = 0.16, r = 12.0, S = 0.16, A = 0.020106192982974676, x0 = 0.014545454545454547, Vdu = 0.0032169908772759484, Vmin = 0.0002924537161159953, Vmax = 0.0035094445933919437, rLR = 3.0, rDS = 1.0)
```

Units are output whenever the functor `units` positional argument evaluates to `true` through
`Bool(units)`, meaning `MC(true)` and the shorter call `MC(1)` have the same effect:

```julia
julia> MC(1)
pairs(::NamedTuple) with 12 entries:
  :R    => 80.0 mm
  :L    => 240.0 mm
  :D    => 160.0 mm
  :r    => 12.0
  :S    => 160.0 mm
  :A    => 201.062 cm^2
  :x0   => 14.5455 mm
  :Vdu  => 3.21699 L
  :Vmin => 0.292454 L
  :Vmax => 3.50944 L
  :rLR  => 3.0
  :rDS  => 1.0
```

It is worth noting that although values are internally stored under the conventions above of
plain floats with implied units, the unit-ed output makes use of "engineering" units, such as
$mm$ for parts linear dimensions, as well as $L$ (liters) for engine volumes, etc.

Arbitrary units of consistent dimensions can be specified upon construction:

```julia
julia> mc = MonoCylinder(80u"mm", 240u"mm", 160u"mm", 12.0)
MonoCylinder{Float64}(0.08, 0.24, 0.16, 12.0)

julia> mc == MC
true
```

### Example 2 – `MonoCylinder` engine kinematics from keyword arguments

- `MonoCylinder` can be instantiated from sufficient keyword arguments (`kwargs`);
- This is successful if `(:R, :L, :D, :r)` can be determined from the `kwargs`;
- `kwargs ∈ (:R, :L, :D, :r, :S, :A, :x0, :Vdu, :Vmin, :Vmax, :rLR, :rDS, :Vd, :z)`;

Suppose one wants to describe the kinematics of a 4-cylinder, square ($r_{DS} = 1$), $2.0 L$
engine with a $11:1$ compression ratio, and rod length to crank radius ratio $r_{LR} = 3.5$,
then:

```julia
julia> MC = MonoCylinder(z = 4, rDS = 1, Vd = 2u"L", rLR = 3.5, r = 11)
MonoCylinder{Float64}(0.04301270069140499, 0.15054445241991746, 0.08602540138280998, 11.0)
```

Suppose further that we'd want to use IEEE-754 single precision floats. We could `convert` the
`MonoCylinder{Float64}` type into a `MonoCylinder{Float32}` one either explicitly, implicitly, or
through a convenience conversion, as:

```julia
julia> convert(MonoCylinder{Float32}, MC)
MonoCylinder{Float32}(0.0430127f0, 0.15054445f0, 0.0860254f0, 11.0f0)

julia> MonoCylinder{Float32}[MC][1]
MonoCylinder{Float32}(0.0430127f0, 0.15054445f0, 0.0860254f0, 11.0f0)

julia> Float32(MC)
MonoCylinder{Float32}(0.0430127f0, 0.15054445f0, 0.0860254f0, 11.0f0)
```

The functor output is consistent with the internal floating point precision:

```julia
julia> Float32(MC)(true)[:S]
86.0254f0 mm
```

## Author

Prof. C. Naaktgeboren, PhD. [Lattes](http://lattes.cnpq.br/8621139258082919).

Hermann von Helmholtz Energy Research Group
[DGP](http://dgp.cnpq.br/dgp/espelhogrupo/8462486184187645).

Federal University of Technology, Paraná
[(site)](https://www.utfpr.edu.br/english), Guarapuava Campus.

`NaaktgeborenC <dot!> PhD {at!} gmail [dot!] com`


## License

This project is [licensed](https://github.com/CNThermSci/SliderCrankGeometry.jl/blob/main/LICENSE)
under the MIT license.


## Citations

Please, refer to the `CITATION.bib` file on how to cite this project.
