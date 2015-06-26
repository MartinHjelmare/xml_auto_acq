## Author(s): Kalle von Feilitzen & Martin Hjelmare

# Gain calculation script
# Run with "Rscript path/to/script.r path/to/first/working/dir/
# path/to/first-histogram-csv-filebase path/to/first/initialgains/csv-file
# input-gains path/to/second/working/dir/
# path/to/second-histogram-csv-filebase path/to/second/initialgains/csv-file"
# from linux command line.
# Repeat for each well.

# Arguments and input needed:
# input_gain, one per channel, space separated string with four numbers for four channels
# first objective path/to/working/dir/
# second objective path/to/working/dir/
# first objective path/to/histogram-csv-filebase
# second objective path/to/histogram-csv-filebase
# initialgains for first objective
# initialgains for second objective

# Gain calculation script
first_obj_path <- commandArgs(TRUE)[1]
first_obj_base <- commandArgs(TRUE)[2]
first_init_gain_csv <- commandArgs(TRUE)[3]
input_gain <- as.numeric(strsplit(commandArgs(TRUE)[4], " ")[[1]])
sec_obj_path <- commandArgs(TRUE)[5]
sec_obj_base <- commandArgs(TRUE)[6]
sec_init_gain_csv <- commandArgs(TRUE)[7]

