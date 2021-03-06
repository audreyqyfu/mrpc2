#This is function to plot a dendrogram and display node groups in colored modules

PlotDendrogram <- function(Adj_directed, minModuleSize = 5, groupLabels = " ", dendroLabels = FALSE, hclustHang = 0.03, dendroAddGuide = FALSE, dendroGuideHang = 0.05, dendroMain = "Dendrogram with modules of nodes in colors", ...) {
  
  #Adj_directed is a matrix from directed graph
  #Start to find Module based on library(WGCNA)
  #convert to a symmetric matrix because Adj_directed is not symmetric
  Adj_symmetric_matrix <- Adj_directed
  for (i in 1:nrow(Adj_symmetric_matrix))
  {
    for (j in 1:ncol(Adj_symmetric_matrix))
    {
      if(Adj_symmetric_matrix[i,j] == 1)
      {
        Adj_symmetric_matrix[j,i] <- 1
      }
    }
  }
  #Adj_symmetric_matrix is symmetric matrix after converting
  TOM <- TOMsimilarity(Adj_symmetric_matrix); #Need Symmetric matrix
  dissTOM <- 1-TOM
  #Call the hierarchical clustering function from fastcluster
  #This hclust that provides a much faster hierarchical clustering routine than the standard hclust function.
  #geneTree = fastcluster::hclust(as.dist(dissTOM), method = "average");
  geneTree <- hclust(as.dist(dissTOM), method = "average");
  # Plot the resulting clustering tree (dendrogram)
  #plot(geneTree, xlab="", sub="", main = "Gene clustering on TOM-based dissimilarity",
  #labels = FALSE, hang = 0.04);
  # Module identification using dynamic tree cut:
  #The Dynamic Tree Cut may identify modules whose expression profiles are very similar.
  dynamicMods <- cutreeDynamic(dendro = geneTree, 
                               distM = dissTOM,
                               deepSplit = 2, 
                               pamRespectsDendro = TRUE,
                               minClusterSize = minModuleSize);
  
  Grouplist <- table(dynamicMods)
  #print(Grouplist) #0=means unassigned genes
  
  # Convert numeric lables into colors
  dynamicColors <- labels2colors(dynamicMods)
  
  Colorlist <- table(dynamicColors)
  #print(Colorlist)
  
  #sizeGrWindow(20,6);
  PlotDendrogramObj <- plotDendroAndColors(dendro = geneTree, 
                                           colors = dynamicColors, 
                                           groupLabels = groupLabels,
                                           dendroLabels = dendroLabels, 
                                           hang = hclustHang,
                                           addGuide = dendroAddGuide, 
                                           guideHang = dendroGuideHang,
                                           main = dendroMain, ...)
return(list(graph = PlotDendrogramObj,
            dynamicColors = dynamicColors,
            GroupMods = Grouplist,
            GroupModsColors = Colorlist,
            Adj_symmetric_matrix = Adj_symmetric_matrix))
}
