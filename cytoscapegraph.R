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

# cytoscapePing ()
# cytoscapeVersionInfo ()
# setVisualStyle('Marquee')

style.name = "insight"
defaults <- list(
  NODE_SHAPE="circle",
  NODE_BORDER_WIDTH=5,
  NODE_BORDER_PAINT="brown",
  NODE_FILL_COLOR="white",
  EDGE_STROKE_UNSELECTED_PAINT="grey",
  EDGE_LABEL_COLOR="grey",
  EDGE_TARGET_ARROW_SHAPE="triangle",
  EDGE_LINE_TYPE="dots",
  EDGE_LINE_WIDTH=5
)

# See https://js.cytoscape.org/#style for different possible styles
# NOTE! Every time you create a new style with a same name, it will be renamed name_1, name_2 etc

node_color <- t(matrix(c(
  'default', 'brown',
  'unknown', 'green',
  'knowledge crystal', 'gold',
  'option', 'palevioletred',
  'task 1', 'brown',
  'task 2', 'yellow',
  'task 3', 'blue',
  'task 4', 'green',
  'task 5', 'red',
  'risk factor', 'pink',
  'indicator', 'brown',
  'arviointikriteeri', 'orange',
  'task', 'green',
  'data', 'orange',
  'health organisation', 'yellow'
), nrow=2))

node_fillcolor <- t(matrix(c(
  'default', 'white',
  'unknown', 'yellow',
  'substance', 'skyblue2',
  'option', 'white',
  'index', 'purple1',
  'graph', 'pink',
  'assessment', 'purple1',
  'stakeholder', 'khaki1',
  'method', 'purple1',
  'process', 'purple1',
  'action', '#009246',
  'decision', 'red',
  'data', 'gold',
  'objective', 'yellow',
  'publication', 'grey',
  'true statement', 'gold',
  'false statement', 'grey',
  'fact opening statement', 'lightskyblue1',
  'value opening statement', 'palegreen1',
  'fact closing statement', 'skyblue',
  'value closing statement', 'springgreen',
  'fact discussion', 'skyblue',
  'value discussion', 'springgreen',
  'indicator', 'gold',
  'operational indicator', '#00d7a7',
  'tactical indicator', '#9fc9eb',
  'strategic indicator', '#0072c6'), nrow=2))

node_shape <- t(matrix(c(
  'default', 'circle',
  'substance', 'circle',
  'index', 'parallelogram',
  'graph', 'triangle',
  'assessment', 'octagon',
  'stakeholder', 'hexagon',
  'method', 'hexagon',
  'process', 'pentagon',
  'action', 'rectangle',
  'data', 'rectangle',
  'objective', 'diamond',
  'statement', 'round-triangle',
  'strategic indicator', 'diamond',
  'fact opening statement', 'round-rectangle',
  'argument', 'circle'
), nrow=2))

edge_shape <- t(matrix(c(
  'activates', 'Arrow',
  'inhibits', 'T',
  'interacts', 'None',
  'relevant attack', 'T',
  'relevant defense', 'Arrow',
  'irrelevant attack', 'T',
  'irrelevant defense', 'Arrow',
  'lisää', 'Arrow',
  'vähentää', 'Arrow',
  'puolustaa', 'Arrow',
  'vastustaa', 'T',
  'on osana', 'square'
), nrow=2))

edge_color <- t(matrix(c(
  'activates', 'black',
  'inhibits', 'red',
  'interacts', 'black',
  'relevant attack', 'red',
  'relevant defense', 'green',
  'irrelevant attack', 'grey',
  'irrelevant defense', 'grey',
  'lisää', 'green',
  'vähentää', 'red',
  'puolustaa', 'green',
  'vastustaa', 'red',
  'on osana', 'black'
), nrow=2))

edge_labelcolor <- t(matrix(c(
  'default', 'grey',
  'positive causal link', '#009246',
  'increases', '#009246',
  'negative causal link', '#bd2719',
  'decreases', '#bd2719',
  'part_of', 'grey'
), nrow=2))

edge_type <- t(matrix(c(  # FIXME not affecting outcome
  'default', 'Dots',
  'causal link', 'Solid',
  'participatory link', 'Dash',
  'operational link', 'Dash',
  'argumentative link', 'Dots',
  'referential link', 'Dash',
  'argument', 'Dots',
  'fact opening statement', 'Solid'
), nrow=2))

