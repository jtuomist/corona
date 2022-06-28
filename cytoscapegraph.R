# https://bioconductor.org/packages/release/bioc/vignettes/RCy3/inst/doc/Overview-of-RCy3.html

library(RCy3)
library(gsheet)

#df <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1eMMwHV1sD9DvCsnYAoESt8EV5US21mGXRZF7HR-myvA/edit#gid=1340914666")
df <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1eMMwHV1sD9DvCsnYAoESt8EV5US21mGXRZF7HR-myvA/edit#gid=0")

gr <- makeGraph(df)

gr$nodes_df$score <- as.integer(as.numeric(gr$nodes_df$score) * 10)
gr$edges_df$weight <- as.numeric(gr$edges_df$weight)
nodes <- (gr$nodes_df)
edges <- (gr$edges_df)

setdiff(
  unique(c(edges$target)),
  unique(nodes$id)
)
createNetworkFromDataFrames(
  nodes,
  edges,
  title="Insight network",
  collection="DataFrame Example")

#cytoscapePing ()
#cytoscapeVersionInfo ()

#nodes <- data.frame(id=c("node 0","node 1","node 2","node 3"),
#                    group=c("A","A","B","B"), # categorical strings
#                    score=as.integer(c(20,10,15,5)), # integers
#                    stringsAsFactors=FALSE)
#edges <- data.frame(source=c("node 0","node 0","node 0","node 2"),
#                    target=c("node 1","node 2","node 3","node 3"),
#                    interaction=c("inhibits","interacts","activates","interacts"),  # optional
#                    weight=c(5.1,3.0,5.2,9.9), # numeric
#                    stringsAsFactors=FALSE)

#createNetworkFromDataFrames(nodes,edges, title="my first network", collection="DataFrame Example")

setVisualStyle('Marquee')

style.name = "myStyle"
defaults <- list(
  NODE_SHAPE="circle",
  NODE_BORDER_WIDTH=5,
  NODE_BORDER_PAINT="brown",
  NODE_FILL_COLOR="white",
#  NODE_SIZE=30,
  EDGE_STROKE_UNSELECTED_PAINT="grey",
  EDGE_LABEL_COLOR="grey",
  EDGE_TARGET_ARROW_SHAPE="triangle",
  EDGE_LINE_TYPE="dots"
#  EDGE_TRANSPARENCY=120,
#  NODE_LABEL_POSITION="W,E,c,0.00,0.00"
)
#class <- c("fact", "truth", "relevance")
#class_edgetype <- c("None", "arrow","T")
#class_nodecol <- c("blue", "orange", "blue")
#colour <- c("thesis", "pro", "con")
#colour_edge <- c("green", "green", "red")

#nodeLabels <- mapVisualProperty('node label','label','passthrough')
#nodeFills <- mapVisualProperty('node fill color','node.fillcolor','passthrough') # discrete',c("A","B"), c("#FF9900","#66AAAA"))
#arrowShapes <- mapVisualProperty('Edge Target Arrow Shape','interaction','discrete',c("activates","inhibits","interacts"),c("Arrow","T","None"))
#edgeWidth <- mapVisualProperty('edge width','weight','passthrough')
#edgeWidth <- mapVisualProperty('edge width', 'penwidth', 'continuous', c(0, 15), c(0, 15))
#nodeSize

# See https://js.cytoscape.org/#style for different possible styles
# NOTE! Every time you create a new style with a same name, it will be renamed name_1, name_2 etc

