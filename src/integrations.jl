cellmerge(x::Number, y::Number) = x ≈ y ? x : contradiction

using IntervalArithmetic

function cellmerge(x::Interval, y::Interval)
  xy = intersect(x, y)
  isempty(xy) ? contradiction : xy
end