createVisualStyle(style.name, defaults, list(
  mapVisualProperty('node label','label','passthrough'),
  mapVisualProperty('node tooltip', 'tooltip', 'passthrough'),
##  mapVisualProperty('node paint', 'group', 'discrete', node_color[,1], node_color[,2]  # From Opasnet / Insight network
#  mapVisualProperty('node fill color', 'node.fillcolor', 'discrete', node_fillcolor[,1], node_fillcolor[,2]),
#    'default', 'unknown', 'substance', 'option', 'index', 'graph', 'assessment', 'stakeholder', 'method',
#    'process', 'action', 'decision', 'data', 'objective', 'publication', 'true statement', 'false statement',
#    'fact opening statement', 'value opening statement', 'fact closing statement', 'value closing statement',
#    'fact discussion', 'value discussion', 'indicator', 'operational indicator', 'tactical indicator',
#    'strategic indicator'), c(
#      'white', 'yellow', 'skyblue2', 'white', 'purple1', 'pink', 'purple1', 'khaki1', 'purple1', 'purple1',
#      '#009246', 'red', 'gold', 'yellow', 'gray', 'gold', 'gray', 'lightskyblue1', 'palegreen1', 'skyblue',
#      'springgreen', 'skyblue', 'springgreen', 'gold', '#00d7a7', '#9fc9eb', '#0072c6')),
  mapVisualProperty('node fill color','node.fillcolor','passthrough'),
  mapVisualProperty('node border paint', 'node.color', 'passthrough'),
  mapVisualProperty('node shape', 'group', 'discrete', node_shape[,1], node_shape[,2]),
#    'default', 'substance', 'index', 'graph', 'assessment', 'stakeholder', 'method', 'process', 'action', 
#    'data', 'objective', 'statement', 'strategic indicator', 'fact opening statement', 'argument'), c(
#      'circle', 'circle', 'parallelogram', 'triangle', 'octagon', 'hexagon', 'hexagon', 'pentagon', 'rectangle', 
#      'rectangle', 'diamond', 'round-triangle', 'diamond', 'round-rectangle', 'circle')),
#  mapVisualProperty('node size', 'node.width', 'continuous', c(0,1), c(1,10)),
  mapVisualProperty('node label font size', 'node.fontsize', 'passthrough'),

  mapVisualProperty('edge label', 'interaction', 'passthrough'),
  mapVisualProperty('edge target arrow shape', 'interaction', 'discrete', edge_shape[,1], edge_shape[,2]),
#    "activates","inhibits","interacts", "relevant attack", "relevant defense", "irrelevant attack", "irrelevant defense",
#    'lisää', 'vähentää', 'puolustaa', 'vastustaa', 'on osana'),
#    c("Arrow","T","None", "T", "Arrow", "T", "Arrow",
#      'Arrow', 'Arrow', 'Arrow', 'T', 'square')),
  mapVisualProperty('edge width', 'penwidth', 'passthrough'),
#  mapVisualProperty('edge paint', 'name', 'discrete', c(  # From Opasnet / Insight network
#    'default', 'causal link', 'participatory link', 'operational link', 'evaluative link', 
#    'relevant attack', 'relevant defense', 'relevant comment', 'irrelevant argument', 'referential link'), c(
#      'grey', 'black', 'purple', 'black', 'green', 'red', 'green', 'blue', 'gray', 'red')),
  mapVisualProperty('edge stroke unselected paint', 'interaction', 'discrete', edge_color[,1], edge_color[,2]),
#    "activates","inhibits","interacts", "relevant attack", "relevant defense", "irrelevant attack", "irrelevant defense",
#    'lisää', 'vähentää', 'puolustaa', 'vastustaa', 'on osana'),
#    c("black","red","black", "red", "green", "gray", "gray",
#      'green', 'red', 'green', 'red', 'black')),
  mapVisualProperty('edge label color', 'colour', 'discrete', edge_labelcolor[,1], edge_labelcolor[,2]),
#    'default', 'positive causal link', 'increases', 'negative causal link', 'decreases', 'part_of'), c(
#      'grey', '#009246', '#009246', '#bd2719', '#bd2719', 'gray')),
  mapVisualProperty('edge width', 'penwidth', 'passthrough'),
  mapVisualProperty('edge line type', 'type', 'discrete', edge_type[,1], edge_type[,2])
#    'default', 'causal link', 'participatory link', 'operational link', 'argumentative link', 'referential link',
#    'argument', 'fact opening statement'), c(
#      'Dots', 'Solid', 'Dash', 'Dash', 'Dots', 'Dash', 'Dots', 'Solid'))  # FIXME not affecting outcome
))
setVisualStyle(style.name)
