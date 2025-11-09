#import "@preview/touying:0.6.1": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly
#import "@preview/algo:0.3.6": algo, code, comment, d, i
#import "@preview/note-me:0.5.0": *
#import "@preview/mannot:0.3.0": *
#import "@preview/fletcher:0.5.8": *

// #set text(font: "Fira Sans")
// #show math.equation: set text(font: "Fira Math")

#let colgray(x) = text(fill: gray, $#x$)

#let thanks(body) = {
  footnote(numbering: _ => [])[#body]
  counter(footnote).update(n => n - 1)
}

#show link: set text(fill: blue)
#show link: underline

#show: university-theme.with(config-info(
  title: [Combinatorial optimization layers in machine learning pipelines],
  subtitle: [ROAPA -- ENPC],
  author: [Guillaume Dalle],
  date: [10.11.2025],
  institution: [#link("https://gdalle.github.io/")[gdalle.github.io/]],
))

#title-slide()

#components.adaptive-columns(outline(depth: 1))

#thanks[Figures without attribution are borrowed from #cite(<blondelElementsDifferentiableProgramming2024>) or the works of our team]

= Deep learning -- setup

== Problem statement

We are given:
- A set of inputs $cal(X)$ and a set of outputs $cal(Y)$
- With an unknown distribution $p(x, y)$ on $cal(X) times cal(Y)$

Given a new input $x$, we want to predict the corresponding output $y$.

We approximate $y = f_w (x)$ with a parametric model $f_w in cal(F)$.

Example:

- $cal(F) = {x mapsto w^top x: w in bb(R)^n}$ family of linear functions
- $cal(F) = {x mapsto "NN"_w(x): w in bb(R)^"big"}$ family of neural networks

== Loss function

To measure our prediction error, we have a loss function $ell(hat(y))$.

Examples:

- Continuous prediction: $ell(hat(y), y) = norm(hat(y) - y)^2$
- Discrete prediction: $ell(hat(y), y) = 1_(hat(y) != y)$

Ideally, we want the parameters $w$ that minimize the true risk:

$
  min_w R(w) = bb(E)_((x, y) tilde p) [ell(f_w (x), y)]
$

== Empirical risk minimization

The true distribution $p$ is unknown, but we have training data

$
  cal(D)_n = {(x_i, y_i) in cal(X) times cal(Y): i in [1:n]}
$

So we minmize the empirical risk instead:

$
  min_w R_n (w) = 1/n sum_(i=1)^n ell(f_w (x_i), y_i)
$

Amounts to the approximation

$
  p approx 1/n sum_(i=1)^n delta_((x_i, y_i))
$

== Error types

- Approximation error: the family of functions $cal(F)$ does not include the true data generator
- Optimization error: the empirical risk $R_n (w)$ is not minimized exactly
- Generalization error: the empirical risk $R_n (w)$ is a bad proxy for the true risk $R(w)$

It's hard to minimize all three at the same time!

== Likelihood-based approaches

A good way to define a loss is to adopt a probabilistic framework.

Example: $y = f_w (x) + epsilon$ where $epsilon tilde cal(N)(0, sigma^2)$ is a Gaussian noise.

Likelihood: $p(y | x, w) = 1/(sqrt(2 pi sigma^2)) exp(-(y - f_w (x))^2 / (2 sigma^2))$

Log-likelihood: $log p(y | x, w) = "constants" - (y - f_w (x))^2$

Maximizing log-likelihood = minimizing loss.

== Regularization

To avoid overfitting the training set, another term is added to the loss to penalize model complexity.

If we think the weights should remain small, then we solve

$
  min_w R_n (w) + lambda norm(w)^2
$

Amounts to a Gaussian prior on $w$ that depends on the penalty $lambda$.

= Deep learning -- pipelines

== Basic layers & composition

In deep learning, each scalar is associated with a "neuron" and neurons are structured in layers to propagate information.

