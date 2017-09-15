function BIC = computeBICfromR2(R2, n, k)
% R2 = r-squared
% n = number of data points used to compute R2
% k = number of free parameters used to estimate predictions for computing
%     R2

BIC = n * log(1 - R2) + k * log(n);