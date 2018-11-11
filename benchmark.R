library(rbenchmark)
library(parallel)
library(doParallel)
library(foreach)
library(ggplot2)    

# https://www.slideshare.net/RevolutionAnalytics/speeding-up-r-with-parallel-programming-in-the-cloud
pbirthdaysim <- function(n) {
  ntests <- 100000
  pop <- 1:365
  anydup <- function(i)
    any(duplicated(
      sample(pop, n, replace=TRUE)))
  sum(sapply(seq(ntests), anydup)) / ntests
}

n.cores <- detectCores()
cl <- makeCluster(n.cores)
registerDoParallel(cl)

l <- list()

bmark <- benchmark(
  "for loop" = { for (i in 1:50) l[i] <- pbirthdaysim(i) },
  "lapply" = { lapply(1:50, pbirthdaysim) },
  "mclapply" = { mclapply(1:50, pbirthdaysim, mc.cores = 8) },
  "foreach parallel" = { foreach(i=1:50) %dopar% pbirthdaysim(i) }, replications = 1, columns = c("test", "elapsed", "relative"))

stopCluster(cl)
