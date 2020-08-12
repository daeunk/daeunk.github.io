library(rvest)
library(XML)
library(httr)
library(jsonlite)
library(plyr)
library(dplyr)

setwd("/Users/sharon/Documents/2017-2018/CS 448B/Final Project")

# DATA FOR NUMBER OF FOREIGN ACTORS OVER TIME
actorinfo <- read.csv('ActorFinalData.csv', header = TRUE)[,1:3]
cast <- read.csv('allcast.csv', header =TRUE)[,1:2]
movies <- read.csv('AllMovieInfo.csv', header = TRUE)[,c(1,4,7)]
movies <- movies[order(movies$year, movies$bo, decreasing = TRUE),]
cast$Actor <- tolower(cast$Actor)
actorinfo$Actor <- tolower(actorinfo$Actor)

years <- seq(2007, 2017, by = 1)
movies100 <- NULL
for(i in 1:length(years)){
  temp <- movies[which(movies$year == years[i])[1:100],]
  movies100 <- rbind(movies100, temp)
}
movies100$Movie <- as.character(movies100$Movie)

movies100$numforeign <- NA
movies100$numactor <- NA
for(i in 1:nrow(movies100)){
  print(i)
  movie <- movies100$Movie[i]
  casting <- cast[which(cast$Movie == movie),]
  casting <- merge(casting, actorinfo, by = 'Actor')
  movies100$numactor[i] <- nrow(casting)
  movies100$numforeign[i] <- nrow(casting[which(casting$Country != 'USA' & casting$Country != 'None'),])
}

containforeign <- NULL
for(i in 1:nrow(movies100)){
  temp <- movies100[i,]
  if(temp$numforeign > 0){
    containforeign <- rbind(containforeign, temp)
  }
}
containforeign$percent <- containforeign$numforeign/containforeign$numactor
temp <- table(containforeign$year)
temp2 <- ddply(containforeign[,c(1,2,6)], "year", numcolwise(mean))

#write.csv(containforeign, 'hasforeign.csv', row.names = FALSE)

totalforeign <- ddply(containforeign[,c(2,4)], "year", numcolwise(sum))
totalactors <- ddply(containforeign[,c(2,5)], "year", numcolwise(sum))


# DATA FOR NUMBER OF FOREIGN LOCATIONS OVER TIME
locations <- read.csv('filmlocations.csv', header = TRUE)
locations$FilmLocations <- tolower(locations$FilmLocations)

moviefilming <- read.csv('AllMovieInfo.csv', header = TRUE)[,c(1,4,10)]
moviefilming$countries <- tolower(moviefilming$countries)
moviefilming$numcountries <- NA
for(i in 1:nrow(moviefilming)){
  film <- moviefilming[i,3]
  film <- strsplit(film, ', ')[[1]]
  film <- film[!film %in% c("")]
  num <- length(film)
  moviefilming$numcountries[i] <- num
}

years <- seq(2007, 2017, by = 1)
locations100 <- NULL
for(i in 1:length(years)){
  temp <- moviefilming[which(moviefilming$year == years[i])[1:100],]
  locations100 <- rbind(locations100, temp)
}
locations100$Movie <- as.character(locations100$Movie)
avglocations <- ddply(locations100[,c(2,4)], "year", numcolwise(mean))


# NUMBER OF FOREIGN STARS OVER TIME
movieapi <- read.csv('AllMovieInfo.csv', header = TRUE)[,c(1,4,6,7)]
movieapi <- movieapi[order(movieapi$year, movieapi$bo, decreasing =TRUE),]
movieapi$bo <- as.character(movieapi$bo)
movieapi$bo <- gsub('\\$', "", movieapi$bo)
movieapi$bo <- as.numeric(as.character(movieapi$bo))

years <- seq(2007, 2017, by = 1)
stars100 <- NULL
for(i in 1:length(years)){
  temp <- movieapi[which(movieapi$year == years[i])[1:100],]
  stars100 <- rbind(stars100, temp)
}
stars100$Movie <- as.character(stars100$Movie)
stars100$apiurl <- as.character(stars100$apiurl)
stars100$stars <- NA
for(i in 1:nrow(stars100)){
  print(i)
  url <- stars100$apiurl[i]
  info <- GET(url)
  info_txt <- content(info, as = "text")
  movieneed <- fromJSON(info_txt)
  stars <- movieneed$stars
  stars <- paste(as.character(stars), collapse = ', ')
  stars100$stars[i] <- stars
}

starsfinal <- NULL
for(i in 1:nrow(stars100)){
  print(i)
  movie <- stars100$Movie[i]
  year <- stars100$year[i]
  stars <- strsplit(stars100$stars[i], ", ")[[1]]
  newLine <- NULL
  for(j in 1:length(stars)){
    newLine <- c(movie, year, tolower(stars[j]))
    starsfinal <- rbind(starsfinal, newLine)
  }
}

starsfinal <- as.data.frame(starsfinal, row.names = FALSE)
names(starsfinal) <- c('Movies', 'Year', 'Actor')
starsfinal <- merge(starsfinal, actorinfo, by = 'Actor')
starsfinal <- starsfinal[order(starsfinal$Year, starsfinal$Movies),]

uniquemovies <- unique(starsfinal$Movies)
uniquemovies <- as.character(uniquemovies)
starsfinal$Year <- as.numeric(as.character(starsfinal$Year))

foreignstars <- NULL
for(i in 1:length(uniquemovies)){
  temp <- starsfinal[which(starsfinal$Movies == uniquemovies[i] & starsfinal$Country != 'USA'),]
  countries <- paste(unique(temp$Country), collapse= ', ')
  if(nrow(temp) > 0){
    newLine <- c(uniquemovies[i], starsfinal$Year[which(starsfinal$Movies == uniquemovies[i])][1], nrow(temp), countries)
    foreignstars <- rbind(foreignstars, newLine)
  }
}
foreignstars <- as.data.frame(foreignstars, row.names = FALSE)
names(foreignstars) <- c('Movie', 'Year', 'ForeignStars', 'Countries')
table(foreignstars$Year)


############################# COMBINE ACTOR INFO ###################################
hasforeign <- read.csv('hasforeign.csv', header = TRUE)[,-1]
actors <- read.csv('AllActorData.csv', header = TRUE)[,-1]

hasforeign <- merge(hasforeign, actors, by = 'Movie', all = TRUE)
hasforeign <- hasforeign[,c(1,2,3,14,15,16,17)]

topactors <- read.csv('topactors.csv', header = TRUE, stringsAsFactors = FALSE)
actors <- unique(topactors$Actor)
topactors$bo <- as.numeric(as.character(topactors$bo))

actorinfo <- NULL
for(i in 1:length(actors)){
  print(i)
  temp <- topactors[which(topactors$Actor == actors[i]),]
  indexhigh <- which(temp$bo == max(temp$bo))
  allbo <- sum(temp$bo)
  nextLine <- c(temp$Movie[indexhigh], temp$year[indexhigh], temp$bo[indexhigh], temp$Actor[indexhigh], temp$Character[indexhigh], temp$Country[indexhigh], temp$Continent[indexhigh],
                allbo)
  actorinfo <- rbind(actorinfo, nextLine)
}


actorinfo <- as.data.frame(actorinfo, row.names = FALSE)
names(actorinfo) <- c('Movie', 'Year', 'BO', 'Actor', 'Character', 'Country', 'Continent', 'TotalBO')




