#import "@preview/frame-it:1.2.0": *

#set document(
  title: "Dantzig-Wolfe decomposition",
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

#let (definition, proposition, theorem, remark, exercise, algorithm, idea) = frames(
  definition: ("Definition", aqua),
  proposition: ("Proposition", orange),
  theorem: ("Theorem", red),
  remark: ("Remark", yellow),
  exercise: ("Exercise", green),
  algorithm: ("Algorithm", gray),
  idea: ("Idea", fuchsia),
)
// This is necessary. Don't forget this!
#show: frame-style(styles.boxy)

#title(context document.title)

#align(center)[
  #text(context document.author.at(0)) \
  _MPRO -- Decomposition methods for integer programming_
]

All of the content is taken from @confortiIntegerProgramming2014 or @uchoaOptimizingColumnGeneration2024.

#outline()

= Motivation: complicating constraintsx

For each of the following problems:

1. Give a mixed integer programming formulation.
2. Describe the structure of the constraint matrix.

#exercise[Generalized assignment -- modeling][
  There are a number of tasks $i in [m]$ to be performed by agents $j in [n]$.
  Assigning task $i$ to agent $j$ generates profit $c_(i j)$ and takes time $t_(i j)$.
  Each agent has a time budget $T_j$.
  Agents do not collaborate on tasks.
  The goal is to maximize the profit subject to time constraints.
]

Let $x_(i j)$ be a binary variable equal to $1$ if task $i$ is assigned to agent $j$.
The GAP can be formulated as:
$
  max_x quad sum_(i, j) c_(i j) x_(i j) quad "s.t." quad cases(
    thick sum_j x_(i j) <= 1 & quad forall i,
    thick sum_i t_(i j) x_(i j) <= T_j & quad forall j,
    thick x_(i j) in {0, 1} & quad forall (i, j),
    delim: "|"
  )
$ <GAP>

The constraint matrix has a block diagonal structure with one block per agent $j$ and a coupling block on top (at most one agent per task).

#exercise[Cutting stock -- modeling][
  At a paper mill, we have large rolls of paper of width $W$, to be cut into smaller rolls.
  The client's order is to produce $b_i$ rolls of width $w_i$ for each $i in [m]$.
  The goal is to minimize the number of large rolls necessary.
]

We assume that at most $p$ large rolls will be necessary.
Let $y_j$ be a binary variable equal to $1$ if roll $j in [p]$ is used, and $z_(i j)$ be an integer variable denoting the number of small rolls of width $w_i$ cut out from large roll $j$.
The CSP can be formulated as:

$
  min_(y, z) quad sum_j y_j quad "s.t." quad cases(
    thick sum_i w_i z_(i j) <= W y_j & quad forall j,
    thick sum_j z_(i j) >= b_i & quad forall i,
    thick y_j in {0, 1} & quad forall j,
    thick z_(i, j) in bb(N) & quad forall (i, j),
    delim: "|"
  )
$ <CSP>

The constraint matrix has a block diagonal structure with one block per large roll $j$ and a coupling block on top (demand satisfaction).

#exercise[Facility location -- modeling][
  A company would like to set up facilities to serve its customers $i in [m]$.
  For each possible facility location $j in [n]$, the fixed annual operating cost is $f_j$ and the cost of serving client $i$ is $c_(i j)$.
  The goal is to select which facilities to open in order to minimize total annual costs.
]

Let $x_j$ be a binary variable equal to $1$ if facility $j$ is open, and $y_(i j)$ be the fraction of demand $d_i$ transported from $j$ to $i$.
The FLP can be formulated as:

$
  min_(x, y) quad sum_j f_j x_j + sum_(i, j) c_(i j) y_(i j) quad "s.t." quad cases(
    thick sum_j y_(i j) = 1 & quad forall i,
    thick y_(i j) <= x_j & quad forall (i, j),
    thick x_j in {0, 1} & quad forall j,
    thick y_(i, j) >= 0 & quad forall (i, j),
    delim: "|"
  )
$ <FLP>

The constraint matrix has a block diagonal structure with one block per facility $j$ and a coupling block on top (serving clients).