# Make function and call with the different objective arguments
# and with gain values from previous screening
# Return output from second regression curv function
# on_off is switch to specify what is x and what is y in plot, regression etc
func3 <- function(init_gain_csv, input, obj_path, obj_base, on_off) {
  
  gain <- list()
  bins <- list()
  gains <- list()
  
  green <- 11;      # 11 images
  blue <- 18;       # 7 images
  yellow <- 25;     # 7 images
  red <- 32;        # 7 images
  channel <- vector()
  channel_name <- vector()
  channel <- append(channel, rep(green, green-length(channel)))
  channel_name <- append(channel_name, rep('green', green-length(channel_name)))
  channel <- append(channel, rep(blue, blue-length(channel)))
  channel_name <- append(channel_name, rep('blue', blue-length(channel_name)))
  channel <- append(channel, rep(yellow, yellow-length(channel)))
  channel_name <- append(channel_name, rep('yellow', yellow-length(channel_name)))
  channel <- append(channel, rep(red, red-length(channel)))
  channel_name <- append(channel_name, rep('red', red-length(channel_name)))
  channels <- unique(channel)
  
  for (i in 1:(length(channels))) {
    bins[[i]] <- vector()
    gains[[i]] <- vector()
  }
  
  setwd(obj_path)
  filebase <- obj_base
  # Initial gain values used
  initialgains <- read.csv(init_gain_csv)$gain
  
  # Create curve and function for each individual well
  for (i in 1:32) {
    # Read histogram CSV file
    csvfile <- paste(filebase, "C", sprintf("%02d", i-1), ".ome.csv", sep="")
    csv <- read.csv(csvfile)
    csv1 <- csv[csv$count>0 & csv$bin>0,]
    bin1 <- csv1$bin
    count1 <- csv1$count
    # Only use values in interval 10-100
    binmax <- tail(csv$bin, n=1)
    csv2 <- csv[csv$count <= 100 & csv$count >= 10 & csv$bin < binmax,]
    bin2 <- csv2$bin
    count2 <- csv2$count
    # Plot values
    test <- 0
    if (on_off == "gain_bin") {
      png(filename=paste(filebase, "C", sprintf("%02d", i-1), ".gain-bin.ome.png", sep = ""))
    }
    if (on_off == "bin_gain") {
      png(filename=paste(filebase, "C", sprintf("%02d", i-1), ".bin-gain.ome.png", sep = ""))
    }
    if (length(bin1) > 0) {
      plot(count1, bin1, log="xy")
    }
    # Fit curve
    sink("/dev/null")	# Suppress output
    curv <- tryCatch(nls(bin2 ~ A*count2^B, start=list(A = 1000, B=-1), trace=T), warning=function(e) NULL, error=function(e) NULL)
    sink()
    if (!is.null(curv)) {
      # Plot curve
      lines(count2, fitted.values(curv), lwd=2, col="green")
      # Find function and save gain value
      func <- function(val, A=coef(curv)[1], B=coef(curv)[2]) {A*val^B}
      chn <- which(channels==channel[i])
      bins[[chn]] <- append(bins[[chn]], func(2))	# 2 is close to 0 but safer
      gains[[chn]] <- append(gains[[chn]], initialgains[i])
    }
    dev.off()
  }
  
  output <- vector()
  
  # Create curve and function for each channel (multiple wells)
  for (i in 1:(length(channels))) {
    
    bins_c <- bins[[i]]
    gains_c <- gains[[i]]
    
    # Remove values not making a upward trend (Martin Hjelmare)
    point.connected <- 0
    point.start <- 1
    point.end <- 1
    for (k in 1:(length(bins_c)-1)) {
      for (l in (k+1):length(bins_c)) {
        if (bins_c[l] >= bins_c[l-1]) {
          if ((l-k+1) > point.connected) {
            point.connected <- l-k+1
            point.start <- k
            point.end <- l
          }
        }
        else {
          break
        }
      }
    }
    bins_c <- bins_c[point.start:point.end]
    gains_c <- gains_c[point.start:point.end]
    gain[[i]] <- round(initialgains[channels[i]])
    
    # Switch to change axis for plots and regressions
    if (on_off == "gain_bin") {
      x <- gains_c
      y <- bins_c
      output[i] <- round(binmax)
    }
    if (on_off == "bin_gain") {
      x <- bins_c
      y <- gains_c
      output[i] <- round(gain[[i]])
    }
    if (on_off == "gain_bin") {
      png(filename=paste(filebase, channel_name[channels[i]], "gain-bin_gain.png", sep = ""))
    }
    if (on_off == "bin_gain") {
      png(filename=paste(filebase, channel_name[channels[i]], "bin-gain_gain.png", sep = ""))
    }
    plot(x, y)
    
    #if (length(bins_c) >= 3) {
    if (length(y) >= 3) {
      # Fit curve
      sink("/dev/null")	# Suppress output
      # Different nsl starting values depending on ON/OFF switch
      if (on_off == "gain_bin") {
        curv2 <- tryCatch(nls(y ~ exp(C+x*D), start=list(C=10, D=0), trace=T), warning=function(e) NULL, error=function(e) NULL)
      }
      if (on_off == "bin_gain") {
        curv2 <- tryCatch(nls(y ~ C*x^D, start=list(C=1, D=1), trace=T), warning=function(e) NULL, error=function(e) NULL)
      }
      sink()
      # Find function
      if (!is.null(curv2)) {
        if (on_off == "gain_bin") {
          func2 <- function(val, A=coef(curv2)[1], B=coef(curv2)[2]) {exp(A+val*B)}
        }
        if (on_off == "bin_gain") {
          func2 <- function(val, A=coef(curv2)[1], B=coef(curv2)[2]) {A*val^B}
        }
        lines(x, fitted.values(curv2), lwd=2, col="green")
        abline(v=input[i])
        
        # Enter gain values from previous gain screening with first
        # objective into function func2
        output[i] <- round(func2(input[i]))
      }
    }
    dev.off()
  }
  return(output)
}

# Use func3 to get output from first objective which will be input for second objective in func3 next round
input_sec_obj <- func3(first_init_gain_csv, input_gain, first_obj_path, first_obj_base, "gain_bin")
output_sec_obj <- func3(sec_init_gain_csv, input_sec_obj, sec_obj_path, sec_obj_base, "bin_gain")

cat(paste(output_sec_obj[1], output_sec_obj[2], output_sec_obj[3], output_sec_obj[4]))
