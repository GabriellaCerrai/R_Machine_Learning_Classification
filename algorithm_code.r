#==================
# IMPORT PACKAGES:
#==================
library(tree)
library(rpart)
library(rpart.plot)
library(colorspace)
library(h2o)

#========================================
# CREATE COLOUR SCHEME FOR SCATTER PLOTS: 
#========================================
dataa = read.table('Assignment2_2022.txt', h= TRUE)
color.gradient = function(x, colors=c('magenta', 'orange', 'green'), colsteps=50)
{
  colpal = colorRampPalette(colors)
  return (colpal(colsteps)[ findInterval (x, seq(min(x), max(x),
                                                 length = colsteps))])
}
plot(dataa$X2~dataa$X1, col = color.gradient(dataa$Y), pch = 16)

# ==============
# READ IN DATA: 
#===============
dat = read.table("DigitsFeatures2022.txt", header = TRUE)
head(dat)
attach(dat)

#=====================
# Create Scatterplots:
#=====================
windows()
dat$Y = as.numeric(as.factor(dat$Y))
plot(Asymmetry~Intensity, col = color.gradient(dat$Y), pch = 16)
plot(EW_HI~Intensity, col = color.gradient(dat$Y), pch = 16)
plot(NS_HI~Intensity, col = color.gradient(dat$Y), pch = 16)

#========
# Trees:
#========
set.seed(2022)
res1 = rpart.plot(Y~., data = dat)
plot(res1)
text(res1)

# starting tree:
res2 = prune.rpart(res1, cp=0.001)
plot(res2)
text(res2)

# cp plot to check level of pruning:
plotcp(res2)
abline(v=3, col = "red")

# pruned trees:
res3 = prune.rpart(res1, cp=0.15)
rpart.plot(res3, yesno=2)
res4 = prune.rpart(res1, cp=0.062)
rpart.plot(res4, yesno=2)

#================================
# Create Machine Leanrning Model:
#================================
h2o.init()

# create training and validation sets (50/50):
dt = data.frame(Y=as.factor(Y), Intensity, Asymmetry, EW_HI, NS_HI)
N = dim(dt)[1]
set.seed(2022)
set = sample(1:N,floor(0.5*N),replace = FALSE)
dat_train = as.h2o(dt[set,])
dat_val = as.h2o(dt[-set,])
l2_seq = exp(seq(-7,-2,length=20))
lisst = list(NULL)
l2_seq = exp(seq(-7,-2, length = 20))
for (i in 1:length(l2_seq)){
  model = h2o.deeplearning(x= 2:5, y= 1,
                           training_frame = dat_train ,
                           validation_frame = dat_val,
                           standardize = TRUE,
                           hidden = c(5),
                           activation = 'Tanh',
                           distribution = 'multinomial',
                           loss='CrossEntropy',
                           l2=l2_seq[i],
                           rate=0.001,
                           adaptive_rate= FALSE,
                           epochs = 1000,
                           reproducible = TRUE,
                           seed=2)
  report = h2o.logloss(model, train = TRUE, valid = TRUE)
  rr = report[2] # extract the validation error
  lisst = append(lisst, rr)
}

# validation error vs L-2 regularisation to find level of L-2 regularisation
lisst[[1]] = NULL
plot(as.numeric(lisst)~l2_seq,type= 'l', col = 'blue')
which.min(unlist(lisst)) # 10 is the minimum
abline(v=l2_seq[10], col="red")

#===========================
# create new neural network
#===========================
newmodel = h2o.deeplearning(x= 2:5, y= 1,
                            training_frame = dat_train ,
                            validation_frame = dat_val,
                            standardize = TRUE,
                            hidden = c(5),
                            activation = 'Tanh',
                            distribution = 'multinomial',
                            loss='CrossEntropy',
                            l2=l2_seq[10],
                            rate=0.001,
                            adaptive_rate= FALSE,
                            epochs = 1000,
                            reproducible = TRUE,
                            seed=2)
plot(newmodel)