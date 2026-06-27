## v0.2.0

- Constructors accept _any_ combination of `Real` and `Quantity{<:Real}` arguments;
- Types are `functor`s that output commonly used derived quantities as `Base.Pairs`;
- `SimpleCR` can be instantiated from sufficient keyword arguments (`kwargs`);
- This is successful if `(:R, :L, :D, :r)` can be determined from the `kwargs`;
- `kwargs ∈ (:R, :L, :D, :r, :S, :A, :x0, :Vdu, :Vmin, :Vmax, :rLR, :rDS, :Vd, :z)`;
- All 188 tests passing.

## v0.1.0

- Initial release.