- linear layer: $x in bb(R)^n mapsto W x + b in bb(R)^m$
- activation layer: $x in bb(R)^n mapsto sigma(x) in bb(R)^n$ (nonlinearities)
- structured layers: convolution, recurrence, message-passing, attention

These layers are chained together from input to output:

$
  f_w = f^L_(w_L) compose f^(L-1)_(w_(L-1)) compose dots compose f^2_(w_2) compose f^1_(w_1)
$

where $w_ell$ are the weights in layer $ell$.

== Gradient descent

To minimize the loss, the algorithm of choice is gradient descent:

$
  w <- w - eta nabla R_n (w) thick
$

where the gradient is a sum over samples

$
  nabla R_n (w) = 1/n sum_(i=1)^n nabla_w [ell(f_w (x_i), y_i)]
$

Requires:

- Differentiable model $f_w$
- Differentiable loss $ell$
- Minibatching for large datasets

== Exercise

Logistic regression is a binary classification task defined by the following model:

$
  p(y=1 | x, w) = sigma(w^top x + b) quad "where" sigma(z) = 1 / (1 + e^(-z))
$

- Write the empirical risk $R_n (w)$ for a given dataset $cal(D)_n$
- Compute its gradient $nabla_w R_n (w)$

== The need for automatic differentiation

#columns[
  Modern architectures are huge #cite(<vaswaniAttentionAllYou2017>).

  Don't want manual work when the model changes.

  Automatic differentiation enables:

  - easy experimentation
  - modular code

  #colbreak()

  #align(center)[
    #image("img/vaswani/ModalNet-21.png")
  ]
]

== The big picture

#columns[

  _*Differentiable programming* is a programming paradigm in which *complex computer programs* (including those with control flows and data structures) can be differentiated end-to-end automatically, enabling gradient-based *optimization of parameters* in the program._

  From the book #cite(<blondelElementsDifferentiableProgramming2024>) (see also #cite(<scardapaneAlicesAdventuresDifferentiable2024>))

  #colbreak()

  #align(center)[
    #image("img/scardapane/alice_partial.png", height: 70%)
  ]
]

= Autodiff -- basics

== Definitions

Derivative = linear approximation of function $f$ around point $x$:

$ f(x + v) = f(x) + partial f(x) [v] + o(norm(v)) $

Here $partial f(x)[v]$ means "the linear map $partial f(x)$ applied to $v$".

== Manual / symbolic differentiation

#columns[
  Plug the expression for $f(x)$ into a computer algebra system.

  Gives an expression for $f'(x)$, possibly very long.

  Expression trees are not great for computer programs:

  - shared variables
  - loops

  #colbreak()

  Exercise #cite(<laueEquivalenceAutomaticSymbolic2022>): expression tree & computational graph for $f(x) = sin(x_1 + x_2) cos(x_1 + x_2)$

  #pause

  #columns[
    #image("img/laue/tree.pdf", width: 90%)
    #image("img/laue/DAG.pdf", width: 90%)
  ]

]

== Numeric differentiation

Execute the computational graph $f$ at nearby points (finite differences):

$ partial f(x)[v] approx (f(x + epsilon v) - f(x)) / epsilon $

Great at first glance:

- Applies to arbitrary programs
- Only requires two function calls instead of one

== Problems of numeric differentiation (1)

#slide(composer: (55%, auto))[
  #align(center)[
    #image("img/blondel/approx_error.pdf")
  ]
][
  #align(horizon)[
    Numerical errors:

    - Taylor truncation
    - Floating-point round-off
  ]
]

== Problems of numeric differentiation (2)

Computing a gradient is expensive: $n+1$ evaluations

$
  nabla f(x) = mat(partial_1 f(x); partial_2 f(x); ...; partial_n f(x)) approx 1/epsilon mat(
    f(x + epsilon e_1) - f(x); f(x + epsilon e_2) - f(x); dots.v; f(x + epsilon e_n) - f(x);
  )
