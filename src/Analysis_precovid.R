######################################################################################
#
# Initialization part 
#
######################################################################################

# Required packages 
# igraph = Create graphs for network analysis 
# StatNet = Perform network statistics 
# Intergraph = Convert between graph objs. Network -> igraph and vice-versa 
if (!"igraph" %in% installed.packages()) install.packages("igraph")
if (!"statnet" %in% install.packages()) install.packages("statnet")
if (!"intergraph" %in% install.packages()) install.packages("intergraph") 


library(statnet)
library(dplyr)  # For data manipulation 
library(intergraph)


sessionInfo() # check other attached packages. 
list.files()
connectionsFromEdgesPre <- read.csv("../data/edges_pre.csv")

# View the first rows of the edgelist to make sure it imported correctly:
head(connectionsFromEdgesPre)



######################################################################################
#
# Graph formation and visualization 
#
######################################################################################

# Convert the edgelist to a network object in statnet format:
# connections <- network(matrix(scan(file="edges_all.csv", skip=1), byrow=TRUE), matrix.type = "edgelist") 
connections_pre <- as.network.matrix(connectionsFromEdgesPre, matrix.type = "edgelist", directed = FALSE)

# Connections object in statnet format
conn_mat_pre <- as.matrix.network(connections_pre)
sum(conn_mat_pre)
connections_pre

# 'Omkar': 1, 'Aditya': 2, 'Amisha': 3, 'Anuradha': 4
# For coloring the connections, grab all connections separately for the 4 group members 
c1_pre <- connections_pre[,1]
c2_pre <- connections_pre[,2]
c3_pre <- connections_pre[,3]
c4_pre <- connections_pre[,4]

# Color codes for just tied tied to one, or if tied to  others
total_nodes = dim(conn_mat_pre)[1]

cCodes_pre <- rep(NA, total_nodes)
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
  if ((c1_pre[i] + c2_pre[i] + c3_pre[i] + c4_pre[i]) > 1 ) {
    cCodes_pre[i] <- "coral"
  }
}
cCodes_pre[1:4] <- "cyan"

# Add attribute and check plot using statnet
# Make sure igraph is not loaded in order for set.vertex.attribute to work 
connections_pre
detach(package:igraph)  
set.vertex.attribute(connections_pre,"contact.color",cCodes_pre)
connections_pre
get.vertex.attribute(connections_pre,"contact.color")
par(mar = c(0, 0, 0, 0)) 
plot(connections_pre, vertex.col = "contact.color")

# Visualize the giant component 
connections_igraph_pre <- asIgraph(connections_pre)
connections_igraph_pre


# Load igraph after finishing up with tasks related to intergraph 
library('igraph')
par(mar = c(0, 0, 0, 0))  # This is to set plotting parameters  

cCodes_pre
V(connections_igraph_pre)$color <- cCodes_pre # Have to give valid R color names

color_mat = V(connections_igraph_pre)$color
table(color_mat) # Get the color count 


# Full pre-covid graph in a different layout 
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

# Giant component plot 
giantGraph_pre <- connections_igraph_pre %>% 
  induced.subgraph(., which(comp_pre$membership == which.max(comp_pre$csize)))
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



######################################################################################
#
# Network Statistics - Local and Global metrics 
#
######################################################################################

# check if the network is directed or undirected
detach(package:igraph)  
is.directed(connections_pre)

summary(connections_pre)                             
network.size(connections_pre)                        
length(isolates(connections_pre))
network.density(connections_pre)


# Load the combined connections info file 
combined_conn <- read.csv('../data/combined_data.csv')
# Extract the ID and Full Name column from it 
# Note that %>% is used for piping functions 
id_to_names <- combined_conn %>% 


save.image("snap_file_pre.RData")
load("snap_file_pre.RData")
