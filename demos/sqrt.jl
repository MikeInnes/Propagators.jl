using Propagators: Cell, propagator, propagate!, block, constant, switch

# function sqrt_heron(x)
#   g = x/x
#   while !(g^2 ≈ x)
#     g = (x/g+g)/2
#   end
#   return g
# end

function heron_step(x, g, h)
  block(x, g) do
    xdg = Cell()
    gpxdg = Cell()
    two = Cell()
    constant(2)(two)
    propagator(/)(x, g, xdg)
    propagator(+)(g, xdg, gpxdg)
    propagator(/)(gpxdg, two, h)
  end
end

function sqrt_network(x, answer)
  block(x) do
    one = Cell()
    constant(1)(one)
    sqrt_iter(x, one, answer)
  end
end

function sqrt_iter(x, g, answer)
  block(x, g) do
    done = Cell()
    notdone = Cell()
    xifnotdone = Cell()
    gifnotdone = Cell()
    newg = Cell()
    propagator((g, x) -> g^2 ≈ x)(g, x, done)
    propagator(!)(done, notdone)
    switch(done, g, answer)
    switch(notdone, x, xifnotdone)
    switch(notdone, g, gifnotdone)
    heron_step(xifnotdone, gifnotdone, newg)
    sqrt_iter(xifnotdone, newg, answer)
  end
end

# x = Cell()
# y = Cell()
# sqrt_network(x, y)
# x[] = 2
# propagate!()
# y[]