$

One perturbation per input dimension!

== Automatic (or algorithmic) differentiation

Transform the computational graph $f$ into a new graph $partial f$ and propagate derivatives through it:

- Keeps the compact program encoding ($!=$ symbolic)
- Yields exact derivative values ($!=$ numeric)
- Can compute gradients efficiently (in reverse mode)

Automatic differentiation = chain rule + layers with known derivatives.

= Autodiff -- modes

== Derivatives as linear maps

If $f : bb(R)^n --> bb(R)^m$, then $partial f(x)$ can be represented as a Jacobian matrix:

$
  J_f (x) = ( (partial f_i) / (partial x_j) (x))_(i, j) = mat(
    (partial f_1) / (partial x_1) (x), dots, (partial f_1) / (partial x_n) (x);
    dots.v, dots.down, dots.v;
    (partial f_m) / (partial x_1) (x), dots, (partial f_m) / (partial x_n) (x);
  )
$

However, the linear map $v mapsto.long partial f(x)[v]$ is natural to work with:

- generalizes to arbitrary vector spaces
- no need to materialize a matrix or flatten anything

== The chain rule

Given a function composition $f = h compose g$ with two layers, we have

$ partial f(x) = partial h(g(x)) compose partial g(x) $

The derivative of $f$ is the composition of two linear maps:

$ partial f(x): & u stretch(mapsto)^(partial g(x)) v stretch(mapsto)^(partial h( g(x) )) w $

We can differentiate any function knowing the derivatives of its layers.

== From matmul to map composition

#align(center)[
  #image("img/hill/chainrule.svg", width: 80%)
  #image("img/hill/matrixfree.svg", width: 80%)
]

== From matmul to map composition (2)

#align(center)[
  #image("img/hill/forward_mode_eval.svg", width: 70%)
]

== Scalar layers

