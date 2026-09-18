"""
Follow-up experiment (README, section 8).

The Malliavin weight  Pi = (4/T) B_T - (6/T^2) int_0^T s dB_s  is discretised in the
notebook with a left-point Ito sum, sum_k t_k * dB_k. Because the payoff depends on
B_T and the discretisation error is a centred Gaussian correlated with B_T, this
introduces a first-order bias  e^{-rT} * 3 / (2M)  in the Delta estimator.
Using the midpoint  t_{k+1/2}  removes it.

Run:  python malliavin_weight_bias_check.py
"""
import math
import numpy as np

X0, R, T = 100.0, 0.10, 1.0
STRIKE, BARRIER = 100.0, 110.0
N_PATHS, SEED = 400_000, 0

rng = np.random.default_rng(SEED)


def malliavin_delta(M, rule):
    """Monte Carlo Delta with the Malliavin weight; rule in {'left', 'mid'}."""
    dt = T / M
    dB = math.sqrt(dt) * rng.standard_normal((N_PATHS, M))
    B = np.concatenate([np.zeros((N_PATHS, 1)), np.cumsum(dB, axis=1)], axis=1)
    X = X0 + B
    A = (T / M) * X.sum(axis=1)                       # same discretisation as the notebook
    payoff = np.where(A < BARRIER, 1.0, 0.0) * np.maximum(X[:, -1] - STRIKE, 0.0)

    t = (np.arange(M) + (0.5 if rule == "mid" else 0.0)) * dt
    pi = (4.0 / T) * B[:, -1] - (6.0 / T**2) * (t * dB).sum(axis=1)

    sample = math.exp(-R * T) * payoff * pi
    return sample.mean(), 1.96 * sample.std(ddof=1) / math.sqrt(N_PATHS)


if __name__ == "__main__":
    closed_form = 0.5 * math.exp(-R * T)               # ATM Bachelier call, sigma = 1
    print(f"closed-form Delta = {closed_form:.5f}\n")
    print(f"{'M':>4} | {'left-point':>18} | {'midpoint':>18} | predicted bias")
    for M in (50, 150, 250):
        dl, cl = malliavin_delta(M, "left")
        dm, cm = malliavin_delta(M, "mid")
        print(f"{M:>4} | {dl:.4f} +/- {cl:.4f} | {dm:.4f} +/- {cm:.4f} | "
              f"{math.exp(-R * T) * 1.5 / M:.4f}")
