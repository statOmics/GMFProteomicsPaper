test_that("plotSGD() works", {
    set.seed(100)
    res1 <- runSGD(sce, ncomponents = 5)
    expect_s3_class(plotSGD(res1), "ggplot")
})


