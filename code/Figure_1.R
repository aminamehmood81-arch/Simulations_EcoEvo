# Figure_1.R
# Author: Amina Mehmood
# Part 1 figure: a) deterministic vs stochastic time series, b) extinction probability.
# Panel b needs the 20 HPC result files in results/panel_b_rda/.
# Run from the project root:  Rscript code/Figure_1.R

rm(list = ls())
source("code/Demographic.R")

# ============================================================
# Panel a data (from Panel_A.R)
# ============================================================
set.seed(2026)
n_steps    <- 24
n_examples <- 5
time       <- 0:n_steps

det_100 <- deterministic_simulation(c(0, 0, 0, 100), projection_matrix, n_steps)
det_10  <- deterministic_simulation(c(0, 0, 0, 10),  projection_matrix, n_steps)

sto_100 <- replicate(n_examples, stochastic_simulation(c(0, 0, 0, 100), growth_matrix,
                     reproduction_matrix, clutch_distribution, n_steps))
sto_10  <- replicate(n_examples, stochastic_simulation(c(0, 0, 0, 10), growth_matrix,
                     reproduction_matrix, clutch_distribution, n_steps))

all_values <- c(det_100, det_10, sto_100, sto_10)
y_range    <- range(all_values[all_values > 0])
red_light  <- adjustcolor("red",  alpha.f = 0.45)
blue_light <- adjustcolor("blue", alpha.f = 0.45)

# ============================================================
# Panel b data (from Panel_B.R)  -- NO rm(list = ls()) here!
# ============================================================
rda_files <- list.files("results/panel_b_rda", pattern = "\\.rda$", full.names = TRUE)
stopifnot(length(rda_files) == 20)   # stop with an error if any HPC file is missing

initial_sizes <- c(3, 10, 30, 100)
size_names    <- as.character(initial_sizes)
n_extinct <- setNames(rep(0, 4), size_names)
n_runs    <- setNames(rep(0, 4), size_names)

for (f in rda_files) {
  load(f)
  for (N in size_names) {
    final_sizes  <- results[[N]][nrow(results[[N]]), ]   # last row = time step 120
    n_extinct[N] <- n_extinct[N] + sum(final_sizes == 0)
    n_runs[N]    <- n_runs[N] + length(final_sizes)
  }
}
p_extinct <- n_extinct / n_runs
se        <- sqrt(p_extinct * (1 - p_extinct) / n_runs)

# ============================================================
# Draw both panels side by side
# ============================================================
legend_inset <- c(0, -0.52)   # one value used by BOTH legends, so they sit level

pdf("results/figure_1.pdf", width = 10, height = 5, pointsize = 12)
par(mfrow = c(1, 2), mar = c(8, 5, 2.5, 1), font.lab = 2)   # same margins for both panels

# ---- Panel a ----
plot(time, det_100, type = "n", log = "y", ylim = y_range, las = 1,
     xlab = "Time step", ylab = "Total population size (log scale)",
     yaxt = "n", bty = "l")
axis(2, at = c(1, 2, 5, 10, 20, 50, 100, 200, 500), las = 1)
matlines(time, sto_100, col = red_light,  lty = 2, lwd = 1)
matlines(time, sto_10,  col = blue_light, lty = 2, lwd = 1)
lines(time, det_100, col = "red",  lwd = 3)
lines(time, det_10,  col = "blue", lwd = 3)
mtext("a)", side = 3, adj = 0, line = 0.5, font = 2, cex = 1.3)
legend("bottom", inset = legend_inset, xpd = TRUE, ncol = 2, bty = "n",
       legend = c("Start: 100 adults", "Start: 10 adults", "Deterministic", "Stochastic"),
       col = c("red", "blue", "black", "black"), lty = c(1, 1, 1, 2), lwd = c(3, 3, 3, 1))

# ---- Panel b ----
plot(initial_sizes, p_extinct, log = "x", type = "b", pch = 19, lwd = 1,
     xlim = c(2.5, 200), ylim = c(-0.02, max(p_extinct + se) * 1.1),
     xaxt = "n", las = 1, bty = "l",
     xlab = "Initial adult population size (log scale)",
     ylab = "Probability of extinction by time step 120")
axis(1, at = initial_sizes)
has_error <- se > 0
arrows(initial_sizes[has_error], (p_extinct - se)[has_error],
       initial_sizes[has_error], (p_extinct + se)[has_error],
       angle = 90, code = 3, length = 0.05)

# labels in front of every dot; last two lifted a little above the flat line
label_x <- initial_sizes * c(1, 1, 0.92, 0.92)    # nudge last two slightly left, closer to their dot
label_y <- p_extinct + c(0, 0, 0.025, 0.025)
text(label_x, label_y, labels = paste0("(", round(p_extinct, 3), ")"),
     pos = 4, offset = 0.6)
mtext("b)", side = 3, adj = 0, line = 0.5, font = 2, cex = 1.3)

# legend: dot for row 1, nothing yet for row 2 (we draw the error-bar symbol ourselves)
lg <- legend("bottom", inset = legend_inset, xpd = TRUE, bty = "n",
             legend = c("Extinction probability (800 runs per size)",
                        "Error bars: \u00B1 1 standard error"),
             pch = c(19, NA))

# draw a small error bar in row 2, directly under the dot of row 1
char_w <- par("cin")[1] * par("cex") * diff(par("usr")[1:2]) / par("pin")[1]
sym_x  <- 10^(lg$text$x[2] - char_w)
half_h <- 0.35 * strheight("M")
arrows(sym_x, lg$text$y[2] - half_h, sym_x, lg$text$y[2] + half_h,
       angle = 90, code = 3, length = 0.04, xpd = TRUE)
dev.off()