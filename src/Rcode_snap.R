#testing
if (!"igraph" %in% installed.packages()) install.packages("igraph") ## this package is a network analysis tool
if (!"statnet" %in% install.packages()) install.packages("statnet") ## this package is another popular network analysis tool
install.packages("intergraph")


library(statnet)
library(dplyr)
library('intergraph')
detach(package:igraph)
sessionInfo() ## check other attached packages. If magrittr, vosonSML, & igraph are listed there, you're ready!
setwd("C:/Users/agarw/Downloads/data")
list.files()
connectionsFromEdgesAll <- read.csv("edges_all.csv")
# View the first rows of the edgelist to make sure it imported correctly:
head(connectionsFromEdgesAll)
# Convert the edgelist to a network object in statnet format:
# connections <- network(matrix(scan(file="edges_all.csv", skip=1), byrow=TRUE), matrix.type = "edgelist") 
connections <- as.network.matrix(connectionsFromEdgesAll, matrix.type = "edgelist", directed = FALSE)

# Connections object in statnet format

conn_mat <- as.matrix.network(connections)
sum(conn_mat)
connections

c1 <- connections[,1]
c2 <- connections[,2]
c3 <- connections[,3]
c4 <- connections[,4]

# Color codes for just tied tied to one, or if tied to  others
cCodes <- rep(NA,1505)
for (i in 1:length(cCodes)) {
  if ((c1[i] == 1) & (c2[i] == 0) & (c3[i] == 0) & (c4[i] == 0)) {
    cCodes[i] <- "red"
  }
  if ((c1[i] == 0) & (c2[i] == 1) & (c3[i] == 0) & (c4[i] == 0)) {
    cCodes[i] <- "blue"
  }
  if ((c1[i] == 0) & (c2[i] == 0) & (c3[i] == 1) & (c4[i] == 0)) {
    cCodes[i] <- "yellow"
  }
  if ((c1[i] == 0) & (c2[i] == 0) & (c3[i] == 0) & (c4[i] == 1)) {
    cCodes[i] <- "green"
  }
  if ((c1[i] + c2[i] + c3[i] + c4[i]) >1 ) {
    cCodes[i] <- "coral"
  }
}
cCodes[1:4] <- "cyan"

# Add attribute and check plot using statnet

connections
set.vertex.attribute(connections,"contact.color",cCodes)
connections
get.vertex.attribute(connections,"contact.color")

plot(connections, vertex.col = "contact.color")

# check if the network is directed or undirected
is.directed(connections)

summary(connections)                              # summarize the Buy In From You network
network.size(connections)                         # print out the network size
betweenness(connections)                          # calculate betweenness for the network
isolates(connections)  

network.density(connections)

save.image("snap_file.RData")
load("snap_file.RData")


library('igraph')

par(mar = c(0, 0, 0, 0)) 

connections_igraph <- asIgraph(connections)
connections_igraph
V(connections_igraph)$color <- cCodes # Have to give valid R color names
comp <- components(connections_igraph)
comp
connections_igraph %>% 
  plot(.,
       layout = layout_with_fr(.), ## Fruchterman-Reingold layout
       edge.arrow.size = .4, ## arrow size
       vertex.size = 5, ## node size
       #vertex.label = NA,
       vertex.label.cex = .4, ## node label size
       vertex.label.color = 'black') ## node label color

comp <- components(connections_igraph)
comp

giantGraph <- connections_igraph %>% 
  induced.subgraph(., which(comp$membership == which.max(comp$csize)))
V(giantGraph)$color <- cCodes # Have to give valid R color names
vcount(giantGraph) ## the number of nodes/actors/users
ecount(giantGraph) ## the number of edges

par(mar = c(0, 0, 0, 0)) 

giantGraph %>% 
  plot(.,
       layout = layout_with_kk(.), ## Davidson and Harel graph layout
       edge.arrow.size = .4,
       vertex.size = 6,
       vertex.label.cex = .5,
       vertex.label.color = 'black')


<<<<<<< Updated upstream
sna_g <- igraph::get.adjacency(giantGraph, sparse=FALSE) %>% network::as.network.matrix()
detach('package:igraph')
library(statnet)
degree(sna_g, cmode = 'indegree')
centralities <- data.frame('node_name' = as.character(network.vertex.names(sna_g)),
                           'in_degree' = degree(sna_g, cmode = 'indegree'))
centralities$out_degree <- degree(sna_g, cmode = 'outdegree')
centralities$betweenness <- betweenness(sna_g)
centralities$incloseness <- igraph::closeness(giantGraph, mode = 'in')
centralities$outcloseness <- igraph::closeness(giantGraph, mode = 'out')
centralities$eigen <- evcent(sna_g)
centralities$netconstraint <- igraph::constraint(giantGraph)
centralities$authority <- igraph::authority_score(giantGraph, scale = TRUE)$`vector`
centralities$hub <- igraph::hub_score(giantGraph, scale = TRUE)$`vector`
View(centralities)
=======
# Convert to igraph for plotting
# (Need to have intergraph package installed and loaded)
>>>>>>> Stashed changes