#exercise[Network design -- modeling][
  Let $G = (N, A)$ be a directed graph of potential arcs to be constructed.
  We need to select a subset of arcs from $A$ to route commidities $k in [K]$.
  Each commodity $k$ goes from source $s_k$ to target $t_k$ with volume $v_k$.
  Each arc $a in A$ has capacity $c_a$ and construction cost $f_a$.
  The goal is to design a network at minimum cost that is able to route all the flow.
]

Let $x_a$ be a binary variable equal to $1$ if arc $a$ is constructed.
Let $y_a^k$ denote the amount of commodity $k$ flowing through $a$.
The NDP can be formulated as:

$
  min_(x, y) quad sum_a f_a x_a quad "s.t." quad cases(
    thick sum_(a in delta^+(i)) y_a^k - sum_(a in delta^-(i)) y_a^k = (1_(i = s_k) - 1_(i = t_k)) v_k & quad forall i,
    thick sum_k y_a^k <= c_a x_a & quad forall a,
    thick x_a in {0, 1} & quad forall j,
    thick y_a^k >= 0 & quad forall (a, k),
    delim: "|"
  )
$ <NDP>

There are two ways to look at this constraint matrix:

- Block structure in the commodities
- Block structure in the arcs

#idea[Parallel subproblems][
  In each of these problems, removing the coupling constraint would allow parallel solution of simpler subproblems.
  Can we use this insight to
  1. Solve LPs faster?
  2. Obtain a better relaxation for branch & bound when solving ILPs?
]

Indeed, the number of nodes in the branch & bound tree grows exponentially with the integrality gap, and some of the formulations above have really bad gaps.

#exercise[Cutting stock relaxation][
  What is the value of the linear relaxation of the cutting stock problem?
  How can we obtain it more easily?
]

= Dantzig-Wolfe relaxation

== Definition

#definition[Setting][
  Consider the following integer program with rational coefficients:
  $
    z_("ILP") = max_x quad c^top x quad "s.t." quad cases(
      thick A x <= b & quad "(hard constraint)",
      thick C x <= d & quad "(easy constraint)",
      thick x in bb(Z)^n & quad "(integrality)",
      delim: "|",
    )
  $ <ILP>
  and its continuous relaxation
  $
    z_("LP") = max_x quad c^top x quad "s.t." quad cases(
      thick A x <= b,
      thick C x <= d,
      thick x in bb(R)^n,
      delim: "|",
    )
  $ <LP>
  We define $S = {x in bb(Z)^n : A x <= b, C x <= d}$ the integer feasible set and $Q = {x in bb(Z)^n : C x <= d}$ the integer feasible set with the hard constraint relaxed.
  Furthermore, we assume that problems of the form $max {tilde(c)^top x: x in Q}$ are easy to solve.
]

#definition[Dantzig-Wolfe relaxation][
  The Dantzig-Wolfe relaxation of the ILP in @ILP is defined as
  $
    z_("DW") = max_x quad c^top x "s.t." quad cases(
      thick A x <= b,
      thick x in "conv"(Q),
      delim: "|",
    )
  $ <DW>
]

#proposition[Often better than the continuous relaxation][
  We have $z_"ILP" <= z_"DW" <= z_"LP"$.
]

The feasible sets of these three problems satisfy
$
  S = {A x <= b} inter Q subset.eq {A x <= b} inter "conv"(Q) <= {A x <= b} inter {C x <= d}
$

#exercise[Not always][
  In which cases is the Dantzig-Wolfe relaxation equal to the linear programming relaxation?
]

When $"conv"(Q) = {C x <= d}$, the Dantzig-Wolfe relaxation does not give a better bound than the linear programming relaxation (but it may still be easier to compute, see below).

== Extended formulation

#proposition[Extended formulation][
  There exist $v_k$ and $r_h$ such that the Dantzig-Wolfe relaxation can be formulated as
  $
    max_(lambda, mu) quad & sum_(k in K) lambda_k c^top v_k + sum_(h in H) mu_h c^top r_h \
              "s.t." quad & sum_(k in K) lambda_k A v_k + sum_(h in H) mu_h A r_h <= b \
                          & sum_(k in K) lambda_k = 1 \
                          & lambda in bb(R)_+^K, mu in bb(R)_+^H,
  $ <DWE>
]

