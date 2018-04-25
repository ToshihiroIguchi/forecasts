#インストール方法
#https://facebook.github.io/prophet/docs/installation.html

#Windowsの場合Rtoolsを最初に必ずインストール。
#https://cran.r-project.org/bin/windows/Rtools/

#最後にprophetをインストール
#install.packages("prophet")
#install.packages("bindrcpp")
#install.packages("dplyr")

#ライブラリ読み込み
library(prophet)
library(dplyr)

#日付を2018-04-01のような形式に変換
#as.dsの内部で使用
date2date <- function(x){
  #日付をprophetが読める形に変換
  #http://biostat.mc.vanderbilt.edu/wiki/pub/Main/ColeBeck/datestimes.pdf
  
  #変換する日付の形式
  format.vec <- c("%m/%d/%Y", "%Y/%m/%d", "%Y-%m-%d", "%m-%d-%Y")
  
  #変換可能か一つづつ評価
  for(i in 1:length(format.vec)){
    ret <- as.Date(x, format = format.vec[i])
    if(!is.na(ret)){return(as.character(ret))}
  }
  #変換に失敗した場合
  stop("Failed to convert date.")
}

#ベクトルに変換
as.vec <- function(x){return(as.vector(as.matrix(x)))}


#日付のベクトルを2018-04-01のような形式に変換
as.ds <- function(x){
  x <- as.vec(x)
  return(sapply(x, date2date))
}

#日付の項目名を取得
get.date.name <- function(df){
  df.name <- colnames(df)
  n <- length(df[1, ])
  ret <- NULL
  for(i in 1:n){
    chk <- try(as.ds(df[, i]), silent = TRUE)
    if(!class(chk) == "try-error"){ret <- c(ret, df.name[i])}
  }
  return(ret)
}

#コンマが入ったベクトルを数値に変換
as.num <- function(x){
  x <- as.vec(x)
  x <- as.numeric(gsub(",", "", x))
  return(x)
}

#数値の項目名を取得
get.numeric.name <- function(df){
  df.name <- colnames(df)
  n <- length(df[1, ])
  ret <- NULL
  for(i in 1:n){
    chk <- tryCatch({as.num(df[, i])}, warning = function(e){}, silent = TRUE)
    if(is.numeric(chk) && !is.na(chk)){ret <- c(ret, df.name[i])}
  }
  return(ret)
}


#prophetに読み込ませる形式に変換
make.df <- function(ds, y){
  #ベクトルに変換
  y <- as.vec(y)
  ds <- as.vec(ds)
  
  #y <- as.numeric(y)
  
  #データのチェック
  if(length(ds) != length(y)){stop("The lengths of ds and y are different.")}
  
  #カンマを取り除く。正規表現を使ってもう少しいい方法もありそうな気がするが、まずはこれで。
  y <- as.num(y)

  #yが数値であることを確認
  if(!is.numeric(y)){stop("y is not numeric.")}

  #日付の変換
  ds <- as.ds(ds)
  
  #戻り値を作成
  ret <- data.frame(ds = ds, y = y)
  return(ret)
}

#prophetの結果から未来の値を予測
forecast.pred <- function(m, periods = 365, freq = "day"){
  future <- make_future_dataframe(m, periods = periods, freq = freq)
  forecast <- predict(m, future)
  return(forecast)
}

#forecast.predで出力したデータのdsをcharacterに変換
forecast_ds <- function(forecast){
  ret <- forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')]
  ret[,1] <- as.character(ret[,1])
  return(ret)
}