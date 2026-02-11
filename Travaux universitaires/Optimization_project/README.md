# Numerical Methods for Optimization — Portfolio Optimization (Mean–Variance)

This repository contains my project for the course **Numerical Methods for Optimization** (Université Paris 1 Panthéon-Sorbonne, Jan–Feb 2026).

We study a **mean–variance portfolio optimization** problem with **12 assets**, comparing several numerical optimization algorithms on:
- an **unconstrained reduced quadratic problem** (after eliminating the equality constraint), and
- a **constrained problem on the probability simplex** (long-only portfolio).

---

## Problem

Given expected returns `μ`, covariance matrix `Σ`, and risk-aversion parameter `φ = 5`, we minimize:

$$
J(w) = w^\top \Sigma w - \varphi \, \mu^\top w 
$$

subject to:

- $\ w_i \ge 0 \$
- $\\sum_{i=1}^{12} w_i = 1 \$

---

## Methods Implemented

### Unconstrained (reduced) quadratic problem
After eliminating the equality constraint, the objective becomes:

$$
\tilde{J}(x) = x^\top Qx + q^\top x + r
$$

Implemented solvers:
- **Steepest Descent** with **Strong Wolfe** line search
- **Newton’s Method** with **Strong Wolfe** line search
- **Linear Conjugate Gradient** (solving the equivalent SPD linear system)
- **SciPy (BFGS)** as a reference/validation

### Constrained (simplex) problem
Implemented solver:
- **Projected Gradient Descent** on the simplex  
  - Euclidean projection
  - **Armijo** backtracking on the projected step
  - Stopping based on a **projected-gradient mapping**
---

## Results 

- **Steepest descent** converges but can require **many iterations** on ill-conditioned quadratics.
- **Newton** converges in **one iteration** for a quadratic objective with constant Hessian.
- **Linear CG** converges in a **small number of iterations**.
- **Projected GD** converges on the simplex and returns a **sparse** optimal portfolio.
