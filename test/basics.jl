using Propagators, Test
using Propagators: Cell, propagator, propagate!

let
  inc(x) = x+1

  x = Cell()
  y = Cell()

  propagator(inc)(x, y)

  x[] = 3
  propagate!()

  @test y[] == 4
end

include("../demos/sqrt.jl")

let
  x = Cell()
  y = Cell()
  sqrt_network(x, y)
  x[] = 2
  propagate!()
  @test y[] ≈ sqrt(2)
end

using Propagators: constraint, quadratic

let
  x = Cell()
  y = Cell()
  quadratic(x, y)
  x[] = 2
  propagate!()
  @test y[] == 4

  x = Cell()
  y = Cell()
  quadratic(x, y)
  y[] = 4
  propagate!()
  @test x[] == 2
end

let
  x = Cell()
  y = Cell()
  z = Cell()
  constraint(*)(x, y, z)
  x[] = 2
  y[] = 3
  propagate!()
  @test z[] == 6

  x = Cell()
  y = Cell()
  z = Cell()
  constraint(*)(x, y, z)
  x[] = 2
  z[] = 6
  propagate!()
  @test y[] == 3
end

let
  x = Cell()
  y = Cell()
  z = Cell()
  constraint(*)(x, y, z)
  x[] = 2..5
  y[] = 3..6
  propagate!()
  @test z[] == x[]*y[]

  z[] = interval(5, 10)
  length(Propagators.workqueue)
  propagate!()
  @test x[] == interval(2, 10/3)
  @test y[] == interval(3, 5)
end
