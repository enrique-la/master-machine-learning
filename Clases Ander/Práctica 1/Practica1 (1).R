###########################
## Practica 1: Compresores
###########################

#Cargo librer?as
library(bit64)
library(scales)
library(ROCR)
library(glmnet)
library(randomForest)


setwd("C:\\Users\\60149\\Desktop\\2025\\TECNUN\\2025\\ML\\20251020")
source("calcularIndicadores.R")

#Cargo los datos
load("Practica1.RData")

#Convertir a date_time
#1a)
date_time<-as.POSIXct(df[,"ts"]/1000, origin="1970-01-01") #tz=""
#1b)
#date_time<-strptime(paste(substr(df[,2],1,4),"-",substr(df[,2],5,6),"-",substr(df[,2],7,8)," ",df[,3],":",df[,4],":",df[,5],sep=""),format="%Y-%m-%d %H:%M:%S") #lento

#A?adimos la variable date_time al data.frame df
df<-data.frame(date_time,df)

head(df[,c("ts","day","hour","minute","second","date_time")])

uts<-unique(df[,"ut"])
uts
#"01" "02" "03" "04"


#2a) Plot de la evolucion temporal de la presion

ut<-"01"
#Filtramos la ut para la ventana temporal indicada
fecha_inicio<-strptime("2019-01-31 08:00:00",format="%Y-%m-%d %H:%M:%S")
fecha_fin<-strptime("2019-01-31 11:00:00",format="%Y-%m-%d %H:%M:%S")
df_ut<-df[which(df[,"ut"]==ut & df[,"date_time"]>=fecha_inicio & df[,"date_time"]<=fecha_fin),]
x11();
matplot(x=df_ut[,"date_time"],y=df_ut[,c("p1","p2")],pch=16,cex=0.5,col=c("blue","red"),ylab="Pressure [bar]",xlab="Date time",main=ut)

#2b) A?adir las activaciones de encendido y leakage al gr?fico anterior
x11();
matplot(x=df_ut[,"date_time"],y=cbind(df_ut[,"p1"],df_ut[,"p2"]),pch=16,cex=0.5,col=c("blue","red"),ylab="Pressure [bar]",xlab="Date time",main=ut,ylim=c(6,11))
matlines(x=df_ut[,"date_time"],y=cbind(df_ut[,"on1"]+7,df_ut[,"on2"]+6,df_ut[,"leak1"]+7,df_ut[,"leak2"]+6), col=c("blue","red","blue","red"),lty=c(1,1,2,2))

#3) Calcular los indicadores para la ut 04 (con la funcion calcularIndicadores)
matResults<-calcularIndicadores(df,ut="04",deleteOverlaps=F)
head(matResults,5)

#4a) Graficar la evoluci?n temporal ton_leak de los compresores 1 y 2
x11();plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]",cex=0.5)
points(matResults[matResults[,"comp"]==2,"date_time"],matResults[matResults[,"comp"]==2,"ton_leak"],col="red",pch=16,cex=0.5)

#4b) Graficar el plot anterior pero quitando solapes de compresores
matResults<-matResults[which(matResults[,"ratio_othercomp"]==0),]
x11();plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]",cex=0.5)
points(matResults[matResults[,"comp"]==2,"date_time"],matResults[matResults[,"comp"]==2,"ton_leak"],col="red",pch=16,cex=0.5)
#4c) A?adimos la orden de mantenimiento al plot
pos<-match("2019-02-01",substr(matResults[,1],1,10))
abline(v=matResults[pos,1],lwd=2,col="black")


#5a) Evaluar si existe diferencia significativa de ton_leak entre el compresor 1 y 2 mediante t-test, test de wilcoxon y curva ROC.
#    Hacer la comparativa entre compresores antes y despu?s de la orden de mantenimiento.

#Recomendable hacer as.factor(comp) para garantizar que "comp" es un factor (y no una variable numerica)
matResults[,"comp"]<-as.factor(matResults[,"comp"])

