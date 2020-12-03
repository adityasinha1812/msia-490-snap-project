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


set.vertex.attribute(t1Net, "nu",nu[,1])
set.vertex.attribute(t2Net, "nu",nu[,2])
set.vertex.attribute(t1Net, "eng",eng[,1])
set.vertex.attribute(t2Net, "eng",eng[,2])
set.vertex.attribute(t1Net, "research",research[,1])
set.vertex.attribute(t2Net, "research",research[,2])
set.vertex.attribute(t1Net, "manager",manager[,1])
set.vertex.attribute(t2Net, "manager",manager[,2])
set.vertex.attribute(t1Net, "director",director[,1])
set.vertex.attribute(t2Net, "director",director[,2])

netList <- list(t1Net, t2Net)
# Run model
# "ergm-terms" in help
# Add node attribute for the four group members
model1 <- stergm(netList, 
                 formation = ~ edges +nodematch("nu", diff=T) +nodematch("eng", diff=T) +nodematch("research", diff=T) +nodematch("manager", diff=T) +nodematch("director", diff=F) +gwesp(decay = 0.25),# +gwdsp(0.1, fixed=T),
                 dissolution = ~ edges, 
                 estimate = "CMLE")
summary(model1)
mcmc.diagnostics(model1)
d <- gof(model1)
d
plot(d)
