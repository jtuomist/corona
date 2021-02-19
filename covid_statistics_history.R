# Paketti JSON-stat tiedon lukemista varten
library(rjstat)

# Osoitteen perusosa
url_base <- "https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.json"

# Haetaan näkymä kuutiosta (palautuu listana, jossa alkiona taulukko data.framena)
infections_previous <- fromJSONstat(
  paste0(url_base, "?row=hcdmunicipality2020-445268L&column=dateweek20200101-509030"),
  naming = "label", use_factors = F, silent = T)

# Ugly way because the json is not in standard format and crashes.
tst <- readLines("https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.dimensions.json")
tst <- tst[grep("dateweek20200101/1/week", tst)-5] # Find sids for weeks.
tst <- gsub(',', '', gsub('\\t\\"sid\\":', '', tst))
out <- data.frame()

###### CASES

# Each health care district, total age, total sex, daily and weekly
for(i in tst) {
  tmp <- fromJSONstat(
    paste0(url_base, "?row=hcdmunicipality2020-445222&row=ttr10yage-444309.&row=dateweek20200101-", i, "&column=sex-444328.&filter=measure-444833"),
    naming = "label", use_factors = F, silent = T)[[1]]
  out <- rbind(out, tmp)
}

# Each municipality, total age, total sex, weekly
for(i in tst) {
  tmp <- fromJSONstat(
    paste0(url_base, "?row=hcdmunicipality2020-445268L&row=ttr10yage-444309.&row=dateweek20200101-", i, ".&column=sex-444328.&filter=measure-444833"),
    naming = "label", use_factors = F, silent = T)[[1]]
  out <- rbind(out, tmp)
}
out$measure <- "cases"

######## DEATHS
# Total municipality, total age, total sex, daily
for(i in tst) {
  tmp <- fromJSONstat(
    paste0(url_base, "?row=hcdmunicipality2020-445222.&row=ttr10yage-444309.&row=dateweek20200101-", i, "&column=sex-444328.&filter=measure-492118"),
    naming = "label", use_factors = F, silent = T)[[1]]
  out <- rbind(out, cbind(tmp, measure = "deaths"))
}

######## TESTS
# Total municipality, total age, total sex, daily
for(i in tst) {
  tmp <- fromJSONstat(
    paste0(url_base, "?row=hcdmunicipality2020-445222.&row=ttr10yage-444309.&row=dateweek20200101-", i, "&column=sex-444328.&filter=measure-445356"),
    naming = "label", use_factors = F, silent = T)[[1]]
  out <- rbind(out, cbind(tmp, measure = "tests"))
}

############ POPULATION
# Each health care district, total age, total sex, weekly
for(i in tst) {
  tmp <- fromJSONstat(
    paste0(url_base, "?row=hcdmunicipality2020-445222&row=ttr10yage-444309.&row=dateweek20200101-", i, ".&column=sex-444328.&filter=measure-445344"),
    naming = "label", use_factors = F, silent = T)[[1]]
  out <- rbind(out, cbind(tmp, measure = "population"))
}

# Each municipality, total age, total sex, weekly
for(i in tst) {
  tmp <- fromJSONstat(
    paste0(url_base, "?row=hcdmunicipality2020-445268L&row=ttr10yage-444309.&row=dateweek20200101-", i, ".&column=sex-444328.&filter=measure-445344"),
    naming = "label", use_factors = F, silent = T)[[1]]
  out <- rbind(out, cbind(tmp, measure = "population"))
}

############################## VACCINATION

tst <- readLines("https://sampo.thl.fi/pivot/prod/api/vaccreg/cov19cov/fact_cov19cov.dimensions.json")
weeks <- gsub(',', '', gsub('\\t\\"sid\\":', '', tst[grep("Vuosi", tst)-1]))

url_base2 <- "https://sampo.thl.fi/pivot/prod/api/vaccreg/cov19cov/fact_cov19cov.json"

# measure: Korona-annokset 141082
# Ensimmäinen annos 518240
# Toinen annos 518281
# cov_vac_age: All ages 518413
# There is no municipality-specific data available even at all ages - weekly level

out2 <- data.frame()

for(i in weeks) {
  tmp <- fromJSONstat(
    paste0(url_base2, "?row=area-518362&row=cov_vac_age-518413&column=dateweek20201226-531437&filter=measure-518240"),
    naming = "label", use_factors = FALSE, silent = TRUE)[[1]]
  tmp$measure <- "first shot"         
  out2 <- rbind(out2, tmp)
  
  tmp <- fromJSONstat(
    paste0(url_base2, "?row=area-518362&row=cov_vac_age-518413&column=dateweek20201226-",i,"&filter=measure-518281"),
    naming = "label", use_factors = FALSE, silent = TRUE)[[1]]
  tmp$measure <- "second shot"         
  out2 <- rbind(out2, tmp)
  
}
out2 <- out2[!is.na(out2$value),]

storecsv <- function(obj, file) {
  
  if(file.exists(file)) {
    inp <- read.csv(file) 
  } else {
    inp <- data.frame()
  }
  
  write.csv(rbind(inp, obj), file, row.names = FALSE)
}

storecsv(out, "data/covid_statistics_history.csv")
storecsv(out2, "data/covid_vaccination_history.csv")
