using Propagators: Cell, propagator, constraint, block,
  constant, quadratic, propagate!
using IntervalArithmetic

# h = gt²/2

function fallduration(t, h)
  block(t, h) do
    g = Cell()
    onehalf = Cell()
    t² = Cell()
    gt² = Cell()
    constant(9.789..9.832)(g)
    constant(1/2..1/2)(onehalf)
    quadratic(t, t²)
    constraint(*)(g, t², gt²)
    constraint(*)(onehalf, gt², h)
  end
end

# s_ba/h_ba == s/h

function similartriangles(s_ba, h_ba, s, h)
  block(s_ba, h_ba, s, h) do
    ratio = Cell()
    constraint(*)(s_ba, ratio, h_ba)
    constraint(*)(s, ratio, h)
  end
end

barometerheight = Cell()
barometershadow = Cell()
buildingheight = Cell()
buildingshadow = Cell()
similartriangles(barometershadow, barometerheight, buildingshadow, buildingheight)

buildingshadow[] = 54.9..55.1
barometerheight[] = 0.3..0.32
barometershadow[] = 0.36..0.37
propagate!()

# Initial guess based on barometer height/shadow
buildingheight[]

falltime = Cell()
fallduration(falltime, buildingheight)
propagate!()

# We have an idea of falltime even before measuring it
falltime[]
# Add our measurement
falltime[] = 2.9..3.1

propagate!()

# Building height with shadow + fall time
buildingheight[]

# We refined both of our measurements
falltime[]
barometerheight[]

# If we know the building height, it refines our measurements further
buildingheight[] = 45..45
propagate!()

falltime[]
barometerheight[]
barometershadow[]
buildingshadow[]
