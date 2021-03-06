"""
```
 set_regime_val!(p::Parameter{S},
    i::Int64, v::S; override_bounds::Bool = false) where S <: Float64
```

sets the value in regime `i` of `p` to be `v`. By default, we enforce
the bounds that are currently in `p`, but the bounds can be ignoerd by
setting `override_bounds = true`.
"""
function set_regime_val!(p::Parameter{S},
                         i::Int64, v::S; override_bounds::Bool = false) where S <: Float64
    if !haskey(p.regimes, :value)
        p.regimes[:value] = OrderedDict{Int64,S}()
    end
    if p.valuebounds[1] <= v <= p.valuebounds[2] || override_bounds
        p.regimes[:value][i] = v
    else
        throw(ParamBoundsError("New value of $(string(p.key)) ($(v)) is out of bounds ($(p.valuebounds))"))
    end
    return v
end

"""
```
function regime_val(p::Parameter{S}, i::Int64) where S <: Float64
```

returns the value of `p` in regime `i`.
"""
function regime_val(p::Parameter{S}, i::Int64) where S <: Float64
    if !haskey(p.regimes, :value) || !haskey(p.regimes[:value], i)
        @error "get_regime_val(), Input Error: No regime $(i)"
    end
    return p.regimes[:value][i]
end

"""
```
function toggle_regime!(p::Parameter{S}, i::Int64) where S <: Float64
```

changes the fields of `p` to regime `i`.

For example, if

```
p.regimes[:value] = OrderedDict{Int, Any}(1 => 1, 2 => 3)
```

then `toggle_regime!(p, 1)` will cause `p.value = 1` and `toggle_regime!(p, 2)`
will cause `p.value = 3`.
"""
function toggle_regime!(p::Parameter{S}, i::Int64) where S <: Float64
    for field in [:value, :valuebounds, :transform_parameterization,
                  :transform, :prior, :fixed]
        if haskey(p.regimes, field) && haskey(p.regimes[field], i)
            if field == :value
                p.value = p.regimes[field][i]
            elseif field == :valuebounds
                p.valuebounds = p.regimes[field][i]
            elseif field == :transform_parameterization
                p.transform_parameterization = p.regimes[field][i]
            elseif field == :transform
                p.transform = p.regimes[:transform][i]
            elseif field == :prior
                p.prior = p.regimes[:transform][i]
            elseif field == :fixed
                p.transform = p.regimes[:transform][i]
            end
        elseif haskey(p.regimes, field) && !haskey(p.regimes[field], i)
            error("Regime $i for field $field not found")
        end
    end
end
