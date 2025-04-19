-- Oracle Database Setup for Vinyl Collection Management

CREATE TABLESPACE cst2355_GroupAssignment2
  DATAFILE 'vinyl_data.dat' SIZE 50M
  ONLINE;

-- Create single user with all privileges
CREATE USER groupAssignment2_admin IDENTIFIED BY GroupAssignment2Password123 ACCOUNT UNLOCK
  DEFAULT TABLESPACE cst2355_GroupAssignment2
  QUOTA UNLIMITED ON cst2355_GroupAssignment2;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE TRIGGER, 
      CREATE PROCEDURE, CREATE SEQUENCE TO groupAssignment2_admin;

-- Connect as application user
CONNECT groupAssignment2_admin/GroupAssignment2Password123;

CREATE OR REPLACE PROCEDURE sp_checkInvalidArtistName(ArtistName IN VARCHAR)
AS
BEGIN
	-- Check the format is OK, otherwise throw a unique error
	IF REGEXP_LIKE(ArtistName, q'{[^A-Za-z \-]}') THEN
		RAISE_APPLICATION_ERROR (-20000, 'Artist name cannot contain numbers or symbols! Only letters, spaces, and hyphens are allowed.');
	END IF;	
END;
/

-- Artists (only primary key)
CREATE TABLE Artists (
    ArtistID int NOT NULL AUTO INCREMENT,
    ArtistName varchar(45) NOT NULL,
    Type VARCHAR(25) NOT NULL,
    PRIMARY KEY (ArtistID)
);

CREATE OR REPLACE TRIGGER Artist_Name_Check
BEFORE INSERT OR UPDATE
ON Artists
FOR EACH ROW 
DECLARE 
	var_pc	varchar(45) := :NEW.ArtistName;
BEGIN
	sp_checkInvalidArtistName(var_pc);
END;
/

INSERT INTO Artists VALUES (1,'The Beatles', 'Band');
INSERT INTO Artists VALUES (2, 'Queen', 'Band');
INSERT INTO Artists VALUES (3, 'ABBA', 'Band');

-- Genres (only primary key)
CREATE TABLE Genres (
    GenreID int NOT NULL AUTO INCREMENT,
    GenreName VARCHAR(25) NOT NULL,
    PRIMARY KEY (GenreID)
);

INSERT INTO Genres VALUES (1, 'Rock');
INSERT INTO Genres VALUES (2, 'Pop');

-- Albums (primary key + single-value fields)
CREATE TABLE Albums (
    AlbumID INT NOT NULL AUTO INCREMENT,
    Title VARCHAR(100),
    ReleaseYear INT,
    GenreID INT NOT NULL,
    ArtistID INT NOT NULL,
    CONSTRAINT fk_album_genre FOREIGN KEY (GenreID) REFERENCES Genres(GenreID),
    CONSTRAINT fk_album_artist FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID),
    PRIMARY KEY(AlbumID)
);

INSERT INTO Albums VALUES (1, 'Abbey Road',  1969, 1, 1);
INSERT INTO Albums VALUES (2, 'Sheer Heart Attack',  1973, 1, 2);

-- Recordings (primary key + single-value fields)
CREATE TABLE Recordings (
    RecordingID INT NOT NULL AUTO INCREMENT,
    Title VARCHAR(100),
    Duration TIMESTAMP NOT NULL,
    AlbumID INT NOT NULL,
    ArtistID INT NOT NULL,
    CONSTRAINT fk_recording_album FOREIGN KEY (AlbumID) REFERENCES Albums(AlbumID),
    CONSTRAINT fk_recording_artist FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID),
    PRIMARY KEY(RecordingID)
);

INSERT INTO Recordings VALUES (1, 'Come Together', to_timestamp('2000-01-01 00:04:20', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO Recordings VALUES (2, 'Brighton Rock', to_timestamp('2000-01-01 00:05:25', 'YYYY-MM-DD HH24:MI:SS'), 2, 2);

-- Recording is-a Type of Genre (Genres) (Is-A)
CREATE TABLE Recording_Genre (
    Recording_GenreID INT NOT NULL AUTO INCREMENT,
    StartTime TIMESTAMP NOT NULL,
    EndTime TIMESTAMP DEFAULT NULL,
    Recordings_RecordingID int NOT NULL,
    Genre_GenreID int NOT NULL,
    CONSTRAINT fk_recording_genre_r FOREIGN KEY(Recordings_RecordingID) REFERENCES Recordings(RecordingID),
    CONSTRAINT fk_recording_genre_g FOREIGN KEY(Genre_GenreID) REFERENCES Genres(GenreID),
    PRIMARY KEY(Recording_GenreID)
);

INSERT INTO Recording_Genre VALUES(1, to_timestamp('2025-04-10 04:55:00', 'YYYY-MM-DD HH24:MI:SS'),NULL, 1, 1);
INSERT INTO Recording_Genre VALUES(2, to_timestamp('2025-04-10 04:59:00', 'YYYY-MM-DD HH24:MI:SS'),NULL, 2, 2);

-- Artist is related to Album (Is-Related-To)
CREATE TABLE Artist_Album (
    Artist_AlbumID INT NOT NULL AUTO INCREMENT,
    StartTime TIMESTAMP NOT NULL,
    EndTime TIMESTAMP DEFAULT NULL,
    Artist_ArtistID int NOT NULL,
    Album_AlbumID int NOT NULL,
    CONSTRAINT fk_artist_album_art FOREIGN KEY(Artist_ArtistID) REFERENCES Artists(ArtistID),
    CONSTRAINT fk_artist_album_alb FOREIGN KEY(Album_AlbumID) REFERENCES Albums(AlbumID),
    PRIMARY KEY(Artist_AlbumID)
);

INSERT INTO Artist_Album VALUES(1, to_timestamp('2025-04-10 03:57:00', 'YYYY-MM-DD HH24:MI:SS'),NULL, 1, 1);
INSERT INTO Artist_Album VALUES(2, to_timestamp('2025-04-10 03:59:00', 'YYYY-MM-DD HH24:MI:SS'),NULL, 2, 2);

-- Album contains Recordings (Contains)
CREATE TABLE Album_Recordings (
    Album_RecordingsID INT NOT NULL AUTO INCREMENT,
    StartTime TIMESTAMP NOT NULL,
    EndTime TIMESTAMP DEFAULT NULL,
    Album_AlbumID int NOT NULL,
    Recordings_RecordingID int NOT NULL,
    CONSTRAINT fk_album_recordings_a FOREIGN KEY(Album_AlbumID) REFERENCES Albums(AlbumID),
    CONSTRAINT fk_album_recordings_r FOREIGN KEY(Recordings_RecordingID) REFERENCES Recordings(RecordingID),
    PRIMARY KEY(Album_RecordingsID)
);

INSERT INTO Album_Recordings VALUES(1, to_timestamp('2025-04-10 04:31:00', 'YYYY-MM-DD HH24:MI:SS'),NULL, 1, 1);
INSERT INTO Album_Recordings VALUES(2, to_timestamp('2025-04-10 04:35:00', 'YYYY-MM-DD HH24:MI:SS'),NULL, 2, 2);

COMMIT;

-- End of File