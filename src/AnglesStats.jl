function get_sigma(phi::Vector{<:Real}, theta::Vector{<:Real})
    return sqrt( inv(length(phi)) * sum( (theta .- phi).^2 ) )
end

function get_sigma(phi, theta)
    return sqrt( inv(length(phi)) * sum( (theta .- phi).^2 ) )
end

function get_sigma_stats_E_t(
    E,t,phi,theta;
    E_vals = [500, 1500, 2500],
    E_step = 1000,
    t_vals = [0.0, 0.083, 2*0.083],
    t_step = 0.083,
    )
    sE = []
    st = []
    for (_E, _t) in zip(E_vals, t_vals)
        println("processing _E = $(_E), _t = $(_t) data")
        indexes_to_keep_E = Int[]
        Threads.@threads for i in eachindex(E)
            if( 
                (_E <= E[i] <= _E+E_step)
              )
              push!(indexes_to_keep_E, i)
            end
        end
        _sE = get_sigma(view(phi, indexes_to_keep_E), view(theta, indexes_to_keep_E))

        indexes_to_keep_t = Int[]
        Threads.@threads for i in eachindex(t)
            if( 
                (_t <= t[i] <= _t+t_step)
              )
              push!(indexes_to_keep_t, i)
            end
        end
        _st = get_sigma(view(phi, indexes_to_keep_t), view(theta, indexes_to_keep_t))

        push!(sE, ( e_range = (_E, _E+E_step), sE = _sE))
        push!(st, ( t_range = (_t, _t+t_step), st = _st))
    end
    return sE, st
end