# 1 step
CREATE TABLE download(
    Url varchar(500) not null,
    id int(11) not null,
    Name varchar(255) not null,
    Subtitle varchar(255) not null ,
    IconURL varchar(500) not null,
    AverageUserRating float not null default 0.0,
    UserRatingCount int(11) not null default 0,
    Price float not null,
    InAppPurchases varchar(300) default null,
    Description text not null,
    Developer varchar(255) not null,
    AgeRating varchar(10) not null,
    Languages varchar(500) not null,
    Size bigint not null,
    PrimaryGenre varchar(100) not null,
    Genres varchar(100) not null,
    OriginalReleaseDate date not null,
    CurrentVersionReleaseDate date not null,
    primary key (id)
);

# step 2
LOAD DATA INFILE '/your/path/to/appstore_games.csv'
IGNORE
INTO TABLE download
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Url, id, Name, Subtitle, IconURL, @AverageUserRating, @UserRatingCount, @Price,
 InAppPurchases, Description, Developer, AgeRating, @Languages, @Size, PrimaryGenre,
Genres, @OriginalReleaseDate, @CurrentVersionReleaseDate)
SET OriginalReleaseDate = STR_TO_DATE(@OriginalReleaseDate, '%d/%m/%Y'),
    CurrentVersionReleaseDate = STR_TO_DATE(@CurrentVersionReleaseDate, '%d/%m/%Y'),
    AverageUserRating = CAST(IFNULL(NULLIF(@AverageUserRating, ''), 0.0) as decimal(10)),
    UserRatingCount = CAST(IFNULL(NULLIF(@UserRatingCount, ''), 0) as UNSIGNED),
    Languages = IF(@Languages = '', 'EN', @Languages), # !
    Price = IFNULL(NULLIF(@Price, ''), 0.0),
    Size = IFNULL(NULLIF(@Size, ''), 0);

# 3 step
ALTER TABLE download MODIFY id INT(11) NOT NULL AUTO_INCREMENT FIRST;

# Check the none duplicates
# select id, name from download where id = 289217958;

# if need start from scratch
# drop table download;
# truncate table download;

