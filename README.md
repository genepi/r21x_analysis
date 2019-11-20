
## Introduction
...

## Help

### Execute the script
 1. Run function below included in script
 2. Use the function as follows (assuming dataset 'data')
    
 `results <- CToutliers2step(CTvalues = data$ct,
                           sampleID = data$id,
                           freqCarrier = 0.1,
                           ['optional_arguments'])`
 
## Input Parameters 
### Mandatory Arguments:
 1. CTvalues: measured Ct values [MANDATORY]
 2. sampleID: unique key-variable with the IDs of the samples  [MANDATORY]
 3. freqCarrier: estimated carrier frequency of the variant  [MANDATORY]

### Optional Arguments:
 4. minplot: minimal value to be plotted on the x-axis (default=20)
 5. maxplot: maximal value to be plotted on the x-axis (default=40)
 6. prob1:  Values above the (1-prob1)-quantile of the carrier distribution and below the prob1-Quantile of the Non-Carrier distribution are identified and marked as outliers, i.e. they cannot be assigned unambiguously to either the carrier or noncarrier-distribution (default=0.01)
 7. prob2:  As prob1, but more conservative (default=0.025)


## Output Parameters 
 1. Dataframe including all input-samples with the following variables:
 2. sampleID
 3. CTvalues
 4. quantCarrier: distribution function of the estimated normal curve for carriers
 5. quantNonCarrier: distribution function of the estimated normal curve for non-carriers
 6. out1: =1: sample has been identified as outlier using prob1  
 7. out2: =1: sample has been identified as outlier using prob2 


