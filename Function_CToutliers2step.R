
# Load required packages
library(VGAM)
library(classInt)


##############################################################################
# function "CToutliers2step" to separate two CT distributions
#
# DESCRIPTION:
# This is a two-step function:
# Step 1: An optimal discrimination threshold between the carrier and non-carrier
#         distribution is estimated using function 'classIntervals' (package 'classInt')
#         using a bagged clustering algorithm (style 'bclust')
# Step 2: The parameters of a univariate normal distribution are estimated via
#         Maximum likelihood (function 'vglm', package 'VGAM') using all CT-values
#         below the obtained optimal threshold for the carrier distribution 
#         and above the threshold for the non-carrier distribution;  
#         Values below the threshold are defined as carriers, above as non-carriers; 
#         values that cannot be assigned unambiguously to one of the two distributions 
#         are marked as outliers and can be removed.
#
# The function requires 7 arguments, which can be set by the user.    
#
#
# INPUT:
# Mandatory Arguments:
# 1. CTvalues: measured Ct values [MANDATORY]
# 2. sampleID: unique key-variable with the IDs of the samples  [MANDATORY]
# 3. freqCarrier: estimated carrier frequency of the variant  [MANDATORY]
#
# Optional Arguments:
# 4. minplot: minimal value to be plotted on the x-axis (default=20)
# 5. maxplot: maximal value to be plotted on the x-axis (default=40)
# 6. prob1:  Values above the (1-prob1)-quantile of the carrier distribution 
#         and below the prob1-Quantile of the Non-Carrier distribution are
#         identified and marked as outliers, i.e. they cannot be assigned 
#         unambiguously to either the carrier or noncarrier-distribution (default=0.01)
# 7. prob2:  As prob1, but more conservative (default=0.025)
#
#
# OUTPUT: ('Value'):
# 1. Dataframe including all input-samples with the following variables:
# 2. sampleID
# 3. CTvalues
# 4. quantCarrier: distribution function of the estimated normal curve for carriers
# 5. quantNonCarrier: distribution function of the estimated normal curve for non-carriers
# 6. out1: =1: sample has been identified as outlier using prob1  
# 7. out2: =1: sample has been identified as outlier using prob2 
#
#
# EXAMPLE: ('Value'):
# 1. Run function below
# 2. Use the function as follows (assuming dataset 'data')
#    
# results <- CToutliers2step(CTvalues = data$ct,
#                           sampleID = data$id,
#                           freqCarrier = 0.1,
#                           ['optional_arguments'])
#


# FUNCTION

CToutliers2step<-function(CTvalues,sampleID,freqCarrier,minplot=20,maxplot=40,prob1=0.01,prob2=0.025)
{
  w=freqCarrier
  
  # calculate ideal discrimination point
  opt<-classIntervals(na.omit(CTvalues), n = 2, style = "bclust")$brks[2]
  print(paste("Optimal discrimination threshold =",opt))
  
  # fit univariate normal distribution to all values below threshold
  temp<-CTvalues[CTvalues<opt]
  fit <- vglm(temp ~ 1, uninormal())
  pars1<-as.vector(coef(fit))
  meanvalue1 = pars1[1]
  sdvalue1 = exp(pars1[2])
  
  # fit univariate normal distribution to all values above threshold
  temp<-CTvalues[CTvalues>=opt]
  fit <- vglm(temp ~ 1, uninormal())
  pars2<-as.vector(coef(fit))
  meanvalue2 = pars2[1]
  sdvalue2 = exp(pars2[2])
  
  # plot histogram
  hist(CTvalues,breaks=100,freq=F)
  abline(v=opt,lty=3,lwd=2)
  x1 <- seq(minplot, opt, 0.1)
  x2 <- seq(opt, maxplot, 0.1)
  points(x1, w*dnorm(x1, meanvalue1, sdvalue1),type="l", col="red", lwd=2)
  points(x2, (1-w)*dnorm(x2, meanvalue2, sdvalue2),type="l", col="blue", lwd=2)
  
  # identify outliers
  temp<-data.frame(sampleID,CTvalues)
  temp<-temp[order(temp$CTvalues),]
  temp$quantCarrier<-pnorm(temp$CTvalues,mean = meanvalue1, sd = sdvalue1)
  temp$quantNonCarrier<-pnorm(temp$CTvalues,mean = meanvalue2, sd = sdvalue2)
  temp$out1<-0
  temp$out2<-0
  temp$out1[temp$quantCarrier>(1-prob1) & temp$quantNonCarrier<=prob1]<-1
  outdata1<-temp[temp$out1==1,c("sampleID","CTvalues")]
  temp$out2[temp$quantCarrier>(1-prob2) & temp$quantNonCarrier<=prob2]<-1
  outdata2<-temp[temp$out2==1,c("sampleID","CTvalues")]
  print(paste("The following values are above the", (1-prob1),"quantile of the Carrier and below the",prob1,"quantile of the Non-Carrier distribution"))
  print(outdata1)
  print(paste("The following values are above the", (1-prob2),"quantile of the Carrier and below the",prob2,"quantile of the Non-Carrier distribution"))
  print(outdata2)
  if (dim(outdata1)[1]>0)
  {rect(min(outdata1$CTvalues-0.1),-0.008,max(outdata1$CTvalues+0.1),0,col="orange")}
  if (dim(outdata2)[1]>0)
  {rect(min(outdata2$CTvalues-0.1),-0.016,max(outdata2$CTvalues+0.1),-0.008,col="pink")}
  temp
}

