if (!"igraph" %in% installed.packages()) install.packages("igraph") ## this package is a network analysis tool
if (!"statnet" %in% install.packages()) install.packages("statnet") ## this package is another popular network analysis tool
install.packages("intergraph")

library(statnet)
library(igraph)
library(dplyr)
library('intergraph')
detach(package:igraph)
sessionInfo() ## check other attached packages. 
list.files()
connectionsFromEdgesPre <- read.csv("../data/edges_pre.csv")
# View the first rows of the edgelist to make sure it imported correctly:
head(connectionsFromEdgesPre)
connectionsFromEdgesPre
# Convert the edgelist to a network object in statnet format:
# connections <- network(matrix(scan(file="edges_all.csv", skip=1), byrow=TRUE), matrix.type = "edgelist") 
connections_pre <- as.network.matrix(connectionsFromEdgesPre, matrix.type = "edgelist", directed = FALSE)

# Connections object in statnet format

conn_mat_pre <- as.matrix.network(connections_pre)
sum(conn_mat_pre)
connections_pre

c1_pre <- connections_pre[,1]
c2_pre <- connections_pre[,2]
c3_pre <- connections_pre[,3]
c4_pre <- connections_pre[,4]

# Color codes for just tied tied to one, or if tied to  others
cCodes_pre <- rep(NA,1505)
for (i in 1:length(cCodes_pre)) {
  if ((c1_pre[i] == 1) & (c2_pre[i] == 0) & (c3_pre[i] == 0) & (c4_pre[i] == 0)) {
    cCodes_pre[i] <- "red"
  }
  if ((c1_pre[i] == 0) & (c2_pre[i] == 1) & (c3_pre[i] == 0) & (c4_pre[i] == 0)) {
    cCodes_pre[i] <- "blue"
  }
  if ((c1_pre[i] == 0) & (c2_pre[i] == 0) & (c3_pre[i] == 1) & (c4_pre[i] == 0)) {
    cCodes_pre[i] <- "yellow"
  }
  if ((c1_pre[i] == 0) & (c2_pre[i] == 0) & (c3_pre[i] == 0) & (c4_pre[i] == 1)) {
    cCodes_pre[i] <- "green"
  }
  if ((c1_pre[i] + c2_pre[i] + c3_pre[i] + c4_pre[i]) >1 ) {
    cCodes_pre[i] <- "coral"
  }
}
cCodes_pre[1:4] <- "cyan"

# Add attribute and check plot using statnet

connections_pre
set.vertex.attribute(connections_pre,"contact.color",cCodes_pre)
connections_pre
get.vertex.attribute(connections_pre,"contact.color")
par(mar = c(0, 0, 0, 0)) 
plot(connections_pre, vertex.col = "contact.color")

# check if the network is directed or undirected
is.directed(connections_pre)

summary(connections_pre)                              # summarize the Buy In From You network
network.size(connections_pre)                         # print out the network size
length(isolates(connections_pre))

network.density(connections_pre)

save.image("snap_file_pre.RData")
load("snap_file_pre.RData")


library('igraph')

par(mar = c(0, 0, 0, 0)) 

connections_igraph_pre <- asIgraph(connections_pre)
connections_igraph_pre
V(connections_igraph_pre)$color <- cCodes_pre # Have to give valid R color names

connections_igraph_pre %>% 
  plot(.,
       layout = layout_with_kk(.), ## Fruchterman-Reingold layout
       edge.arrow.size = .4, ## arrow size
       vertex.size = 5, ## node size
       vertex.label = NA,
       vertex.label.cex = .4, ## node label size
       vertex.label.color = 'black') ## node label color

comp_pre <- components(connections_igraph_pre)
comp_pre

giantGraph_pre <- connections_igraph_pre %>% 
  induced.subgraph(., which(comp_pre$membership == which.max(comp_pre$csize)))
V(giantGraph_pre)$color <- cCodes_pre # Have to give valid R color names
vcount(giantGraph_pre) ## the number of nodes/actors/users
ecount(giantGraph_pre) ## the number of edges

par(mar = c(0, 0, 0, 0)) 

giantGraph_pre %>% 
  plot(.,
       layout = layout_with_kk(.), ## Davidson and Harel graph layout
       edge.arrow.size = .4,
       vertex.size = 6,
       vertex.label = NA,
       vertex.label.cex = .5,
       vertex.label.color = 'black')
