#import "@preview/frame-it:1.2.0": *

#set document(
  title: "Polyhedra & integer programming",
  author: "Guillaume Dalle",
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
)

#set par(
  justify: true,
)

#set page(numbering: "1")

#set math.equation(numbering: "(1)")

#show title: set align(center)
#show title: set block(below: 1em)

#set heading(numbering: "I.1.a.")
#show heading: set block(below: 1em)

#let (definition, proposition, theorem, remark, example, exercise, algorithm) = frames(
  definition: ("Definition", aqua),
  proposition: ("Proposition", orange),
  theorem: ("Theorem", red),
  remark: ("Remark", yellow),
  example: ("Remark", green),
  exercise: ("Exercise", fuchsia),
  algorithm: ("Algorithm", gray),
)
// This is necessary. Don't forget this!
#show: frame-style(styles.boxy)

#title(context document.title)

#align(center)[
  #text(context document.author.at(0)) \
  _MPRO -- DECO_
]

#outline()

All of the content is taken from @confortiIntegerProgramming2014.

#pagebreak()

= Solving integer programs

#definition[Integer program][
  Let $A in bb(R)^(m times n)$, $b in bb(R)^m$ and $c in bb(R)^n$.
  Consider index sets $I,C subset.eq [n]$ such that $I union C = [n]$ and $I inter C = emptyset$.
  We define the _Mixed Integer Linear Program_ (IP) as
  $
    max_x quad c^top x quad "subject to" quad A x <= b, x_I in bb(Z)^I, x_C in bb(R)^C
  $ <IP>
]

== Branch & cut

#definition[Continuous relaxation][
  The continous relaxation of the IP from @IP is the _Linear Program_ (LP)
  $
    max_x quad c^top x quad "subject to" quad A x <= b, x in bb(R)^n
  $
]

Draw relaxation.

#algorithm[Branch & cut][
  The standard algorithm for solving IPs is branch & cut, which builds a search tree iteratively starting from the original problem:
  1. Pick a node in the search tree and solve its continuous relaxation.
  2. If the continuous solution is integer, update best-known solution and prune.
  3. If the continuous solution is worse than the best-known integer solution, prune.
  3. Otherwise, strengthen the formulation through cuts.
  4. Branch to divide the feasible region into a partition and add corresponding nodes to the search tree.
]

The goal of cuts is bringing the continous LP closer to the original IP in terms of bound quality.
This is key for practical efficiency of the method.

== Structure of the feasible set

#remark[Convex hull doesn't matter][
  Given a set $S$, maximizing a linear objective on $S$ or $"conv"(S)$ yields the same value.
]

#definition[Perfect formulation][
  A perfect formulation of a set $S$ is a set of linear inequalities such that $"conv"(S) = {x : A x <= b}$.
]

#proposition[Bounded integer feasible set][
  Let $P = {x in bb(R)^n: A x <= b}$ and $S = P inter bb(Z)^n$.
  If $P$ is a bounded polyhedron, then $"conv"(S)$ is a bounded polyhedron.
]

_Proof_:

If $P$ is bounded, $S$ is finite, so it $"conv"(S)$ is the convex hull of a finite number of points with integer coordinates.
By Minkowski-Weyl, it is a bounded polyhedron.

#theorem[Meyer's theorem][
  Let $P = {x in bb(R)^n : A x <= b}$ be a rational polyhedron (where $A$ and $b$ have rational coefficients).
  If $S = P inter (bb(Z)^I times bb(R)^C)$, then $"conv"(S)$ is a rational polyhedron too.
]

= Polyhedral theory

== Basics

#definition[Polyhedra][
  A _polyhedron_ $P$ is an intersection of finitely many half-spaces: $ P = {x in bb(R)^n : A x <= b} $
]

#definition[Cones][
  - A _cone_ $C$ is a set that is stable by positive scaling
  - A _finitely generated cone_ is defined by $C = {x in bb(R)^n: exists mu >= 0, x = R mu}$
  - A _polyhedral cone_ is a cone that is also a polyhedron (defined by $b = 0$)
]

#definition[Polytopes][
  A _polytope_ $Q$ is the convex hull of a finite set of vectors.
]

#theorem[Minkowski-Weyl for cones][
  A cone $C$ is polyhedral if and only if it is finitely generated.
]

