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

# Add different attributes to the graph object 
connections_pre
detach(package:igraph)  
# Color attribute 
set.vertex.attribute(connections_pre,"contact.color",cCodes_pre)
connections_pre
get.vertex.attribute(connections_pre,"contact.color")


# Adding the "names" attribute
# Load the combined connections info file 
combined_conn <- read.csv('../data/combined_data.csv')
# Extract the ID and Full Name column from it 
# Note that %>% is used for piping functions 
id_to_names <- combined_conn %>% select(ID, Full.Name)
# Delete duplicates 
id_to_names = distinct(id_to_names, ID, .keep_all=TRUE)
# Sort the ids 
id_to_names <- id_to_names[order(id_to_names$ID),]
# Pass the names as a vertex attribute 
set.vertex.attribute(connections_pre,"names", id_to_names$Full.Name)
# Also store the ID as the attribute 
set.vertex.attribute(connections_pre,"ID", id_to_names$ID)


par(mar = c(0, 0, 0, 0)) 
plot(connections_pre, vertex.col = "contact.color")



# Converting statnet network object into igraph
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
       layout = layout_with_fr(.), ## Fruchterman-Reingold layout
       edge.arrow.size = .4, ## arrow size
       vertex.size = 5, ## node size
       vertex.label = NA,
       vertex.label.cex = .4, ## node label size
       vertex.label.color = 'black') ## node label color

comp_pre <- components(connections_igraph_pre)
comp_pre

# Giant component plot 
giantGraph <- connections_igraph_pre %>% 
  induced.subgraph(., which(comp_pre$membership == which.max(comp_pre$csize)))
vcount(giantGraph) ## the number of nodes/actors/users
ecount(giantGraph) ## the number of edges

par(mar = c(0, 0, 0, 0)) 

giantGraph %>% 
  plot(.,
       layout = layout_with_kk(.), ## Davidson and Harel graph layout
       edge.arrow.size = .4,
       vertex.size = 6,
       vertex.label = NA,
       vertex.label.cex = .5,
       vertex.label.color = 'black')


sna_g <- igraph::get.adjacency(giantGraph, sparse=FALSE) %>% network::as.network.matrix()
names_attr <- vertex_attr(giantGraph, 'names')
ids_attr <- vertex_attr(giantGraph, 'ID')


# Save the giant-graph obj 
save.image('PreCovid_image.RData')


######################################################################################
#
# Network Statistics - Centralities 
#
######################################################################################

load('PreCovid_image.RData')

detach(package:igraph)  
is.directed(connections_pre)

summary(connections_pre)                             
network.size(connections_pre)                        
length(isolates(connections_pre))
network.density(connections_pre)



# Calculate different centrality measures 
library(statnet)

# Compute centralities based on 'network' package
# Calculate in-degree centrality
# Store the information
# Calculate degree centrality 
# gmode = graph is used in case of undirected graphs 
centralities <- data.frame( 'node_id' = ids_attr, 'node_name' = names_attr, 
                           'degree' = degree(sna_g, gmode='graph', cmode = 'freeman'))

# Calculate betweenness centrality and store it in the data.frame called 'centralities'
centralities$betweenness <- betweenness(sna_g)

# Calculate closeness centrality and store it in the data.frame called 'centralities'
centralities$closeness <- igraph::closeness(giantGraph, mode = 'all')

# Calculate eigenvector centrality and store it in the data.frame called 'centralities'
centralities$eigen <- evcent(sna_g)

# Calculate Burt's network constraint and store it in the data.frame called 'centralities'
# using 'igraph' because 'sna' doesn't have the function
centralities$netconstraint <- igraph::constraint(giantGraph)

# Calculate authority and store it in the data.frame called 'centralities'
# using 'igraph' because 'sna' doesn't have the function
# 'igraph::' allows calling for any igraph function without loading the package
centralities$authority <- igraph::authority_score(giantGraph, scale = TRUE)$`vector`

# Calculate hub and store it in the data.frame called 'centralities'
# using 'igraph' because 'sna' doesn't have the function
centralities$hub <- igraph::hub_score(giantGraph, scale = TRUE)$`vector`

View(centralities)

######################################################################################
#
# Network Statistics - Global Properties  
#
######################################################################################

### K-Core Decomposition ### 

detach('package:statnet', unload = TRUE)
library(igraph)

kcore <- giantGraph %>% graph.coreness(.) ## calculate k-cores
kcore ## show the results of k-core decomposition

# Count the number of nodes in each group 
max_k <- max(kcore)
k_counts = rep(0, max_k)
for (i in max_k:1){
  
  k_counts[i] = length(which(kcore == i))
  
}
k_counts

## Plot Bar plot of the k-count distribution 
barplot(k_counts, names.arg=seq(1, max_k, 1), xlab="K Count", ylab="Frequency")


## Plot a graph colored by the k-core decomposition results
giantGraph %>% 
  plot(.,
       layout = layout_with_lgl(.),
       edge.arrow.size = .3,
       vertex.size = 4,
       vertex.color = adjustcolor(kcore, alpha.f = .3),
       vertex.label.cex = .5,
       vertex.label.color = 'black',
       mark.groups = by(seq_along(kcore), kcore, invisible),
       mark.shape = 1/4,
       mark.col = rainbow(length(unique(kcore)),alpha = .1),
       mark.border = NA
  )


