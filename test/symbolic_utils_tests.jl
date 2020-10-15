using Impero
using Test
using SymbolicUtils
import SymbolicUtils: Chain, Postwalk, Fixpoint

@wrapper a=1 b=2

@testset "symbolic utils swapping" begin
    println("for $a = ", a.data, ", $b = ", b.data)
    println("changing a+b to a*b")
    c = a+b
    check_c = a*b
    r1 = @acrule ~ra + ~rb => ~ra * ~rb
    new_c = Fixpoint(Postwalk(Chain([r1])))(c)
    @test compute(check_c) == compute(new_c)
    println("changing sin(a+b) * sin(a+a+b) to sin(a*b) * sin(a*a*b)")
    c = sin(a+b) * sin(a+a+b)
    check_c = sin(a*b) * sin(a*a*b)
    new_c = Fixpoint(Postwalk(Chain([r1])))(c)
    @test compute(check_c) == compute(new_c)
end
