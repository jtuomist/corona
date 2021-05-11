# This code takes the collected covid data and calculates e.g. daily values of cases.
# The code also stores the results as csv files for visualisations.

library(tidyverse)

cities <- c("Helsinki","Espoo","Vantaa","Turku","Kuopio","Vaasa", "Oulu","Tampere","Jyväskylä","Pori",
            "Rovaniemi","Järvenpää", "Pieksämäki", "Varkaus")

if(FALSE) {
  URL <- "http://77.86.191.32/rtools_server/runs/" # from where to take the previous data
  folder <- "data/" # to where to put the calculated results
} else {
  URL <- "/var/www/html/rtools_server/runs/"
  folder <- URL
}

# https://thl.fi/fi/tilastot-ja-data/aineistot-ja-palvelut/avoin-data/varmistetut-koronatapaukset-suomessa-covid-19-

dat <- read.csv(paste0(folder,"covid_statistics_history.csv"), stringsAsFactors = FALSE) # Historical, mostly weekly data until 2021-02-15
dat$period <- ifelse(grepl("Vuosi",dat$date), "weekly","daily")
dat <- dat[!is.na(dat$value),]

dat2 <- read.csv(paste0(URL,"covid_statistics_daily_fi.csv"), stringsAsFactors = FALSE) #daily updates
dat2$period <- "cumulative"

dat <- rbind(dat, dat2)
colnames(dat)[1:3] <- c("place","age","date")
for(i in c("place","age","date","sex","measure")) {
  dat[[i]] <- as.factor(dat[[i]])
}

start <- as.POSIXct("2019-12-29 12:00 EET")
shp <- as.character(unique(dat$place[grep("(SHP|Ahvenanmaa)",dat$place)]))

dat$time <- (start + (as.numeric(substr(dat$date,10,10)) * 53 + as.numeric(substr(dat$date,19,20))) * 7*24*3600)
dat$time[dat$period!="weekly"] <- as.POSIXct(paste0(dat$date[dat$period!="weekly"], " 12:00 EET"))

dat$value[dat$value==".."] <- "-1"
dat$value <- as.integer(dat$value)

# Find the highest weekly case value for each place. Note: for only ca. 10 places the peak occurs before August 2020.

tmp <- dat[dat$period=="weekly" & dat$measure=="cases",] %>%
  mutate(value=as.integer(value)) %>%
  group_by(place) %>%
  filter(value == max(value,na.rm=TRUE))
tmp <- tmp[!duplicated(tmp$place),c("place","time")]
colnames(tmp)[2] <- "peak"  
dat <- merge(dat, tmp, all.x=TRUE)
dat$peak <- dat$time - dat$peak

muni <- dat[dat$measure=="cases" & dat$period!="daily" & dat$age=="Kaikki ikäryhmät" & dat$sex=="Kaikki sukupuolet",
            !colnames(dat) %in% c("age","sex","measure")]
muni$daily <- muni$value / 7

tmp2 <- muni[muni$period=="cumulative",] # tmp[tmp$date=="2021-02-15",] # Start time of daily follow-up
tmp2$old <- tmp2$value
tmp2$time <- tmp2$time + 24*3600
tmp2 <- tmp2[colnames(tmp2) %in% c("place","time","old")]
muni <- merge(muni, tmp2, all.x=TRUE)
muni$daily <- ifelse(muni$period=="cumulative", muni$value - muni$old, muni$daily)
muni <- muni[!is.na(muni$daily) & muni$time < Sys.time() , ]
muni <- muni[order(muni$time),]
week <- numeric()
for(i in 1:nrow(muni)) {
  ts <- muni[muni$place==muni$place[i] , c("time","daily")]
  week <- c(week, mean(ts$daily[ts$time <= muni$time[i] & ts$time > muni$time[i]- 7*24*3600],na.rm = TRUE))
}
muni$week <- week

write.csv(muni, paste0(folder,"covid_cases_daily_fi.csv"), row.names = FALSE)
write.csv(dat, paste0(folder,"covid_all_data_fi.csv"), row.names = FALSE)

ggplot(muni[muni$place %in% cities,], aes(x=as.Date(time), y=week, colour=place))+
  geom_line()+
  coord_cartesian(xlim=c((Sys.Date()-50),Sys.Date()))+
  scale_x_date(breaks="1 month", minor_breaks = "1 week")+
  labs(
    title="Weekly average cases of covid-19 by place",
    x = "Date",
    y = "Cases per day"
  )

ggsave(paste0(folder,"covid_cases_cities.pdf"), width=10, height=12)

ggplot(muni[muni$place %in% cities,], aes(x=as.Date(time), y=daily, colour=place))+
  geom_line()+
  coord_cartesian(xlim=c((Sys.Date()-30),Sys.Date()), ylim=c(0,100))+
  scale_x_date(breaks="1 week")+
  labs(
    title="Daily cases of covid-19 by place",
    x = "Date",
    y = "Cases per day"
  )

ggsave(paste0(folder,"covid_cases_cities_daily.pdf"), width=10, height=12)
