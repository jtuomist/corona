# This is code makegraph3.R on github.com/jtuomist/corona/.
# It is a fork from Op_en3861/makeGraph2 on page [[Insight network]]
# It is an update to work with cytoscape rather than with DiagrammeR.

library(OpasnetUtils)

#' Making insight network graph object
#' 
#' makeGraph is a function for taking an insight ovariable and making a graph object.
#'
#' @param a is data.frame or ovariable defining nodes and edges with at least columns: Oldid, type, Item, label, Relation, Object, Description. Other columns for nodes such as URL are allowed.
#' @return two data.frames: nodes_df and edges_df that are directly given as parameters for DiagrammeR::create_graph.

makeGraph <- function(ova, formatting=data.frame(), ...) {
  require(OpasnetUtils)
  require(RCy3)

  if(FALSE) { # Maybe not needed  
    if(!exists("formatted")) formatted <- data.frame()
    if(nrow(formatted)==0) {
      objects.latest("Op_en3861", code_name="formatted") # [[Insight network]] formatted
    }
    if(!exists("chooseGr")) {
      objects.latest("Op_en3861", code_name="chooseGr") # [[Insight network]] chooseGr
    }
  }
  
  if("ovariable" %in% class(ova)) {
    a <- ova@output
    meta <- ova@meta$insightnetwork
  } else {
    a <- ova
    meta <- NULL
  }
  a$truth <- signif(a$truth,2)
  a$relevance <- signif(a$relevance,2)
  for(i in 1:ncol(a)) {
    a[[i]] <- gsub("[\"']", " ", a[[i]])
  }
  
  # Fill in missing labels, Items, and object nodes
  
  a$label <- ifelse(is.na(a$label),substr(a$Item,1,30), a$label)
  a$Item  <- ifelse(is.na(a$Item),a$label, a$Item)
  
  # Find nrow that matches the Object based on Item or label.
  tst <- rep(1:nrow(a),2)[match(a$Object, c(a$Item, a$label))]
  
  # Use Item as Object identifier when possible
  hasobj <- !(is.na(a$Object) | a$Object=="") # Rows of data.frame a that have Object
  a$Object[hasobj] <- a$Item[tst][hasobj]
  
  # Find objects that have not been defined
  newbies  <- ifelse(is.na(tst), a$Object,NA)
  newbies <- newbies[!is.na(newbies)]
  
  if(length(newbies)>0) {
    a <- orbind(
      a,
      data.frame(
        Item=newbies,
        label=substr(newbies,1,30),
        stringsAsFactors = FALSE
      )
    )
  }
  
  nodes <- a[!(duplicated(a$Item) | is.na(a$Item) | a$Item==""),]
  #  nodes$tooltip <- paste0(
  #    nodes$label, ". ",
  #    ifelse(nodes$label == nodes$Item, "", paste0(nodes$Item, ". ")), 
  #    ifelse(is.na(nodes$Description), "", paste0("\n", nodes$Description)),
  #    " (", nodes$Context, "/", nodes$id,")", 
  #  )
  nodes$tooltip <- paste0(
    nodes$Item, ". ", nodes$Description, "/ truth: ", nodes$truth, " relevance: ", nodes$relevance)
  #nodes <- merge(nodes, formatted[setdiff(colnames(formatted),colnames(nodes))],
  #               by.x="type", by.y="Resource")
  #colnames(nodes) <- gsub("node.","",colnames(nodes))
  nodes <- nodes[!grepl("edge.", colnames(nodes))]
  nodes$id <- 1:nrow(nodes)
  
  # Create edges and flip unpreferred relations to their inverse relations
  
  inver <- opbase.data("Op_en7783", subset="Relation types")
  for(i in colnames(inver)) inver[[i]] <- as.character(inver[[i]])
  inve <- data.frame(
    rel = c(inver$`English name`,inver$`Finnish name`),
    inve = c(inver$`English inverse`,inver$`Finnish inverse`),
    stringsAsFactors = FALSE
  )
  
  edges <- a[!(is.na(a$Object) | a$Object=="") , ]
# Disable flipping for now
#  flip <- edges$rel %in% inve$inve
#  tmp <- edges$Item
#  edges$Item[flip] <- edges$Object[flip]
#  edges$Object[flip] <- tmp[flip]
#  edges$rel[flip] <- inve$rel[match(edges$rel, inve$inve)][flip]

#  edges$from <- match(edges$Item, nodes$Item)
#  edges$to <- match(edges$Object, nodes$Item)
  edges$label <- edges$rel
#  edges <- merge(edges, formatted[setdiff(colnames(formatted),colnames(edges))],
#                 by.x="rel", by.y="Resource", all.x = TRUE)
  colnames(edges) <- gsub("edge.","",colnames(edges))
  edges <- edges[!grepl("node.", colnames(edges))]
  edges$id <- 1:nrow(edges)
  edges$labeltooltip <- paste0(edges$label, " (",edges$Context, "/",edges$id, ")")
  
  colnames(nodes)[colnames(nodes)=="Item"] <- "id"
  colnames(nodes)[colnames(nodes)=="type"] <- "group"
  colnames(nodes)[colnames(nodes)=="truth"] <- "score"
  colnames(edges)[colnames(edges)=="Item"] <- "source"
  colnames(edges)[colnames(edges)=="Object"] <- "target"
  colnames(edges)[colnames(edges)=="rel"] <- "interaction"
  colnames(edges)[colnames(edges)=="label"] <- "name"
  colnames(edges)[colnames(edges)=="relevance"] <- "weight"
  
  nodes <- nodes[c("id","group","score")]
  edges <- edges[c("source","target","interaction","weight")]
  
  gr <- list(
    nodes_df=nodes,
    edges_df=edges
  )
#  if(!is.null(meta)) {
#    gr <- chooseGr(gr, input=meta)
#  }
  
  return(gr) 
}
