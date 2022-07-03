# https://bioconductor.org/packages/release/bioc/vignettes/RCy3/inst/doc/Overview-of-RCy3.html

# These tools may become handy in developing graphs and counting # of traversals.
# https://github.com/danilnagy/gd_tools
# https://en.m.wikipedia.org/wiki/Dijkstra's_algorithm
# May work for selecting preferred path when distance is assumed to be lack of explanatory power.

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
  'muuttuja', 'skyblue2',
  'option', 'white',
  'index', 'purple1',
  'graph', 'pink',
  'assessment', 'purple1',
  'stakeholder', 'khaki1',
  'method', 'purple1',
  'process', 'purple1',
  'action', '#009246',
  'toimenpide', '#009246',
  'decision', 'red',
  'data', 'gold',
  'objective', 'yellow',
  'publication', 'grey',
  'true statement', 'gold',
  'false statement', 'grey',
  'fact opening statement', 'lightskyblue1',
  'faktaväite', 'lightskyblue1',
  'arvoväite', 'palegreen1',
  'value opening statement', 'palegreen1',
  'fact closing statement', 'skyblue',
  'value closing statement', 'springgreen',
  'fact discussion', 'skyblue',
  'value discussion', 'springgreen',
  'indicator', 'gold',
  'operational indicator', '#00d7a7',
  'tactical indicator', '#9fc9eb',
  'strategic indicator', '#0072c6',
  'strateginen mittari', '#0072c6'), nrow=2))

node_shape <- t(matrix(c(
  'default', 'circle',
  'substance', 'circle',
  'muuttuja', 'circle',
  'index', 'parallelogram',
  'graph', 'triangle',
  'assessment', 'octagon',
  'stakeholder', 'hexagon',
  'method', 'hexagon',
  'process', 'pentagon',
  'action', 'rectangle',
  'toimenpide', 'rectangle',
  'data', 'rectangle',
  'objective', 'diamond',
  'statement', 'round triangle',
  'arvoväite', 'triangle',
  'faktaväite', 'round triangle',
  'strategic indicator', 'diamond',
  'strateginen mittari', 'diamond',
  'fact opening statement', 'round-rectangle',
  'argument', 'circle',
  'argumentti', 'circle'
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
  'vaikuttaa', 'Arrow',
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
#  mapVisualProperty('node color', 'group', 'discrete', node_color[,1], node_color[,2]),  # From Opasnet / Insight network
#  mapVisualProperty('node fill color','node.fillcolor','passthrough'),
  mapVisualProperty('node fill color', 'group', 'd', node_fillcolor[,1], node_fillcolor[,2]),
  mapVisualProperty('node shape', 'group', 'discrete', node_shape[,1], node_shape[,2]),
  mapVisualProperty('node label font size', 'node.fontsize', 'passthrough'),

  mapVisualProperty('edge label', 'interaction', 'passthrough'),
  mapVisualProperty('edge target arrow shape', 'interaction', 'discrete', edge_shape[,1], edge_shape[,2]),
  mapVisualProperty('edge width', 'penwidth', 'passthrough'),
  mapVisualProperty('edge stroke unselected paint', 'interaction', 'discrete', edge_color[,1], edge_color[,2]),
  mapVisualProperty('edge label color', 'colour', 'discrete', edge_labelcolor[,1], edge_labelcolor[,2]),
  mapVisualProperty('edge width', 'penwidth', 'passthrough'),
  mapVisualProperty('edge line type', 'type', 'discrete', edge_type[,1], edge_type[,2])
))
setVisualStyle(style.name)
