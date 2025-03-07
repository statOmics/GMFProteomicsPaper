
test_that("SGDImpute() works on gaussian data with missing values", {
    set.seed(100)
    dimred <- runSGD(sce, exprs_values = "logintensities",
                     family = gaussian(),
                     ncomponents = 5)
    res1 <- assay(SGDImpute(dimred, exprs_values = "logintensities"),
                  "logintensities_imputed")
    res2 <- assay(SGDImpute(sce,
                      sgdGMF_reducedDims = reducedDim(dimred, "SGD"),
                      exprs_values = "logintensities"),
                  "logintensities_imputed")
    res3 <- SGDImpute(assay(sce, 'logintensities'),
                      sgdGMF_reducedDims = reducedDim(dimred, "SGD"))

    expect_identical(res1, res2, res3)
    expect_equal(sum(is.na(res1)), 0)
})