_Proof_:

Supppose $C$ is finitely generated.
By Fourier elimination we can obtain a polyhedral representation.

Now suppose $C$ is polyhedral:
1. By Farkas' lemma $C^*$ (the dual cone) is finitely generated.
2. By the first point, $C^*$ is polyhedral.
3. Because $bb(R)_+^n$ is self-dual, $C$ is finitely generated.

#theorem[Minkowski-Weyl for polytopes][
  A set $P$ is a polyhedron if and only if $P = Q + C$ where $Q$ is a polytope and $C$ is a finitely generated cone.
]

_Proof_:

Suppose $P = {A x <= b}$.
$P$ can be represented in higher dimension as the intersection of a cone with a hyperplan: $P = {(x, 1): x in C_P}$ where $ C_P = {(x, y) in bb(R)^(n+1): A x - b y <= 0, y >= 0} $
We know that $C_P$ is finitely generated: $C_P = "cone"{(r_1, s_1), dots, (r_k, s_k)}$.
Any $x in P$ can be written as $x = sum_i mu_i r_i$ with $mu_i >= 0$ and $sum_i mu_i s_i = 1$.
Thus we have
$ x = sum_(i: s_i > 0) underbrace(mu_i s_i, lambda_i) (r_i / s_i) + sum_(i: s_i = 0) mu_i r_i $
Defining $v_i = mu_i / s_i$, we get $P = "conv"{v_k} + "cone"{r_ell}$.

Now suppose $P = "conv"{v_k} + "cone"{r_ell}$ and define $C_P = "cone" {(v_k, 1)} union {(r_ell, 0)}$.
That cone is finitely generated, so it is polyhedral: there exist $A$ and $b$ such that $C_P = {(x, y) in bb(R)^n: A x - b y <= 0}$.
Therefore, $P = {x in bb(R)^n: A x - b = 0}$.

#example[Flow polyhedron][
  The flow polyhedron is the sum of the polytope of paths and the cone of circulations.
]

#definition[Recession cone, lineality space][
  Given a non-empty polyhedron $P$, we define
  - its _recession cone_ $"rec"(P) = {r in bb(R)^n: x + lambda r in P thick "for all" x in P, lambda >= 0}$ (set of rays of the polyhedron)
  - its _lineality space_ $"lin"(P) = {r in bb(R)^n: x + lambda r in P thick "for all" x in P, lambda in bb(R)}$ (which is ${0}$ when the polyhedron is pointed)
]

#proposition[Links with Minkowski-Weyl][
  Let $P = "conv"{v_k} + "cone"{r_ell} = {x: A x <= b}$ be a non-empty polyhedron.
  Then
  - $"rec"(P) = {r: A r <= 0} = "cone"{r_ell}$
  - $"lin"(P) = {r: A r = 0}$.
]

_Proof_:

- $"rec"(P) = {r: A r <= 0}$ is obvious.
- If $r in "cone"{v_k}$ then since $P = "conv"{v_k} + "cone"{r_ell}$ we have $x + lambda r in P$ for all $x in P$ and $lambda >= 0$. If $r in.not "cone"{r.ell}$, then $"dist"(x, "cone"{r_ell}) > 0$. Given $x in "conv"{v_k}$ we have $x + lambda r in P$ for all $lambda >= 0$. So what? /* TODO: figure this one out */
- $"lin"(P) = "rec"(P) inter -"rec"(P)$

== Polyhedron dimension

#definition[Affine independence][
  - Points $x_0, dots, x_q$ are _affinely independent_ if the only solution to $sum_(j=0)^q lambda_j x_j = 0$ and $sum_(j=0)^q lambda_j = 0$ is $lambda_0 = dots = lambda_q = 0$.
  - The _dimension_ of a set $S$ is the maxiumum number of affinely independent points inside $S$.
  - The _affine hull_ $"aff"(S)$ of a set $S$ is the minimal affine subspace containing it.
]

#definition[Implicit equality][
  We say that $a_i x <= b$ is an implicit inequality in the system $A x <= b$ if $a_i x = b_i$ is satisfied for every solution.
  We denote by $A^= x <= b^=$ the subsystem of all implicit equalities (indexed by $I^=$) and by $A^< x <= b^<$ the rest (indexed by $I^<$).
  So $ P = {x: A^= x = b^=, A^< x <= b^<} = {x: A^= x <= b^=, A^< x <= b^<} $
]