df_antesOT<-matResults[which(matResults[,1]<strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S")),]
df_antesOT_con_velocidad<-matResults[which(matResults[,1]<strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S") & matResults[,"ratio_speed_greater0"]>0),]
df_antesOT_sin_velocidad<-matResults[which(matResults[,1]<strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S") & matResults[,"ratio_speed_greater0"]==0),]

df_despuesOT<-matResults[which(matResults[,1]>strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S")),]
df_despuesOT_con_velocidad<-matResults[which(matResults[,1]>strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S") & matResults[,"ratio_speed_greater0"]>0),]
df_despuesOT_sin_velocidad<-matResults[which(matResults[,1]>strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S") & matResults[,"ratio_speed_greater0"]==0),]

#Estudio comparativo entre compresores antes de la OT
x11();par(mfrow=c(1,3))
boxplot(ton_leak~comp,data=df_antesOT,ylim=c(0,150),main="sin filtrar")
boxplot(ton_leak~comp,data=df_antesOT_con_velocidad,ylim=c(0,150),main="ratio_speed_greater0 > 0")
boxplot(ton_leak~comp,data=df_antesOT_sin_velocidad,ylim=c(0,150),main="ratio_speed_greater0 = 0")
mtext("Antes de la OT",outer=T,line=-1.5)

t.test(ton_leak~comp,data=df_antesOT)
t.test(ton_leak~comp,data=df_antesOT_con_velocidad)
t.test(ton_leak~comp,data=df_antesOT_sin_velocidad)

wilcox.test(ton_leak~comp,data=df_antesOT)
wilcox.test(ton_leak~comp,data=df_antesOT_con_velocidad)
wilcox.test(ton_leak~comp,data=df_antesOT_sin_velocidad)

pred <- prediction(-df_antesOT[,"ton_leak"],df_antesOT[,"comp"])
perf <- performance(pred,"tpr","fpr")
x11();plot(perf,main="Antes de la OT\nComparativa del ton_leak entre compresor 1 y 2")
pred <- prediction(-df_antesOT_con_velocidad[,"ton_leak"],df_antesOT_con_velocidad[,"comp"])
perf <- performance(pred,"tpr","fpr")
lines(perf@x.values[[1]],perf@y.values[[1]],col="red")
pred <- prediction(-df_antesOT_sin_velocidad[,"ton_leak"],df_antesOT_sin_velocidad[,"comp"])
perf <- performance(pred,"tpr","fpr")
lines(perf@x.values[[1]],perf@y.values[[1]],col="blue")
legend("bottomright",legend=c("Sin filtrar","Ratio_speed_greater0 > 0", "Ratio_speed_greater0 = 0"),
       text.col=c("black","red","blue"),lty = 1,col=c("black","red","blue"))

#En el caso de ratio_speed_greater0 > 0, se amplifica la diferencia de ton_leak entre los compresores 1 y 2. Ver t-test y curva ROC asociada.

#Despues de la OT
x11();par(mfrow=c(1,3))
boxplot(ton_leak~comp,data=df_despuesOT,ylim=c(0,150),main="sin filtrar")
boxplot(ton_leak~comp,data=df_despuesOT_con_velocidad,ylim=c(0,150),main="ratio_speed_greater0 > 0")
boxplot(ton_leak~comp,data=df_despuesOT_sin_velocidad,ylim=c(0,150),main="ratio_speed_greater0 = 0")
mtext("Despues de la  OT",outer=T,line=-1.5)

t.test(ton_leak~comp,data=df_despuesOT)
t.test(ton_leak~comp,data=df_despuesOT_con_velocidad)
t.test(ton_leak~comp,data=df_despuesOT_sin_velocidad)

wilcox.test(ton_leak~comp,data=df_despuesOT)
wilcox.test(ton_leak~comp,data=df_despuesOT_con_velocidad)
wilcox.test(ton_leak~comp,data=df_despuesOT_sin_velocidad)

#Comprobar el FC sin velocidad despues de la OT
FC_despuesOT_sin_velocidad<-median(df_despuesOT_sin_velocidad[df_despuesOT_sin_velocidad$comp==1,"ton_leak"])/median(df_despuesOT_sin_velocidad[df_despuesOT_sin_velocidad$comp==2,"ton_leak"])
FC_despuesOT_sin_velocidad

pred <- prediction(df_despuesOT[,"ton_leak"],df_despuesOT[,"comp"])
perf <- performance(pred,"tpr","fpr")
x11();plot(perf,main="Despues de la OT\nComparativa del ton_leak entre compresor 1 y 2")
pred <- prediction(df_despuesOT_con_velocidad[,"ton_leak"],df_despuesOT_con_velocidad[,"comp"])
perf <- performance(pred,"tpr","fpr")
lines(perf@x.values[[1]],perf@y.values[[1]],col="red")
pred <- prediction(df_despuesOT_sin_velocidad[,"ton_leak"],df_despuesOT_sin_velocidad[,"comp"])
perf <- performance(pred,"tpr","fpr")
lines(perf@x.values[[1]],perf@y.values[[1]],col="blue")
legend("bottomright",legend=c("Sin filtrar","Ratio_speed_greater0 > 0", "Ratio_speed_greater0 = 0"),
       text.col=c("black","red","blue"),lty = 1,col=c("black","red","blue"))


#Tras corregirse el fallo (1/02/2019) del compresor 1 vuelve a la normalidad.
#Las curvas ROC tienen un AUC entorno a 0.5 (caso random) y el t-test y wilcoxon test en la mayor?a de los casos no obtienen significancia estad?stica.
#Por tanto podemos concluir que ambos compresores funcionan parecido (y en este caso normal).

#Por ?ltimo, se va a realizar la comparativa del compresor 1 su comportamiento antes vs despu?s de la OT
#Comparativa del compresor 1 antes vs despu?s de la OT

x11();plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]",cex=0.5)
pos<-match("2019-02-01",substr(matResults[,1],1,10))
abline(v=matResults[pos,1],lwd=2,col="black")

#SIN FILTRO
#Comparativa del compresor 1 (antes vs despues)
ton_leak1_antes<-df_antesOT[df_antesOT[,"comp"]=="1","ton_leak"]
ton_leak1_despues<-df_despuesOT[df_despuesOT[,"comp"]=="1","ton_leak"]
boxplot(ton_leak1_antes,ton_leak1_despues,names=c("ton leak1 antes","ton leak1 despues"),main="Comparativa Compresor 1\nAntes vs Despu?s de la OT")

t.test(ton_leak1_antes,ton_leak1_despues)
wilcox.test(ton_leak1_antes,ton_leak1_despues)
preds<-c(ton_leak1_antes,ton_leak1_despues)
labels<-rep(1,length(preds))
labels[1:length(ton_leak1_antes)]<-2
pred <- prediction(preds,labels)
perf <- performance(pred,"tpr","fpr")
x11();plot(perf)

#Para el compresor 1 existe diferencia signifitiva de ton_leak entre antes y despues (Ver t-test, wilcoxon test y Curva ROC)
#Pod?is hacer la misma comparativa del compresor 1 filtrando por Ratio_speed_greater0>0 y Ratio_speed_greater0=0
#Y si hac?is lo mismo con el compresor 2 (antes vs despu?s) comprobar?is que NO existe diferencia signifitiva de ton_leak

#matResults<-matResults[which(matResults[,"ratio_othercomp"]==0),]

#6) Realizar los pasos desde el 3 al 5 con el resto de uts. Las ordenes de trabajo registradas en el periodo y uts de estudio son las siguientes:
#UT 02 : 2019-02-13 (Se repara el compresor 2)
#UT 04 : 2019-02-01 (Se repara el compresor 1)

#En el calculo de indicadores se han filtrado los solapes para simplificar el problema
matResults01<-calcularIndicadores(df,ut="01",deleteOverlaps=T)
matResults02<-calcularIndicadores(df,ut="02",deleteOverlaps=T)
matResults03<-calcularIndicadores(df,ut="03",deleteOverlaps=T)
matResults04<-calcularIndicadores(df,ut="04",deleteOverlaps=T)

x11();par(mfrow=c(4,1))
#Graficar la evoluci?n temporal ton_leak de los compresores 1 y 2 de la UT01
matResults<-matResults01
plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]", ylim=c(0,300),cex=0.5,main="01")
points(matResults[matResults[,"comp"]==2,"date_time"],matResults[matResults[,"comp"]==2,"ton_leak"],col="red",pch=16,cex=0.5)

#Graficar la evoluci?n temporal ton_leak de los compresores 1 y 2 de la UT02
matResults<-matResults02
plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]", ylim=c(0,300),cex=0.5,main="02")
points(matResults[matResults[,"comp"]==2,"date_time"],matResults[matResults[,"comp"]==2,"ton_leak"],col="red",pch=16,cex=0.5)
pos<-match("2019-02-13",substr(matResults[,1],1,10)) #Se repara el compresor 2
abline(v=matResults[pos,1],lwd=2,col="black")

#Graficar la evoluci?n temporal ton_leak de los compresores 1 y 2 de la UT03
matResults<-matResults03
plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]", ylim=c(0,300),cex=0.5,main="03")
points(matResults[matResults[,"comp"]==2,"date_time"],matResults[matResults[,"comp"]==2,"ton_leak"],col="red",pch=16,cex=0.5)

#Graficar la evoluci?n temporal ton_leak de los compresores 1 y 2 de la UT04
matResults<-matResults04
plot(matResults[matResults[,"comp"]==1,"date_time"],matResults[matResults[,"comp"]==1,"ton_leak"],col="blue",pch=16,xlab="Date time",ylab="Ton leak [s]", ylim=c(0,300),cex=0.5,main="04")
points(matResults[matResults[,"comp"]==2,"date_time"],matResults[matResults[,"comp"]==2,"ton_leak"],col="red",pch=16,cex=0.5)
pos<-match("2019-02-01",substr(matResults[,1],1,10)) #Se repara el compresor 1
abline(v=matResults[pos,1],lwd=2,col="black")

#6) Generar un detector de fallo de compresor
matResultsAll<-rbind(matResults01,matResults02,matResults03,matResults04)
matResultsAll<-matResultsAll[,-6] #se elimina la columna "ratio_othercomp" ya que en el calculo de indicadores se han eliminado los registros con solapes (ratio_othercomp=1)
matResultsAll[,"comp"]<-as.factor(matResultsAll[,"comp"])
ut<-as.factor(c(rep("01",nrow(matResults01)),rep("02",nrow(matResults02)),rep("03",nrow(matResults03)),rep("04",nrow(matResults04))))
matResultsAll<-cbind(matResultsAll,ut)
fallo<-rep(0,nrow(matResultsAll))
fallo[which(matResultsAll[,"ut"]=="02" & matResultsAll[,"comp"]=="2" & matResultsAll[,"date_time"]<strptime("2019-02-13 00:00:00",format="%Y-%m-%d %H:%M:%S"))]<-1
fallo[which(matResultsAll[,"ut"]=="04" & matResultsAll[,"comp"]=="1" & matResultsAll[,"date_time"]<strptime("2019-02-01 00:00:00",format="%Y-%m-%d %H:%M:%S"))]<-1
fallo<-as.factor(fallo)
matResultsAll<-cbind(matResultsAll,fallo)
rownames(matResultsAll)<-NULL

table(fallo)
head(matResultsAll)

#A?adimos dos variables ton_norm y ton_leak_norm
ton_norm<-matResultsAll[,"ton"]
ton_leak_norm<-matResultsAll[,"ton_leak"]
matResultsAll<-cbind(matResultsAll,ton_norm,ton_leak_norm)
matResultsAll_sin_fallo<-matResultsAll[matResultsAll[,"fallo"]==0,]

#La estandarizacion mediante median y mad funciona mejor que mean y sd (no se muestra la comparativa)
#Z=(X-median)/mad (en vez de Z=(X-mean)/sd) 
ton_leak_mean_ut_comp <-tapply(matResultsAll_sin_fallo[,"ton_leak"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),median,na.rm=T)
ton_leak_sd_ut_comp <-tapply(matResultsAll_sin_fallo[,"ton_leak"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),mad,na.rm=T)
ton_mean_ut_comp <-tapply(matResultsAll_sin_fallo[,"ton"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),median,na.rm=T)
ton_sd_ut_comp <-tapply(matResultsAll_sin_fallo[,"ton"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),mad,na.rm=T)

uts<-sort(unique(matResultsAll[,"ut"]))
comps<-sort(unique(matResultsAll[,"comp"]))

for (i in 1:length(uts)){
  for (j in 1:length(comps)){
    cond<-which(matResultsAll[,"ut"]==uts[i] & matResultsAll[,"comp"]==comps[j])
    matResultsAll[cond,"ton_norm"]<-(matResultsAll[cond,"ton_norm"]-ton_mean_ut_comp[i,j])/ton_sd_ut_comp[i,j]
    matResultsAll[cond,"ton_leak_norm"]<-(matResultsAll[cond,"ton_leak_norm"]-ton_leak_mean_ut_comp[i,j])/ton_leak_sd_ut_comp[i,j]
  }
}


#ton_leak vs ton_leak_norm
x11();par(mfrow=c(2,1));
boxplot(ton_leak~comp+ut+fallo,data=matResultsAll,ylim=c(0,300))
boxplot(ton_leak_norm~comp+ut+fallo,data=matResultsAll,ylim=c(-5,5))

#ton vs ton_norm
x11();par(mfrow=c(2,1));
boxplot(ton~comp+ut+fallo,data=matResultsAll,ylim=c(0,300))
boxplot(ton_norm~comp+ut+fallo,data=matResultsAll,ylim=c(-5,5))

matResultsAll_sin_fallo<-matResultsAll[matResultsAll[,"fallo"]==0,]
matResultsAll_con_fallo<-matResultsAll[matResultsAll[,"fallo"]==1,]
uts_comps_sin_fallo<-unique(matResultsAll_sin_fallo[,c("ut","comp")])
uts_comps_con_fallo<-unique(matResultsAll_con_fallo[,c("ut","comp")])

#Ver lo mismo con funciones de densidad
x11();par(mfrow=c(2,1))
for (i in 1:nrow(uts_comps_sin_fallo)){
  if (i==1){
    plot(density(matResultsAll_sin_fallo[which(matResultsAll_sin_fallo[,"ut"]==uts_comps_sin_fallo[i,1] & matResultsAll_sin_fallo[,"comp"]==uts_comps_sin_fallo[i,2]),"ton_leak"]),col=alpha("black",0.5),ylim=c(0,0.075),xlim=c(0,180),main="ton_leak (Fallo (rojo) vs Sin Fallo (negro))")
  }else{
    lines(density(matResultsAll_sin_fallo[which(matResultsAll_sin_fallo[,"ut"]==uts_comps_sin_fallo[i,1] & matResultsAll_sin_fallo[,"comp"]==uts_comps_sin_fallo[i,2]),"ton_leak"]),col=alpha("black",0.5))
  }
}

for (i in 1:nrow(uts_comps_con_fallo)){
  if (i==1){
    lines(density(matResultsAll_con_fallo[which(matResultsAll_con_fallo[,"ut"]==uts_comps_con_fallo[i,1] & matResultsAll_con_fallo[,"comp"]==uts_comps_con_fallo[i,2]),"ton_leak"]),col=alpha("red",0.5),lwd=2)
  }else{
    lines(density(matResultsAll_con_fallo[which(matResultsAll_con_fallo[,"ut"]==uts_comps_con_fallo[i,1] & matResultsAll_con_fallo[,"comp"]==uts_comps_con_fallo[i,2]),"ton_leak"]),col=alpha("red",0.5),lwd=2)
  }
}

for (i in 1:nrow(uts_comps_sin_fallo)){
  if (i==1){
    plot(density(matResultsAll_sin_fallo[which(matResultsAll_sin_fallo[,"ut"]==uts_comps_sin_fallo[i,1] & matResultsAll_sin_fallo[,"comp"]==uts_comps_sin_fallo[i,2]),"ton_leak_norm"]),col=alpha("black",0.5),ylim=c(0,0.5),xlim=c(-5,5),main="ton_leak_norm (Fallo (rojo) vs Sin Fallo (negro))")
  }else{
    lines(density(matResultsAll_sin_fallo[which(matResultsAll_sin_fallo[,"ut"]==uts_comps_sin_fallo[i,1] & matResultsAll_sin_fallo[,"comp"]==uts_comps_sin_fallo[i,2]),"ton_leak_norm"]),col=alpha("black",0.5))
  }
}
for (i in 1:nrow(uts_comps_con_fallo)){
  if (i==1){
    lines(density(matResultsAll_con_fallo[which(matResultsAll_con_fallo[,"ut"]==uts_comps_con_fallo[i,1] & matResultsAll_con_fallo[,"comp"]==uts_comps_con_fallo[i,2]),"ton_leak_norm"]),col=alpha("red",0.5),lwd=2)
  }else{
    lines(density(matResultsAll_con_fallo[which(matResultsAll_con_fallo[,"ut"]==uts_comps_con_fallo[i,1] & matResultsAll_con_fallo[,"comp"]==uts_comps_con_fallo[i,2]),"ton_leak_norm"]),col=alpha("red",0.5),lwd=2)
  }
}

#Comprobaci?n de la estandarizaci?n de variables
tapply(matResultsAll_sin_fallo[,"ton_leak_norm"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),median,na.rm=T)#mediana 0
tapply(matResultsAll_sin_fallo[,"ton_leak_norm"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),mad,na.rm=T) # y mad 1
tapply(matResultsAll_sin_fallo[,"ton_norm"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),median,na.rm=T)#mediana 0
tapply(matResultsAll_sin_fallo[,"ton_norm"],list(matResultsAll_sin_fallo[,"ut"],matResultsAll_sin_fallo[,"comp"]),mad,na.rm=T) # y mad 1

#Funciones de densidad global para ton_leak y ton_leak_norm (en los casos Fallo vs Sin fallo)
x11();par(mfrow=c(2,1))
plot(density(matResultsAll_sin_fallo[,"ton_leak"]),col="black",main="ton_leak global (Fallo (rojo) vs Sin Fallo (negro))")
lines(density(matResultsAll_con_fallo[,"ton_leak"]),col="red")
plot(density(matResultsAll_sin_fallo[,"ton_leak_norm"]),col="black",main="ton_leak_norm global (Fallo (rojo) vs Sin Fallo (negro))")
lines(density(matResultsAll_con_fallo[,"ton_leak_norm"]),col="red")

#Curvas de precision recall
#ton_leak vs ton_leak_norm
#ton vs ton_norm
x11();par(mfrow=c(2,1))
pred <- prediction( matResultsAll[,"ton_leak"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
plot(perf,ylim=c(0,1),main="ton_leak (negro) vs ton_leak_norm (rojo)")
pred <- prediction( matResultsAll[,"ton_leak_norm"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="red")
pred <- prediction( matResultsAll[,"ton"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
plot(perf,ylim=c(0,1),main="ton (negro) vs ton_norm (rojo)")
pred <- prediction( matResultsAll[,"ton_norm"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="red")


df<-matResultsAll[,-1]

X<-model.matrix(~.,data=df)
y<-X[,"fallo1"]
# X<-X[,-ncol(X)]
X<-X[,-c(1,7:11)]

cor(X)

set.seed(123)
cvFit1<-cv.glmnet(X,y,family="binomial",type.measure="auc",alpha=1)
#con penalty.factor puedes seleccionar varibles a priori
x11()
plot(cvFit1)
coef(cvFit1)

set.seed(123)
cvFit2<-cv.glmnet(X,y,family="binomial",type.measure="auc",alpha=0)
#con penalty.factor puedes seleccionar varibles a priori
plot(cvFit2)
coef(cvFit2)


set.seed(123)
df_rf<-data.frame(y,X)
df_rf[,1]<-as.factor(df_rf[,1])
df_rf<-df_rf[which(rowSums(is.na(df_rf))==0),]
oob.err<-double(6)
#mtry is the no of vars randomly chosen at each split
for(mtry in 1:6) 
{
  rf=randomForest(y ~ . , data = df_rf , mtry=mtry,ntree=500) 
  oob.err[mtry] = rf$err.rate[,"OOB"][500] #Error of all Trees fitted
  
  print(mtry) #printing the output to the console
}
x11();
matplot(1:mtry , oob.err, pch=19 , col=c("red","blue"),type="b",ylab="OOB Error",xlab="Number of Predictors Considered at each Split")
legend("topright",legend=c("Out of Bag Error"),pch=19)

pred <- prediction( matResultsAll[,"ton_leak"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
x11();plot(perf,ylim=c(0,1))

pred <- prediction( matResultsAll[,"ton"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="gray")

pred <- prediction( matResultsAll[,"ton_leak_norm"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="blue")

pred <- prediction( matResultsAll[,"ton_norm"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="green",lwd=2)

preds<-predict(cvFit1,X)
pred <- prediction(preds,y)
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="orange")

preds<-predict(cvFit2,X)
pred <- prediction(preds,y)
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="red")

fit<-randomForest(y~.,data=df_rf,mtry=4,ntree=500)
preds<-predict(fit,type="prob")[,"1"]
pred <- prediction(preds,df_rf$y)
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="darkblue")
importances<-importance(fit)
importances[order(-importances[,1]),,drop=F]
#RF es el ganador?

pred <- prediction( matResultsAll[,"ton_norm"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
cond<-which.min(abs(perf@x.values[[1]]-0.4))
thr<-perf@alpha.values[[1]][cond]
xp<-perf@x.values[[1]][cond]
yp<-perf@y.values[[1]][cond]
points(xp,yp,cex=2,col="red",pch=16)

alarm<-1*(matResultsAll[,"ton_norm"]>thr)
table(alarm,matResultsAll[,"ut"])

matResults<-matResultsAll
head(matResults)

x11();par(mfrow=c(4,1))
#Graficar la evoluci?n temporal ton_norm de los compresores 1 y 2 de la UT01

plot(matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="01","date_time"],matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="01","ton_norm"],col="blue",pch=16,xlab="Date time",ylab="Ton norm", ylim=c(-5,6),cex=0.5,main="01")
points(matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="01","date_time"],matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="01","ton_norm"],col="red",pch=16,cex=0.5)
abline(h=thr,lty=2,lwd=2)
#Graficar la evoluci?n temporal ton_norm de los compresores 1 y 2 de la UT02

plot(matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="02","date_time"],matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="02","ton_norm"],col="blue",pch=16,xlab="Date time",ylab="Ton norm", ylim=c(-5,6),cex=0.5,main="02")
points(matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="02","date_time"],matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="02","ton_norm"],col="red",pch=16,cex=0.5)
abline(h=thr,lty=2,lwd=2)
pos<-match("2019-02-13",substr(matResults[,1],1,10)) #Se repara el compresor 2
abline(v=matResults[pos,1],lwd=2,col="black")

#Graficar la evoluci?n temporal ton_norm de los compresores 1 y 2 de la UT03
plot(matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="03","date_time"],matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="03","ton_norm"],col="blue",pch=16,xlab="Date time",ylab="Ton norm", ylim=c(-5,6),cex=0.5,main="03")
points(matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="03","date_time"],matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="03","ton_norm"],col="red",pch=16,cex=0.5)
abline(h=thr,lty=2,lwd=2)

#Graficar la evoluci?n temporal ton_norm de los compresores 1 y 2 de la UT04
plot(matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="04","date_time"],matResults[matResults[,"comp"]==1 & matResults[,"ut"]=="04","ton_norm"],col="blue",pch=16,xlab="Date time",ylab="Ton norm", ylim=c(-5,6),cex=0.5,main="04")
points(matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="04","date_time"],matResults[matResults[,"comp"]==2 & matResults[,"ut"]=="04","ton_norm"],col="red",pch=16,cex=0.5)
abline(h=thr,lty=2,lwd=2)
pos<-match("2019-02-01",substr(matResults[,1],1,10)) #Se repara el compresor 2
abline(v=matResults[pos,1],lwd=2,col="black")

table(matResults$ut,matResults$fallo)
table(matResults$ut,alarm)

table(alarm,matResults$fallo)
Precision=504/571
Recall=504/(759+504)

#Siempre es necesario separar entre training y validation set! Cuidado con los modelos muy pl?sticos!
df<-matResultsAll[,-c(1)]
idTrain<-1*(matResultsAll[,"ut"]=="01" | matResultsAll[,"ut"]=="02")
df<-data.frame(df,idTrain)
X<-model.matrix(~.,data=df)
y<-X[,"fallo1"]
X<-X[,-c(1,7:11)]
Xtrain<-X[which(X[,"idTrain"]==1),]
ytrain<-y[which(X[,"idTrain"]==1)]
Xtest<-X[-which(X[,"idTrain"]==1),]
ytest<-y[-which(X[,"idTrain"]==1)]
Xtrain<-Xtrain[,-ncol(Xtrain)]
Xtest<-Xtest[,-ncol(Xtest)]
set.seed(123)
df_rf_train<-data.frame(ytrain,Xtrain)
df_rf_test<-data.frame(ytest,Xtest)
df_rf_train[,1]<-as.factor(df_rf_train[,1])
colnames(df_rf_train)[1]<-"y"
df_rf_test[,1]<-as.factor(df_rf_test[,1])
colnames(df_rf_test)[1]<-"y"
df_rf_train<-df_rf_train[which(rowSums(is.na(df_rf_train))==0),]
df_rf_test<-df_rf_test[which(rowSums(is.na(df_rf_test))==0),]
oob.err<-double(6)
#mtry is the no of vars randomly chosen at each split
for(mtry in 1:6) 
{
  rf=randomForest(y ~ . , data = df_rf_train , mtry=mtry,ntree=500) 
  oob.err[mtry] = rf$err.rate[,"OOB"][500] #Error of all Trees fitted
  
  print(mtry) #printing the output to the console
}
x11();
matplot(1:mtry , oob.err, pch=19 , col=c("red","blue"),type="b",ylab="OOB Error",xlab="Number of Predictors Considered at each Split")
legend("topright",legend=c("Out of Bag Error"),pch=19)
x11();
pred <- prediction( matResultsAll[,"ton_norm"], matResultsAll[,"fallo"])
perf<-performance(pred, "prec", "rec")
plot(perf,col="green",lwd=2)

fit<-randomForest(y~.,data=df_rf_train,mtry=4,ntree=500)
preds<-predict(fit,df_rf_test,type="prob")[,"1"]
pred <- prediction(preds,df_rf_test$y)
perf<-performance(pred, "prec", "rec")
lines(perf@x.values[[1]],perf@y.values[[1]],col="darkblue")
importances<-importance(fit)
importances[order(-importances),]

#Ser?a interesante hacer un sumarizado por d?a (la precisi?n no es real)