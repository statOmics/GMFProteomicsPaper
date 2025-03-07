
test_that("calculateSGD() works on poisson data", {
    set.seed(100)
    res1 <- reducedDim(runSGD(sce, ncomponents = 5), "SGD")
    set.seed(100)
    res2 <- calculateSGD(sce, ncomponents = 5)
    set.seed(100)
    res3 <- calculateSGD(assay(sce, 'counts'), ncomponents = 5)


    expect_identical(c(res1), c(res2), c(res3))
    expect_identical(attr(res1, "X"), attr(res2, "X"), attr(res3, "X"))
    expect_identical(attr(res1, "Beta"), attr(res2, "Beta"), attr(res3, "Beta"))
    expect_identical(attr(res1, "Beta"), attr(res2, "Beta"), attr(res3, "Beta"))
    expect_identical(attr(res1, "Z"), attr(res2, "Z"), attr(res3, "Z"))
    expect_identical(attr(res1, "Gamma"), attr(res2, "Gamma"), attr(res3, "Gamma"))
    expect_identical(attr(res1, "offset"), attr(res2, "offset"), attr(res3, "offset"))

})


test_that("calculateSGD() works when introducing X and Z matrices", {
    set.seed(100)
    X = matrix(rnorm(ncol(sce)*3), ncol = 3)
    Z = matrix(rnorm(nrow(sce)*3), ncol = 3)
    set.seed(100)
    res1 <- reducedDim(runSGD(sce, X = X, Z = Z, ncomponents = 5), "SGD")
    set.seed(100)
    res2 <- calculateSGD(sce, X = X, Z = Z, ncomponents = 5)
    set.seed(100)
    res3 <- calculateSGD(assay(sce, 'counts'), X = X, Z = Z, ncomponents = 5)


    expect_identical(c(res1), c(res2), c(res3))
    expect_identical(attr(res1, "X"), attr(res2, "X"), attr(res3, "X"))
    expect_identical(attr(res1, "Beta"), attr(res2, "Beta"), attr(res3, "Beta"))
    expect_identical(attr(res1, "Beta"), attr(res2, "Beta"), attr(res3, "Beta"))
    expect_identical(attr(res1, "Z"), attr(res2, "Z"), attr(res3, "Z"))
    expect_identical(attr(res1, "Gamma"), attr(res2, "Gamma"), attr(res3, "Gamma"))
    expect_identical(attr(res1, "offset"), attr(res2, "offset"), attr(res3, "offset"))


    expect_equal(dim(attr(res1, "X"))[2], 3)
    expect_equal(dim(attr(res1, "Z"))[2], 3)

})

test_that("calculateSGD() works on gaussian data with missing values", {
    set.seed(100)
    res1 <- reducedDim(runSGD(sce,
                              exprs_values = "logintensities",
                              family = gaussian(),
                              ncomponents = 5), "SGD")
    set.seed(100)
    res2 <- calculateSGD(sce,
                         exprs_values = "logintensities",
                         family = gaussian(),
                         ncomponents = 5)
    set.seed(100)
    res3 <- calculateSGD(assay(sce, 'logintensities'),
                         family = gaussian(),
                         ncomponents = 5)


    expect_identical(c(res1), c(res2), c(res3))
    expect_identical(attr(res1, "X"), attr(res2, "X"), attr(res3, "X"))
    expect_identical(attr(res1, "Beta"), attr(res2, "Beta"), attr(res3, "Beta"))
    expect_identical(attr(res1, "Beta"), attr(res2, "Beta"), attr(res3, "Beta"))
    expect_identical(attr(res1, "Z"), attr(res2, "Z"), attr(res3, "Z"))
    expect_identical(attr(res1, "Gamma"), attr(res2, "Gamma"), attr(res3, "Gamma"))
    expect_identical(attr(res1, "offset"), attr(res2, "offset"), attr(res3, "offset"))

})

test_that("calculateSGD_cv() works on poisson data", {
    set.seed(100)
    res1 <- metadata(runSGD_cv(sce, ncomponents = c(1:3)))$cv_SGD
    set.seed(100)
    res2 <- calculateSGD_cv(sce, ncomponents = c(1:3))
    expect_identical(res1, res2)
    set.seed(100)
    res3 <- calculateSGD_cv(assay(sce, 'counts'), ncomponents = c(1:3))
    expect_identical(res2, res3)


})

test_that("calculateSGD_cv() works on gaussian data with missing values", {
    set.seed(100)
    res1 <- metadata(runSGD_cv(sce,
                                    exprs_values = "logintensities",
                                    family = gaussian(),
                                    ncomponents = c(1:3)))$cv_SGD
    set.seed(100)
    res2 <- calculateSGD_cv(sce,
                      exprs_values = "logintensities",
                      family = gaussian(),
                      ncomponents = c(1:3))
    expect_identical(res1, res2)
    set.seed(100)
    res3 <- calculateSGD_cv(assay(sce, 'logintensities'),
                                           family = gaussian(),
                                           ncomponents = c(1:3))
    expect_identical(res2, res3)
})




test_that("calculateSGD_rank() works on poisson data", {
    set.seed(100)
    res1 <- metadata(runSGD_rank(sce, maxcomp = 5))$rank_SGD
    set.seed(100)
    res2 <- calculateSGD_rank(sce, maxcomp = 5)
    expect_identical(res1, res2)
    set.seed(100)
    res3 <- calculateSGD_rank(assay(sce, 'counts'), maxcomp = 5)
    expect_identical(res2, res3)

})



