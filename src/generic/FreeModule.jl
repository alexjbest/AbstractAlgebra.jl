###############################################################################
#
#   FreeModule.jl : Free modules over rings
#
###############################################################################

export FreeModule, free_module_elem

###############################################################################
#
#   Basic manipulation
#
###############################################################################

parent_type(::Type{free_module_elem{T}}) where T <: Union{RingElement, NCRingElem} = FreeModule{T}

base_ring(M::FreeModule{T}) where T <: Union{RingElement, NCRingElem} = M.base_ring::parent_type(T)

base_ring(v::free_module_elem{T}) where T <: Union{RingElement, NCRingElem} = base_ring(parent(v))

elem_type(::Type{FreeModule{T}}) where T <: Union{RingElement, NCRingElem} = free_module_elem{T}

parent(m::free_module_elem{T}) where T <: Union{RingElement, NCRingElem} = m.parent

function check_parent(m1::free_module_elem{T}, m2::free_module_elem{T}) where T <: Union{RingElement, NCRingElem}
    parent(m1) != parent(m2) && ("Incompatible free modules")
end

function isdomain_type(::Type{free_module_elem{T}}) where T <: Union{RingElement, NCRingElem}
   return isdomain_type(T)
end

function isexact_type(a::Type{free_module_elem{T}}) where T <: Union{RingElement, NCRingElem}
   return isexact_type(T)
end

@doc Markdown.doc"""
    rank(M::FreeModule{T}) where T <: Union{RingElement, NCRingElem}
> Return the rank of the given free module.
"""
rank(M::FreeModule{T}) where T <: Union{RingElement, NCRingElem} = M.rank

@doc Markdown.doc"""
    dim(M::FreeModule{T}) where T <: FieldElement
> Return the dimension of the given vector space.
"""
dim(M::FreeModule{T}) where T <: FieldElement = M.rank

ngens(M::FreeModule{T}) where T <: Union{RingElement, NCRingElem} = M.rank

function gens(N::FreeModule{T}) where T <: Union{RingElement, NCRingElem}
   return [gen(N, i) for i = 1:ngens(N)]
end

function gen(N::FreeModule{T}, i::Int) where T <: Union{RingElement, NCRingElem}
   R = base_ring(N)
   return N([(j == i ? one(R) : zero(R)) for j = 1:ngens(N)])
end

###############################################################################
#
#   String I/O
#
###############################################################################

function show(io::IO, M::FreeModule{T}) where T <: Union{RingElement, NCRingElem}
   print(io, "Free module of rank ")
   print(io, rank(M))
   print(io, " over ")
   show(IOContext(io, :compact => true), base_ring(M))
end

function show(io::IO, M::FreeModule{T}) where T <: FieldElement
   print(io, "Vector space of dimension ")
   print(io, dim(M))
   print(io, " over ")
   show(IOContext(io, :compact => true), base_ring(M))
end

function show(io::IO, a::free_module_elem)
   print(io, "(")
   M = parent(a)
   for i = 1:rank(M) - 1
      print(IOContext(io, :compact => true), a.v[1, i])
      print(io, ", ")
   end
   if rank(M) > 0
      print(IOContext(io, :compact => true), a.v[1, rank(M)])
   end
   print(io, ")")
end

###############################################################################
#
#   Unary operators
#
###############################################################################

function -(m::free_module_elem)
   M = parent(m)
   return M(-m.v)
end

###############################################################################
#
#   Binary operators
#
###############################################################################

function +(m1::free_module_elem{T}, m2::free_module_elem{T}) where T <: Union{RingElement, NCRingElem}
   check_parent(m1, m2)
   M = parent(m1)
   return M(m1.v + m2.v)
end

function -(m1::free_module_elem{T}, m2::free_module_elem{T}) where T <: Union{RingElement, NCRingElem}
   check_parent(m1, m2)
   M = parent(m1)
   return M(m1.v - m2.v)
end

###############################################################################
#
#   Ad hoc binary operators
#
###############################################################################

function *(m::free_module_elem{T}, c::T) where T <: Union{RingElem, NCRingElem}
   parent(c) != base_ring(m) && error("Incompatible scalar")
   M = parent(m)
   return M(m.v*c)
end

function *(c::T, m::free_module_elem{T}) where T <: Union{RingElem, NCRingElem}
   parent(c) != base_ring(m) && error("Incompatible scalar")
   M = parent(m)
   return M(c*m.v)
end

function *(m::free_module_elem{T}, c::U) where {T <: Union{RingElement, NCRingElem}, U <: Union{Rational, Integer}}
   M = parent(m)
   return M(m.v*c)
end

function *(c::U, m::free_module_elem{T}) where {T <: Union{RingElement, NCRingElem}, U <: Union{Rational, Integer}}
   M = parent(m)
   return M(c*m.v)
end

###############################################################################
#
#   Comparison
#
###############################################################################

function ==(m1::free_module_elem{T}, m2::free_module_elem{T}) where T <: Union{RingElement, NCRingElem}
   check_parent(m1, m2)
   return m1.v == m2.v
end

###############################################################################
#
#   Parent object call overload
#
###############################################################################

function (M::FreeModule{T})(a::Vector{T}) where T <: Union{RingElement, NCRingElem}
   length(a) != rank(M) && error("Number of elements does not equal rank")
   R = base_ring(M)
   v = matrix(R, 1, length(a), a)
   z = free_module_elem{T}(v)
   z.parent = M
   return z
end

function (M::FreeModule{T})(a::AbstractAlgebra.MatElem{T}) where T <: Union{RingElement, NCRingElem}
   ncols(a) != rank(M) && error("Number of elements does not equal rank")
   nrows(a) != 1 && error("Matrix should have single row")
   z = free_module_elem{T}(a)
   z.parent = M
   return z
end

###############################################################################
#
#   FreeModule constructor
#
###############################################################################

function FreeModule(R::NCRing, rank::Int; cached::Bool = true)
   T = elem_type(R)
   return FreeModule{T}(R, rank, cached)
end

