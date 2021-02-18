struct Contradiction end
const contradiction = Contradiction()

Base.show(io::IO, ::Contradiction) = print(io, "contradiction")

isunusable(x) = x == nothing || x == contradiction

# Scheduler

const workqueue = WorkQueue()

alert!() = return
alert!(ps...) = push!(workqueue, ps...)

function propagate!()
  while !isempty(workqueue)
    p = pop!(workqueue)
    p.activate!()
  end
end

# Cells

mutable struct Cell
  neighbours
  content
end

Cell() = Cell(Set(), nothing)

function cellmerge(content, increment)
  (content == nothing || increment == contradiction) && return increment
  (increment == nothing || content == contradiction) && return content
  content == increment && return content
  return contradiction
end

function addcontent!(cell, increment)
  answer = cellmerge(cell.content, increment)
  if cell[] == answer
    return
  elseif answer == contradiction
    error("Contradiction")
  else
    cell.content = answer
    alert!(cell.neighbours...)
    return
  end
end

Base.setindex!(c::Cell, value) = addcontent!(c, value)
Base.getindex(c::Cell) = c.content

# Propagators

struct Propagator
  inputs
  activate!
  function Propagator(inputs, activate!)
    me = new(inputs, activate!)
    for cell in inputs
      push!(cell.neighbours, me)
    end
    alert!(me)
    return me
  end
end

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
    return Propagator(inputs, activate!)
  end
end

function compund_propagator(inputs, tobuild)
  isbuilt = false
  function maybebuild()
    if !(isbuilt || all(isunusable, map(getindex, inputs)))
      tobuild()
      isbuilt = true
    end
  end
  return Propagator(inputs, maybebuild)
end