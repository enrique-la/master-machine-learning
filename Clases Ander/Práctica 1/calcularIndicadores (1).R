calcularIndicadores<-function(df,utsel,deleteOverlaps=T){
  df_ut<-df[which(df[,"ut"]==utsel),]
  df_ut<-df_ut[order(df_ut[,"ts"]),]
  
  #Separo por compresor 1 y 2
  
  #Primero calculo los indicadores para el compresor 1
  df_ut_co1<-df_ut[which(df_ut[,"on1"]==1),]
  pos<-which(diff(df_ut_co1[,"ts"])>1024) #Los registros de encendido de un mismo arranque deben tener una diferencia de timestamp de 1024. Si la diferencia es mayor se trata de otro arranque
  if(length(pos)>0){
    pos<-c(0,pos)
    results<-list()
    count<-1;
    for (i in 2:length(pos)){
      cond<-(pos[i-1]+1):pos[i]
      df_ut_co1_cycle<-df_ut_co1[cond,]
      ton<-(df_ut_co1_cycle[nrow(df_ut_co1_cycle),"ts"]-df_ut_co1_cycle[1,"ts"])/1000
      ton_leakage<-(df_ut_co1_cycle[which(df_ut_co1_cycle[,"leak1"]==1)[1],"ts"]-df_ut_co1_cycle[1,"ts"])/1000
      ratio_speed<-sum(df_ut_co1_cycle[,"speed"]>0)/nrow(df_ut_co1_cycle)
      mean_speed<-mean(df_ut_co1_cycle[,"speed"],na.rm=T)
      ratio_othercomp<-sum(df_ut_co1_cycle[,"leak2"]==1)/nrow(df_ut_co1_cycle)
      pinicial<-df_ut_co1_cycle[1,"p1"]
      results[[count]]<-data.frame(df_ut_co1_cycle[1,c("date_time")],ton,ton_leakage,ratio_speed,mean_speed,ratio_othercomp,pinicial,1)
      count<-count+1
    }
    matResults1<-do.call(rbind,results)
    colnames(matResults1)<-c("date_time","ton","ton_leak","ratio_speed_greater0","mean_speed","ratio_othercomp","initialp","comp")
  }
  
  #Después calculo los indicadores para el compresor 2
  df_ut_co2<-df_ut[which(df_ut[,"on2"]==1),]
  pos<-which(diff(df_ut_co2[,"ts"])>1024)
  if(length(pos)>0){
    pos<-c(0,pos)
    results<-list()
    count<-1;
    for (i in 2:length(pos)){
      cond<-(pos[i-1]+1):pos[i]
      df_ut_co2_cycle<-df_ut_co2[cond,]
      ton<-(df_ut_co2_cycle[nrow(df_ut_co2_cycle),"ts"]-df_ut_co2_cycle[1,"ts"])/1000
      ton_leakage<-(df_ut_co2_cycle[which(df_ut_co2_cycle[,"leak2"]==1)[1],"ts"]-df_ut_co2_cycle[1,"ts"])/1000
      ratio_speed<-sum(df_ut_co2_cycle[,"speed"]>0)/nrow(df_ut_co2_cycle)
      mean_speed<-mean(df_ut_co2_cycle[,"speed"],na.rm=T)
      ratio_othercomp<-sum(df_ut_co2_cycle[,"leak1"]==1)/nrow(df_ut_co2_cycle)
      pinicial<-df_ut_co2_cycle[1,"p2"]
      results[[count]]<-data.frame(df_ut_co2_cycle[1,c("date_time")],ton,ton_leakage,ratio_speed,mean_speed,ratio_othercomp,pinicial,2)
      count<-count+1
    }
    matResults2<-do.call(rbind,results)
    colnames(matResults2)<-c("date_time","ton","ton_leak","ratio_speed_greater0","mean_speed","ratio_othercomp","initialp","comp")
  }
  
  matResults<-rbind(matResults1,matResults2)
  matResults[is.na(matResults[,"ton_leak"]),"ton_leak"]<-matResults[is.na(matResults[,"ton_leak"]),"ton"]
  
  matResults<-matResults[which(matResults[,"initialp"]>8 & matResults[,"ton_leak"]>0 & matResults[,"ton"]>0),]
  matResults<-matResults[order(matResults[,1]),]
  if(deleteOverlaps){
    matResults<-matResults[which(matResults[,"ratio_othercomp"]==0),]
  }
  return(matResults)
}