# Copied from the NAguideR shiny application:
# https://github.com/wangshisheng/NAguideR/blob/15ec86263d5821990ad39a8d9f378cf4d76b25fb/inst/NAguideRapp/app.R#L1705-L1849

nafunctions<-function(x,method="zero"){
  df<-df1<-as.data.frame(x)
  method<-tolower(method)
  if(method=="zero"){
    df[is.na(df)]<-0
  }
  else if(method=="minimum"){
    df[is.na(df)]<-min(df1,na.rm = TRUE)
  }
  else if(method=="colmedian"){
    library(e1071)
    df<-impute(df1,what ="median")
  }
  else if(method=="rowmedian"){
    library(e1071)
    dfx<-impute(t(df1),what ="median")
    df<-t(dfx)
  }
  else if(method=="knnmethod"){
    library(impute)
    data_zero1<-impute.knn(as.matrix(df1),k = 10, rowmax = 1, colmax = 1)#rowmax = 0.9, colmax = 0.9
    df<-data_zero1$data
  }
  else if(method=="seqknn"){
    library(SeqKnn)
    df <- SeqKNN(df1,k = 10)
  }
  else if(method=="bpca"){
    library(pcaMethods)
    data_zero1<-pcaMethods::pca(as.matrix(df1), nPcs = ncol(df1)-1, method = "bpca", maxSteps =100)
    df<-completeObs(data_zero1)
  }
  else if(method=="svdmethod"){
    library(pcaMethods)
    data_zero1<-pcaMethods::pca(as.matrix(df1), nPcs = ncol(df1)-1, method = "svdImpute")
    df<-completeObs(data_zero1)
  }
  else if(method=="lls"){
    library(pcaMethods)
    data_zero1<-llsImpute(t(df1), k = 10)
    df<-t(completeObs(data_zero1))
  }
  else if(method=="mle"){
    library(norm)
    xxm<-as.matrix(df1)
    ss <- norm::prelim.norm(xxm)
    thx <- norm::em.norm(ss)
    norm::rngseed(123)
    df <- norm::imp.norm(ss, thx, xxm)
  }
  else if(method=="qrilc"){
    library(imputeLCMD)
    xxm<-t(df1)
    data_zero1 <- imputeLCMD::impute.QRILC(xxm, tune.sigma = 1)[[1]]
    df<-t(data_zero1)
  }
  else if(method=="mindet"){
    library(imputeLCMD)
    xxm<-as.matrix(df1)
    df <- imputeLCMD::impute.MinDet(xxm, q = 0.01)
  }
  else if(method=="minprob"){
    library(imputeLCMD)
    xxm<-as.matrix(df1)
    df <- imputeLCMD::impute.MinProb(xxm, q = 0.01, tune.sigma = 1)
  }
  else if(method=="irm"){
    library(VIM)
    df <- irmi(df1, trace = TRUE,imp_var=FALSE)
    rownames(df)<-rownames(df1)
  }
  else if(method=="impseq"){
    library(rrcovNA)
    df <- impSeq(df1)
  }
  else if(method=="impseqrob"){
    library(rrcovNA)
    data_zero1 <- impSeqRob(df1, alpha=0.9)
    df<-data_zero1$x
  }
  else if(method=="mice-norm"){
    library(mice)
    minum<-5
    datareadmi<-mice(df1,m=minum,seed = 1234, method ="norm")
    newdatareadmi<-0
    for (i in 1:minum) {
      newdatareadmi<-complete(datareadmi,action = i)+newdatareadmi
    }
    df<-newdatareadmi/minum
    rownames(df)<-rownames(df1)
  }
  else if(method=="mice-cart"){
    library(mice)
    minum<-5
    datareadmi<-mice(df1,m=minum,seed = 1234, method ="cart")
    newdatareadmi<-0
    for (i in 1:minum) {
      newdatareadmi<-complete(datareadmi,action = i)+newdatareadmi
    }
    df<-newdatareadmi/minum
    rownames(df)<-rownames(df1)
  }
  else if(method=="trknn"){
    source('Trunc_KNN/Imput_funcs.r')
    sim_trKNN_wrapper <- function(data) {
      result <- data %>% as.matrix %>% t %>% imputeKNN(., k=10, distance='truncation', perc=0) %>% t
      return(result)
    }
    df1x <- sim_trKNN_wrapper(t(df1))
    df<-as.data.frame(t(df1x))
  }
  else if(method=="rf"){
    library(missForest)
    data_zero1 <- missForest(t(df1), maxiter =10,ntree = input$rfntrees,mtry=floor(nrow(df1)^(1/3)),verbose = TRUE)
    df<-t(data_zero1$ximp)
  }
  else if(method=="pi"){
    width <- input$piwidth
    downshift <- input$pidownshift
    for(i in 1:ncol(df1)){
      temp <- df1[[i]]
      if(sum(is.na(temp))>0){
        temp.sd <- width * sd(temp[!is.na(temp)], na.rm = TRUE)
        temp.mean <- mean(temp[!is.na(temp)], na.rm = TRUE) - downshift * sd(temp[!is.na(temp)], na.rm = TRUE)
        n.missing <- sum(is.na(temp))
        temp[is.na(temp)] <- rnorm(n.missing, mean = temp.mean, sd = temp.sd)
        df[[i]]<-temp
      }
    }
    df
  }
  else if(method=="grr"){
    library(DreamAI)
    df<-impute.RegImpute(data=as.matrix(df1), fillmethod = "row_mean", maxiter_RegImpute = 10,conv_nrmse = 1e-03)
  }
  else if(method=="gms"){
    library(GMSimpute)
    df<-GMS.Lasso(df1,nfolds=3,log.scale=FALSE,TS.Lasso=TRUE)
  }
  else{
    stop("Unspported methods so far~~")
  }
  df<-as.data.frame(df)
  df
}