Let $dot(x)$ denote an arbitrary input tangent (directional derivative).

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: horizon,
    inset: 10pt,
    table.header([*variables*], [*function* $f$], [*derivative* $partial f$]),
    [$x in bb(R)$], [$a x$], [#pause $a dot(x)$],
    [$x in bb(R)$], [$sin(x)$], [#pause $cos(x)dot(x)$],
    [$x, y in bb(R)$], [$x, y$], [#pause $x dot(y) + y dot(x)$],
  )
]

This mirrors exactly what we learned in high school.

== Array layers

Define rules for array functions with known derivatives #cite(<petersenMatrixCookbook2012>).

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: horizon,
    inset: 10pt,
    table.header([*variables*], [*function* $f(x)$], [*derivative* $partial f(x)[dot(x)]$]),
    [$x in bb(R)^n$], [$A x + b$], [#pause $A dot(x)$],
    [$x in bb(R)^n$], [$sigma(x)$], [#pause $sigma'(x) dot(x)$],
    [$x in bb(R)^n$], [$norm(x)^2$], [#pause $2 x^top dot(x)$],
    [$X in bb(R)^(n times n)$], [$X^(-1)$], [#pause $-X^(-1) dot(X) X^(-1)$],
  )
]

For the inverse, a Jacobian matrix of size $(n times n)^2$ is not needed: the linear map is more efficient.

== This was forward mode

Propagate the input and its tangent together through a chain of layers.

#align(center)[
  #image("img/blondel/chain_jvp.pdf", height: 60%)
]

== Jacobian-Vector Products

Back to matrices, forward mode computes JVPs $partial f(x)[v] = J_f(x) v$.

With $v = e_j$, this gives a column of the Jacobian matrix:

$
  partial f(x)[e_j] = mat(
    colgray((partial f_1) / (partial x_1) (x)), colgray(dots), (partial f_1) / (partial x_j) (x), colgray(dots), colgray((partial f_1) / (partial x_n) (x));
    colgray((partial f_2) / (partial x_1) (x)), colgray(dots), (partial f_2) / (partial x_j) (x), colgray(dots), colgray((partial f_2) / (partial x_n) (x));
    colgray(dots.v), colgray(dots.down), dots.v, colgray(dots.down), colgray(dots.v);
    colgray((partial f_m) / (partial x_1) (x)), colgray(dots), (partial f_m) / (partial x_j) (x), colgray(dots), colgray((partial f_m) / (partial x_n) (x));
  )
$

== A tale of columns and rows

For a scalar-valued function $f : bb(R)^n -> bb(R)$, the Jacobian has one row:

$
  J_f (x) = nabla f(x)^top = mat(
    (partial f) / (partial x_1) (x), (partial f) / (partial x_2) (x), dots, (partial f) / (partial x_n) (x);
  )
$

We need $n$ forward-mode JVPs to compute it column by column:

$
  partial f(x)[e_1] = mat(
    (partial f) / (partial x_1) (x), colgray((partial f) / (partial x_2) (x)), colgray(dots), colgray((partial f) / (partial x_n) (x));
  ) \
  partial f(x)[e_2] = mat(
    colgray((partial f) / (partial x_1) (x)), (partial f) / (partial x_2) (x), colgray(dots), colgray((partial f) / (partial x_n) (x));
  )
$

Can we compute it row by row instead, in one shot?

== Columnwise Jacobian

#image("img/hill/forward_mode.svg", width: 100%)

Bad for gradients (just one row)

== Rowwise Jacobian

#grid(
  columns: (70%, auto),
  image("img/hill/reverse_mode.svg", width: 100%), [#v(6cm) Good for gradients (just one row)],
)

== Transpositions and adjoints

The adjoint of a linear map $ell: bb(R)^n -> bb(R)^m$ is the only linear map $ell^* : bb(R)^m -> bb(R)^n$ such that

$ forall (x, y) in bb(R)^n times bb(R)^m, quad chevron.l ell(x), y chevron.r = chevron.l x, ell^*(y) chevron.r $

If $ell$ is represented by a matrix $A$, then $ell^*$ is represented by $A^top$.

== Vector-Jacobian Products

If we could compute $partial f(x)^*$, it would give us rows of the Jacobian through VJPs:

$
  partial f(x)^*[e_i] = J_f(x)^top e_i = mat(
    colgray((partial f_1) / (partial x_1)(x)), colgray(dots), colgray((partial f_1) / (partial x_n)(x));
    colgray(dots.v), colgray(dots.down), colgray(dots.v);
    (partial f_i) / (partial x_1)(x), dots, (partial f_i) / (partial x_n)(x);
    colgray(dots.v), colgray(dots.down), colgray(dots.v);
    colgray((partial f_m) / (partial x_1)(x)), colgray(dots), colgray((partial f_m) / (partial x_n)(x));
  )
$

In particular, the gradient is just $nabla f(x) = partial f(x)^*[1]$.

== Adjoint chain rule

Adjoint of linear maps reverse order, like matrix transposes:

$
  partial f(x) = partial h(g(x)) compose partial g(x) \
  partial f(x)^* = partial g(x)^* compose partial h(g(x))^*
$

Now the propagation happens from the output back to the input:

$
  partial f(x)^*: & u stretch(arrow.l.bar)_(partial g(x)^*) v stretch(arrow.l.bar)_(partial h( g(x) )^*) w
$

We can differentiate any function in reverse mode knowing the adjoint derivatives of its layers.

== Transposed matmul & adjoint composition

#image("img/hill/reverse_mode_eval.svg", width: 100%)

== Back to our layer examples

Let $overline(y)$ be an arbitrary output cotangent (sensitivity).

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    align: horizon,
    inset: 10pt,
    table.header([*variables*], [*output*], [*function* $f(x)$], [*adjoint* $partial f(x)^*[overline(y)]$]),
    [$x in bb(R)$], [$y in bb(R)$], [$sin(x)$], [$cos(x)overline(y)$],
    [$x in bb(R)^n$], [$y in bb(R)^m$], [$A x + b$], [#pause $A^top overline(y)$],
    [$x in bb(R)^n$], [$y in bb(R)$], [$norm(x)^2$], [#pause $2 x overline(y)$],
    [$X in bb(R)^(n times n)$], [$Y in bb(R)^(n times n)$], [#pause $X^(-1)$], [$-X^(-top) overline(Y) X^(-top)$],
  )
]

More crazy formulas in #cite(<gilesExtendedCollectionMatrix2008>).

== This was reverse mode

Propagate the input through a chain of layers, record enough information, backpropagate the output cotangent.

#align(center)[
  #image("img/blondel/chain_vjp.pdf", height: 70%)
]

== Time complexity

*Theorem (Baur-Strassen):*
- Cost of 1 JVP (forward mode) $prop$ cost of 1 function call
- Cost of 1 VJP (reverse mode) $prop$ cost of 1 function call

Rather easy to believe:

- Individual derivatives not much harder than the corresponding layer
- Composition of linear maps adds up their computational costs

== Time complexity (special cases)

Assume the function $f$ can be computed in time $O(tau)$.

What is the complexity of computing a full Jacobian matrix?

#pause

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    align: horizon,
    inset: 10pt,
    table.header([*setting*], [*object*], [*forward mode*], [*reverse mode*]),
    $bb(R)^n -> bb(R)^m$, [Jacobian matrix], $O(n tau)$, $O(m tau)$,
    $bb(R)^n -> bb(R)$, [gradient vector], $O(n tau)$, $O(tau)$,
    $bb(R) -> bb(R)^m$, [derivative vector], $O(tau)$, $O(m tau)$,
  )
]

