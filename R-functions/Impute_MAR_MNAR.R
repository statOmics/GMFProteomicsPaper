imputation_NAs <- function(data, MISTOT = 0.1, MNAR = 0.25){
  
  data_noNA <- c(data[!is.na(data)])
  
  mean <- mean(c(data_noNA), na.rm = TRUE)
  sd = sd(c(data_noNA), na.rm = TRUE)
  
  q <- quantile(data_noNA, probs = MISTOT)
  q <- qnorm(p = MISTOT, mean = mean, sd = sd)
  threshold <- rnorm(n = length(c(data_noNA)), mean = q, sd = 0.01)
  
  censored <- c(threshold > data_noNA) 
  censored_bernouilli <- rbinom(n = sum(censored), prob = MNAR, size = 1)
  
  censored[censored == TRUE][censored_bernouilli == 0] <- FALSE
  
  MNAR_matrix <- matrix(0, ncol = ncol(data), nrow = nrow(data))
  MNAR_matrix[!is.na(data)][censored == TRUE] <- 1
  
  
  data[!is.na(data)][censored == TRUE] <- NA
  
  censored_ad_random <- rbinom(length(data[!is.na(data)]), 
                               prob = MISTOT*(1-MNAR), size = 1) == 1
  
  MAR_matrix <- matrix(0, ncol = ncol(data), nrow = nrow(data))
  MAR_matrix[!is.na(data)][censored_ad_random == TRUE] <- 1
  
  data[!is.na(data)][censored_ad_random == 1] <- NA
  
  return(list(data = data, MAR = MAR_matrix, MNAR = MNAR_matrix))
  
}