#remark[Existence of strictly feasible point][
  If $P eq.not emptyset$, then $P$ contains a point $overline(x)$ such that $A^< overline(x) < b^<$.
]

_Proof_:

There is a strictly satisfying point for each constraint that is not an implicit equality. Take the average.

#theorem[Affine hull][
  Let $P = {x in bb(R)^n: A x <= b}$ be a non-empty polyhedron.
  $ "aff"(P) = {x in bb(R)^n: A^= x = b^=} quad "and" quad "dim"(P) = n - "rank"(A^=) $
]

_Proof_:

We trivially have $P subset.eq {x: A^= x = b^=}$ and the latter is an affine space, so $"aff"(P)$ satisfies the same inclusion.
Also, ${x: A^= x = b^=} subset.eq {x: A^= x <= b^=}$.

Conversely, let $hat(x) in {x: A^= x <= b^=}$.
We know there is a strictly satisfying point $tilde(x) in P$ such that $A^< tilde(x) < b^<$ and $A^= tilde(x) = b^=$.
There exists $epsilon > 0$ small enough such that $z = tilde(x) + epsilon(hat(x) - tilde(x))$ satisfies $A^< z <= b^<$ and still $A^= z <= b^=$, so $z in P$.
Thus, the whole line linking $tilde(x)$ and $z$ is contained in $"aff"(P)$, hence $hat(x) in "aff"(P)$.

And finally $dim("aff"(P)) = n - "rank"(A^=)$.

#definition[Full-dimensional][
  A polyhedron $P subset.eq bb(R)^n$ is full-dimensional if $"dim"(P) = n$.
]

#remark[Identifying the dimension of a set][
  We give two methods to prove that $dim(S) = k$:
  1. Find a system $A x = b$ such that $S subset.eq {x : A x = b}$ and $"rank"(A) = n-k$, and find $k+1$ affinely independent points in $S$.
  2. Same first step but then prove that every other equality satisfied by all $x in S$ can be obtained from combinations of $A x = b$ (this means that every affine space containing $S$ also contains ${x : A x = b}$)
]

#exercise[Knapsack polytope][
  The knapsack polytope is $P = "conv"{x in {0, 1}^n: a^top x <= b}$ where $a in bb(R)_+^n$ and $b > 0$.
  Show that $dim(P) = n - |J|$ where $J = {j: a_j > b}$.
]

Since $P subset.eq {x in bb(R)^n: x_j = 0 "for all" j in J}$, we have $dim(P) <= n - |J|$.
On the other hand, if $j in.not J$, then $x = e_j in P$.
Since the origin is in $P$ too, we have $n-|J|+1$ affinely independent points in there.

#exercise[Hamiltonian path polytope][
  The Hamiltonian path polytope $P$ of a graph $G = (V, E)$ is the convex hull of the incidence vectors of the Hamiltonian paths of $G$ (those that go exactly once through each node).
  Show that if $G$ is the complete graph on $n$ nodes, $dim(P) = binom(n, 2) - 1$.
]

All Hamiltonian path incidence vectors $x$ satisfy $sum_e x_e = n-1$.
Thus $dim(P) <= binom(n, 2) - 1$.
Let $alpha^top x = beta$ be any other equality satisfied by all $x in P$.
It suffices to prove that $alpha_e = alpha_e'$.
Let $T$ be a Hamiltonian tour containing both $e$ and $e'$.
Then $T backslash {e}$ and $T backslash {e'}$ are both Hamiltonian paths, and their incidence vectors satisfy $alpha^top x = alpha^top x' = beta$, so $0 = alpha_e - alpha_e'$.

== Faces

#definition[Valid inequality][
  An inequality $c^top x <= delta$ is _valid_ for the set $P$ if it is satisfied by every point in $P$.
]

#theorem[Valid inequalities are combinations][
  An inequality $c^top x <= delta$ is valid for $P = {x: A x <= b}$ if and only if there exists $u >= 0$ such that $c = sum_i u_i a_i$ and $sum_i u_i b_i <= delta$.
]

_Proof_:

If $(c, delta)$ is a positive combination of $(A, b)$, the inequality is obviously valid.

