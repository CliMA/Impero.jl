using Plots
import Plots: plot
export plot

plot(a::AbstractExpression) = plot(to_expr(a), shape = :circle, fontsize=10, shorten=0.01, axis_buffer=0.15)
plot(a::Equation) = plot(to_expr(a), shape = :circle, fontsize=10, shorten=0.01, axis_buffer=0.15)