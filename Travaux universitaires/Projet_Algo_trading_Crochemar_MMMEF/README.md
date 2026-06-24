# Intraday Systematic Trading Backtester

A look-ahead-free Python backtesting engine for **1-minute equity-index data**, built with strict in-sample / out-of-sample discipline and statistical significance testing. Academic project for the *Systematic Trading Module* (M.Sc. Applied Mathematics & Quantitative Finance, Université Paris 1 Panthéon-Sorbonne).

> **Headline.** The engine is designed to evaluate a strategy *honestly*, not to advertise one. The main result is a rigorously demonstrated **absence of net edge**: out-of-sample gross returns are ≈ 0 and net returns are negative, a conclusion confirmed independently by an out-of-sample Sharpe confidence interval (Lo, 2002) and an in-sample Deflated Sharpe Ratio (Bailey & López de Prado, 2014). Demonstrating non-viability cleanly is the deliverable.

---

## Why this repository is worth a look

- **No look-ahead by construction.** The position `pos_t` is decided with information up to bar `t` and held over `t → t+1`, so `pnl_t = pos_t · (P_{t+1} - P_t)`. Causality is structural, not an afterthought.
- **Strict IS/OOS protocol.** Parameters are calibrated on the first 5 months and **frozen**; the out-of-sample month is run **exactly once**, with no re-optimization.
- **Fee-aware evaluation.** Per-leg transaction costs are modeled exactly; both **gross and net** P&L are reported, because the gap between them is the whole story at 1-minute frequency.
- **Statistical honesty.** Performance is not taken at face value: it is stress-tested with the Lo (2002) Sharpe standard error and the Bailey & López de Prado (2014) Deflated Sharpe Ratio, which correct for short samples, non-normality, and selection bias.

---

## Methodology

**Universe & data.** Five global indices at 1-minute resolution: S&P 500 (`GSPC`), Dow Jones (`DJI`), Russell 2000 (`RUT`), FTSE 100 (`FTSE`), Nikkei 225 (`N225`), over 6 Jan – 31 Jul 2025 (~7 months).

**In-sample / out-of-sample split.** IS = 6 Jan – 30 May 2025 (103 trading days, calibration only); OOS = 2 Jun – 31 Jul 2025 (44 days, validation). The split respects the brief's bounds (IS ≤ 5 months, OOS ≥ 1 month) and the OOS is **sealed**: a single pass, no iteration.

**Strategy (frozen).** Low-turnover intraday **momentum** on a causal rolling z-score:

- entry when `|z| > 3` (rare entries → low turnover), exit when `|z| < 0.3` or stop-loss;
- proportional sizing `w = tanh(γ·z)` frozen at entry, bounded in (−1, 1);
- 0.5 % stop-loss; flat at end of day (no overnight risk).

The momentum direction (continuation, not mean-reversion) was selected *after* a sign diagnostic, not assumed.

**Costs.** `fees += |Δpos| · bp · P_t` per leg, with `bp = 1e-4`; over a round trip this recovers the brief's formula `|pos| · bp · (S_start + S_end)`.

**Portfolio.** Equal-weight aggregation of per-asset daily net returns, with **per-day weight renormalization** over the assets actually trading (handles non-overlapping calendars, e.g. Japanese holidays).

**Validation.** Lo (2002) Sharpe standard error → out-of-sample confidence intervals; Deflated Sharpe Ratio → in-sample significance after correcting for ~30 trials and non-normality.

---

## Results (out-of-sample, sealed single run)

| Asset | Gross % | Net % | Ann. Sharpe | Max DD % | Trades/day |
|:--|--:|--:|--:|--:|--:|
| DJI | -0.21 | -0.79 | -1.84 | -1.43 | 0.9 |
| FTSE | -0.04 | -0.78 | -2.52 | -1.05 | 1.1 |
| GSPC | -1.46 | -2.14 | -6.00 | -2.52 | 1.0 |
| N225 | -0.22 | -0.53 | -1.78 | -0.63 | 0.5 |
| RUT | +1.66 | +1.23 | +2.30 | -0.68 | 0.7 |
| **Portfolio (with RUT)** | +0.02 | -0.54 | -2.19 | -0.95 | 4.1 |
| **Portfolio (ex-RUT)** | -0.42 | -1.01 | -4.52 | -1.17 | 3.5 |