If $c^top x <= delta$ is valid, then $max_(x in P) c^top x$ admits a finite optimum with value $delta' <= delta$.
Let $u$ be a dual optimal solution: it is such that $A^top u = c$ and $b^top u = delta' <= d$.

#definition[Face][
  - A _face_ of a polyhedron $P$ is a set of the form $P = P inter {x: c^top x = delta}$ where $c^top x <= delta$ is a valid inequality for $P$.
  - If a valid inequality defines a face, the hyperplane ${c^top x = delta}$ is called a _supporting hyperplane_.
  - A face $F$ is _proper_ if $F eq.not emptyset$ and $F eq.not P$.
  - A _facet_ is an inclusionwise-maximal, proper face of $P$.
]

Draw simple examples.

#theorem[Characterization of faces][
  Let $P = {x: A x <= b}$ be a non-empty polyhedron with constraint set $M$.
  For any $I subset.eq M$ with $J = M backslash I$, $ F_I = {x: A^I x = b_I, A^J x <= b_J} $ is a face of $P$.
  Conversely, any non-empty face of $P$ is equal to $F_I$ for some $I$.
]

_Proof_:

Let $I subset.eq M$.
We pick $c = sum_(i in I) a_i$ and $delta = sum_(i in I) b_i$ to define the face $F = P inter {x: c^top x = delta}$.
Obviously $F_I subset.eq P$ and any $x in F_I$ satisfies $c^top x = sum_(i in I) a_i^top x = sum_i b_i = delta$, so $F_i subset.eq F$.
Let $x in F$: we know that $a_j^top x <= b_j$ for all $j in J = M backslash I$.
If there was an $i in I$ such that $a_i^top x < b_i$, we would have $c^top x < delta$, thus $x$ would not be in $F$.
Therefore, $x in F_I$.
We conclude that $F_I = I$, and so $F$ is a face.

Conversely, let $F$ be a non-empty face of $P$.
$F$ is the set of optimal primal solutions to $max_(x in P) c^top x$.
Let $u$ be an optimal dual solution to that linear program. $min_(u >= 0, A^top u = c) b^top u$
The complementary slackness condition $u_i (a_i^top x - b_i) = 0$ holds for all $i in M$ if and only if $x in F$.
Thus, with $I = {i in M: u_i > 0}$, we have $x in F$ iff $x in P$ and $a_i^top x = b_i$ for all $i in I$.

#proposition[Facts about faces][
  Let $P$ be a polyhedron.
  - The set of faces is finite.
  - The set of faces is stable by intersection.
  - Two faces are distinct iff they have different affine hulls.
  - If $F' subset F$ then $dim(F') < dim(F)$.
  - $"lin"(F) = "lin"(P)$
]

#definition[Reundant constraint][
  Given a polyhedron $P = {x: A x <= b}$, we say that a constraint $i$ is _redundant_ if removing it doesn't change the polyhedron.
]

#proposition[Irredundant inequality constraints][
  Let $P$ be a non-empty polyhedron and $j in I^<$ such that $a_j^top x <= b_j$ is irredundant.
  We define the face $F = {x in P: a_j^top x = b_j}$. Then
  - $F$ contains an $hat(x)$ such that $a_i^top x < b_i$ for all $i in I^< backslash {j}$.
  - $"aff"(F) = {x: a_i^top x = b_i "for all" i in I^= union {j}}$ and $dim(F) = dim(P) - 1$
]

_Proof_:

There exists $overline(x) in P$ that is strictly feasible for all $i in I^<$.
Since $j$ is not redundant, removing it enlarges the polyhedron.
There exists $tilde(x)$ satisfying all the constraints of $P$ except $j$, so that $a_j^top tilde(x) > b_j$.
The segment $[overline(x), tilde(x)]$ goes through $F$ at $hat(x)$.
The intersection satisfies $a_i^top hat(x) = b_i$ for all $i in I^=$ and $a_i^top hat(x) < b_i$ for all $i in I^< backslash {j}$.

The system $a_i^top x = b_i, i in I^= union {j}$ and $a_i^top x <= b_i, i in I^< backslash {j}$ has a set of implicit equalities given by $I^= union {j}$.
Thus its affine hull is $"aff"(F) = {A^= x = b^=} inter {a_j^top x = b_j}$.

