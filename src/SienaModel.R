install.packages("RSiena")
#library(xtable)
library(RSiena)
library(statnet)

?RSiena
?sienaNet

if (!"igraph" %in% installed.packages()) install.packages("igraph")
if (!"statnet" %in% install.packages()) install.packages("statnet")
if (!"intergraph" %in% install.packages()) install.packages("intergraph") 

library(statnet)
library(dplyr)  # For data manipulation 
library(intergraph)

sessionInfo() # check other attached packages. 
list.files()
connectionsFromEdgesPre <- read.csv("/Users/anuradha/Documents/GitHub/msia-490-snap-project/data/edges_pre.csv")
connectionsFromEdgesPost <- read.csv("/Users/anuradha/Documents/GitHub/msia-490-snap-project/data/edges_post.csv")

head(connectionsFromEdgesPre)
head(connectionsFromEdgesPost)

connections_pre <- as.matrix(connectionsFromEdgesPre, matrix.type = "edgelist", directed = FALSE)
connections_post <- as.matrix(connectionsFromEdgesPost, matrix.type = "edgelist", directed = FALSE)

connections_pre<- as.network(connections_pre)
connections_post<- as.network(connections_post)

plot(connections_pre)
plot(connections_post)

connections <- sienaNet(array(c(connections_pre, connections_post)))