By Meyer's theorem, $"conv"(Q)$ is a rational polyhedron.
By the Minkowski-Weyl theorem, it can be written as the sum of a polytope and a finitely-generated cone.

#remark[Reformulation, general case][
  To obtain a reformulation of the original ILP, just add the following constraint to the DW relaxation:
  $
    sum_(k in K) lambda_k A v_k + sum_(h in H) mu_h A r_h in bb(Z)^n
  $
]

#remark[Reformulation, simple case][
  When $Q$ is bounded, we can also pick $v_k$ to be all points in $Q$ (not just vertices), and then a solution to @DW is integral if $lambda in {0, 1}^K$.
]

== Back to coupling constraints

Many practical problems look like this (considering the pure binary case for simplicity):
$
  max_(x in {0, 1}^(n times p)) quad & c_1^top x_1 +    &    c_2^top x_2 + & dots + & c_p^top x_p & \
                         "s.t." quad & B_1 x_1 #hide[+] &                  &        &             & quad <= b \
                                     &                  & B_2 x_2 #hide[+] &        &             & quad <= d \
                                     &                  &                  &        &             & \
                                     &                  &                  &        &     B_p x_p & quad <= b_p \
                                     & D_1 x_1 +        &        D_2 x_2 + & dots + &     D_p x_p & quad <= d \
$

#proposition[Block-diagonal problems][
  Block-diagonal problems have a natural DW decomposition.
]

Let $Q_j = {x_j in {0, 1}^n: B_j x <= b_j}$, the Dantzig-Wolfe relaxation is given by

$
  max_lambda quad & sum_j sum_(v in Q_j) lambda_v^j c_j^top v \
      "s.t." quad & sum_j sum_(v in Q_j) lambda_v^j D_j v <= d \
                  & sum_(v in Q_j) lambda_v^j = 1 quad forall j \
                  & lambda in bb(R)_+^(|Q| times p)
$

#remark[Identical blocks][
  Subproblems can be aggregated.
]

With $p$ identical blocks, this simplifies with $lambda_v = sum_j lambda_v^j$ (which counts the number of block solutions equal to $v$):

$
  max_lambda quad & sum_(v in Q) lambda_v c^top v \
      "s.t." quad & sum_(v in Q) lambda_v D_j v <= d \
                  & sum_(v in Q) lambda_v = p quad \
                  & lambda in bb(R)_+^(|Q|)
$

This formulation removes symmetry.

== Examples

#remark[Coming up with a DW reformulation][
  Either use the formula from the polyhedron $"conv"(Q)$, or try to guess it by enumerating all solutions.
]

#exercise[Generalized assignment -- DW][
  Write the Dantzig-Wolfe reformulation of @GAP.
]

Let $Q_j = {x_j in {0, 1}^m: sum_i t_(i j) x_(i j) <= T_j}$ be a binary knapsack set relative to one agent.
The DW reformulation of @GAP is:

$
  max_lambda quad & sum_j sum_(v in Q_j) lambda_v^j c_j^top v \
      "s.t." quad & sum_j sum_(v in Q_j) lambda_v^j v_i <= 1  &      quad forall i \
                  & sum_(v in Q_j) lambda_v^j = 1             &      quad forall j \
                  & lambda_v^j in {0, 1}                      & quad forall (j, v)
$ <GAP-DW>

But we could also write it by enumerating possible sets of tasks associated with each agent.

#exercise[Cutting stock -- DW][
  Write the Dantzig-Wolfe reformulation of @CSP.
]

Let $Q = {(k, f) in {0, 1} times bb(N)^m: sum_i w_i f_i <= W k} = {(0, 0)} union {(1, f): f in F}$ be the union of all cutting formats.
The DW reformulation of @CSP is

$
  min_lambda quad & sum_(f) x_f \
      "s.t." quad & sum_(f) x_f f_i >= b_i \
                  & sum_(f) x_f <= p \
                  & x_f in bb(N)           & quad forall f
