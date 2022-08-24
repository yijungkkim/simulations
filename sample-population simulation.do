
* TRIAL 1: 10 samples with 50 observations each 
  clear
  set seed 12345
  set obs 50 // set observation for each sample
  forvalues i = 1/10 {
      gen height`i' = 150 +int((190-150+1)*runiform()) // gen i num samples, uniformly distributed between 150~190 
	  egen mheight`i'= mean(height`i') // gen mean of each sample
  }
  gen grandheight=rnormal(170,1) // gen normally distributed v, mean=170, sd=1
  egen grandmheight=rowmean(mheight*) // gen grandmean of all heights

  su  grandheight grandmheight // grandheight=170.11, grandmheight=169.46

  
  
* TRAIL 2: 500 samples with 1000 observations each
  clear
  set seed 12345
  set obs 1000 // set observation for each sample
  forvalues i = 1/500 {
      gen height`i' = 150 +int((190-150+1)*runiform()) // gen i num samples, uniformly distributed between 150~190  
	  egen mheight`i'= mean(height`i') // gen mean of each sample
  }
  gen grandheight=rnormal(170,1) // gen normally distributed v, mean=170, sd=1
  egen grandmheight=rowmean(mheight*) // gen grandmean of all heights

  su  grandheight grandmheight // grandheight=169.99, grandmheight=169.99
  
* SAE'S CODE

