% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/influence_functions.R
\name{get_ifvals}
\alias{get_ifvals}
\title{Estimation of influence functions for the bounds on ATE}
\usage{
get_ifvals(n, eps, upper, nu, tau, ghatmat, delta = 1)
}
\arguments{
\item{n}{sample size.}

\item{eps}{vector of arbitrary length specifying the values for the 
proportion of confounding where the lower and upper bounds curves are 
evaluated.}

\item{upper}{boolean for whether the upper or the lower bound curve needs to
be computed.}

\item{nu}{nx1 vector of influence function values for the parameter 
E(E(Y|A = 1, X) - E(Y|A = 0, X)).}

\item{tau}{nx1 vector of influence function values for the parameter
E(g_l(eta)) is upper=FALSE or E(g_u(eta)) if upper=TRUE.}

\item{ghatmat}{nxd matrix containing the values of g_l(eta)
if upper=FALSE or g_u(eta) if upper=TRUE, evaluated at each values of X. 
Each column of the matrix represents the vector of values for a specific 
value of delta, the maximum bias allowed for the confounded units.}

\item{delta}{vector of arbitrary length specifyin the values of delta used
to bound maximal confounding among S = 0 units. Default is delta = 1, which 
imposes no assumption if the outcome Y is bounded.}
}
\value{
A list containing:
\item{ifvals} a n x length(eps) x length(delta) array containing 
the influence functions (varphi_l or varphi_u in manuscript) evaluated at 
the observed X as a function of epsilon and delta; 
\item{lambda} a n x length(eps) x length(delta) array containing 
the indicator ghatmat <= q if upper = FALSE or ghatmat > q, where q is 
eps-quantile or (1-eps)-quantile of ghatmat.
\item{quant} a length(eps) x length(delta) matrix containing the estimated
quantiles of ghatmat as a function of eps and delta. If upper = FALSE, 
eps-quantiles are returned, if upper = TRUE, (1-eps)-quantiles are returned.
\item{lambdaq} the product lambda * quant as a function of eps and delta.
}
\description{
\code{get_ifvals} is the main function for getting the influence 
function values used to construct the estimator of either the lower and upper 
bound curves.
}
\examples{
eps <- seq(0, 0.1, 0.01)
delta <- c(0.5, 1)
n <- 500
x <- data.frame(x1 = rnorm(n), x2 = runif(n))
a <- rbinom(n, 1, pnorm(x$x1))
y <- 2 + x$x1 - x$x2 + rnorm(n)
ymin <- min(y)
ymax <- max(y)
nuis_fns <- do_crossfit(y, a, x, min(y), max(y), outfam = gaussian(), 
                        treatfam = binomial(), nsplits = 5, 
                        sl.lib = c("SL.mean", "SL.glm", "SL.gam"))
pi0hat <- nuis_fns[, "pi0"]
pi1hat <- nuis_fns[, "pi1"]
mu0hat <- nuis_fns[, "mu0"]
mu1hat <- nuis_fns[, "mu1"]

psi0hat <- if_gamma(y = y, a = a, aval = 0, pia = pi0hat, mua = mu0hat)
psi1hat <- if_gamma(y = y, a = a, aval = 1, pia = pi1hat, mua = mu1hat)
nuhat <- as.matrix(psi1hat - psi0hat)
guhat <- pi0hat * (ymax - mu1hat) - pi1hat * (ymin - mu0hat)
glhat <- pi0hat * (ymin - mu1hat) - pi1hat * (ymax - mu0hat)
glhat <- glhat \%*\% t(delta)
guhat <- guhat \%*\% t(delta)

tauhat_lb <- if_tau(y = y, a = a, ymin = ymin, ymax = ymax, pi0 = pi0hat, 
                    pi1 = pi1hat, mu0 = mu0hat, mu1 = mu1hat, upper = FALSE)
tauhat_ub <- if_tau(y = y, a = a, ymin = ymin, ymax = ymax, pi0 = pi0hat, 
                    pi1 = pi1hat, mu0 = mu0hat, mu1 = mu1hat, upper = TRUE)
tauhat_lb <- tauhat_lb \%*\% t(delta)
tauhat_ub <- tauhat_ub \%*\% t(delta)
                    
list_lb <- get_ifvals(n = n, eps = eps, delta = delta, upper = FALSE, 
                      nu = nuhat, tau = tauhat_lb, ghatmat = glhat)
list_ub <- get_ifvals(n = n, eps = eps, delta = delta, upper = TRUE, 
                      nu = nuhat, tau = tauhat_ub, ghatmat = guhat)
                      
head(list_lb$quant)
head(list_ub$quant)
head(list_lb$ifvals[, , 1])
head(list_ub$ifvals[, , 1])
head(list_lb$lambdaq[, , 1])
head(list_ub$lambdaq[, , 1])

}
\seealso{
\code{\link{if_gamma}}, \code{\link{if_tau}}.
}
