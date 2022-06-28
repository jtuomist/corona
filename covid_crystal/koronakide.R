# This code is Op_fi5925/koronakide on page [[Koronavirus]]

library(OpasnetUtils)
library(tidyverse)

# First version of data https://docs.google.com/spreadsheets/d/1Wzj_VqubkV6uomQS-St5UxzS5k25dDBs15DQFEsroOg/edit#gid=0

objects.latest("Op_en3861", code_name="makeGraph2") # [[Insight network]] makeGraph
objects.latest("Op_en2382", code_name="update") # [[Discussion]] update_truth, update_relevance, infer_tree

preprocess_arguments <- function(
  file_path, # Name of zip file at Opasnet
  wiki = "opasnet_fi", # Wiki identifier
  file_name, # Name of file in the zip file
  relevants = NA, # vector of Items for relevance arguments
  addition = NA, # vector of arguments to be added to original list.
  truth_prior = 0.3, # prior truth value without other information
  truth_prior_with_reference = 0.7, # prior truth value with credible reference
  sensitivity_prime = 0.3, # sensitivity defend value without other information
  sensitivity_prime_attack = -0.5 # sensitivity attack value without other information
) {
  dfl <- opasnet.data(file_path, wiki, unzip=file_name)
  #  dfl <- read_lines("~/discussion/climate/what-is-the-best-measure-to-decrease-climate-change-31294.txt")
  dfl <- strsplit(dfl, "\n")[[1]]
  df_title <- gsub("Discussion Title: ", "", dfl[1])
  dfl <- dfl[-(1:2)]
  if(!any(is.na(addition))) dfl <- c(dfl, addition)
  df <- data.frame(level = regexpr("\\. ",dfl))
  df$Item = substr(dfl,1,df$level-1)
  df$class = substr(dfl,df$level+6,regexpr(":", dfl)-1)
  df$colour <- substr(dfl,df$level+2, df$level+4)
  df$colour <- ifelse(df$colour %in% c("Pro","Con"), df$colour, "Thesis")
  df$text = substr(dfl, ifelse(df$colour=="Thesis",regexpr("\\. ",dfl), regexpr(":",dfl))+2,999)
  df$level <- nchar(gsub("[0-9]","", df$Item))
  added_argument <- unlist(lapply(strsplit(df$Item,split="\\."), FUN=function(x) max(as.numeric(x))))
  df$level <- df$level * ifelse(added_argument < 99, 1, ifelse(added_argument>999, 10, 0.1))
  df$Object <- gsub("\\.[0-9]*$","", df$Item)
  df$relevance <- ifelse(df$colour=="Pro",sensitivity_prime, sensitivity_prime_attack)
  df$truth <- ifelse(grepl("http", df$text), truth_prior_with_reference, truth_prior)
  df$class <- ifelse(df$class=="", "truth", df$class)
  df$class <- ifelse(df$colour=="Thesis", "fact", df$class)
  if(!any(is.na(relevants))) df$class[df$Item %in% relevants] <- "relevance"
  df$alias <- ifelse(grepl("^-> See", df$text), gsub("\\.$", "", substr(df$text,8,999)), "")
  df$alias[grepl("discussion",df$alias)] <- ""
  
  return(list(df_title, df))
}

prepare_graph <- function(
  df = df,
  drop_gray = TRUE, # Drop gray branches?
  drop_higher_levels = 0, # Drop higher levels (0: drop nothing)?
  RELEVANCE_LIMIT = 0.2, # value below which argument is considered irrelevant and dropped from graph
  TRUTH_LIMIT = 0.05, # value below which argument is considered untrue and dropped from graph
  verbose=FALSE
) {
  thesis <- df$colour=="Thesis"
  df$edge.penwidth <- abs(df$relevance*15)
  df$node.width <- ifelse(thesis,1,df$truth)
  df$node.fontsize <- ifelse(thesis,15,df$truth*20)
  df$node.color <- ifelse(df$class=="truth","orange","blue")
  df$Context <- "Koronakide"
  df$label <- substr(df$text, 1,30)
  df$label <- paste(df$label, ifelse(thesis, signif(df$truth,2),""))
  df$rel <- ifelse(toupper(df$colour)=="PRO","relevant defense","relevant attack")
  df$rel <- paste0(ifelse(abs(df$relevance) < RELEVANCE_LIMIT, "ir", ""), df$rel)
  df$type <- "argument"
  df$type <- ifelse(df$class %in% c("value","fact"), paste(df$class,"opening statement"), df$type)
  df$Description <- df$text
  drop <- df$Item[(df$truth<TRUTH_LIMIT | abs(df$relevance)<RELEVANCE_LIMIT) & df$level>0]
  if(verbose) print(drop)
  out <- character()
  tmp <- drop
  for(i in sort(na.omit(drop))) {
    branch <- tmp[grep(paste0("^",i), tmp)]
    if(length(branch)>0) {
      if(verbose) print(branch)
      out <- c(out, branch[1])
      tmp <- tmp[!tmp %in% branch[-1]]
    }
  }
  drop <- out
  if(verbose) print(drop)
  df$node.fillcolor <- "white"
  for(i in drop) {
    df$node.fillcolor = ifelse(grepl(paste0("^",i), df$Item), "gray", df$node.fillcolor)
  }
  if(drop_gray) df <- df[df$node.fillcolor!="gray" | df$Item %in% drop ,]
  if(drop_higher_levels>0) df <- df[df$level<=drop_higher_levels | df$level>10,]
  return(df)
}