**Reading.** Gross is ≈ 0; the negative net is essentially the fee drag. The in-sample Sharpe looked promising (≈ 1.9 with RUT) but the **Deflated Sharpe Ratio rejects it** (DSR = 0.92 with RUT, 0.38 without, both below the 0.95 threshold), and on 44 OOS days every Sharpe confidence interval contains zero except GSPC (significantly negative). The apparent in-sample edge was concentrated in a single asset (RUT) and a single regime (the April 2025 small-cap turbulence) and did not generalize.

---

## Repository structure

| File | Role |
|:--|:--|
| `config.py` | Central parameters (universe, fees, IS/OOS split, strategy params) |
| `data_loader.py` | Loads/cleans 1-min pickles; synthetic-data generator |
| `strategy.py` | Mean-reversion z-score signal (course baseline) |
| `strategy_momentum.py` | **Frozen strategy:** low-turnover momentum |
| `strategy_trend.py` | Trend variant |
| `strategy_intraday_momentum.py` | Gao et al. (2018) intraday-momentum signal |
| `backtester.py` | Look-ahead-free P&L engine with per-leg fees |
| `portfolio.py` | Daily-return aggregation; per-day weight renormalization; EW / inverse-vol |
| `calibrate_is.py` | In-sample grid search, robustness, γ-invariance |
| `compare_strategies.py` | A-priori 3-strategy in-sample comparison |
| `compare_trend.py` | Trend vs mean-reversion experiment |
| `diagnostics.py`, `diagnostics2.py` | Sign-flip diagnosis, RUT autopsy, 2×2 grid |
| `metrics.py` | **Sealed out-of-sample** performance matrix + Lo confidence intervals |
| `dsr.py` | Deflated Sharpe Ratio |
| `extract.py` | Initial data-extraction utility |

---

## Installation

```bash
git clone https://github.com/tcroche/<repo>.git
cd <repo>
pip install -r requirements.txt
```

Requires Python 3.12. Dependencies: `numpy`, `pandas` (everything else is standard library).

---

## Usage

The proprietary 1-minute data is **not** included (see below). Either drop your own `.pkl` files under `data/` (one file per ticker per day), or generate synthetic data to run the full pipeline end-to-end:

```bash
python -c "import data_loader, config; data_loader.generate_synthetic_dataset(tickers=config.UNIVERSE, n_days=150)"
```

Recommended execution order:

```bash
python data_loader.py         # 1. verify data loads
python calibrate_is.py        # 2. in-sample calibration + robustness grid
python compare_strategies.py  # 3. a-priori strategy comparison (IS)
python diagnostics2.py        # 4. RUT autopsy + 2x2 diagnostic grid
python portfolio.py           # 5. in-sample portfolio construction
python metrics.py             # 6. SEALED out-of-sample run (run once)
python dsr.py                 # 7. Deflated Sharpe Ratio
```

> `metrics.py` is the single, sealed out-of-sample pass. Re-running it on tuned parameters would turn the OOS into a second in-sample and invalidate the test.

---

## Data availability

The 1-minute index data used in the report is course-provided and is **not redistributed** here. The repository is fully runnable on the built-in synthetic generator (`data_loader.generate_synthetic_dataset`). Synthetic results are illustrative only — the figures in the report and above come from the real dataset.

---

## Key takeaways

- **Turnover, not signal direction, dominates at 1-minute frequency.** A high-turnover mean-reversion baseline loses ~50 % net in-sample; cutting turnover is what makes any variant survivable.
- **Work in return space, not price points.** Fees scale with price level, so cross-index comparisons are only meaningful in returns.
- **Effective sample size ≪ bar count.** ~150k autocorrelated 1-minute bars carry only ~100 quasi-independent daily observations — a hard constraint on any inference, machine learning included.
- **A rigorous null result is a valid deliverable.** The brief explicitly asks for a gross-vs-net viability assessment; demonstrating non-viability with IS/OOS discipline and significance testing is the intended outcome.

---

## References

- Bailey, D. H., & López de Prado, M. (2014). The Deflated Sharpe Ratio. *Journal of Portfolio Management*, 40(5), 94–107.
- Gao, L., Han, Y., Li, S. Z., & Zhou, G. (2018). Market Intraday Momentum. *Journal of Financial Economics*, 129(2), 394–414.
- Lo, A. W. (2002). The Statistics of Sharpe Ratios. *Financial Analysts Journal*, 58(4), 36–52.

---

## Author

**Théo Crochemar** — M.Sc. Applied Mathematics & Quantitative Finance, Université Paris 1 Panthéon-Sorbonne.
[LinkedIn](https://www.linkedin.com/in/theocrochemar/)
