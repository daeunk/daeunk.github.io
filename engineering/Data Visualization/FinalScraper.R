library(rvest)
library(XML)
library(httr)
library(jsonlite)
library(plyr)
library(dplyr)

setwd("/Users/sharon/Documents/2017-2018/CS 448B/Final Project")

######################################## SCRAPE BOX OFFICE INFO #######################################

years <- seq(2007, 2017, by = 1)
pages <- c(1:3)

# Pull basic info from IMDB top grossing list
finalpull <- NULL
for(i in 1:length(years)){
  y <- years[i]
  for(j in 1:length(pages)){
    p <- pages[j]
    url <- paste('http://www.imdb.com/search/title?year=',y, ",", y,'&sort=boxoffice_gross_us,desc&page=', p, '&ref_=adv_nxt', sep = '')
    print(url)
    page <- read_html(url)
    linknodes <- html_nodes(page, xpath='//*[@class="lister-item-header"]//@href')
    links <- html_text(linknodes)
    links <- paste('imdb.com', links, sep ='')
    titlenodes <- html_nodes(page, xpath='//*[@class="lister-item-header"]//a')
    titles <- html_text(titlenodes)
    newLine <- cbind(titles, links, url, p, y)
    finalpull <- rbind(newLine, finalpull)
  }
}

# Convert to dataframe
finalpull <- as.data.frame(finalpull)
names(finalpull) <- c('title', 'link', 'url', 'page','year')
finalpull$year <- as.numeric(as.character(finalpull$year))
finalpull$page <- as.numeric(as.character(finalpull$page))

# Add API URL
finalpull$link <- as.character(finalpull$link)
finalpull$id <- NA
for (i in 1:nrow(finalpull)){
  temp <- strsplit(finalpull$link[i], '/')[[1]][3]
  finalpull$id[i] <- temp
}

# Get box office info
finalpull$apiurl <- NA
for(i in 1:nrow(finalpull)){
  finalpull$apiurl[i] <- paste('http://www.theimdbapi.org/api/movie?movie_id=', finalpull$id[i], sep = '')
}

#remove <- which(finalpull$page>5 & finalpull$year == 2017)
#finalpull <- finalpull[-remove,]

finalpull$bo <- NA
finalpull$casting <- NA
finalpull$characters <- NA
finalpull$countries <- NA

finalpull <- read.csv('look2.csv', header = TRUE)[,-1]

# Pull API info!
finalpull$apiurl <- as.character(finalpull$apiurl)
for (i in 1:nrow(finalpull)){
  print(i)
  url <- finalpull$apiurl[i]
  info <- GET(url)
  info_txt <- content(info, as = "text")
  movieneed <- fromJSON(info_txt)
  
  # Box office info
  finalpull$bo[i] <-strsplit(movieneed$metadata$gross, "  ")[[1]][1]
  
  # Add casting info
  cast <- movieneed$cast$name
  if(length(cast)>0){
    allcast <- NULL
    for(j in 1:length(cast)){
      allcast <- paste(allcast, cast[j], sep = ', ')
    }
    finalpull$casting[i] <- allcast
    
    # Add character info
    character <- movieneed$cast$character
    allcharacter <- NULL
    for(j in 1:length(cast)){
      allcharacter <- paste(allcharacter, character[j], sep = ', ')
    }
    finalpull$characters[i] <- allcharacter
  }
  
  # Add country info
  country <- movieneed$metadata$countries
  if(length(country) > 0){
    allcountries <- NULL
    for(j in 1:length(country)){
      allcountries <- paste(allcountries, country[j], sep = ', ')
    }
    finalpull$countries[i] <- allcountries
  }
}



#write.csv(finalpull[which(finalpull$year == 2017),], 'look2.csv')
finalfinal <- finalpull[which(grepl('USA', finalpull$countries)),]
finalfinal$bo <- as.character(finalfinal$bo)
for (i in 1:nrow(finalfinal)){
  if(is.na(finalfinal$bo[i]) == FALSE){
    finalfinal$bo[i] <- substring(finalfinal$bo[i], 2)
    finalfinal$bo[i] <- gsub(',', '', finalfinal$bo[i])
  }
}
remove <- which(is.na(finalfinal$bo))
finalfinal <- finalfinal[-remove,]

