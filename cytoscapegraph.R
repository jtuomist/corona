# https://bioconductor.org/packages/release/bioc/vignettes/RCy3/inst/doc/Overview-of-RCy3.html

library(RCy3)
library(gsheet)

df <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1eMMwHV1sD9DvCsnYAoESt8EV5US21mGXRZF7HR-myvA/edit#gid=1340914666")

gr <- makeGraph(df)

gr$nodes_df$score <- as.integer(gr$nodes_df$score) * 10
gr$edges_df$weight <- as.numeric(gr$edges_df$weight)
createNetworkFromDataFrames(
  gr$nodes_df,
  gr$edges_df,
  title="Insight network",
  collection="DataFrame Example")

cytoscapePing ()
cytoscapeVersionInfo ()

nodes <- data.frame(id=c("node 0","node 1","node 2","node 3"),
                    group=c("A","A","B","B"), # categorical strings
                    score=as.integer(c(20,10,15,5)), # integers
                    stringsAsFactors=FALSE)
edges <- data.frame(source=c("node 0","node 0","node 0","node 2"),
                    target=c("node 1","node 2","node 3","node 3"),
                    interaction=c("inhibits","interacts","activates","interacts"),  # optional
                    weight=c(5.1,3.0,5.2,9.9), # numeric
                    stringsAsFactors=FALSE)

createNetworkFromDataFrames(nodes,edges, title="my first network", collection="DataFrame Example")

setVisualStyle('Marquee')

style.name = "myStyle"
defaults <- list(NODE_SHAPE="diamond",
                 NODE_SIZE=30,
                 EDGE_TRANSPARENCY=120,
                 NODE_LABEL_POSITION="W,E,c,0.00,0.00")
nodeLabels <- mapVisualProperty('node label','id','p')
nodeFills <- mapVisualProperty('node fill color','group','d',c("A","B"), c("#FF9900","#66AAAA"))
arrowShapes <- mapVisualProperty('Edge Target Arrow Shape','interaction','d',c("activates","inhibits","interacts"),c("Arrow","T","None"))
edgeWidth <- mapVisualProperty('edge width','weight','p')

createVisualStyle(style.name, defaults, list(nodeLabels,nodeFills,arrowShapes,edgeWidth))
setVisualStyle(style.name)