createVisualStyle(style.name, defaults, list(
  mapVisualProperty('node label','label','passthrough'),
  mapVisualProperty('node tooltip', 'tooltip', 'passthrough'),
#  mapVisualProperty('node paint', 'group', 'discrete', c(
#    'default', 'unknown', 'knowledge crystal', 'option', 'task 1', 'task 2', 'task 3', 'task 4', 'task 5',
#    'risk factor', 'indicator', 'arviointikriteeri', 'task', 'data', 'health organisation'), c(
#      'brown', 'green', 'gold', 'palevioletred', 'brown', 'yellow', 'blue', 'green', 'red', 'pink',
#      'brown', 'orange', 'green', 'orange', 'yellow')),
  mapVisualProperty('node fill color', 'node.fillcolor', 'discrete', c(
    'default', 'unknown', 'substance', 'option', 'index', 'graph', 'assessment', 'stakeholder', 'method',
    'process', 'action', 'decision', 'data', 'objective', 'publication', 'true statement', 'false statement',
    'fact opening statement', 'value opening statement', 'fact closing statement', 'value closing statement',
    'fact discussion', 'value discussion', 'indicator', 'operational indicator', 'tactical indicator',
    'strategic indicator'), c(
      'white', 'yellow', 'skyblue2', 'white', 'purple1', 'pink', 'purple1', 'khaki1', 'purple1', 'purple1',
      '#009246', 'red', 'gold', 'yellow', 'gray', 'gold', 'gray', 'lightskyblue1', 'palegreen1', 'skyblue',
      'springgreen', 'skyblue', 'springgreen', 'gold', '#00d7a7', '#9fc9eb', '#0072c6')),
  mapVisualProperty('node fill color','node.fillcolor','passthrough'),
  mapVisualProperty('node border paint', 'node.color', 'passthrough'),
  mapVisualProperty('node shape', 'group', 'discrete', c(
    'default', 'substance', 'index', 'graph', 'assessment', 'stakeholder', 'method', 'process', 'action', 
    'data', 'objective', 'statement', 'strategic indicator', 'fact opening statement', 'argument'), c(
      'circle', 'circle', 'parallelogram', 'triangle', 'octagon', 'hexagon', 'hexagon', 'pentagon', 'rectangle', 
      'rectangle', 'diamond', 'round-triangle', 'diamond', 'round-rectangle', 'circle')),
#  mapVisualProperty('node size', 'node.width', 'continuous', c(0,1), c(1,10)),
  mapVisualProperty('node label font size', 'node.fontsize', 'passthrough'),

  mapVisualProperty('edge target arrow shape', 'interaction', 'discrete', c(
    "activates","inhibits","interacts", "relevant attack", "relevant defense", "irrelevant attack", "irrelevant defense"),
    c("Arrow","T","None", "T", "Arrow", "T", "Arrow")),
  mapVisualProperty('edge width', 'penwidth', 'passthrough'),
#  mapVisualProperty('edge paint', 'name', 'discrete', c(  # From Opasnet / Insight network
#    'default', 'causal link', 'participatory link', 'operational link', 'evaluative link', 
#    'relevant attack', 'relevant defense', 'relevant comment', 'irrelevant argument', 'referential link'), c(
#      'grey', 'black', 'purple', 'black', 'green', 'red', 'green', 'blue', 'gray', 'red')),
  mapVisualProperty('edge stroke unselected paint', 'interaction', 'discrete', c(
    "activates","inhibits","interacts", "relevant attack", "relevant defense", "irrelevant attack", "irrelevant defense"),
    c("black","red","black", "red", "green", "gray", "gray")),
  mapVisualProperty('edge label color', 'colour', 'discrete', c(
    'default', 'positive causal link', 'increases', 'negative causal link', 'decreases', 'part_of'), c(
      'grey', '#009246', '#009246', '#bd2719', '#bd2719', 'gray')),
  mapVisualProperty('edge width', 'penwidth', 'passthrough'),
  mapVisualProperty('edge line type', 'type', 'discrete', c(
    'default', 'causal link', 'participatory link', 'operational link', 'argumentative link', 'referential link',
    'argument', 'fact opening statement'), c(
      'Dots', 'Solid', 'Dash', 'Dash', 'Dots', 'Dash', 'Dots', 'Solid'))  # FIXME not affecting outcome
))
setVisualStyle(style.name)
