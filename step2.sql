# insert in tables data from download table
insert into apps (
    appNativeId, Url, Name, Subtitle, IconURL,
    AverageUserRating, UserRatingCount, Price,
    InAppPurchases, Description, Developer, AgeRating,
    Size, PrimaryGenre, OriginalReleaseDate, CurrentVersionReleaseDate)
select
    id, Url, Name, Subtitle, IconURL, AverageUserRating,
    UserRatingCount, Price, IF(InAppPurchases = '', 0, 1), Description,
    Developer, AgeRating, Size, PrimaryGenre,
    OriginalReleaseDate, CurrentVersionReleaseDate from download;

insert into developers (Developer)
select apps.Developer from apps
on duplicate key update Developer=apps.Developer;

# show the unique values problem
select genre, count(1) from (
  select
    substring_index(
      substring_index(Genres, ', ', 1),
      ', ',
      -1
    ) as genre
  from download
) genresCount
group by 1;

select IF(language = '', 'EN', language), count(1) from (
  select
    substring_index(
      substring_index(Languages, ', ', 1),
      ', ',
      -1
    ) as language
  from download
) languages
group by 1;

# insert unique languages
CREATE PROCEDURE InsertUniqueLanguages()
BEGIN
    declare i int;
    set i = 1;
    while i <= 15 do
        insert into languages (language)
        select IF(language = '', 'EN', language) from (
          select
            substring_index(
              substring_index(Languages, ', ', i),
              ', ',
              -1
            ) as language
          from download
        ) languages
        group by 1
        on duplicate key update language=language;
        set i = i + 1;
    end while;
END;

CALL InsertUniqueLanguages();


# insert unique genres
CREATE PROCEDURE InsertUniqueGenres()
BEGIN
    declare i int;
    set i = 1;
    while i <= 10 do
        insert into genres (Genre)
        select Genre from (
          select
            substring_index(
              substring_index(Genres, ', ', i),
              ', ',
              -1
            ) as Genre
          from download
        ) genresCount
        group by 1
        on duplicate key update Genre=Genre;
        set i = i + 1;
    end while;
    insert into genres(Genre) select PrimaryGenre from apps group by  PrimaryGenre
    on duplicate key update Genre=Genre;
END;

CALL InsertUniqueGenres();

# add fk's to apps table
alter table apps
add foreign key (Developer) references developers(Developer)
    on delete cascade on update cascade,
add foreign key (PrimaryGenre) references genres(Genre)
    on delete set null on update cascade;

# insert in relation tables
insert into app_genres (appId, Genre)
select apps.id, genres.Genre
from download
join apps on download.id = apps.appNativeId
right join genres on locate(genres.Genre, download.Genres)
order by apps.id;

insert into app_languages (appId, Language)
select apps.id, languages.Language
from download
join apps on download.id = apps.appNativeId
right join languages on locate(languages.Language, download.Languages)
order by apps.id;