################################# ADDITIONAL BOX OFFICE INFO ##################################### 
allinfo <- NULL
index <- 1
for(i in 1:200){
  print(i)
  url <- paste('http://www.imdb.com/search/title?sort=boxoffice_gross_us&title_type=feature&view=simple&page=', i, '&ref_=adv_nxt', sep = '')
  page <- read_html(url)
  yearnodes <- html_nodes(page, xpath='//*[@class="lister-item-year text-muted unbold"]')
  years <- html_text(yearnodes)
  years <- substr(years, nchar(years)-4,nchar(years)-1)
  years <- as.numeric(years)
  
  linknodes <- html_nodes(page, xpath='//*[@class="lister-item-header"]//@href')
  links <- html_text(linknodes)
  links <- paste('imdb.com', links, sep ='')
  
  titlenodes <- html_nodes(page, xpath='//*[@class="lister-item-header"]//a')
  titles <- html_text(titlenodes)
  indices <- seq(index, index+49, 1)
  newLine <- cbind(titles, links, years, indices)
  allinfo <- rbind(allinfo, newLine)
  index <- index + 50
}
allinfo <- as.data.frame(allinfo)

# years <- seq(1997, 2017, by = 1)
# for(i in 1:length(years)){
#   print(length(allyears[which(allyears == years[i])]))
# }
#temp <- cbind(temp[,1:3], c(1:200))
names(temp) <- names(allinfo)
everything <- rbind(allinfo, temp)

everything <- everything[order(everything$years, everything$indices, decreasing = TRUE),]
temp2 <- everything
temp2$years <- as.numeric(as.character(temp2$years))
temp2$indices <- as.numeric(as.character(temp2$indices))
temp2 <- temp2[order(temp2$years, temp2$indices, decreasing = FALSE),]
temp2 <- temp2[which(temp2$years > 2006),]

temp3 <- NULL
for(i in 1:length(years)){
  newLine <- temp2[which(temp2$years == years[i])[1:200],]
  temp3 <- rbind(temp3, newLine)
}
temp3 <- temp3[order(temp3$years, temp3$indices, decreasing = FALSE),]


allmovies <- temp3

additional <- NULL
for(i in 1:length(years)){
  end <- length(which(temp2$years == years[i]))
  newLine <- temp2[which(temp2$years == years[i])[201:end],]
  additional <- rbind(additional, newLine)
}

# get next few pages of 2010, 2011, 2012, 2015 movies
temptemp <- NULL
pages <- c(6,7,8)
allyears <- c(2010,2011,2012,2015)
for(i in 1:length(allyears)){
  y <- allyears[i]
  for(j in 1:length(pages)){
    p <- pages[j]
    print(url)
    url <- paste('http://www.imdb.com/search/title?year=',y, ",", y,'&sort=boxoffice_gross_us,desc&page=', p, '&ref_=adv_nxt', sep = '')
    page <- read_html(url)
    linknodes <- html_nodes(page, xpath='//*[@class="lister-item-header"]//@href')
    links <- html_text(linknodes)
    links <- paste('imdb.com', links, sep ='')
    titlenodes <- html_nodes(page, xpath='//*[@class="lister-item-header"]//a')
    titles <- html_text(titlenodes)
    newLine <- cbind(titles, links, y)
    temptemp <- rbind(newLine, temptemp)
  }
}

temptemp <- as.data.frame(temptemp)
names(temptemp) <- c('titles', 'links', 'years')
temptemp$years <- as.numeric(as.character(temptemp$years))

temptemp$links <- as.character(temptemp$links)
temptemp$ids <- NA
for (i in 1:nrow(temptemp)){
  temp <- strsplit(temptemp$links[i], '/')[[1]][3]
  temptemp$ids[i] <- temp
}

