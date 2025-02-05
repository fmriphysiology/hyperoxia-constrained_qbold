# Code developed to analyse a new approach to mapping oxygen extraction fraction 

The code in this repository was used to analyse quantitative BOLD (qBOLD) data to estimate the oxygen extraction fraction (OEF) following two approaches. 
* Streamlined-qBOLD - a recently developed technique using a FLAIR-GASE acquisition to remove the confounding effects of cerebral spinal fluid, large scale magnetic field inhomogeneity and, by keeping a constant echo time, T2-weighting.
* Hyperoxia-constrained qBOLD - is a novel multiparametric qBOLD technique using hyperoxia BOLD to map deoxygenated blood volume and a FLAIR-GASE acquisition to map R2'

Comparison was made with a whole brain measurement of OEF using TRUST. Please reference this code using the forthcoming Zenodo DOI if you use it in your work. 

Data were analysed using MATLAB version 9.13.0.2193358 (R2022b) and FSL (FMRIB Software Library) version 6.0.6.4 on macOS 13.2.1.