$ <CSP-DW>

where $x_f$ counts the number of times format $f$ is used.
Note that $sum_f x_f <= p$ is redundant by definition of $p$.

#exercise[Facility location -- DW][
  Write the Dantzig-Wolfe reformulation of @FLP.
]

Let $Q = {(x, y) in {0, 1}^n times {0, 1}^(m times n): y_(i j) <= x_j thick forall (i, j)}$ be the set of client assignments for each facility.
Each element of $Q$ can be expressed as a non-empty set of clients $s$ associated with each open facility $j$.
The DW reformulation of @FLP is:

$
  min_lambda quad & sum_j f_j sum_s lambda_s^j + sum_(i, j) sum_(s in.rev i) c_(i j) lambda_s^j \
      "s.t." quad & sum_j sum_(s in.rev i) lambda_s^j = 1 quad forall i \
                  & sum_S lambda_s^j <= 1 quad forall j \
                  & lambda_s^j in {0, 1} quad forall (j, s)
$ <FLP-DW>

Note that we don't constrain the sum of $lambda_s^j$ to be $1$ because we want to allow choosing no set of clients for a facility (i.e. not opening it).
Alternatively, we could allow the empty set $s = emptyset$ and adjust the opening price.

#exercise[Network design -- DW][
  Write the Dantzig-Wolfe reformulation of @NDP.
]

Let $Q_k$ be the flow polyhedron associated with commodity $k$.
It is bounded due to finite capacity constraints, and its extreme points are elementary paths from $s_k$ to $t_k$ (no extreme rays)
Let $P_k$ be the set of such paths.
The DW reformulation of @NDP is:

$
  min_lambda quad & sum_a x_a \
      "s.t." quad & sum_k sum_(p in P_k\ p in.rev a) lambda_p^k <= c_a x_a quad forall a \
                  & sum_(p in P_k) lambda_p^k = 1 quad forall k \
                  & lambda_p^k in {0, 1} quad forall (k, p) \
                  & x_a in {0, 1} quad forall a
$ <NDP-DW>

We could also have enumerated every possible flow (a more natural first solution perhaps).

= Column generation

== Subsets of variables

#remark[Exponential size][
  The Dantzig-Wolfe relaxation in @DWE has an exponential number of variables (size of the Minkowski-Weyl representation of $"conv"(Q)$).
  It cannot be solved "as is" by existing solvers.
]

We describe an approach to tackle this exponential size by considering a few generators only.

#definition[Restricted Dantzig-Wolfe relaxation][
  The restricted Dantzig-Wolfe relaxation is defined by using a subset of vertices $K' subset K$ and a subset of rays $H' subset H$ in @DWE:
  $
    max_(lambda, mu) quad & sum_(k in K') lambda_k c^top v_k + sum_(h in H') mu_h c^top r_h \
              "s.t." quad & sum_(k in K') lambda_k A v_k + sum_(h in H') mu_h A r_h <= b \
                          & sum_(k in K') lambda_k = 1 \
                          & lambda in bb(R)_+^(K'), mu in bb(R)_+^(H'),
  $ <DWR>
  If it is unbounded, then @DWE is also unbounded.
  Otherwise, let $(overline(lambda), overline(mu))$ be an optimal solution of @DWR.
]

If $(overline(lambda), overline(mu))$ is not optimal for @DWE, the question is how to select new generator candidates to insert into $K'$ and $H'$.

#proposition[Dual of main problem][
  The dual of @DWE is given by
  $
    min_(sigma, pi) quad & sigma + pi^top b \
             "s.t." quad & (c - A^top pi)^top v_k - sigma <= 0 & quad forall k in K \
                         & (c - A^top pi)^top r_h <= 0         & quad forall k in K \
                         & pi >= 0
  $ <DWE-dual>
]

