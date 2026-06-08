# Malliavin Calculus — Monte Carlo Estimation of Greeks

**Project 5 — Malliavin Calculus (graduate course)**

This repository covers the theoretical derivation and numerical estimation of option
sensitivities, comparing **finite-difference methods** with **Malliavin integration by
parts**. The work combines:

- a theoretical study of the **Clark–Ocone representation**,
- the derivation of a **Malliavin weight** for the Delta of a path-dependent payoff,
- a numerical comparison of **finite-difference** and **Malliavin-based** Monte Carlo
  estimators in the **Bachelier model**.

## Table of contents

1. [Mathematical setting](#mathematical-setting)
2. [Objectives](#objectives)
3. [Malliavin weight: derivation](#malliavin-weight-derivation)
4. [Numerical methods](#numerical-methods)
5. [Results](#results)
6. [Discussion](#discussion)
7. [Repository structure](#repository-structure)

## Mathematical setting

We work in the **Bachelier model** with unit volatility,

$$
X_t^x = x + B_t, \qquad t \in [0, T],
$$

where $(B_t)_{t \ge 0}$ is a standard Brownian motion. The model parameters are:

| Parameter | Symbol | Value |
|-----------|--------|-------|
| Initial value | $x$ | $100$ |
| Interest rate | $r$ | $10\%$ |
| Maturity | $T$ | $1$ |

The payoff is the discounted expectation of

$$\phi\:\left( \int_0^T X_t^x\,dt,\; X_T^x\right )$$
=
\mathbf{1}_{\left\{\int_0^T X_t^x\,dt \,<\, 110\right\}}\,(X_T^x - 100)_+ .
$$

This payoff is **irregular**: it combines an indicator function (discontinuity) with a
positive part (kink). It is therefore a natural test case for assessing both the
benefits and the limitations of Malliavin-based estimators.

## Objectives

### 1. Theoretical foundations
- $L^2(\Omega)$ approximation of square-integrable random variables by stochastic
  integrals,
- proof of the **Clark–Ocone formula**,
- application to hedging in the Black–Scholes framework.

### 2. Malliavin representation of the Delta
- derivation of the Delta formula for a payoff of the form
  $\Phi\!\left(\int_0^T X_s^x\,ds,\; X_T^x\right)$,
- characterization of admissible Malliavin weights,
- explicit construction of the weight in the Bachelier model,
- discussion of its optimality.

### 3. Numerical experiments
- Monte Carlo estimation of the **price**,
- Delta estimation by **finite differences**,
- Delta estimation via the **Malliavin weight**,
- comparison on **stability**, **empirical variance**, and **confidence intervals**.

## Malliavin weight: derivation

Write $I = \int_0^T X_t^x\,dt$ and note the two $x$-sensitivities

$$
\partial_x I = T, \qquad \partial_x X_T^x = 1 .
$$

We look for a deterministic direction $h \in L^2([0,T])$ such that

$$
\langle DI, h\rangle = \int_0^T (T - s)\,h(s)\,ds = T,
\qquad
\langle DX_T^x, h\rangle = \int_0^T h(s)\,ds = 1,
$$

using $D_s I = T - s$ and $D_s X_T^x = 1$. Looking for $h(s) = a + bs$ and solving the
two linear equations gives

$$
a = \frac{4}{T}, \qquad b = -\frac{6}{T^2}.
$$

The Delta then admits the Malliavin representation

$$
\Delta(x)
=
e^{-rT}\,\mathbb{E}\!\left[
\Phi\!\left(\int_0^T X_t^x\,dt,\; X_T^x\right)\Pi
\right],
\qquad
\Pi = \int_0^T h(s)\,dB_s = \frac{4}{T}B_T - \frac{6}{T^2}\int_0^T s\,dB_s .
$$

The discount factor $e^{-rT}$ is deterministic, so $\partial_x$ acts only on $\Phi$,
which justifies the formula above.

## Numerical methods

### Price estimation

The time integral is discretized by a (left) Riemann sum on a grid of $M$ steps,

$$
\int_0^T X_t^x\,dt
\;\approx\;
\frac{T}{M}\sum_{k=0}^{M-1} X^x_{kT/M},
$$

evaluated for $M \in \{50, 150, 250\}$. The price is estimated by standard Monte Carlo.

> Note: the sum runs over $M$ points (indices $0$ to $M-1$), so the total weight is
> exactly $T$. A trapezoidal rule, weighting the endpoints by $\tfrac12$, would reduce
> the discretization bias further.

### Delta by finite differences

A centered finite-difference estimator is used:

$$\widehat{\Delta}$$^$${\,FD}_{N,\varepsilon}$$
=
\frac{\widehat P_N(x+\varepsilon) - \widehat P_N(x-\varepsilon)}{2\varepsilon}.
$$

Variance is reduced by **common random numbers**: the same Brownian paths drive both
$\widehat P_N(x+\varepsilon)$ and $\widehat P_N(x-\varepsilon)$.

### Delta by Malliavin calculus

The weight derived above yields a direct Monte Carlo estimator:

$$
\widehat{\Delta}^{\,Mall}_N
=
\frac{e^{-rT}}{N}\sum_{i=1}^{N}
\Phi\!\left(\int_0^T X_t^{x,(i)}\,dt,\; X_T^{x,(i)}\right)\Pi^{(i)} .
$$

## Results

- The **price estimator** is stable and converges as the number of simulations grows.
- The discretization level $M$ has a **small effect** on the price over the tested range.
- The **finite-difference Delta** is very stable and only weakly affected by $M$.
- The perturbation $\varepsilon$ mainly drives the **variance** and the
  **confidence-interval width**.
- In this implementation, the **Malliavin estimator is noticeably noisier** than the
  finite-difference one.

| Estimator | Empirical variance | Confidence-interval width |
|-----------|--------------------|---------------------------|
| Finite differences (CRN) | baseline | baseline |
| Malliavin weight | $\approx 22\times$ larger | $\approx 4.7\times$ wider |

## Discussion

These results do **not** reproduce the variance reduction usually attributed to
Malliavin integration by parts for irregular payoffs. Plausible explanations:

- the specific **Bachelier framework** (additive noise, unit volatility);
- the **discretization** of the stochastic integral in the weight $\Pi$, which injects
  additional variance;
- the strong variance reduction already achieved by **centered finite differences with
  common random numbers**, a hard baseline to beat here.

## Repository structure

```
.
├── README.md
├── report/          # theoretical write-up (Clark–Ocone, weight derivation)
├── src/             # Monte Carlo estimators (price, FD Delta, Malliavin Delta)
└── results/         # figures, variance / CI tables
```
