#testing
if (!"igraph" %in% installed.packages()) install.packages("igraph") ## this package is a network analysis tool
if (!"statnet" %in% install.packages()) install.packages("statnet") ## this package is another popular network analysis tool

install.packages("texreg")

library(statnet)

sessionInfo() ## check other attached packages. If magrittr, vosonSML, & igraph are listed there, you're ready!
setwd("C:/Users/agarw/Downloads/data")
list.files()
connectionsFromEdgesAll <- read.csv("edges_all.csv")
# View the first rows of the edgelist to make sure it imported correctly:
head(connectionsFromEdgesAll)
# Convert the edgelist to a network object in statnet format:
# connections <- network(matrix(scan(file="edges_all.csv", skip=1), byrow=TRUE), matrix.type = "edgelist") 
connections <- as.network.matrix(connectionsFromEdgesAll, matrix.type = "edgelist", directed = FALSE)
connections # View a summary of the network object

# check if the network is directed or undirected
is.directed(connections)

summary(connections)                              # summarize the Buy In From You network
network.size(connections)                         # print out the network size
betweenness(connections)                          # calculate betweenness for the network
isolates(connections)  

network.density(connections)

save.image("snap_file.RData")
load("snap_file.RData")


detach(package:statnet)
library('igraph')

connections_igraph <- graph.adjacency(as.matrix.network(connections))


comp <- components(connections_igraph)
comp

par(mar = c(0, 0, 0, 0)) 
connections_igraph


connections_igraph %>% 
  plot(.,
       layout = layout_with_fr(.), ## Fruchterman-Reingold layout
       edge.arrow.size = .3, ## arrow size
       vertex.size = 4, ## node size
       vertex.color = 'red', ## node color
       vertex.label.cex = .5, ## node label size
       vertex.label.color = 'black') ## node label color

giantGraph <- connections_igraph %>% 
  induced.subgraph(., which(comp$membership == which.max(comp$csize)))
vcount(giantGraph) ## the number of nodes/actors/users
ecount(giantGraph) ## the number of edges

par(mar = c(0, 0, 0, 0)) 

giantGraph %>% 
  plot(.,
       layout = layout_with_kk(.), ## Davidson and Harel graph layout
       edge.arrow.size = .3,
       vertex.size = 4,
       vertex.color = 'red',
       vertex.label.cex = .5,
       vertex.label.color = 'black')

par(mar = c(0, 0, 0, 0)) 

giantGraph %>% 
  plot(.,
       layout = layout_with_drl(.), ## Davidson and Harel graph layout
       edge.arrow.size = .3,
       vertex.size = 4,
       vertex.color = 'red',
       vertex.label.cex = .5,
       vertex.label.color = 'black')