== Space complexity

#columns[
  #align(center)[
    #image("img/blondel/chain_jvp_memory.pdf")

    Forward mode has constant memory cost.
  ]

  #colbreak()

  #align(center)[
    #image("img/blondel/chain_vjp_memory.pdf")

    Reverse mode has linear memory cost (in the depth of the chain).
  ]
]

= Autodiff -- implementation

== Non-standard interpretation

Autodiff reinterprets a computer program to mean something else #cite(<margossianReviewAutomaticDifferentiation2019>).

We can take the same idea in other directions:

- Uncertainty propagation
- Physical unit checking
- Sparsity detection
- Kernel fusion

== Operator overloading

Pass augmented values to language operators & overload their behavior.

Example: `Dual` numbers in `ForwardDiff.jl` #cite(<revelsForwardModeAutomaticDifferentiation2016>).

#text(
  size: 1em,
)[
  #columns[
    ```julia
    using ForwardDiff: Dual

    u, u̇ = 2.0, 3.0
    v, v̇ = 4.0, 5.0
    du = Dual(u, u̇)
    dv = Dual(v, v̇)
    ```
    #colbreak()
    ```julia
    julia> du * dv
    Dual{Nothing}(8.0,22.0)

    julia> u * v̇ + v * u̇
    22.0

    julia> du / dv
    Dual{Nothing}(0.5,0.125)

    julia> (u̇ * v - v̇ * u) / v^2
    0.125
    ```
  ]
]

== Source transformation

Preprocess the source code to add derivative bookkeeping.

Example: #raw("jaxpr") intermediate representation in #raw("JAX") #cite(<bradburyJAXComposableTransformations2018>)

#text(
  size: 0.6em,
)[
  #columns[
    ```python
    import jax
    import jax.numpy as jnp

    def selu(x, alpha=1.67, lambda_=1.05):
        return lambda_ * jnp.where(
            x > 0,
            x,
            alpha * jnp.exp(x) - alpha
        )

    x = jnp.arange(5.0)
    jax.make_jaxpr(selu)(x)
    ```
    #colbreak()
    ```python
    { lambda ; a:f32[5]. let
        b:bool[5] = gt a 0.0:f32[]
        c:f32[5] = exp a
        d:f32[5] = mul 1.6699999570846558:f32[] c
        e:f32[5] = sub d 1.6699999570846558:f32[]
        f:f32[5] = jit[
          name=_where
          jaxpr={ lambda ; b:bool[5] a:f32[5] e:f32[5]. let
              f:f32[5] = select_n b e a
            in (f,) }
        ] b a e
        g:f32[5] = mul 1.0499999523162842:f32[] f
      in (g,) }
    ```
  ]
]

