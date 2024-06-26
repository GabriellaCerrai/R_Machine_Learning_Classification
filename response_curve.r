#=========================
# creating a reponse curve
#=========================
M = 100
x1_dummy = seq(min(Asymmetry),max(Asymmetry), length = M)
x2_dummy = seq(min(Intensity),max(Intensity), length = M)
X1 = rep(x1_dummy,M)
X2 = rep(x2_dummy,each = M)
Lat = data.frame(Asymmetry = X1, Intensity = X2, EW_HI = median(EW_HI),
                 NS_HI =median(NS_HI))
Latt = as.h2o(Lat)
pred = h2o.predict(newmodel,Latt)
pred1 = as.data.frame(pred)
clss = pred1[,1]
cols = c('blue', 'green', 'purple')
plot(X1~X2, col = cols[clss], xlab="Intensity", ylab="Asymmetry")
plot(clss~X2)