We know that $F$ is strictly contained in $P$ since $j in I^<$, so $dim(F) < dim(P)$.
We also know that $dim(F) = n - "rank"(A^(= union {j})) >= n - "rank"(A^=) - 1 = dim(P) - 1$.

#definition[Minimal representation][
  The system $a_i^top x = b_i, i in I^=$ and $a_i^top x <= b_i, i in I^<$ defining $P$ is a _minimal representation_ when all the constraints are irredundant.
]

#exercise[Redundant inequalities][
  Let $a_1^top x <= b_1$ and $a_2^top x <= b_2$ be redundant inequalities for $P = {x: A x <= b}$.
  We construct $P'$ by removing $a_1^top x <= b_1$ from $P$.
  Is $a_2^top x <= b_2$ always redundant for $P'$?
]

#theorem[Characterization of facets][
  Let $P = {x: A x <= b}$ be a non-empty polyhedron.
  - For each facet $F$ of $P$, there is an irredundant constraint $j in I^<$ such that $F = P inter {x: a_j^top x = b_j}$.
  - A face $F$ of $P$ is a facet iff it is non-empty and $dim(F) = dim(P)-1$.
  - The number of facets of $P$ is the size of $I^<$ in a minimal representation.
]

_Proof_:

Let $F$ be a facet.
There exists a set of constraints $I subset.eq I^<$ such that $F = {x in P: a_i^top x = b_i "for all" i in I}$
Since $F eq.not P$, $I eq.not emptyset$.
Let $j in I$ and $F' = {x in P: a_j^top x = b_j}$.
$F'$ is also a face and $F subset.eq F' subset P$ since $j in I^<$.
By maximality, $F = F'$, so $I = {j}$ and $F$ is defined by $a_j^top x <= b_j$.

#exercise[Stable set polytope][
  The stable set polytope $P$ is the convex hull of the characteristic vectors $x$ of all the stable sets in a graph $G$.
  - Find the dimension of $P$
  - Given a maximal clique $K$, show that the inequality $sum_(v in K) x_v <= 1$ is valid and facet-defining.
]

$P$ is full-dimensional since it contains $0$ and every $e_i$.
We want to find $|V|$ affinely-independent vectors in the face $F_K$.
We start by taking $e_k$ for $k in K$.
For each vertex $v in V backslash K$, we need to pair it with $k in K$ such that $x = e_v + e_k in P$.
This means that $(v, k)$ should not be an edge of the graph.
Luckily, if there was a $v in V backslash K$ connected to everyone in the clique, $K$ would not be maximal.

#theorem[Uniqueness of the minimal representation][
  The minimal representation of a full-dimensional polyhedron is unique up to permutation and multiplication of the inequalities.
]

#remark[Importance of facets][
  In a sense, are the tightest cuts that one can find, which means they are very useful in solvers.
]

== Vertices & edges

#definition[Minimal face][
  A minimal face of a polyhedron is a face that contains no proper face.
]

#theorem[Characterization of minimal faces][
  Let $P = {x: A x <= b}$ be a non-empty polyhedron.
  - A non-empty face $F$ of $P$ is minimal iff $F = {x: A' x = b'}$ for some subsystem $A' x <= b'$ from $A x <= b$ such that $"rank"(A') = "rank"(A)$.
  - The dimensions of non-empty faces of $P$ range from $dim("lin"(P))$ to $dim(P)$.
]

_Proof_:

Let $F$ be a non-empty face of $P$.
If $F = {x: A' x = b'}$ then $F$ is an affine space and has no proper face, so $F$ is a minimal face of $P$.
If $F$ is a minimal face of $P$, let $A' x = b'$ be the subsystem of $A x = b$ that is saturated at every point of $F$, and $A'' x <= b''$ the rest.
Let $C^=, C^<, d^=, d^<$ be a minimal representation of $F$ extracted from $A' x = b', A'' x <= b''$.
Since $F$ is minimal, it has no facet, so $C^< = emptyset$ and $F = {x: C^= x = d^=}= {x: A' x = b'}$.
$F$ is an affine subspace so $F = {v} + "lin"(F)$ and $dim(F) = dim("lin"(P))$, so $"rank"(A') = n - dim(F) = n - dim("lin"(P)) = "rank"(A)$.
Finally, a face of dimension $> dim("lin"(P))$ contains a smaller face.

#definition[Vertices, edges][
  - A face of dimension $0$ of $P$ is called a _vertex_.
  - A face of dimension $1$ of $P$ is called an _edge_ (or an _extreme ray_ for a polyhedral cone).
  - The _skeleton_ of a polytope is the graph defined by vertices and edges.
]

