# Paketti JSON-stat tiedon lukemista varten
library(rjstat)

# Osoitteen perusosa
url_base <- "https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.json"

###### CASES
# Each municipality, total age, total sex
tmp <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445268L&row=ttr10yage-444309.&column=sex-444328.&filter=measure-444833"),
  naming = "label", use_factors = F, silent = T)[[1]]

# Total municipality, each age, total sex
tmp2 <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445222.&row=ttr10yage-444309&column=sex-444328.&filter=measure-444833"),
  naming = "label", use_factors = F, silent = T)[[1]]

# Total municipality, each age, total sex
tmp3 <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445222.&row=ttr10yage-444309.&column=sex-444328&filter=measure-444833"),
  naming = "label", use_factors = F, silent = T)[[1]]

out <- rbind(tmp, tmp2, tmp3)
out$measure <- "cases"

######## DEATHS
# Total municipality, each age, total sex
tmp <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445222.&row=ttr10yage-444309&column=sex-444328.&filter=measure-492118"),
  naming = "label", use_factors = F, silent = T)[[1]]

# Total municipality, total age, each sex
tmp2 <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445222.&row=ttr10yage-444309.&column=sex-444328&filter=measure-492118"),
  naming = "label", use_factors = F, silent = T)[[1]]

tmp <- rbind(tmp, tmp2)
tmp$measure <- "deaths"
out <- rbind(out, tmp)

######## TESTS
# Each health care district, total age, total sex
tmp <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445222&row=ttr10yage-444309.&column=sex-444328.&filter=measure-445356"),
  naming = "label", use_factors = F, silent = T)[[1]]
tmp$measure <- "tests"
out <- rbind(out, tmp)

############ POPULATION
# Each municipality, total age, total sex
tmp <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445268L&row=ttr10yage-444309.&column=sex-444328.&filter=measure-445344"),
  naming = "label", use_factors = F, silent = T)[[1]]
tmp$measure <- "population"
out <- rbind(out, tmp)

#colnames(out)
#[1] "hcdmunicipality2020" "ttr10yage"           "sex"                 "value"               "measure"            
#colnames(out) <- c("place","age","sex","value","measure")

#################### VACCINATION

tst <- readLines("https://sampo.thl.fi/pivot/prod/api/vaccreg/cov19cov/fact_cov19cov.dimensions.json")

# aiemmin url_base2 <- "https://sampo.thl.fi/pivot/prod/api/vaccreg/cov19cov/fact_cov19cov.json"
url_base2 <- "https://sampo.thl.fi/pivot/prod/fi/vaccreg/cov19cov/fact_cov19cov.json"

# measure: Korona-annokset 533046 # aiemmin 141082
# Ensimmäinen annos 533042 # aiemmin 518240
# Toinen annos 533034 # aiemmin 518281
# cov_vac_age: All ages 518413
# There is no municipality-specific data available even at all ages - weekly level

hcd <- gsub(',', '', gsub('\\t\\"sid\\":', '', tst[c(grep("Ahvenanmaa", tst), grep("SHP",tst))-1]))
out2 <- data.frame()
for(i in hcd) {# Go through health care districts
  tmp <- fromJSONstat(
    paste0(url_base2, "?row=cov_vac_dose-533170.533164.&row=area-", i, "&column=cov_vac_age-518413&filter=measure-533047"), # &row=cov_vac_age-518413&column=dateweek20201226-525425.&filter=measure-533046"),
    naming = "label", use_factors = FALSE, silent = TRUE)[[1]]
  out2 <- rbind(out2, tmp)
  
#  tmp <- fromJSONstat(
#    paste0(url_base2, "?row=area-", i, "&row=cov_vac_age-518413&column=dateweek20201226-525425.&filter=measure-533034"),
#    naming = "label", use_factors = FALSE, silent = TRUE)[[1]]
#  tmp$measure <- "second shot"         
#  out2 <- rbind(out2, tmp)
}

#> colnames(out2)
#[1] "area"             "cov_vac_age"      "dateweek20201226" "value"            "measure"         
colnames(out2) <- c("annos","place","age","value")
out2$measure <- ifelse(out2$annos == "Ensimmäinen annos","first shot", "second shot")
out2$annos <- NULL

out$dateweek20200101 <- as.character(Sys.Date())
out2$time <- as.character(Sys.Date())
out2 <- out2[c("place","age","time","value","measure")]

storecsv <- function(obj, file) {
  
  if(file.exists(file)) {
    inp <- read.csv(file) 
  } else {
    inp <- data.frame()
  }
  write.csv(rbind(inp, obj), file, row.names = FALSE)
}

storecsv(out, "/var/www/html/rtools_server/runs/covid_statistics_daily_fi.csv")
storecsv(out2, "/var/www/html/rtools_server/runs/covid_vaccination_daily_fi.csv")
