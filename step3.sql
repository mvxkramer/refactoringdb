# triggers
CREATE TABLE logs(
    id int(11) not null auto_increment,
    action enum('insert', 'delete') not null,
    time timestamp not null default current_timestamp,
    rowId int(11) not null,
    primary key (id)
);
# drop table logs;


CREATE TRIGGER InsertRowIntoSource after INSERT ON download
FOR EACH ROW BEGIN
    insert into logs set rowId = NEW.id, action = 'insert';

    insert into developers (Developer) VALUE (NEW.Developer)
    on duplicate key update Developer=Developer;

    insert into apps (
        appNativeId, Url, Name, Subtitle, IconURL,
        AverageUserRating, UserRatingCount, Price,
        InAppPurchases, Description, Developer, AgeRating,
        Size, PrimaryGenre, OriginalReleaseDate, CurrentVersionReleaseDate
    ) values (
        NEW.id, NEW.Url, NEW.Name, NEW.Subtitle, NEW.IconURL, NEW.AverageUserRating,
        NEW.UserRatingCount, NEW.Price, IF(NEW.InAppPurchases = '', 0, 1), NEW.Description,
        NEW.Developer, NEW.AgeRating, NEW.Size, NEW.PrimaryGenre,
        NEW.OriginalReleaseDate, NEW.CurrentVersionReleaseDate
    );

    insert into app_genres (appId, Genre)
    select apps.id, genres.Genre
    from download
    join apps on download.id = apps.appNativeId
    right join genres on locate(genres.Genre, download.Genres)
    where apps.appNativeId = NEW.id
    order by apps.id;

    insert into app_languages (appId, Language)
    select apps.id, languages.Language
    from download
    join apps on download.id = apps.appNativeId
    right join languages on locate(languages.Language, download.Languages)
    where apps.appNativeId = NEW.id
    order by apps.id;
END;


CREATE TRIGGER DeleteRowFromSource after DELETE ON download
FOR EACH ROW BEGIN
    insert into logs set rowId = OLD.id, action = 'delete';
    delete from apps where apps.appNativeId = OLD.id;
END;

# test triggers

INSERT INTO `download` (
    `id`, `Url`, `Name`, `Subtitle`, `IconURL`, `AverageUserRating`,
    `UserRatingCount`, `Price`, `InAppPurchases`, `Description`, `Developer`,
    `AgeRating`, `Languages`, `Size`, `PrimaryGenre`, `Genres`, `OriginalReleaseDate`,
    `CurrentVersionReleaseDate`
) VALUES (
    NULL, 'https://apps.apple.com/us/app/awesomeapp/1475076712', 'awesome app', 'awesome to show how triggers works',
    'https://awesome-pics.com/image/adsad-aba8-308a-05c0-19385a377c0e/source/512x512.jpg',
    '4', '0', '4.99', '2.99', 'Show triggers to insert record into db and delete that.', 'Max Kramer', '18+',
    'EN, RU', '12345678', 'Utilities', 'Utilities, Productivity', '2019-12-22', '2019-12-25'
);

delete from download where Developer = 'Max Kramer';