#theorem[Characterization of vertices][
  Let $P = {x: A x <= b}$ be a pointed polyhedron and $overline(x) in P$.
  The following are equivalent:
  1. $overline(x)$ is a vertex.
  2. $overline(x)$ saturates $n$ linearly independent inequalities of $A x <= b$.
  3. $overline(x)$ is not a proper convex combination of distinct points of $P$.
]

_Proof_:

$P$ is pointed so $"lin"(P) = {0}$ and $"rank"(A) = n$.

- By the previous theorem, any vertex $overline(x)$ is a minimal face which satisfies $n$ linearly independent equalities from $A x <= b$ and vice-versa.
- Let $overline(x)$ satisfy $n$ linearly independent equalities, and let $y, z$ be such that $x = lambda y + (1 - lambda) z$ with $lambda in (0, 1)$.
  Since ${overline(x)}$ is a face, there exists a valid inequality $c^top x <= delta$ saturated only at $overline(x)$ inside $P$.
  We see that $y$ and $z$ are in $P$ saturate it too, so $y = z = x$.
- Let $overline(x)$ be such that the maximum set of independent equalities satisfied is $A' x = b$ with $"rank"(A') < n$, we denote by $A'' x < b''$ the rest.
  There exists a vector $v in "ker"(A') backslash {0}$ such that $A' v = 0$.
  Taking $y = x - epsilon v$ and $z = x + epsilon v$ with $epsilon > 0$ small enough gives us two points that are still in $P$ and such that $x = (y + z) / 2$, so $overline(x)$ is not an extreme point.

#exercise[Vertices of binary polytopes][
  Let $S subset.eq {0, 1}^n$ and $P = "conv"(S)$.
  Show that $S$ is the set of vertices of $P$.
]

#theorem[Carathéodory][
  - Let $v$ be a conic combination of some set $X$: it is a conic combination of at most $dim("cone"(X))$ linearly independent vectors of $X$.
  - Let $v$ be a convex combination of some set $X$: it is a convex combination of at most $dim("conv"(X))+1$ affinely independent vectors of $X$.
]

_Proof_:

We first prove the conic case.
Let $x_1, dots, x_k$ and $lambda_1, dots, lambda_k$ be such that $v = sum_i lambda_i x_i$.
The polyhedron $P = {lambda in bb(R)^k: lambda >= 0, sum_i lambda_i x_i = v}$ is non-empty and pointed, so it has a vertex $overline(lambda)$.
That vertex satisfies $k$ independent equality constraints among the $2k$ constraints $lambda >= 0, sum_i lambda_i x_i = v$. /* TODO: figure this out */

#exercise[Existence of basic LP solutions][
  Let $A x = b, x >= 0$ be a system of equations and inequations.
  Prove that if the system is feasible, there exists a solution $overline(x)$ such that the columns of $A$ corresponding to positive entries of $x$ are linearly independent.
]

Uses Carathéodory on $b in "cone"{a_i^top}$.

#theorem[Decomposition of polyhedra][
  Let $P$ be a non-empty polyhedron with $dim("lin"(P)) = t$.
  Then $P = "conv"{v_k} + "cone"{r_ell} + "lin"(P)$ where one $v_k$ is picked arbitrarily in each minimal face of $P$, one $r_ell$ is picked arbitrarily in each $t+1$-dimensional face of $"rec"(P)$.
  Furthermore, every Minkowski-Weyl decomposition can be written like this.
]

#definition[Extended formulation][
  Given a polyhedron $P$, a description as $P = "proj"(Q)$ for some higher-dimensional polyhedron $Q$ and projection operator $"proj"$ is called an _extended formulation_.
]

= Perfect formulations

== Integral polyhedra

#definition[Integral set][
  A convex set $P$ is _integral_ if $P = "conv"(P inter bb(Z)^n)$.
]