== Software

#columns[
  *Python libraries*

  - #link("https://github.com/HIPS/autograd")[#raw("autograd")] (historical)
  - #link("https://www.tensorflow.org/")[#raw("TensorFlow")]
  - #link("https://pytorch.org/")[#raw("PyTorch")]
  - #link("https://docs.jax.dev/en/latest/")[#raw("JAX")]

  #colbreak()

  *Julia libraries* (see #cite(<dalleCommonInterfaceAutomatic2025>))

  - #link("https://github.com/JuliaDiff/ForwardDiff.jl")[#raw("ForwardDiff.jl")]
  - #link("https://github.com/FluxML/Zygote.jl")[#raw("Zygote.jl")]
  - #link("https://github.com/EnzymeAD/Enzyme.jl")[#raw("Enzyme.jl")]
  - #link("https://github.com/chalk-lab/Mooncake.jl")[#raw("Mooncake.jl")]
]

#align(center)[
  #columns[
    #image("img/dalle/ecosystem_python.pdf", width: 60%)
    #image("img/dalle/ecosystem_julia_di.pdf", width: 60%)
  ]
]

== A subset of the language

Not every framework can differentiate every operation.

- `PyTorch`, `JAX`: restricted to domain-specific sublanguage
- `Zygote.jl`, `JAX`: error on code with mutation
- `ForwardDiff.jl`: errors on code with type constraints

#image("img/jax/thesharpbits.png", height: 50%)


== When to stop autodiffing

A function is approximated by a program #cite(<huckelheimTaxonomyAutomaticDifferentiation2024>). We can either

#columns[
  1. Differentiate the approximation
  #colbreak()
  2. Approximate the derivative
]

#align(center)[
  #image("img/huckelheim/integral.pdf", height: 65%)
]

== Example: Heron's method

The following iteration approximates the square root of $a in [0, infinity[$:

$ x_0 = a, quad x_(n+1) = 1/2 (x_n + a/x_n) $

#columns[
  #algo(line-numbers: false, inset: 20pt)[
    $x_0 = a$ \
    $dot(x)_0 = 1$ \
    While not converged #i\ \
    $x_(n+1) = 1/2 (x_n + a/x_n)$\ \
    $dot(x)_(n+1) = 1/2 (dot(x)_n + 1/x_n - (a dot(x)_n)/(2 x_n^2))$#d\ \
    Return $dot(x)_N$
  ]

  #colbreak()

  #algo(line-numbers: false, inset: 20pt)[
    $x_0 = a$ \
    While not converged #i\ \
    $x_(n+1) = 1/2 (x_n + a/x_n)$#d\ \
    Return $1 / (2 x_N)$
  ]
]

= CO layers -- theory

== Decision-focused learning

Using operations research solvers inside learning pipelines #cite(<mandiDecisionFocusedLearningFoundations2024>).

#image("img/mandi/Fig1.png", width: 100%)

- Ensures constraint satisfaction (better ML)
- Makes a solver data-driven (better CO)

== Notations

Typical pipeline focuses on learning costs, not constraints:

- $x$: input (contains the instance data)
- $theta$: cost vector
- $y$: solution to the optimization problem

Machine learning model: $hat(theta) = f_w (x)$

Optimization solver (linear objective):

$
  hat(y) = limits("argmax") {hat(theta)^top v: v in cal(Y)(x)}
$

where $cal(Y)(x)$ contains feasible solutions for $x$

