using DiffEqBiological
using Test

@time begin
  @time @testset "Model Macro" begin include("make_model_test.jl") end
  @time @testset "Gillespie Tests" begin include("gillespie.jl") end
  @time @testset "Test Solvers" begin include("solver_test.jl") end
  @time @testset "Higher Order" begin include("higher_order_reactions.jl") end
  @time @testset "Additional Functions" begin include("func_test.jl") end
  @time @testset "Steady state solver" begin include("steady_state.jl") end
  @time @testset "Mass Action Jumps" begin include("mass_act_jump_tests.jl") end
end

@time begin
  @time @testset "Model Macro (Min)" begin include("make_model_test_min.jl") end
  @time @testset "Gillespie Tests (Min)" begin include("gillespie_min.jl") end
  @time @testset "Test Solvers (Min)" begin include("solver_test_min.jl") end
  @time @testset "Higher Order (Min)" begin include("higher_order_reactions_min.jl") end
  @time @testset "Additional Functions (Min)" begin include("func_test_min.jl") end
  @time @testset "Steady state solver (Min)" begin include("steady_state_min.jl") end
  @time @testset "Mass Action Jumps (Min)" begin include("mass_act_jump_tests_min.jl") end
end