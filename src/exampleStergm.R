library(statnet)

adj_pre <- as.matrix(read.table("../data/adj_pre.dat"))
adj_post <- as.matrix(read.table("../data/adj_post.dat"))

# Load the features 
nu <- as.matrix(read.table("../data/nu.dat"))
eng <- as.matrix(read.table("../data/Engineer.dat"))
research <- as.matrix(read.table("../data/Research.dat"))
manager <- as.matrix(read.table("../data/Manager.dat"))
director <- as.matrix(read.table("../data/Director.dat"))

# Setup data
t1Net <- as.network.matrix(adj_pre, directed = F)
t2Net <- as.network.matrix(adj_post, directed = F)
netList <- list(t1Net, t2Net)

set.vertex.attribute(t1Net, "nu",nu[,1])
set.vertex.attribute(t2Net, "nu",nu[,2])

# Run model
# "ergm-terms" in help
# Add node attribute for the four group members
model1 <- stergm(netList, 
                 formation = ~ edges + nodematch("nu",diff=T) +gwesp(decay=0.5) + gwdsp(decay = 0.1),
                 dissolution = ~ edges, 
                 estimate = "CMLE")
summary(model1)