if (!exists("formatted")) {
  objects.latest("Op_en3861", code_name = "formatted")
}
if (!exists("chooseGr")) {
  objects.latest("Op_en3861", code_name = "chooseGr")
}

file_list_covid <- c(
  "are-tracking-apps-a-legitimate-and-proportional-means-to-fight-covid-19-36145.txt"                ,
  "do-people-have-a-right-to-not-wear-a-mask-in-public-spaces-during-the-covid-19-pandemic-38770.txt",
  "do-we-need-a-vaccine-to-fight-the-covid-19-pandemic-38268.txt"                                    ,
  "do-we-need-a-vaccine-to-fight-the-covid-19-pandemic-38268(1).txt"                                 ,
  "education-will-never-be-the-same-as-it-was-before-covid-19-43590.txt"                             ,
  "is-covid-19-more-dangerous-than-regular-flu-viruses-34602.txt"                                    ,
  "is-herd-immunity-for-covid-19-achievable-39248.txt"                                               ,
  "is-it-wrong-to-have-a-lockdown-for-covid-19-36981.txt"                                            ,
  "should-a-global-curfew-be-introduced-to-stop-covid-19-34523.txt"                                  ,
  "should-countries-have-closed-their-borders-to-china-to-reduce-the-spread-of-covid-19-33660.txt"   ,
  "should-covid-19-vaccines-be-mandatory-39517.txt"                                                  ,
  "should-schools-close-during-the-covid-19-pandemic-44845.txt"                                      ,
  "should-vaccine-passports-be-mandatory-49452.txt"                                                  ,
  "will-covid19-bring-lasting-environmental-changes-34939.txt"                                       ,
  "will-the-covid-19-pandemic-have-a-lasting-impact-on-society-34267.txt"        
)