### Cluster analysis using Newman Girman, gives 0.44 mod
# VERY SLOW 
# cluster <- giantGraph %>% cluster_edge_betweenness(directed=FALSE) 
# Save the cluster file as its too time consuming to calculate over and over again 
# saveRDS(cluster, 'cluster_ng.rds')

# Load the cluster
cluster = readRDS('cluster_ng.rds')


# Using walktrap, gives 0.42 mod 
# cluster <- giantGraph %>% cluster_walktrap()

# Using fast greedy # Mod = 0.437
# Performs almost as well as Newman Girvan, and is much faster
# cluster <- giantGraph %>% cluster_fast_greedy() 

cluster 


# modularity measure
modularity(cluster)

# Find the number of clusters
membership(cluster)   # affiliation list
length(cluster) # number of clusters

# Find the size the each cluster 
# Note that communities with one node are isolates, or have only a single tie
sizes(cluster) 

# Visualize clusters - that puts colored blobs around the nodes in the same community.
# You may want to remove vertex.label=NA to figure out what terms are clustered.
cluster %>% plot(.,giantGraph,
                 # layout = layout_with_gem(.),
                 layout = layout_with_fr(giantGraph),
                 edge.arrow.size = .3,
                 vertex.size = 4,
                 vertex.color = adjustcolor(membership(.), alpha.f = .3),
                 vertex.label.cex = .5,
                 vertex.label.color = 'black',
                 mark.groups = by(seq_along(membership(.)), membership(.), invisible),
                 mark.shape = 1/4,
                 mark.col = rainbow(length(.),alpha = .1),
                 # mark.border = NA
)


# Get the members of the 5th community 
members_arr = cluster$membership
total_members = length(members_arr)
members_names = rep(0, sizes(cluster)[5]) 
counter = 1
for (i in 1:total_members){
  if (members_arr[i] == 5)
  {
    members_names[counter] <- names_attr[i]
    counter <- counter +  1 
  }
}

members_names


### Degree distribution ### 

giantGraph %>% degree.distribution(.,) %>% 
  plot(., col = 'black', pch = 19, cex = 1.5,
       main = 'Degree Distribution',
       ylab = 'Density',
       xlab = 'Degree')

# CCDF - Complementary Cumulative Distribution Function
# Plot a log-log plot of Degree distribution
giantGraph %>% 
  degree.distribution(.,cumulative = TRUE ) %>% 
  plot(1:(max(degree(giantGraph))+1),., ## since log doesn't take 0, add 1 to every degree
       log='xy', type = 'l',
       main = 'Log-Log Plot of Degree',
       ylab = 'CCDF',
       xlab = 'Degree')

# Fit a power law to the degree distribution
# The output of the power.law.fit() function tells us what the exponent of the power law is ($alpha)
# and the log-likelihood of the parameters used to fit the power law distribution ($logLik)
# Also, it performs a Kolmogov-Smirnov test to test whether the given degree distribution could have
# been drawn from the fitted power law distribution.
# The function thus gives us the test statistic ($KS.stat) and p-vaule ($KS.p) for that test
in_power <- giantGraph %>% 
  degree.distribution(.,) %>%
  power.law.fit(.)
in_power



### Small-world characteristics 

ntrials <- 1000 ## set a value for the repetition
cl.rg <- numeric(ntrials) ## create an estimated value holder for clustering coefficient
apl.rg <- numeric(ntrials) ## create an estimated value holder for average path length
for (i in (1:ntrials)) {
  g.rg <- rewire(giantGraph, keeping_degseq(niter = 100))
  cl.rg[i] <- transitivity(g.rg, type = 'global')
  apl.rg[i] <- average.path.length(g.rg)
}

# plot a histogram of simulated values for clustering coefficient + the observed value
# Calculate the x-lim correctly to make sure the red line is also shown 
x_low = min(cl.rg)
x_high = max(cl.rg)
epsilon = 0.005
hist(cl.rg,
     main = 'Histogram of Clustering Coefficient',
     xlab = 'Clustering Coefficient',
     xlim = range(x_low, x_high+epsilon)
    )
par(xpd = FALSE)
# the line indicates the mean value of clustering coefficient for your network
abline(v = giantGraph %>% transitivity(., type = 'global'), col = 'red', lty = 2)
# this tests whether the observed value is statistically different from the simulated distribution
t.test(cl.rg, mu=giantGraph %>% transitivity(., type = 'global'),
       alternative = 'less') ##pick either 'less' or 'greater' based on your results

# plot a histogram of simulated values for average path length + the observed value
hist(apl.rg,
     main = 'Histogram of Average Path Length',
     xlab = 'Average Path Length')
# the line indicates the mean value of average path length for your network
abline(v = giantGraph %>% average.path.length(), col = 'red', lty = 2)
# this tests whether the observed value is statistically different from the simulated distribution
t.test(apl.rg, mu=giantGraph %>% average.path.length(.),
       alternative = 'less') ##pick either 'less' or 'greater' based on your results



