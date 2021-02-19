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

out$dateweek20200101 <- as.character(Sys.Date())

file <- "/var/www/html/rtools_server/runs/covid_statistics_daily_fi.csv"

if(file.exists(file)) {
  inp <- read.csv(file) 
} else {
  inp <- data.frame()
}
  
write.csv(rbind(inp, out), file, row.names = FALSE)
