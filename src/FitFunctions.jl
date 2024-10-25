using Optim, SpecialFunctions
function fit_chi_square_mle(x_data, y_data, initial_params = [1.0, 1.0, 1.0], lower_bounds = [0.001, 0.001, 0.001])
    # modified chisquare function - (slight shift in x-direction adjusted by α)
    function fit_func(x_data, p)
        k, α = p
        1/(2^(k/2) * gamma(k/2)) * (x_data*α)^(k/2 - 1) * exp(-(x_data*α)/2)
    end

    function neg_log_likelihood(params, x_data, y_data)
        k, α, σ = params
        y_pred = map(x->fit_func(x, [k, α]), x_data)
    
        # Log likelihood is defined as normally distributed error about prediction
        return sum(@. log(σ * √(2 * π)) + (y_data .- y_pred).^2 / (2 * σ^2))
    end

    @show result = optimize(params -> neg_log_likelihood(params, x_data, y_data), lower_bounds, Inf, initial_params, Fminbox(BFGS()))
  
    @show fitted_k, fitted_α, fitted_sigma = Optim.minimizer(result)

    return fitted_k, fitted_α,  fitted_sigma
end