In the unrestricted Dantzig-Wolfe relaxation, let $sigma in bb(R)$ be the Lagrange multiplier associated with constraint $sum_(k in K) lambda_k = 1$, and $pi >= 0$ the vector  of Lagrange multipliers associated with $sum_(k in K) lambda_k A v_k + sum_(h in H) mu_h A r_h <= b$.
The Lagrangian writes
$
  cal(L)(lambda, mu; sigma, pi) = & sum_k lambda_k c^top v_k + sum_h mu_h c^top r_h \
                                  & + sigma (1 - sum_k lambda_k) \
                                  & + pi^top (b - sum_k lambda_k A v_k - sum_h mu_h A r_h) \
  cal(L)(lambda, mu; sigma, pi) = & sum_k lambda_k (c^top v_k - pi^top A v_k - sigma) \
                                  & + sum_h mu_h (c^top r_h - pi^top A r_h) \
                                  & + sigma + pi^top b
$
And thus the dual is $min_(sigma, pi) max_(lambda, mu) cal(L)(lambda, mu; sigma, pi)$, which boils down to
$
  min_(sigma, pi) quad & sigma + pi^top b \
           "s.t." quad & c^top v_k - pi^top A v_k - sigma <= 0 & quad forall k \
                       & c^top r_h - pi^top A r_h <= 0         & quad forall k \
                       & pi >= 0
$

#idea[Dual variables are shadow prices][
  Let $(overline(sigma), overline(pi))$ be a dual optimal solution associated with $(overline(lambda), overline(mu))$ for @DWR.
  The dual variables tell us whether it is worth adding new generators to $K'$ and $H'$.
]

== Pricing

#proposition[Finding new generators][
  For $k in K$, let $overline(c)_k = (c - A^top overline(pi))^top v_k - overline(sigma)$ be the reduced cost associated with vertex $v_k$.
  For $h in H$, let $overline(c)_h = (c - A^top overline(pi))^top r_h$ be the reduced cost associated with ray $r_h$.
  If all $overline(c)_k$ are zero and all $overline(c)_h$ are zero, then $(overline(lambda), overline(mu))$ is an optimal solution to the full relaxation @DWR.
  Otherwise, generators with positive reduced costs can be added to the main problem to improve the solution.
]

Indeed, if $((overline(lambda), overline(mu)), (overline(sigma), overline(pi)))$ is a primal-dual optimal pair for @DWR, then they satisfy complementary slackness.
Furthermore, $(overline(lambda), overline(mu))$ is feasible for the full problem @DWE.
Thus, $(overline(lambda), overline(mu))$ is optimal for @DWE as well if and only if $(overline(sigma), overline(pi))$ is feasible for its dual @DWE-dual.
If it is not feasible, there must be a violated constraint, and we can add it to the dual, which means adding the corresponding variable to the primal.

#exercise[Simplex dual solution][
  Given an optimal basis $B$ in the simplex algorithm for a standard-form LP $max {c^top x: A x = b, x >= 0}$, how does one retrieve a dual optimal solution?
]

The dual problem is $min {b^top y: A^top y >= c}$.
At the end of the simplex, the reduced costs are negative:
$
  r_N = c_N - A_N^top A_B^(-top) c_B <= 0
$
This gives us a natural candidate for the dual optimal solution: $y^* = A_B^(-top) c_B$.
We can also check that $b^top y^* = c^top x^*$.

#definition[Pricing subproblem][
  The pricing subproblem is the optimization problem
  $
    zeta = -overline(sigma) + max_(x in Q) (c - A^top overline(pi))^top x
  $ <pricing>
]

There can be three situations:

- The problem @pricing is unbounded if and only if there is an extreme ray $r_h$ such that $(c - A^top pi)^top r_h > 0$, i.e. with positive reduced cost.
- If it is bounded and $eta > 0$, then there is a vertex $v_k$ with positive reduced cost.
- If it is bounded and $eta <= 0$, no variable has a positive reduced cost.

== Full algorithm

#algorithm[Column generation for large MILPs][
  1. Start with variable subsets $K'$ and $H'$.
  2. Solve the restricted main problem (@DWR), obtain $(overline(lambda), overline(mu))$ and $(overline(sigma), overline(pi))$.
  3. Solve the pricing subproblem (@pricing), and depending on its result, either terminate or add variables to $K'$ / $H'$ and loop.
]

