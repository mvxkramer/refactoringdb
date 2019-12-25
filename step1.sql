# Look at the source table
select * from download limit 10;

# Create separated tables
CREATE TABLE apps(
    id int(11) not null auto_increment,
    appNativeId int(11) not null unique,
    Url varchar(500) not null,
    Name varchar(255) not null,
    Subtitle varchar(255) not null ,
    IconURL varchar(500) not null,
    AverageUserRating float not null default 0.0,
    UserRatingCount int(11) not null default 0,
    Price float not null,
    InAppPurchases tinyint(1) not null,
    Description text not null,
    Developer varchar(255) not null,
    AgeRating varchar(10) not null,
    Size bigint not null,
    PrimaryGenre varchar(50) default null,
    OriginalReleaseDate date not null,
    CurrentVersionReleaseDate date not null,
    primary key (id)
);


CREATE TABLE languages(
    Language varchar(4) not null unique,
    primary key (Language)
);


CREATE TABLE genres(
    Genre varchar(50) not null unique,
    primary key (Genre)
);


CREATE TABLE app_genres(
    id int(11) not null auto_increment,
    appId int(11) not null,
    Genre varchar(50) not null,
    primary key (id),
    foreign key (appId)  references apps(id) on delete cascade on update cascade,
    foreign key (Genre) references genres(Genre) on delete cascade on update cascade
);


CREATE TABLE app_languages(
    id int(11) not null auto_increment,
    appId int(11) not null,
    Language varchar(4) not null,
    primary key (id),
    foreign key (appId) references apps(id) on delete cascade on update cascade,
    foreign key (Language) references languages(Language) on delete cascade on update cascade
);

CREATE TABLE developers(
    Developer varchar(255) not null,
    primary key (Developer)
);