== Prediction-focused learning

- Dataset: inputs and cost vectors ${(x_i, overline(theta)_i)}$

- Objective: minimize the error on cost prediction alone

$
  min_w 1/n sum_(i=1)^n ell(hat(theta)_i, overline(theta)_i) quad "with" quad hat(theta)_i = f_w (x_i)
$

Problem: doesn't take downstream decision into account, treats all errors the same.

== Learning by cost + solution imitation

Idea explained by @elmachtoubSmartPredictThen2022: learn to predict a cost _such that the downstream decision is good_.

True cost of the downstream decision: $overline(theta)^top hat(y)$

$
  min_w 1/n sum_(i=1)^n overline(theta)_i^top (op("argmin", limits: #true)_(y_i in cal(Y)(x_i)) hat(theta)_i^top y_i) quad "with" quad hat(theta)_i = f_w (x_i)
$

== Learning by solution imitation

Sometimes, true costs are not known.
Then, we learn to imitate known solutions, with a decision-aware loss:

$
  min_w 1/n sum_(i=1)^n ell(hat(theta)_i, y_i) quad "with" quad hat(theta)_i = f_w (x_i)
$

== Learning by experience

Most of the times, optimal solutions for training are expensive.

Then we just use a black-box cost evaluator:

$
  min_w 1/n sum_(i=1)^n c_(x_i)(op("argmin", limits: #true)_(y_i in cal(Y)(x_i)) hat(theta)_i^top y_i) quad "with" quad hat(theta)_i = f_w (x_i)
$

Similar to reinforcement learning but allows more structured actions.

== Differentiation challenge

Discrete solvers and program elements don't have useful derivatives.

#columns[

  #align(center)[
    #diagram(
      node-stroke: 1pt,
      $
        A edge(theta, ->) edge("d", 1, ->) & B edge("d", 1, ->) \
                             C edge(1, ->) & D
      $,
    )
  ]

  #colbreak()

  $
    "shortest_path"(theta) = cases(
      "ABD if" theta < 1,
      "ACD if" theta > 1,
      "both if" theta = 1
    )
  $

  Piecewise-constant function!

]

We need a nicely differentiable surrogate to allow backpropagation.

== Linear programs

#columns[

  #image("img/dalle/polytope.pdf")

  #colbreak()

  $
    y(theta) = "argmax" {theta^top y: A y <= b}
  $

  Feasible set is a polyhedron.

  Almost surely on $theta$, the optimum is a vertex.

  Requires smoothing!
]

= CO layers -- differentiation

== Smoothing linear programs

Three paradigms:
- Regularization
- Integration
- Clever loss

== Regularization

Solve a convex program instead!

Quadratic regularization #cite(<wilderMeldingDataDecisionsPipeline2019>):