#theorem[Characterization of integral polyhedra][
  Let $P$ be a rational polyhedron.
  The following conditions are equivalent:
  1. $P$ is an integral polyhedron.
  2. Every minimal face of $P$ contains an integer point.
  3. $max_(x in P) c^top x$ is attained by an integral vector $x$ whenever the maximum is finite.
  4. $max_(x in P) c^top x$ is integer whenever $c$ is integer and the maximum is finite.
]

_Proof_:

1. $arrow.double$ 2.
2. $arrow.double$ 1.

== Total unimodularity

#definition[Total unimodularity][
  A matrix $A$ is _totally unimodular_ if every square submatrix has determinant $0$, $+1$ or $-1$.
]

In particular, this implies that every coefficient is in ${0, +1, -1}$.

#theorem[Hoffman & Kruskal][
  Let $A$ be an integral matrix.
  The polyhedron $P = {x : A x <= b}$ is integral for every $b in bb(Z)^m$ if and only if $A$ is totally unimodular.
]

_Proof_:

We only prove the "if".
Let $b$ be an integral vector and let $x$ be a vertex of $P(b)$.
Then $x$ satisfies $n$ linearly independent equalities among $A x <= b$, say $C x = d$.
We have $x = C^(-1) d$ and $C^(-1) = (1 / det(C)) "cofactor"(C)^top$.
The determinant is $+1$ or $-1$ and every coefficient in the cofactor matrix too, so $x in bb(Z)^n$.

#exercise[Integral polyhedron in general form][
  Let $A$ be a totally unimodular matrix.
  Prove that ${x: c <= A x <= d, ell <= x <= u}$ is integral for every integral $(c, d, ell, u)$.
]

#definition[Equitable bicoloring][
  An _equitable bicoloring_ of a matrix $A$ is a partition of its columns into two sets, red and blue, such that the sum of the red columns minus the sum of the blue columns is a vector with coefficients in ${0, +1, -1}$.
]

#theorem[Total unimodularity criterion][
  A matrix $A$ is totally unimodular if and only if it has an equitable bicoloring.
]

#proposition[Simpler total unimodularity criterion][
  A matrix $A$ with coefficients in ${0, +1, -1}$ such that each column has at most one $1$ and  one $-1$ is totally unimodular.
]

_Proof_:

By recurrence:

- If $A$ has a zero column, $det(A) = 0$
- Otherwise, if $A$ has a column with just one non-zero, we develop the determinant using that column.
- Otherwise, all columns have exactly two non-zeros so the sum of each column is $0$ and $det(A) = 0$.

== Paths, flows, matchings

#proposition[Incidence matrices][
  The edge-vertex incidence matrix of a directed graph is totally unimodular.
]

#theorem[Graph problems with perfect formulations][
  The following optimization problems on graphs can be solved with the continuous relaxation:
  - shortest paths
  - minimum-cost flows
  - matchings on bipartite graphs
]

#remark[Using the simplex][
  The simplex algorithm must be used to obtain a basic feasible solution (a vertex).
  With interior point algorithms or other LP solvers, there is no guarantee that the resulting solution will be integral.
]

#proposition[Spanning tree polytope][
  The spanning tree polytope of $G = (V, E)$ is described by
  $
       sum_(e in E) x_e & = |V| - 1 \
    sum_(e in E[S]) x_s & <= |S| - 1 quad forall S subset V, S eq.not emptyset \
                    x_e & >= 0 quad forall e in E
  $
]

#remark[Exponential size of perfect formulation][
  The spanning tree is not an isolated case: many other problems (TSP, matching) require exponentially many constraints to describe exactly the convex hull of their feasible solutions.
]

= Valid inequalities


#exercise[2-variable mixed integer set][
  Consider the set $S = {(x, y) in bb(Z) times bb(R)_+: x - y <= beta}$.
  Let $f = beta - floor(beta)$.
  Prove that $x - y / (1 - f) <= floor(beta)$ is a valid inequality for $S$.
  Provide a graphical interpretation.
]

== Split inequalities

- General framework
- Gomory
- Chvatal

== Structured approaches

- Knapsack cover inequalities
- TSP comb inequalities

#theorem[Billera-Sarangarajan][
  Any ${0, 1}$ polytope is affinely equivalent to a face of an asymmetric TSP polytope in sufficiently large dimension.
]

#bibliography("DECO.bib")