To control convergence, use the optimum of the pricing problem.

#proposition[Gap control][
  Let $(overline(lambda), overline(mu))$ be a feasible solution to the restricted main problem (no extreme rays), and $(overline(sigma), overline(pi))$ be an associated dual solution.
  Let $zeta$ be the value of the pricing subproblem, which we assume finite and $> 0$.
  Then the optimum of the full main problem has value in $[c^top overline(x), c^top overline(x) + zeta]$.
]

Indeed, if $zeta > 0$, then $zeta$ corresponds to the maximum violation of a dual constraint in @DWE-dual by a vertex of $Q$.
This means that $(overline(sigma) + zeta, overline(pi))$ is dual-feasible, with dual objective value $overline(sigma) + zeta + overline(pi)^top b = c^top overline(x) + zeta$.

== Examples

#exercise[Generalized assignment -- pricing][
  Identify the pricing subproblem of @GAP-DW. How would you solve it?
]

Binary knapsack problem, possibly with negative costs.
Solvable by dynamic programming.

#exercise[Cutting stock -- pricing][
  Identify the pricing subproblem of @CSP-DW. How would you solve it?
]

Integer knapsack problem, possibly with negative costs.
Solvable by dynamic programming.

#exercise[Facility location -- pricing][
  Identify the pricing subproblem of @FLP-DW. How would you solve it?
]

Unconstrained binary linear program, decomposes by customer: only add the ones who are beneficial.
Capacity constraints would couple them.

#exercise[Network design -- pricing][
  Identify the pricing subproblem of @NDP-DW. How would you solve it?
]

Shortest path problem, possibly with negative weights.
Solvable with Bellman-Ford.

= Branch and price

#algorithm[Branch & price][
  The branch & price algorithm is a branch & bound where at each node, the relaxation is given by Dantzig-Wolfe.
]

== Branching techniques

#remark[Adding branching inequalities][
  It is better to add branching inequalities to the main problem than the pricing problem.
]

Otherwise one may disturb the specific structure that makes pricing easy.

#remark[Variable to branch on][
  It is better to branch on the original variables $x$ as opposed to the reformulation variables $lambda$.
]

Two reasons:

- Fixing $lambda_k = 1$ means separating just one vertex from the rest of the polytope, not a very useful split.
- Fixing $lambda_k = 0$ doesn't mean we won't try to include $v_k$ further down in the pricing step, which means we'd have to look for the second-best solution of pricing.

== Implementation tricks

#remark[Suboptimal pricing][
  Still works as long as the columns have positive reduced cost.
]

No need to fully resolve pricing, except at the very end to check optimality.

#remark[Column addition or removal][
  Nothing stops us from adding several columns at once to the main problem.
  Conversely, we can also clean up when it gets too big.
]

Useful when the solver naturally produces several solutions.

#remark[Warm starting][
  One can restart the primal simplex from the previous solution, since adding a variable doesn't affect primal feasibility.
]

How does this differ from branch & cut?
Branch & cut uses the dual simplex.

#exercise[Double block angular structure][
  How to handle the case with binding constraints?
]

Split the variables.

== Flow subproblems

A very common case.

#exercise[Vertex and ray pricing][
  Which algorithm can be used to solve both pricing subproblems for a flow?
]

Bellman-Ford will either identify a negative-cost cycle or find an elementary shortest path.
In special cases we can do even better, e.g. for acyclic graphs (topological sort).

== Getting an integer solution

There are some heuristics to get a suboptimal integer solution from the output of the DW decomposition.

#remark[MIP-ifying][
  Idea: run column generation then solve the restricted main problem one last time as an integer program (forcing vertex coefficients to be zero or one).
  Then we get a feasible solution to the original MILP.
]

== Take-home messages

When to use DW?

- Not appropriate for general problems without structure.
- When the pricing subproblems are independent (block-diagonal structure).
- When pricing can be done with a dedicated solver.
- Especially relevant when pricing is NP-hard in theory (perfect formulations don't give better bounds) but well-solved in practice. Weakly NP-hard is a good balance (knapsack).

#bibliography("DECO.bib")
