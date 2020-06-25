using JuMP, MathOptInterface, LinearAlgebra
using CalculusTreeTools, PartiallySeparableNLPModel

using BenchmarkTools

m = Model()
n = 100000
@variable(m, x[1:n])
@NLobjective(m, Min, sum( 100 * (x[j-1]^2 - x[j])^2 + (x[j-1] - 1)^2  for j in 2:n)) #rosenbrock function
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph])
Expr_j = MathOptInterface.objective_expr(evaluator)
expr_tree_j = CalculusTreeTools.transform_to_expr_tree(Expr_j)
complete_expr_tree = CalculusTreeTools.create_complete_tree(expr_tree_j)
x = ones(n)



sps1 = PartiallySeparableNLPModel.deduct_partially_separable_structure(Expr_j, n)
sps2 = PartiallySeparableNLPModel.deduct_partially_separable_structure(expr_tree_j, n)
sps3 = PartiallySeparableNLPModel.deduct_partially_separable_structure(complete_expr_tree, n)


bench_original = @benchmark PartiallySeparableNLPModel.evaluate_SPS(sps3, x)
bench_new = @benchmark PartiallySeparableNLPModel.evaluate_SPS2(sps3, x)
# bench_related_function = @benchmark PartiallySeparableNLPModel.get_related_function(sps3)
# rl_fun = PartiallySeparableNLPModel.get_related_function(sps3)
# bench_xs = @benchmark PartiallySeparableNLPModel.create_empty_3dim_array(rl_fun, Float64)
# xs = PartiallySeparableNLPModel.create_empty_3dim_array(rl_fun, Float64)
# bench_set_xs = @benchmark PartiallySeparableNLPModel.set_different_xs!(sps3,rl_fun,xs,x)
# PartiallySeparableNLPModel.set_different_xs!(sps3,rl_fun,xs,x)


# @code_warntype PartiallySeparableNLPModel.evaluate_SPS2(sps3, x)
# @benchmark PartiallySeparableNLPModel.get_related_vars(sps3)

res_new = PartiallySeparableNLPModel.evaluate_SPS2(sps3, x)
res_original = PartiallySeparableNLPModel.evaluate_SPS(sps3, x)

@show res_new - res_original
@show res_new


# test = ones(100000)
# view_test = view(test, [1:10000;])
# view_test2 = view(test, [25555:25558;])
# @benchmark Array(view_test)
# @benchmark Array(view_test2)