$
  y_gamma (theta) = op("argmax", limits: #true)_v thick theta^top y - gamma norm(y)^2 quad "s.t." quad A y <= b
$

Logarithmic barrier #cite(<mandiInteriorPointSolving2020>):

$
  y_gamma (theta) = op("argmax", limits: #true)_y thick theta^top y - gamma sum_i log(s_i) quad "s.t." quad A y + s = b
$

Must use a different solver and differentiate the convex problem.

== Integration

#columns[
  Instead of picking a single polytope vertex, construct a probability distribution $p_theta (y)$ over solutions #cite(<dalleLearningCombinatorialOptimization2022>) #cite(<niepertImplicitMLEBackpropagating2021>) #cite(<paulusGradientEstimationStochastic2020>).

  Replace discrete optimizer with an expectation.

  $
    y_epsilon (theta) = bb(E)[op("argmax", limits: #true)_(y in cal(Y)) thick (theta + epsilon Z)^top y]
  $

  #image("img/berthet/perturbed_big.pdf", width: 100%)
]

== Clever loss

Differentiating through the solver itself may not be necessary.

Some loss functions provide (sometimes convex) surrogates #cite(<mandiDecisionFocusedLearningFoundations2024>):

#columns[
  - SPO+ loss #cite(<elmachtoubSmartPredictThen2022>)
  #colbreak()
  - Fenchel-Young loss #cite(<blondelLearningFenchelYoungLosses2020>)
]

#align(center)[
  #image("img/mandi/Fig3.png", height: 50%)
]

= CO layers -- practice

== Model structure

Key design choices in decision-focused learning:

- Choice of optimization solver
  - Practical relevance (close to real problem)
  - Fast enough (to be used in training)
- Choice of machine learning model
  - Expressivity (capture relevant features)
  - Variable size (adapts to small and large instances)
  - Invariance properties (respect problem symmetries)

== Generalized Linear Models

Many problems are on graphs $x = (cal(G), cal(E))$, with a cost function per edge:

$
  y(theta) = op("argmin", limits: #true)_y sum_(e in cal(E)) theta_e y_e quad "s.t". quad y in cal(Y)
$

Very simple model: combines edge features $phi_e$ with same weights $w$

$
  theta_e = sigma(w^top phi_e (x))
$

No interactions between edges in the model.

== Graph Neural Networks

Graph-equivariant functions $f$ are defined on node features $X$ such that

$
  f(P X) = P f(X) "for all permutations" P
$

#columns[

  Message-passing neural networks #cite(<velickovicMessagePassingAll2022>) are one such family:

  $
    h_u = phi(x_u, limits(xor.big)_(v in cal(N)_u) psi(x_u, x_v))
  $

  which aggregates information over neighborhoods

  #colbreak()

  #image("img/velickovic/GNN_GDL_TYPES_MP.pdf", width: 100%)

]

== Exercise

For each of the problems that follow:

- Choose an appropriate optimization solver
- Choose an appropriate statistical model
- Suggest relevant features
- Imagine a practical situation corresponding to each learning scenario

== Exercise: shortest paths on a map

- You are: an explorer
- I give you: a satellite image of a country
- You give me: the shortest path between the northernmost and southernmost points

#pause
#image("img/dalle/warcraft_pipeline.pdf", width: 80%)

== Example: stochastic vehicle scheduling

- You are: a taxi company in a city with unpredictable traffic
- I give you: a list of clients to transport
- You give me: the assignment of cars to trips

#pause
#image("img/dalle/stovsp_pipeline.pdf", width: 80%)

== Example: 2-stage spanning trees

- You are: an electrical network operator looking to connect all vertices
- I give you: fixed design costs + variable recourse costs
- You give me: which wires to build first before the variable costs are revealed

#pause
#image("img/dalle/spanning_tree_pipeline.pdf", width: 80%)

== Software

#columns[
  *Python libraries*

  - `cvxpylayers` #cite(<agrawalDifferentiableConvexOptimization2019>)
  - `TorchOpt` #cite(<renTorchOptEfficientLibrary2023>)
  - `optax` #cite(<deepmind2020jax>)
  - `Theseus` #cite(<pinedaTheseusLibraryDifferentiable2022>)
  - `PyEPO` #cite(<tangPyEPOPyTorchbasedEndtoend2024>)

  #colbreak()

  *Julia libraries*

  - `DiffOpt.jl` #cite(<sharmaFlexibleDifferentiableOptimization2022>)
  - `ImplicitDifferentiation.jl` #cite(<dalleMachineLearningCombinatorial2022>)
  - `InferOpt.jl` #cite(<dalleLearningCombinatorialOptimization2022>)
]

== Take-home messages

- Deep learning relies on the combination of differentiable layers
- Each layer needs a reverse-mode chain rule for efficient gradients
- Decision-focused learning uses discrete solvers as layers
- There are various learning scenarios depending on available data
- The loss function is not necessarily differentiable
- Models must be constructed based on the problem at hand

== References

#text(size: 12pt)[
  #bibliography("AD.bib", title: none)
]
