######################################################################################
#
# Initialization part 
#
######################################################################################


if (!"igraph" %in% installed.packages()) install.packages("igraph")
if (!"statnet" %in% install.packages()) install.packages("statnet")
if (!"intergraph" %in% install.packages()) install.packages("intergraph") 
if (!"RSiena" %in% install.packages()) install.packages("RSiena") 
if (!"texreg" %in% install.packages()) install.packages("texreg") 

library(RSiena)
library(statnet)
library(dplyr)  # For data manipulation 
library(intergraph)

sessionInfo() # check other attached packages. 
list.files()


adj_pre <- as.matrix(read.table("../data/adj_pre.dat"))
adj_post <- as.matrix(read.table("../data/adj_post.dat"))


# Load the features 
nu <- as.matrix(read.table("../data/nu.dat"))
eng <- as.matrix(read.table("../data/Engineer.dat"))
research <- as.matrix(read.table("../data/Research.dat"))
manager <- as.matrix(read.table("../data/Manager.dat"))
director <- as.matrix(read.table("../data/Director.dat"))


######################################################################################
#
# SIENA Model Creation 
#
######################################################################################



# Convert to siena object 
combined_net <- array(c(adj_pre, adj_post), dim=c(1505, 1505, 2))
sNet <- sienaNet(combined_net)
nuNet <- - sienaNet(nu, type="behavior")
engNet <- - sienaNet(eng, type="behavior")
rNet <- - sienaNet(research, type="behavior")
mNet <- - sienaNet(manager, type="behavior")
dNet <- - sienaNet(director, type="behavior")

# Create report 
# Model 1 effect at a time - First nuNet (Whether users belong to northwestern or not)
mybehdata <- sienaDataCreate(sNet, nuNet)

myeff <- getEffects(mybehdata)
myeff$include[]

myeff <- includeEffects(myeff, egoX, altX, sameX, interaction1 = "nuNet")
mymodel <- sienaModelCreate(useStdInits = TRUE, projname = 'sna_proj')
myeff

ans1 <- siena07(mymodel, data=mybehdata, effects=myeff, batch=FALSE, verbose=FALSE, 
                useCluster=TRUE, nbrNodes=4, returnDeps = TRUE)

ans1$theta
stan_err <- ans1$se
estimates <- abs(ans1$theta)
param_sig <- estimates/stan_err 


odds_ratio = exp(ans1$theta)
probs = odds_ratio / (1 + odds_ratio)
# Option B:
library(texreg) ## if you haven't installed it, install it first using the command on the top of the script
# texreg(ans1) ## for LaTex
screenreg(ans1)
saveRDS(ans1, 'ans1_nu.rds')




# Model 1 effect at a time - Second EngNet
mybehdata <- sienaDataCreate(sNet, engNet)

myeff <- getEffects(mybehdata)
myeff$include[]

myeff <- includeEffects(myeff, egoX, altX, sameX, interaction1 = "engNet")
mymodel <- sienaModelCreate(useStdInits = TRUE, projname = 'sna_proj')
myeff

ans1 <- siena07(mymodel, data=mybehdata, effects=myeff, batch=FALSE, verbose=FALSE, 
                useCluster=TRUE, nbrNodes=4, returnDeps = TRUE)

ans1$theta
stan_err <- ans1$se
estimates <- abs(ans1$theta)
param_sig <- estimates/stan_err 


odds_ratio = exp(ans1$theta)
probs = odds_ratio / (1 + odds_ratio)
# Option B:
library(texreg) ## if you haven't installed it, install it first using the command on the top of the script
# texreg(ans1) ## for LaTex
screenreg(ans1)
saveRDS(ans1, 'ans1_eng.rds')





# Model 1 effect at a time - Second EngNet
mybehdata <- sienaDataCreate(sNet, mNet)

myeff <- getEffects(mybehdata)
myeff$include[]

myeff <- includeEffects(myeff, egoX, altX, sameX, interaction1 = "mNet")
mymodel <- sienaModelCreate(useStdInits = TRUE, projname = 'sna_proj')
myeff

ans1 <- siena07(mymodel, data=mybehdata, effects=myeff, batch=FALSE, verbose=FALSE, 
                useCluster=TRUE, nbrNodes=4, returnDeps = TRUE)

ans1$theta
stan_err <- ans1$se
estimates <- abs(ans1$theta)
param_sig <- estimates/stan_err 


odds_ratio = exp(ans1$theta)
probs = odds_ratio / (1 + odds_ratio)

screenreg(ans1)
saveRDS(ans1, 'ans1_MNet.rds')





# Model 1 effect at a time - Researchers 
mybehdata <- sienaDataCreate(sNet, rNet)

myeff <- getEffects(mybehdata)
myeff$include[]

myeff <- includeEffects(myeff, egoX, altX, sameX, interaction1 = "rNet")
mymodel <- sienaModelCreate(useStdInits = TRUE, projname = 'sna_proj')
myeff

ans1 <- siena07(mymodel, data=mybehdata, effects=myeff, batch=FALSE, verbose=FALSE, 
                useCluster=TRUE, nbrNodes=4, returnDeps = TRUE)

ans1$theta
stan_err <- ans1$se
estimates <- abs(ans1$theta)
param_sig <- estimates/stan_err 


odds_ratio = exp(ans1$theta)
probs = odds_ratio / (1 + odds_ratio)

screenreg(ans1)
saveRDS(ans1, 'ans1_rNet.rds')





# Model 1 effect at a time - Second EngNet
mybehdata <- sienaDataCreate(sNet, dNet)

myeff <- getEffects(mybehdata)
myeff$include[]

myeff <- includeEffects(myeff, egoX, altX, sameX, interaction1 = "dNet")
mymodel <- sienaModelCreate(useStdInits = TRUE, projname = 'sna_proj')
myeff

ans1 <- siena07(mymodel, data=mybehdata, effects=myeff, batch=FALSE, verbose=FALSE, 
                useCluster=TRUE, nbrNodes=4, returnDeps = TRUE)

ans1$theta
stan_err <- ans1$se
estimates <- abs(ans1$theta)
param_sig <- estimates/stan_err 


odds_ratio = exp(ans1$theta)
probs = odds_ratio / (1 + odds_ratio)

screenreg(ans1)
saveRDS(ans1, 'ans1_dNet.rds')


