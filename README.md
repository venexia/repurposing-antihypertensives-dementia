# Comparison of antihypertensive drug classes for dementia prevention: an instrumental variable analysis study

This respository contains the code to reproduce the analysis from the following paper:

Walker, V., Davies, N., Martin, R., & Kehoe, P. (2019). Comparison of antihypertensive drug classes for dementia prevention. BioRxiv. https://doi.org/10.1101/517482

## Abstract

Introduction: There is evidence that hypertension in midlife can increase the risk of Alzheimer’s disease and vascular dementia in late life. In addition, some treatments for hypertension have been proposed to have cognitive benefits, independent of their effect on hypertension. Consequently, there is potential to repurpose treatments for hypertension for dementia. This study systematically compared seven antihypertensive drug classes for this purpose, using data on over 849,000 patients from the Clinical Practice Research Datalink. 

Methods: Treatments for hypertension were assessed in an instrumental variable (IV) analysis to address potential confounding and reverse causation. Physicians’ prescribing preference was used as a categorical instrument, defined by the physicians’ last seven prescriptions. Participants were new antihypertensive users between 1996-2016, aged 40 and over.

Findings: We analysed 849,378 patients with total follow up of 5,497,266 patient-years. Beta-adrenoceptor blockers and vasodilator antihypertensives were found to confer small protective effects – for example, vasodilator antihypertensives resulted in 27 (95% CI: 17 to 38; p=4.4e-7) fewer cases of any dementia per 1000 treated compared with diuretics.

Interpretation: We found small differences in antihypertensive drug class effects on risk of dementia outcomes. However, we show the magnitude of the differences between drug classes is smaller than previously reported. Future research should look to implement other causal analysis methods to address biases in conventional observational research with the ultimate aim of triangulating the evidence concerning this hypothesis.

## Using this code

To run this code, set your working directory in the files ‘Hypertentension.do’ and ‘Hypertentension.R’. Make sure you have installed the required dependencies, listed in 'dependency.do' and 'dependency.R' respectively. You should then be able to run the file ‘Hypertentension.do’ in Stata initially and then ‘Hypertentension.R’ in R. All other files are called when required from these files. The Stata code covers most of the analysis, while the R code covers most of the graphical and supplementary output. Setup of the CPRD dataset prior to this analysis is covered in a separate repository: https://github.com/venexia/CleanCPRD.

## Availability of data

The data used in this project are available on application from the Clinical Practice Research Datalink.

## Supplementary material

This repository contains three further items of supplementary material in the folder ‘Supplement’: 
- [AntihypertensivesIV_Codelists.xlsx](https://github.com/venexia/repurposing-antihypertensives-dementia/blob/master/supplement/AntihypertensivesIV_Codelists.xlsx), which contains the code lists used to define the diagnoses and treatments in the CPRD as used in this study
- [AntihypertensivesIV_eTables.xlsx](https://github.com/venexia/repurposing-antihypertensives-dementia/blob/master/supplement/AntihypertensivesIV_eTables.xlsx), which contains the supplementary tables associated with this paper
- [AntihypertensivesIV_eText_eFigures.pdf](https://github.com/venexia/repurposing-antihypertensives-dementia/blob/master/supplement/AntihypertensivesIV_eText_eFigures.pdf), which contains the supplementary test and figures associated with this paper

## Funding statement

This work was supported by the Perros Trust and the Integrative Epidemiology Unit. The Integrative Epidemiology Unit is supported by the Medical Research Council and the University of Bristol [grant number MC_UU_00011/1, MC_UU_00011/3]. 

## Further information

If you would like any further information, please contact venexia.walker@bristol.ac.uk. 