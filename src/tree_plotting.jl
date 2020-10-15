using Plots
import Plots: plot
export plot

function plot(a::AbstractExpression)
    return plot(to_expr(a))
end