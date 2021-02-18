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
