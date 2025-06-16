# Cross-Decoding Analysis of Action Representations using CoSMoMVPA

A MATLAB implementation of cross-decoding analysis to investigate the neural representations of person-directed and object-directed actions in the human brain using CoSMoMVPA.

## Overview

This script performs cross-decoding analysis to examine how different brain regions represent action features across different contexts. Specifically, it tests:

1. **Person-directedness across objects**: Can we decode person-directed vs. non-person-directed actions when generalizing across object-directedness?
2. **Object-directedness across persons**: Can we decode object-directed vs. non-object-directed actions when generalizing across person-directedness?

## Academic Context

This script was prepared for the Advanced fMRI Analysis course at CIMeC (Center for Mind/Brain Sciences) under the supervision of Prof. Wurm.(2024)

## Requirements

- MATLAB (tested on R2023a)
- [CoSMoMVPA toolbox](http://www.cosmomvpa.org/)

## Data Structure

The script expects the following data organization:

```
fMRIset2/
├── glm/
│   ├── SUB01_video_twoPerRunwise_sm3mm.mat
│   ├── SUB02_video_twoPerRunwise_sm3mm.mat
│   └── ... (19 subjects total)
└── msk/
    ├── univarConjunction_spherical_12mm_MTG.mat
    ├── univarConjunction_spherical_12mm_PMC.mat
    ├── univarConjunction_spherical_12mm_SPL.mat
    └── univarConjunction_spherical_12mm_IFG.mat
```

## Analysis Pipeline

### 1. Data Loading
- Loads GLM results for each subject
- Applies ROI masks (12mm spherical ROIs)
- Four ROIs analyzed: MTG, PMC, SPL, IFG

### 2. Cross-Decoding Design

#### Test 1: Person-Directedness
- **Training**: Object-directed actions (targets 1-4)
- **Testing**: Non-object-directed actions (targets 5-8)
- **Classification**: Person-directed (3,4,7,8) vs. Non-person-directed (1,2,5,6)

#### Test 2: Object-Directedness
- **Training**: Person-directed actions (targets 3,4,7,8)
- **Testing**: Non-person-directed actions (targets 1,2,5,6)
- **Classification**: Object-directed (1-4) vs. Non-object-directed (5-8)

### 3. Classification
- **Classifier**: Linear Discriminant Analysis (LDA)
- **Cross-validation**: Leave-one-run-out
- **Metric**: Classification accuracy

### 4. Statistical Analysis
- Computes mean accuracy across subjects
- Calculates standard error of the mean (SEM)
- Performs one-tailed one-sample t-tests against chance (50%)

## Usage

```matlab
% Run the entire analysis
cross_decoding_analysis

% The script will:
% 1. Loop through all 19 subjects
% 2. Perform both cross-decoding tests for each ROI
% 3. Generate bar plots with error bars
% 4. Output statistical results
```

## Output

### Variables
- `allRes`: 3D matrix containing accuracies [subjects × ROIs × tests]
- `meanAcc`: Mean accuracy across subjects
- `semAcc`: Standard error of the mean
- `H`, `P`, `CI`, `STAT`: T-test results

### Visualizations
The script generates two bar plots:
1. Person vs Non-Person Directed across objects
2. Object vs Non-Object Directed across persons

Each plot shows:
- Mean accuracy for each ROI
- Error bars (SEM)
- Chance level line (50%)

## Key Functions Used

### CoSMoMVPA Functions
- `cosmo_fmri_dataset`: Load fMRI data with mask
- `cosmo_match`: Select specific conditions
- `cosmo_slice`: Extract subset of dataset
- `cosmo_nfold_partitioner`: Create cross-validation partitions
- `cosmo_crossvalidation_measure`: Perform cross-validation
- `cosmo_classify_lda`: LDA classifier

## Experimental Design

The analysis uses a 2×2 factorial design:
- Factor 1: Person-directedness (person-directed vs. not)
- Factor 2: Object-directedness (object-directed vs. not)

This creates 8 unique conditions that allow for cross-decoding analyses to test the independence of neural representations.

## Notes

- The script uses 3mm smoothed data
- ROI masks are 12mm spherical regions
- Statistical tests are one-tailed (testing for above-chance performance)
- Chance level for binary classification is 50%


## References

- Oosterhof, N. N., Connolly, A. C., & Haxby, J. V. (2016). CoSMoMVPA: Multi-Modal Multivariate Pattern Analysis of Neuroimaging Data in Matlab/GNU Octave. Frontiers in Neuroinformatics, 10, 27.




This script is for educational purposes as part of the Advanced fMRI course at CIMeC.
