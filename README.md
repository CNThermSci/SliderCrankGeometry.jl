# EngineKinematics.jl

Educational package for reciprocating engine kinematics

## Description

`EngineKinematics.jl` is a package developed in the context of undergraduate mechanical
engineering course on internal combustion engine simulation at the equilibrium thermodynamics
level, also known as 0-D models. It provides types for organizing and storing reciprocating
internal combustion engine core piston-in-cylinder mechanism parameters and related utility
calculations.

Currently supported models are:

- `SimpleCR`: a `ℙ <: Base.IEEEFloat` parametric model for simple crank-rod-piston mechanism.

`EngineKinematics.jl` is not meant for research or production scenarios