# Get box office info
temptemp$apiurl <- NA
for(i in 1:nrow(temptemp)){
  temptemp$apiurl[i] <- paste('http://www.theimdbapi.org/api/movie?movie_id=', allmovies$ids[i], sep = '')
}
temptemp$bo <- NA
temptemp$casting <- NA
temptemp$characters <- NA
temptemp$countries <- NA

temptemp$indices <- NA
counter <- 201
for(i in 1:nrow(temptemp)){
  temptemp$indices[i] <- counter
  counter <- counter + 1
}
temptemp <- temptemp[,c(1,2,3,10,4,5,6,7,8,9)]

######################################## SCRAPE FOREIGN COUNTRY BOX OFFICES #######################################
movies <- read.csv('AllMovieInfo.csv', header = TRUE, stringsAsFactors = FALSE)[,1]
movies <- tolower(movies)
movies <- gsub(" ", "", movies)
baseurl <- 'http://www.boxofficemojo.com/movies/?page=intl&id='


international <- NULL
for (i in 97:length(movies)){
  print(i)
  moviename <- movies[i]
  if(moviename == 'goinginstyle2017'){
    moviename <- 'goinginsty2017'
  }
  url <- paste(baseurl, moviename, '.htm', sep = '')
  page <- read_html(url)
  countrynodes1 <- html_nodes(page, xpath='//*[@bgcolor="#f4f4ff"]/td[1]//a')
  countries1 <- html_text(countrynodes1)
  countrynodes2 <- html_nodes(page, xpath='//*[@bgcolor="#ffffff"]/td[1]//a')
  countries2 <- html_text(countrynodes2)[-c(1,2)]
  countries <- c(countries1,countries2)
  bonodes1 <- html_nodes(page, xpath='//*[@bgcolor="#f4f4ff"]/td[6]')
  bo1 <- html_text(bonodes1)
  bonodes2 <- html_nodes(page, xpath='//*[@bgcolor="#ffffff"]/td[6]')
  bo2 <- html_text(bonodes2)[-1]
  boxoffice <- c(bo1,bo2)
  if(length(countries) > 0 & length(boxoffice) > 0){
    newLines <- cbind(countries, boxoffice, movies[i]) 
    newLines <- as.data.frame(newLines, stringsAsFactors = FALSE)
    names(newLines) <- c('Country', 'BoxOffice', 'Movie')
    international <- rbind(international, newLines)
  }
}


haveinternational <- unique(international$Movie)
movies2 <- movies
for(i in 1:length(movies2)){
  movies2[i] <- str_replace_all(movies2[i], "[^[:alnum:]]", "")
}
have <- which(movies2 %in% international$Movie)
nointernational <- movies2[-have]


# Re-scrape for missing
for(i in 1:length(nointernational)){
  nointernational[i] <- str_replace_all(nointernational[i], "[^[:alnum:]]", "")
}
international2 <- NULL
for (i in 523:length(nointernational)){
  moviename <- nointernational[i]
  print(i)
  if(moviename == 'bigmommaslikefatherlikeson'){
    moviename <- 'bigmomma3'
  }
  url <- paste(baseurl, moviename, '.htm', sep = '')
  page <- read_html(url)
  countrynodes1 <- html_nodes(page, xpath='//*[@bgcolor="#f4f4ff"]/td[1]//a')
  countries1 <- html_text(countrynodes1)
  countrynodes2 <- html_nodes(page, xpath='//*[@bgcolor="#ffffff"]/td[1]//a')
  countries2 <- html_text(countrynodes2)[-c(1,2)]
  countries <- c(countries1,countries2)
  bonodes1 <- html_nodes(page, xpath='//*[@bgcolor="#f4f4ff"]/td[6]')
  bo1 <- html_text(bonodes1)
  bonodes2 <- html_nodes(page, xpath='//*[@bgcolor="#ffffff"]/td[6]')
  bo2 <- html_text(bonodes2)[-1]
  boxoffice <- c(bo1,bo2)
  if(length(countries) > 0 & length(boxoffice) > 0){
    newLines <- cbind(countries, boxoffice, nointernational[i]) 
    newLines <- as.data.frame(newLines, stringsAsFactors = FALSE)
    names(newLines) <- c('Country', 'BoxOffice', 'Movie')
    international2 <- rbind(international2, newLines)
  }
}
international <- rbind(international, international2)




