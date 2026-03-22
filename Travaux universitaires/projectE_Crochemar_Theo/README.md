# Malliavin Calculus Project – Monte Carlo Estimation of Greeks

This repository contains my **Project 5 in Malliavin Calculus**, focused on the theoretical and numerical computation of option sensitivities using both **finite-difference methods** and **Malliavin integration by parts**.

The project combines:
- a theoretical study of **Clark–Ocone representation**,
- the derivation of a **Malliavin weight formula** for the Delta of a path-dependent payoff,
- and a numerical comparison between **finite differences** and **Malliavin-based Monte Carlo estimators** in the **Bachelier model**.

## Project context

The project was completed in the context of a graduate-level course in **Malliavin Calculus**.  
The main goal is to estimate the **price** and the **Delta** of a complex Asian-style option and to compare different Monte Carlo approaches from both a theoretical and numerical perspective.

## Mathematical setting

We work in the **Bachelier model**
\[
X_t^x = x + B_t,
\]
with:
- initial value \(x = 100\),
- interest rate \(r = 10\%\),
- maturity \(T = 1\).

The payoff is
\[
\Phi\left(\int_0^T X_t^x\,dt,\;X_T^x\right)
=
\mathbf{1}_{\left\{\int_0^T X_t^x\,dt<110\right\}}(X_T^x-100)_+.
\]

This payoff is irregular because it involves both:
- an indicator function,
- and a kink through the positive part \((X_T^x-100)_+\).

This makes it a relevant example for studying the interest and the limitations of Malliavin-based estimators.

## Main objectives

The project is divided into three parts:

### 1. Theoretical foundations
- Density of stochastic integral representations in \(L^2\),
- Proof of the **Clark–Ocone formula**,
- Application to hedging in the Black–Scholes framework.

### 2. Malliavin representation of the Delta
- Derivation of the Delta formula for a payoff of the form
  \[
  \Phi\left(\int_0^T X_s^x\,ds,\;X_T^x\right),
  \]
- Characterization of admissible Malliavin weights,
- Explicit construction of the weight in the Bachelier model,
- Study of the optimality of the obtained weight.

### 3. Numerical experiments
- Monte Carlo estimation of the **price**,
- Delta estimation by **finite differences**,
- Delta estimation using the **Malliavin weight formula**,
- Comparison of both methods in terms of:
  - stability,
  - empirical variance,
  - confidence intervals.

## Numerical methods

### Price estimation
The time integral is discretized as
\[
\int_0^T X_t^x\,dt
\approx
\frac{T}{M}\sum_{k=0}^{M} X^x_{kT/M},
\]
for several discretization levels:
- \(M = 50\),
- \(M = 150\),
- \(M = 250\).

The price is then estimated by standard Monte Carlo simulation.

### Delta by finite differences
A centered finite-difference estimator is used:
\[
\widehat{\Delta}^{FD}_{N,\varepsilon}
=
\frac{\widehat P_N(x+\varepsilon)-\widehat P_N(x-\varepsilon)}{2\varepsilon}.
\]

To reduce variance, the implementation uses **common random numbers**.

### Delta by Malliavin calculus
Using the result derived in the project, the Delta can be written as
\[
\Delta(x)
=
e^{-rT}\mathbb{E}\left[
\Phi\left(\int_0^T X_t^x\,dt,\;X_T^x\right)\Pi
\right],
\]
with Malliavin weight
\[
\Pi
=
\frac{4}{T}B_T-\frac{6}{T^2}\int_0^T s\,dB_s.
\]

This gives a direct Monte Carlo estimator of the Delta.

## Main results

The numerical study leads to the following conclusions:

- The **price estimator** is stable and converges as expected when the number of simulations increases.
- The effect of the discretization parameter \(M\) on the price is relatively small for the tested values.
- The **finite-difference Delta estimator** is very stable and only weakly affected by \(M\).
- The perturbation parameter \(\varepsilon\) mainly affects the **variance** and the **confidence interval width**.
- In this implementation, the **Malliavin estimator is much noisier** than the finite-difference estimator.
- For the tested values, the empirical variance of the Malliavin estimator is roughly **22 times larger** than that of the finite-difference estimator, and its confidence intervals are about **4.7 times wider**.

A notable point is that these numerical results do **not** reproduce the favorable variance reduction effect often associated with Malliavin integration by parts for irregular payoffs. In this project, this may be explained by:
- the specific **Bachelier framework**,
- the discretization of the stochastic integral appearing in the Malliavin weight,
- and the strong variance reduction obtained by centered finite differences with common random numbers.

