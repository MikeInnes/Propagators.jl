function propagator(f)
  function (cells...)
    output = last(cells)
    inputs = cells[1:end-1]
    function activate!()
      inputvalues = map(getindex, inputs)
      if !any(isunusable, inputvalues)
        addcontent!(output, f(inputvalues...))
      end
    end
    return Propagator(activate!, inputs)
  end
end

function block(tobuild, inputs...)
  isbuilt = false
  function maybebuild()
    if !(isbuilt || all(isunusable, map(getindex, inputs)))
      tobuild()
      isbuilt = true
    end
  end
  return Propagator(maybebuild, inputs)
end

constant(x) = propagator(() -> x)

function conditional(p, t, f, out)
  Propagator([p, t, f]) do
    predicate = p[]
    predicate != nothing || return
    out[] = predicate ? t[] : f[]
  end
end

switch(p, t, out) = conditional(p, t, Cell(), out)

function constraint(::typeof(*))
  function (x, y, xy)
    propagator(*)(x, y, xy)
    propagator(/)(xy, x, y)
    propagator(/)(xy, y, x)
  end
end

function constraint(::typeof(+))
  function (x, y, xy)
    propagator(+)(x, y, xy)
    propagator(-)(xy, x, y)
    propagator(-)(xy, y, x)
  end
end

function quadratic(x, x²)
  propagator(x -> x^2)(x, x²)
  propagator(sqrt)(x², x)
end