# Scrape for Box office mojo name
newlinks <- NULL
for(i in 1:length(nointernational)){
  print(i)
  url <- paste('https://www.bing.com/search?q=', nointernational[i], 'boxofficemojo', sep ="")
  page <- read_html(url)
  bomnode <- html_nodes(page, xpath='//*[@class="b_algo"][1]//h2//@href')
  bomnode <- html_text(bomnode)
  newLine <- c(bomnode, nointernational[i])
  newlinks <- rbind(newlinks, newLine)
}
newlinks <- as.data.frame(newlinks)

newlinks <- read.csv('nobo.csv', header = TRUE, stringsAsFactors =  FALSE)
newmovies <- newlinks$movie
newids <- NULL
for(i in 1:nrow(newlinks)){
  temp <- newlinks$newurl[i]
  newid <- strsplit(strsplit(temp, 'id=')[[1]][2], '.htm')[[1]][1]
  newids <- c(newids, newid)
}
newids <- as.data.frame(newids)
newlinks <- cbind(newlinks, newids)

international2 <- NULL
for (i in 1:nrow(newlinks)){
  print(i)
  moviename <- newlinks$movie[i]
  url <- paste(baseurl, newlinks$newids[i], '.htm', sep = '')
  page <- read_html(url)
  countrynodes1 <- html_nodes(page, xpath='//*[@bgcolor="#f4f4ff"]/td[1]//a')
  countries1 <- html_text(countrynodes1)
  countrynodes2 <- html_nodes(page, xpath='//*[@bgcolor="#ffffff"]/td[1]//a')
  countries2 <- html_text(countrynodes2)[-c(1,2)]
  countries <- c(countries1,countries2)
  bonodes1 <- html_nodes(page, xpath='//*[@bgcolor="#f4f4ff"]/td[6]')
  bo1 <- html_text(bonodes1)
  bonodes2 <- html_nodes(page, xpath='//*[@bgcolor="#ffffff"]/td[6]')
  bo2 <- html_text(bonodes2)[-1]
  boxoffice <- c(bo1,bo2)
  if(length(countries) > 0 & length(boxoffice) > 0){
    newLines <- cbind(countries, boxoffice, newlinks$movie[i]) 
    newLines <- as.data.frame(newLines, stringsAsFactors = FALSE)
    names(newLines) <- c('Country', 'BoxOffice', 'Movie')
    international2 <- rbind(international2, newLines)
  }
}

international <- rbind(international, international2)
movieswithbo <- unique(international$Movie)



################################### SCRAPE FOR MOVIE SCRIPTS #######################################
allmoviescripts <- NULL
# Script-o-rama scrape
tables <- c(2:4)
url <- "http://www.script-o-rama.com/snazzy/table.html"
page <- read_html(url)
titlenodes <- html_nodes(page, xpath='//*[@bordercolorlight="#FFFFFF"]//tr//a')
titles <- html_text(titlenodes)
linknodes <- html_nodes(page, xpath='//*[@bordercolorlight="#FFFFFF"]//tr//@href')
links <- html_text(linknodes)
links <- as.character(links)
for(i in 1:length(links)){
  links[i] <- paste('http://www.imsdb.com/', links[i], sep = '')
}
newLine <- cbind(titles, links)
newLine <- as.data.frame(newLine)
allmoviescripts <- rbind(allmoviescripts, newLine)

for (j in 1:length(tables)){
  url <- paste("http://www.script-o-rama.com/snazzy/table", tables[j], ".html", sep = "")
  page <- read_html(url)
  titlenodes <- html_nodes(page, xpath='//*[@bordercolorlight="#FFFFFF"]//tr//a')
  titles <- html_text(titlenodes)
  linknodes <- html_nodes(page, xpath='//*[@bordercolorlight="#FFFFFF"]//tr//@href')
  links <- html_text(linknodes)
  links <- as.character(links)
  for(i in 1:length(links)){
    links[i] <- paste('http://www.imsdb.com/', links[i], sep = '')
  }
  newLine <- cbind(titles, links)
  newLine <- as.data.frame(newLine)
  allmoviescripts <- rbind(allmoviescripts, newLine)
}

