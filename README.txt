FACECOMPRULES

This project contains data and code for the experiments published in:
Cheng, McCarthy, Wang, Palmeri & Little (2017) JEP:LMC

Archive created 14-Sep-17
TODO: Add MDS analysis code (waiting on Tony)

========================================================================
Folders:
========================================================================
Experimental Code
------------------------------------------------------------------------
2014 FACECOMPRULES
- Contains MATLAB code for running Logical Rule experimental conditions from Cheng2017
- There are two versions of the main script:
-- RUN_FACECOMPRULES_v1.m is for the inverted faces and uses 0, .5, 1 morph levels 
-- RUN_FACECOMPRULES_v1.m is for the upright faces and uses .2, .6, .8 morph levels
-- (See Footnote 3 for more information)
-- Data was initial collected as part of honours projects for Xue Jun Cheng and Callum McCarthy

2015 COMPOSITE FACE TASK
- Contains MATLAB code for the Complete Design Composite Face task reported in Appendix C

2014 FACECOMPMDS [Turk]
- Javascript code for Amazon Turk MDS experiment

2014 FACECOMPMDS 
- Matlab code for MDS (not used in Cheng2017)

========================================================================
Data
- Contains Raw Data and analysis code from Cheng2017
------------------------------------------------------------------------

FaceCompRules
- Main analysis script is analyzeLogicalRules_FACECOMPRULES.m
- \rawdata\ contains raw data from 2014 FACECOMPRULES
-- columns are:
cols = {'sub', 'con', 'rot', 'ses', 'tri', 'itm', 'top', 'bot', 'rsp', 'cat', 'acc', 'rt'};
-- rot = rotation (not used)
-- items are numbered as follows: 1 = HH, 2 = HL, 3 = LH, 4 = LL, 5 = Ex, 6 = Ix, 7 = Ey, 8 = Iy, 9 = R
-- top is value of top half
-- bot is value of bottom half
- \Rdata\ is output from analysis for input to Houpt's SFT [R] package
-- cols are {'sub', 'con', 'rt', 'acc', 'itm'}
- \modeldata\ is output from analysis for input to DEMCMC modeling
-- files are .mat files
-- cols are {'sub', 'con', 'rot', 'ses', 'blk', 'tri', 'itm', 'top', 'bot', 'rsp', 'cat', 'acc', 'rt'}; 
- Subject numbers correspond to the paper as follows:
101 = UA1
103 = omitted for high error rates
105 = UA2
107 = UA3 
109 = UA4
202 = UM1
204 = UM2
206 = UM3
208 = omitted for high error rates
210 = UM4
301 = IA1
302 = IA2
303 = IA3
304 = IA4
306 = IA5
401 = IM1
402 = IM2
403 = IM3
404 = IM4


Composite Face Task
- Main analysis script is analyseData.m
- \rawdata\ contains raw data files from complete design composite face task
- Columns in data file are:
cols = {'Subject', 'Block', 'Number', 'Set', 'Cued', 'Resp', 'Congruent', 'Direction', 'Alignment', 'Study', 'Test', 'Correct', 'Response', 'RT'};
-- Number is Nominal Block (not used)
-- Set is Face Set (v1 or v2)
-- Cued is instructed attended face half (1 = Top, 0 = Bottom)
-- Resp is the correct reponse (1 = Same, 0 = Different)
-- Congruent is 1 if congruent trial, 0 if incongruent
-- Direction is 1 if upright, 0 if inverted
-- Alignment is 1 if aligned, 0 if split
-- Study is the study item
-- Test is the test item
-- Correct = 1 if correct, 0 if wrong
-- Response is the actual response = 1 if Same, 0 if DIff
-- RT is response time
- \csv_files\ contain the rawdata in csvfile format

FaceCompMDS [Turk]
- Main data used to derive the coordinates used in the modeling in the paper

FaceCompMDS 
- MDS data collected from *some* of the subjects who completed the logical rules study

========================================================================
Modeling
------------------------------------------------------------------------
DEMCMC_FACERULES
- Contains code for fitting logical rule models using DEMCMC
- Main file is DEMCMC_Facerules_All.m
-- This will run the DEMCMC estimation
- Use summarizeFitsFacerules.m to compute DIC
- Use plotPosteriors to view chains
- Use plotPosteriorPredictives to make plots in the supplementary material (need to load fit file first)
- Use plotPosteriorsViolin to make parameter plots in the supplement

DEMCMC_FACERULES_FREEDRIFT
- Contains code for fitting the free drift rate model using DEMCMC