file_list_climate <- c(
  "a-carbon-tax-should-be-implemented-to-subsidize-the-reduction-of-consumers-carbon-footprint-25338.txt"                        ,
  "all-humans-should-be-vegan-2762.txt"                                                                                          ,
  "are-battery-electric-vehicles-better-than-hydrogen-fuel-cell-vehicles-2710.txt"                                               ,
  "are-the-milankovitch-cycles-major-causes-of-climate-change-14194.txt"                                                         ,
  "are-the-rich-or-the-poor-more-responsible-for-environmental-damages-10248.txt"                                                ,
  "climate_discussions.zip"                                                                                                      ,
  "deep-sea-oil-and-gas-exploration-in-the-great-australian-bight-should-be-banned-15489.txt"                                    ,
  "do-we-need-nuclear-power-for-sustainable-energy-production-6182.txt"                                                          ,
  "do-wind-farms-have-more-advantages-than-disadvantages-9620.txt"                                                               ,
  "is-carpooling-the-way-of-the-future-18711.txt"                                                                                ,
  "is-climate-crisis-inevitable-31239.txt"                                                                                       ,
  "is-having-children-a-bad-idea-in-todays-times-13236.txt"                                                                      ,
  "is-it-appropriate-for-the-epa-to-declare-biomass-to-be-carbon-neutral-14080.txt"                                              ,
  "is-it-reasonable-to-create-a-directly-democratic-and-all-inclusive-internet-based-forum-to-address-global-issues-43718.txt"   ,
  "is-low-energy-nuclear-reaction-lenr-technology-the-solution-to-fossil-fuel-burning-30393.txt"                                 ,
  "is-organic-farming-better-than-conventional-farming-9613.txt"                                                                 ,
  "is-the-united-nations-the-best-forum-to-tackle-climate-change-27811.txt"                                                      ,
  "no-one-should-feel-obliged-to-change-their-lifestyle-to-combat-global-warming-30084.txt"                                      ,
  "periodic-lockdowns-should-be-planned-as-emergency-measures-to-fight-climate-change-36808.txt"                                 ,
  "recycling-works-30534.txt"                                                                                                    ,
  "should-fracking-be-banned-7587.txt"                                                                                           ,
  "should-governments-push-to-implement-100%-renewable-energy-3871.txt"                                                          ,
  "should-governments-subsidize-ethanol-10385.txt"                                                                               ,
  "should-humans-act-to-fight-climate-change-4540.txt"                                                                           ,
  "should-nuclear-energy-replace-fossil-fuels-9326.txt"                                                                          ,
  "should-people-go-vegan-if-they-can-31640.txt"                                                                                 ,
  "should-private-cars-be-forbidden-in-large-cities-9351.txt"                                                                    ,
  "should-public-transport-be-free-33112.txt"                                                                                    ,
  "should-renewable-energy-sources-replace-fossil-fuels-15900.txt"                                                               ,
  "should-the-ecological-crisis-we-are-facing-become-our-collective-and-singular-focus-3185.txt"                                 ,
  "should-the-eu-introduce-a-carbon-tax-29370.txt"                                                                               ,
  "should-the-us-government-commit-to-a-green-new-deal-30325.txt"                                                                ,
  "should-the-us-have-pulled-out-of-the-paris-climate-agreement-15487.txt"                                                       ,
  "should-there-be-one-singular-global-governmententity-31213.txt"                                                               ,
  "the-earth-will-not-be-irreparable-in-12-years-from-climate-change-32101.txt"                                                  ,
  "the-fight-of-western-countries-against-climate-change-is-hypocritical-31852.txt"                                              ,
  "the-us-should-adopt-a-carbon-fee-and-dividend-plan-to-address-the-primary-cause-of-climate-change-30792.txt"   ,
  "the-world-needs-an-international-environmental-government-that-has-political-power-to-mitigate-environmental-damage-45042.txt",
  "there-should-be-further-research-on-solar-geoengineering-16729.txt"                                                           ,
  "universities-should-divest-from-fossil-fuels-28142.txt"                                                                      , 
  "vertical-farming-is-the-future-of-agriculture-7487.txt"                                                                       ,
  "we-should-adapt-to-climate-change-rather-than-advert-it-31679.txt"                                                            ,
  "what-is-the-best-measure-to-decrease-climate-change-31294.txt"                                                                ,
  "what-is-the-worst-world-problem-of-the-utmost-concern-9143.txt"                                                               ,
  "will-man-made-climate-change-cause-human-extinction-31221.txt" 
)

relevants <- opasnet.data("4/44/Covid-19_discussions.zip", wiki="op_fi", unzip="should-covid-19-vaccines-be-mandatory-39517_relevants.txt")
relevants <- strsplit(relevants, split="\n")[[1]]
addition <- opasnet.data("4/44/Covid-19_discussions.zip", wiki="op_fi", unzip="should-covid-19-vaccines-be-mandatory-39517_addition.txt")
addition <- strsplit(addition, split="\n")[[1]]

l <- preprocess_arguments(
  #  file_path =  "7/74/Climate_discussions.zip",
  #  file_name = file_list_climate[43],
  #  relevants = NA,#relevants, # NA for all others except discussion #11 Should COVID-19 vaccines be mandatory?
  #  addition = NA,#addition,
  file_path =  "4/44/Covid-19_discussions.zip",
  file_name = "should-covid-19-vaccines-be-mandatory-39517.txt",
  relevants = relevants,
  addition = addition,
  truth_prior = 0.3,
  truth_prior_with_reference = 0.7,
  sensitivity_prime = 0.3,
  sensitivity_prime_attack = -0.5
)

df <- prepare_graph(
  df=infer_tree(l[[2]], verbose=FALSE),
  drop_gray = TRUE,
  drop_higher_levels = 2,
  TRUTH_LIMIT = 0.1,
  RELEVANCE_LIMIT = 0.2,
  verbose=FALSE
)
gr <- makeGraph(
  ova=df,
  formatted=formatted)
render_graph(gr, title=df[[1]])

#export_graph(gr, "~/home/jouni/Documents/Koronakide.svg")

#out <- prepare_graph(
#  df=infer_tree(df[[2]]),
#  drop_gray = TRUE, drop_higher_levels = 3, TRUTH_LIMIT = 0.1, RELEVANCE_LIMIT = 0.2, verbose=FALSE)

#df_default <- infer_tree(df)
#df_no_relevance <- infer_tree(df %>% mutate(class="truth"), sensitivity_prime, truth_prior)
#plot(df_default$truth, df_no_relevance$truth)
# The correlation between inference with truth/relevance classification and that without is not great.
# However, it is reasonable for very high and very low values.
# So, let's try to analyze a large amount of discussions with truth-only setting

##################

dt <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1eMMwHV1sD9DvCsnYAoESt8EV5US21mGXRZF7HR-myvA/edit#gid=0")
gr <- makeGraph(dt)
render_graph(gr)