allmoviescripts$titles <- gsub("\n", "", allmoviescripts$titles)
allmoviescripts$titles <- gsub("\t", "", allmoviescripts$titles)
for(i in 1:nrow(allmoviescripts)){
  title <- allmoviescripts$titles[i]
  if(substr(title, nchar(title)-4, nchar(title)) == ', The'){
    newtitle <- paste('The ', substr(title, 1, nchar(title)-5), sep = '')
    allmoviescripts$titles[i] <- newtitle
  }
}


# Scrape from IMSDB
url <- "http://www.imsdb.com/all%20scripts/"
page <- read_html(url)
titlenodes <- html_nodes(page, xpath='//td/p//a')
titles <- html_text(titlenodes)
linknodes <- html_nodes(page, xpath='//td/p//@href')
links <- html_text(linknodes)
links <- as.character(links)
for(i in 1:length(links)){
  newlink <- links[i]
  newlink <- paste('http://www.imsdb.com/s', substr(newlink, 9,nchar(newlink)), sep='')
  newlink <- gsub(" ", '-', newlink)
  newlink <- gsub("-Script", "", newlink)
  links[i] <- newlink
}
newLine <- cbind(titles, links)
newLine <- as.data.frame(newLine)
allmoviescripts <- rbind(allmoviescripts, newLine)



# Scrape from Simply Scripts
url <- "http://www.simplyscripts.com/movie-screenplays.html"
page <- read_html(url)
titlenodes <- html_nodes(page, xpath='//p/a[1]')
titles <- html_text(titlenodes)
linknodes <- html_nodes(page, xpath='//p/a[1]/@href')
links <- html_text(linknodes)
links <- as.character(links)
newLine <- cbind(titles, links)
newLine <- as.data.frame(newLine)
allmoviescripts <- rbind(allmoviescripts, newLine)


# Scrape from Screenplays for you
url <- "https://sfy.ru/scripts"
page <- read_html(url)
titlenodes <- html_nodes(page, xpath='//p/a[1]')
titles <- html_text(titlenodes)
linknodes <- html_nodes(page, xpath='//p/a[1]/@href')
links <- html_text(linknodes)
links <- as.character(links)
links <- links[-1]
titles <- titles[-1]
for(i in 1:length(links)){
  newlink <- links[i]
  if(substr(newlink, 1, 8) != 'https://'){
    newlink <- paste('https://sfy.ru', newlink, sep='')
    links[i] <- newlink
  }
}
newLine <- cbind(titles, links)
newLine <- as.data.frame(newLine)
allmoviescripts <- rbind(allmoviescripts, newLine)

# Scrape from Daily Scripts
url <- "http://www.dailyscript.com/movie.html"
page <- read_html(url)
titlenodes <- html_nodes(page, xpath='//p/a[1]')
titles <- html_text(titlenodes)
linknodes <- html_nodes(page, xpath='//p/a[1]/@href')
links <- html_text(linknodes)
links <- as.character(links)
for(i in 1:length(links)){
  newlink <- links[i]
  newlink <- paste('http://www.dailyscript.com/', newlink, sep = "")
  links[i] <- newlink
}
newLine <- cbind(titles, links)
newLine <- as.data.frame(newLine)
allmoviescripts <- rbind(allmoviescripts, newLine)



# Which movies have scripts:
movies <- read.csv('AllMovieInfo.csv', header = TRUE, stringsAsFactors = FALSE)[,1]
movies <- tolower(movies)

havescripts <- allmoviescripts$titles
havescripts <- tolower(havescripts)
havescripts <- unique(havescripts)

have <- NULL
for(i in 1:length(movies)){
  print(i)
  for(j in 1:length(havescripts)){
    if(grepl(movies[i], havescripts[j])){
      have <- c(have, i)
    }
  }
}
have <- unique(have)

moviewithscripts <- movies[have]
movienoscript <- movies[-have]