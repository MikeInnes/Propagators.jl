struct Contradiction end
const contradiction = Contradiction()

Base.show(io::IO, ::Contradiction) = print(io, "contradiction")

isunusable(x) = x == nothing || x == contradiction

# Scheduler

const workqueue = WorkQueue()

alert!() = return
alert!(ps...) = push!(workqueue, ps...)

function propagate!()
  try
    while !isempty(workqueue)
      p = pop!(workqueue)
      p.activate!()
    end
  finally
    empty!(workqueue)
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
  function Propagator(activate!, inputs)
    me = new(inputs, activate!)
    for cell in inputs
      push!(cell.neighbours, me)
    end
    alert!(me)
    return me
  end
end
