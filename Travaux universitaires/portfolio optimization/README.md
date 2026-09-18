# ETF Universe Analysis & Return-Based Replication of Two Anonymized Allocations

*M2 MMMEF, Université Paris 1 Panthéon-Sorbonne — Python for Finance project (November 2025).*

> **Headline.** Starting from 105 anonymised ETF price series, 14 asset-class indices and the NAVs of two unknown portfolios (2019-01-02 → 2024-05-20, **1,404 common trading days**), the project reverse-engineers what the two portfolios hold. A static no-intercept regression on the 20 most correlated ETFs explains **97.3 %** of the daily return variance of Mystery Allocation 1 and **91.4 %** of Mystery Allocation 2. Mapped onto the asset-class indices, Allocation 1 is a pure **US-equity** mix (S&P 500 / Nasdaq 100 / small caps, roughly one third each); Allocation 2 is a **global-equity** mix (US, Euro area, UK) with a small **US high-yield** sleeve, and a 60-day rolling regression confirms that its exposures drift over time. The universe itself is characterised by risk metrics, k-means clustering and a correlation-based mapping to the main asset classes.

## Contents

1. [Data](#1-data)
2. [Pipeline](#2-pipeline)
3. [Results](#3-results)
4. [Limitations and what I would do next](#4-limitations-and-what-i-would-do-next)
5. [Repository structure](#5-repository-structure)
6. [Running the code](#6-running-the-code)

## 1. Data

Four CSV files supplied with the assignment (course material, not redistributed here):

| File | Content | Shape |
|---|---|---|
| `Anonymized ETFs.csv` | 105 ETF price indices, rebased to 100 on 2019-01-01 | 1,405 × 105 |
| `Main Asset Classes.csv` | 14 broad indices: S&P 500, Nasdaq 100, US Small Caps, Euro Stoxx 50, UK FTSE, MSCI EM, Japan, US IG, US HY, EU IG, EU HY, EM Bond, Gold, Commodity | 1,668 × 14 |
| `Mystery Allocation 1.csv` | NAV of a portfolio built from the 105 ETFs with a **fixed** allocation | 1,405 × 1 |
| `Mystery Allocation 2.csv` | NAV of a portfolio with a **slowly changing** allocation | 1,405 × 1 |

All series are aligned on their common dates (1,404 daily simple returns).

## 2. Pipeline

Everything lives in one notebook, organised as a script with six numbered sections (`1. Data loading` … `6. Main program`).

**2.1 Returns and risk metrics** — for each ETF: annualised return (compounded mean daily return, 252 days), annualised volatility, Sharpe ratio (risk-free rate set to 0), maximum drawdown on the price index.

**2.2 Clustering** — k-means (k = 4, 10 restarts, fixed seed) on the z-scored triplet (annualised return, volatility, Sharpe), to segment the universe into risk profiles.

**2.3 ETF → asset-class mapping** — correlation matrix between the 105 ETF return series and the 14 index return series; each ETF is assigned the index with the highest absolute correlation (e.g. ETF 1 → S&P 500 with ρ = 1.000, ETF 3 → MSCI EM with ρ = 0.999, ETF 5 → UK FTSE with ρ = 1.000).

**2.4 Static replication of the Mystery Allocations** — three steps:
1. screen the **20 ETFs** most correlated (in absolute value) with the portfolio's returns;
2. ordinary least squares **without intercept**, $r^{port}_t \approx \sum_j w_j\, r^{ETF_j}_t$, solved with `numpy.linalg.lstsq`; the $R^2$ of this fit is the goodness-of-fit measure;
3. long-only reading of the weights: negative coefficients are set to zero and the remainder is renormalised to sum to one.

**2.5 Rolling replication** — for Allocation 2 only: the same no-intercept OLS on a **60-day rolling window**, restricted to the 10 ETFs most correlated over the full sample, to visualise time-varying weights.

**2.6 Asset-class exposure** — each ETF's long-only weight is split across its three most correlated indices, proportionally to |ρ|, and the contributions are summed.

## 3. Results

### 3.1 The universe

Annualised volatility across the 105 ETFs: min 0.02 % (a cash-like instrument), Q1 8.7 %, median 17.0 %, Q3 20.1 %, max 28.3 %. The universe therefore spans money-market-like and fixed-income exposures up to volatile equity and commodity exposures.

k-means splits it into two large groups (77 and 26 ETFs) and two singletons — see §4 on why the singletons are a limitation rather than a finding.

### 3.2 Mystery Allocation 1 — static, US equity

| | |
|---|---|
| $R^2$ of the 20-ETF regression | **0.973** |
| Largest long-only weights | ETF 22 (30.6 %), ETF 1 (20.3 %), ETF 92 (14.5 %), ETF 50 (9.6 %), ETF 59 (7.8 %) |
| Asset-class exposure | S&P 500 **35.5 %**, Nasdaq 100 **32.8 %**, US Small Caps **31.7 %**, all others 0 |

A fixed combination of a handful of ETFs explains almost all daily moves, consistent with the "fixed allocation" description of the file. The implied exposure is pure US equity with a balanced large-cap / growth / small-cap tilt.

### 3.3 Mystery Allocation 2 — dynamic, global equity + high yield

| | |
|---|---|
| $R^2$ of the 20-ETF regression | **0.914** |
| Largest long-only weights | ETF 60 (34.3 %), ETF 4 (25.8 %), ETF 14 (13.9 %), ETF 18 (7.4 %), ETF 2 (6.0 %) |
| Asset-class exposure | S&P 500 **24.5 %**, Euro Stoxx 50 **22.4 %**, UK FTSE **20.1 %**, Nasdaq 100 **13.9 %**, US Small Caps **13.8 %**, US HY **5.3 %** |

The lower $R^2$ is what a slowly changing allocation should produce when fitted with constant weights. The rolling 60-day regression shows unstable coefficients over time, in line with a drifting allocation, but the raw rolling weights are too noisy to be read as portfolio weights (§4).

## 4. Limitations and what I would do next

This section is deliberately explicit: a recruiter reading the notebook will notice these points, and they are the parts of the project I would rework.

1. **Long-only weights are obtained by clipping, not by constrained estimation.** Zeroing negative OLS coefficients and renormalising is not the least-squares solution under $w \ge 0$, $\sum w = 1$; the reported $R^2$ belongs to the unconstrained fit, not to the long-only weights. The fix is non-negative least squares (`scipy.optimize.nnls`) or a small QP with `cvxpy`, reporting the $R^2$ of the constrained fit.
2. **The rolling regression is ill-conditioned.** Ten highly collinear ETFs on 60 observations produce raw weights swinging between roughly −6 and +6 from one day to the next. It supports the qualitative claim "the allocation moves" but nothing more. Ridge or simplex-constrained rolling regressions, or a Kalman filter on the weights, would make the dynamics interpretable.
3. **k-means is dominated by outliers.** Two of the four clusters are singletons: the near-zero-volatility ETF has an extreme standardised Sharpe ratio and gets its own cluster. Excluding cash-like instruments, using robust scaling, and choosing $k$ by silhouette score would give a usable segmentation.
4. **The asset-class exposure is a heuristic.** Splitting each ETF weight across its three most correlated indices is an ad-hoc allocation rule. The standard approach is a returns-based style analysis (Sharpe, 1992): regress the portfolio directly on the 14 indices under long-only and full-investment constraints.
5. **No out-of-sample validation.** The replication is fitted and evaluated on the same sample; a held-out year would tell whether the static 20-ETF portfolio actually tracks the target.
6. Minor: the Sharpe ratio uses a zero risk-free rate, and the annualised return compounds the mean daily return; both are simplifications stated in the report.

## 5. Repository structure

```
.
├── README.md
├── README_PORT_FR.md                        # version française
├── final version .ipynb                     # full pipeline (sections 1–6), executed with outputs
└── python_project_report_complete.pdf       # code listing + written report (methodology, results, limitations)
```

## 6. Running the code

```bash
pip install numpy pandas scikit-learn matplotlib jupyter
# place the four CSV files next to the notebook, then run all cells
jupyter notebook "final version .ipynb"
```

The plotting helpers (`plot_mystery_nav`, `plot_etf_risk_return`, `plot_asset_exposure`, `plot_rolling_weights`, …) are defined in section 5 of the notebook and called from the commented-out lines at the end of `main()`.
