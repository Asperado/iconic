function A = gen_cov_matrix(visFeatures, featureData, Y)
    a11 = fast_cov2(visFeatures, visFeatures);
    a12 = fast_cov2(visFeatures, featureData);
    a13 = fast_cov2(visFeatures, Y);

    a21 = fast_cov2(featureData, visFeatures);
    a22 = fast_cov2(featureData, featureData);
    a23 = fast_cov2(featureData, Y);

    a31 = fast_cov2(Y, visFeatures);
    a32 = fast_cov2(Y, featureData);
    a33 = fast_cov2(Y, Y);
    
    A = [a11, a12, a13; a21, a22, a23; a31, a32, a33];
    A = A ./ (size(visFeatures, 1) - 1);
end