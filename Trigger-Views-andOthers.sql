-- Package for artist_pkg
CREATE OR REPLACE PACKAGE artist_pkg AS
PROCEDURE change_album(ArtistID IN NUMBER, Title IN VARCHAR2, ReleaseYear IN NUMBER, GenreID IN NUMBER);

FUNCTION new_artist(
    ArtistName IN VARCHAR2,
    Type IN VARCHAR2,
    Title IN VARCHAR2 DEFAULT NULL,
    ReleaseYear IN NUMBER DEFAULT NULL,
    GenreID IN NUMBER DEFAULT NULL
)RETURN NUMBER;

END artist_pkg;
/

-- Body Package for artist_pkg
CREATE OR REPLACE PACKAGE BODY artist_pkg AS
PROCEDURE change_album(ArtistID IN NUMBER, Title IN VARCHAR2, ReleaseYear IN NUMBER, GenreID IN NUMBER)
IS
BEGIN
UPDATE Artist_Album SET EndTime = SYSDATE
WHERE Artist_ArtistID = ArtistID AND EndTime IS NULL;

INSERT INTO Albums(AlbumID, Title, ReleaseYear, GenreID, ArtistID)
VALUES (ALBUMS_Sequence.NEXTVAL, Title, ReleaseYear, GenreID, ArtistID);

INSERT INTO Artist_Album(Artist_AlbumID, StartTime, EndTime, Artist_ArtistID, Album_AlbumID)
VALUES (ARTIST_ALBUM_Sequence.NEXTVAL, SYSDATE, NULL, ArtistID, ALBUMS_Sequence.CURRVAL);

END change_album;

FUNCTION new_artist(
ArtistName IN VARCHAR2,
Type IN VARCHAR2,
Title IN VARCHAR2 DEFAULT NULL,
ReleaseYear IN NUMBER DEFAULT NULL,
GenreID IN NUMBER DEFAULT NULL)
RETURN NUMBER IS v_Artist_id NUMBER;
BEGIN
INSERT INTO Artists(ArtistID, ArtistName, Type)
VALUES(ARTISTS_Sequence.NEXTVAL, ArtistName, Type)
RETURNING ArtistID INTO v_Artist_id;

IF Title IS NOT NULL AND ReleaseYear IS NOT NULL AND GenreID IS NOT NULL
THEN change_album(v_Artist_id, Title, ReleaseYear, GenreID);
END IF;

RETURN v_artist_id;
END new_artist;

END artist_pkg;
/

-- Package for recording_pkg
CREATE OR REPLACE PACKAGE recording_pkg AS
PROCEDURE change_genre(RecordingID IN NUMBER, GenreName IN VARCHAR2);

FUNCTION new_recording(
    Title IN VARCHAR2,
    Duration IN TIMESTAMP,
    AlbumID IN NUMBER,
    ArtistID IN NUMBER,
    GenreName IN VARCHAR2 DEFAULT NULL
)RETURN NUMBER;

END recording_pkg;
/

-- Body Package for recording_pkg
CREATE OR REPLACE PACKAGE BODY recording_pkg AS
PROCEDURE change_genre(RecordingID IN NUMBER, GenreName IN VARCHAR2)
IS
BEGIN
UPDATE Recording_Genre SET EndTime = SYSDATE
WHERE Recordings_RecordingID = RecordingID AND EndTime IS NULL;

INSERT INTO Genres(GenreID, GenreName)
VALUES (GENRES_Sequence.NEXTVAL, GenreName);

INSERT INTO Recording_Genre(Recording_GenreID, StartTime, EndTime, Recordings_RecordingID, Genre_GenreID)
VALUES (RECORDING_GENRE_Sequence.NEXTVAL, SYSDATE, NULL, RecordingID, GENRES_Sequence.CURRVAL);

END change_genre;

FUNCTION new_recording(
Title IN VARCHAR2,
Duration IN TIMESTAMP,
AlbumID IN NUMBER,
ArtistID IN NUMBER,
GenreName IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS v_Recording_id NUMBER;
BEGIN
INSERT INTO Recordings(RecordingID, Title, Duration, AlbumID, ArtistID)
VALUES(RECORDINGS_Sequence.NEXTVAL, Title, Duration, AlbumID, ArtistID)
RETURNING RecordingID INTO v_Recording_id;

IF GenreName IS NOT NULL
THEN change_genre(v_Recording_id, GenreName);
END IF;

RETURN v_Recording_id;
END new_recording;

END recording_pkg;
/

-- Package for album_pkg
CREATE OR REPLACE PACKAGE album_pkg AS
PROCEDURE change_record(AlbumID IN NUMBER, Title IN VARCHAR2, Duration IN TIMESTAMP, ArtistID IN NUMBER);

FUNCTION new_album(
    a_Title IN VARCHAR2,
    ReleaseYear IN NUMBER,
    GenreID IN NUMBER,
    a_ArtistID IN NUMBER,
    r_Title in VARCHAR2 DEFAULT NULL,
    Duration IN TIMESTAMP DEFAULT NULL,
    AlbumID IN NUMBER DEFAULT NULL,
    r_ArtistID IN NUMBER DEFAULT NULL
)RETURN NUMBER;

END album_pkg;
/

-- Body Package for album_pkg
CREATE OR REPLACE PACKAGE BODY album_pkg AS
PROCEDURE change_record(AlbumID IN NUMBER, Title IN VARCHAR2, Duration IN TIMESTAMP, ArtistID IN NUMBER)
IS
BEGIN
UPDATE Album_Recordings SET EndTime = SYSDATE
WHERE Album_AlbumID = AlbumID AND EndTime IS NULL;

INSERT INTO Recordings(RecordingID, Title, Duration, ALbumID, ArtistID)
VALUES (RECORDINGS_Sequence.NEXTVAL, Title, Duration, AlbumID, ArtistID);

INSERT INTO Album_Recordings(Album_RecordingsID, StartTime, EndTime, Album_AlbumID, Recordings_RecordingID)
VALUES (ALBUM_RECORDINGS_Sequence.NEXTVAL, SYSDATE, NULL, AlbumID, RECORDINGS_Sequence.CURRVAL);

END change_record;

FUNCTION new_album(
a_Title IN VARCHAR2,
ReleaseYear IN NUMBER,
GenreID IN NUMBER,
a_ArtistID IN NUMBER,
r_Title in VARCHAR2 DEFAULT NULL,
Duration IN TIMESTAMP DEFAULT NULL,
AlbumID IN NUMBER DEFAULT NULL,
r_ArtistID IN NUMBER DEFAULT NULL)
RETURN NUMBER IS v_Album_id NUMBER;
BEGIN
INSERT INTO Albums(AlbumID, Title, ReleaseYear, GenreID, ArtistID)
VALUES(ALBUMS_Sequence.NEXTVAL, a_Title, ReleaseYear, GenreID, a_ArtistID)
RETURNING AlbumID INTO v_Album_id;

IF r_Title IS NOT NULL AND Duration IS NOT NULL AND AlbumID IS NOT NULL AND r_ArtistID IS NOT NULL
THEN change_record(v_Album_id, r_Title, Duration, r_ArtistID);
END IF;

RETURN v_Album_id;
END new_album;

END album_pkg;
/

-- View for ARTIST_VIEW
CREATE OR REPLACE VIEW ARTIST_VIEW AS
SELECT Artists.ArtistID, Artists.ArtistName, Artists.Type, Albums.Title, Albums.ReleaseYear, Albums.GenreID, Albums.ArtistID AS Album_ArtistID
FROM Artists JOIN Artist_Album ON Artists.ArtistID = Artist_Album.Artist_ArtistID
JOIN Albums ON Artist_Album.Album_AlbumID = Albums.AlbumID
WHERE Artist_Album.EndTime IS NULL;

-- View for RECORDING_VIEW
CREATE OR REPLACE VIEW RECORDING_VIEW AS
SELECT Recordings.RecordingID, Recordings.Title, Recordings.Duration, Recordings.AlbumID, Recordings.ArtistID, Genres.GenreName
FROM Recordings JOIN Recording_Genre ON Recordings.RecordingID = Recording_Genre.Recordings_RecordingID
JOIN Genres ON Recording_Genre.Genre_GenreID = Genres.GenreID
WHERE Recording_Genre.EndTime IS NULL;

-- View for ALBUM_VIEW
CREATE OR REPLACE VIEW ALBUM_VIEW AS
SELECT Albums.AlbumID, Albums.Title AS Album_Title, Albums.ReleaseYear, Albums.ArtistID AS Album_ArtistID, Recordings.RecordingID, Recordings.Title AS Recording_Title, Recordings.Duration, Recordings.AlbumID AS Recording_AlbumID, Recordings.ArtistID AS Recordings_ArtistID
FROM Albums JOIN Album_Recordings ON Albums.AlbumID = Album_Recordings.Album_AlbumID
JOIN Recordings ON Album_Recordings.Recordings_RecordingID = Recordings.RecordingID
WHERE Album_Recordings.EndTime IS NULL;

-- Trigger for ARTIST_VIEW_TRIGGER
CREATE OR REPLACE TRIGGER ARTIST_VIEW_TRIGGER INSTEAD OF INSERT OR UPDATE ON ARTIST_VIEW FOR EACH ROW
BEGIN
IF UPDATING AND (:NEW.Title IS NOT NULL OR :NEW.ReleaseYear IS NOT NULL OR :NEW.GenreID IS NOT NULL OR :NEW.Album_ArtistID IS NOT NULL) THEN
UPDATE Artist_Album SET EndTime = SYSDATE
WHERE Artist_ArtistID = :NEW.ArtistID
AND EndTime IS NULL;

INSERT INTO Albums(AlbumID, Title, ReleaseYear, GenreID, ArtistID)
VALUES(ALBUMS_Sequence.NEXTVAL, :NEW.Title, :NEW.ReleaseYear, :NEW.GenreID, :NEW.ArtistID);

INSERT INTO Artist_Album(Artist_AlbumID, StartTime, EndTime, Artist_ArtistID, Album_AlbumID)
VALUES(ARTIST_ALBUM_Sequence.NEXTVAL, SYSDATE, NULL, :NEW.Album_ArtistID, ALBUMS_Sequence.CURRVAL);
END IF;

IF INSERTING THEN
INSERT INTO Artists(ArtistID, ArtistName, Type)
VALUES(ARTISTS_Sequence.NEXTVAL, :NEW.ArtistName, :NEW.Type);

IF :NEW.Title IS NOT NULL AND :NEW.ReleaseYear IS NOT NULL AND :NEW.GenreID IS NOT NULL AND :NEW.Album_ArtistID IS NOT NULL THEN
INSERT INTO Albums(AlbumID, Title, ReleaseYear, GenreID, ArtistID)
VALUES(ALBUMS_Sequence.NEXTVAL, :NEW.Title, :NEW.ReleaseYear, :NEW.GenreID, :NEW.ArtistID);

INSERT INTO Artist_Album(Artist_AlbumID, StartTime, EndTime, Artist_ArtistID, Album_AlbumID)
VALUES(ARTIST_ALBUM_Sequence.NEXTVAL, SYSDATE, NULL, :NEW.Album_ArtistID, ALBUMS_Sequence.CURRVAL);

END IF;
END IF;
END;
/

-- Trigger for RECORDING_VIEW_TRIGGER
CREATE OR REPLACE TRIGGER RECORDING_VIEW_TRIGGER INSTEAD OF INSERT OR UPDATE ON RECORDING_VIEW FOR EACH ROW
BEGIN
IF UPDATING AND (:NEW.GenreName IS NOT NULL) THEN
UPDATE Recording_Genre SET EndTime = SYSDATE
WHERE Recordings_RecordingID = :NEW.RecordingID
AND EndTime IS NULL;

INSERT INTO Genres(GenreID, GenreName)
VALUES(GENRES_Sequence.NEXTVAL, :NEW.GenreName);

INSERT INTO Recording_Genre(Recording_GenreID, StartTime, EndTime, Recordings_RecordingID, Genre_GenreID)
VALUES(RECORDING_GENRE_Sequence.NEXTVAL, SYSDATE, NULL, :NEW.RecordingID, GENRES_Sequence.CURRVAL);
END IF;

IF INSERTING THEN
INSERT INTO Recordings(RecordingID, Title, Duration, AlbumID, ArtistID)
VALUES(RECORDINGS_Sequence.NEXTVAL, :NEW.Title, :NEW.Duration, :NEW.AlbumID, :NEW.ArtistID);

IF :NEW.GenreName IS NOT NULL THEN
INSERT INTO Genres(GenreID, GenreName)
VALUES(GENRES_Sequence.NEXTVAL, :NEW.GenreName);

INSERT INTO Recording_Genre(Recording_GenreID, StartTime, EndTime, Recordings_RecordingID, Genre_GenreID)
VALUES(RECORDING_GENRE_Sequence.NEXTVAL, SYSDATE, NULL, :NEW.RecordingID, GENRES_Sequence.CURRVAL);

END IF;
END IF;
END;
/

-- Trigger for ALBUM_VIEW_TRIGGER
CREATE OR REPLACE TRIGGER ALBUM_VIEW_TRIGGER INSTEAD OF INSERT OR UPDATE ON ALBUM_VIEW FOR EACH ROW
BEGIN
IF UPDATING AND (:NEW.Recording_Title IS NOT NULL OR :NEW.Duration IS NOT NULL OR :NEW.AlbumID IS NOT NULL OR :NEW.Recordings_ArtistID IS NOT NULL) THEN
UPDATE Album_Recordings SET EndTime = SYSDATE
WHERE Album_AlbumID = :NEW.AlbumID
AND EndTime IS NULL;

INSERT INTO Recordings(RecordingID, Title, Duration, AlbumID, ArtistID)
VALUES(RECORDINGS_Sequence.NEXTVAL, :NEW.Recording_Title, :NEW.Duration, :NEW.AlbumID, :NEW.Recordings_ArtistID);

INSERT INTO Album_Recordings(Album_RecordingsID, StartTime, EndTime, Album_AlbumID, Recordings_RecordingID)
VALUES(ALBUM_RECORDINGS_Sequence.NEXTVAL, SYSDATE, NULL, :NEW.AlbumID, RECORDINGS_Sequence.CURRVAL);
END IF;

IF INSERTING THEN
INSERT INTO Recordings(RecordingID, Title, Duration, AlbumID, ArtistID)
VALUES(RECORDINGS_Sequence.NEXTVAL, :NEW.Recording_Title, :NEW.Duration, :NEW.Recording_AlbumID, :NEW.Recordings_ArtistID );

IF :NEW.Recording_Title IS NOT NULL AND :NEW.Duration IS NOT NULL AND :NEW.AlbumID IS NOT NULL AND :NEW.Recordings_ArtistID IS NOT NULL THEN
INSERT INTO Recordings(RecordingID, Title, Duration, AlbumID, ArtistID)
VALUES(RECORDINGS_Sequence.NEXTVAL, :NEW.Recording_Title, :NEW.Duration, :NEW.AlbumID, :NEW.Recordings_ArtistID);

INSERT INTO Album_Recordings(Album_RecordingsID, StartTime, EndTime, Album_AlbumID, Recordings_RecordingID)
VALUES(ALBUM_RECORDINGS_Sequence.NEXTVAL, SYSDATE, NULL, :NEW.AlbumID, RECORDINGS_Sequence.CURRVAL);

END IF;
END IF;
END;
/

-- Trigger for ARTIST_VIEW_DELETE_TRIGGER
CREATE OR REPLACE TRIGGER ARTIST_VIEW_DELETE_TRIGGER INSTEAD OF DELETE ON ARTIST_VIEW FOR EACH ROW
BEGIN
DELETE FROM Artist_Album WHERE Artist_ArtistID = :OLD.ArtistID;
DELETE FROM Artists WHERE ArtistID = :OLD.ArtistID;
DELETE FROM Albums WHERE ArtistID = :OLD.ArtistID;
DELETE FROM Recordings WHERE ArtistID = :OLD.ArtistID;
END;
/

-- Trigger for RECORDING_VIEW_DELETE_TRIGGER
CREATE OR REPLACE TRIGGER RECORDING_VIEW_DELETE_TRIGGER INSTEAD OF DELETE ON RECORDING_VIEW FOR EACH ROW
BEGIN
DELETE FROM Recordings WHERE RecordingID = :OLD.RecordingID;
DELETE FROM Recording_Genre WHERE Recordings_RecordingID = :OLD.RecordingID;
DELETE FROM Album_Recordings WHERE Recordings_RecordingID = :OLD.RecordingID;
END;
/

-- Trigger for ALBUM_VIEW_DELETE_TRIGGER
CREATE OR REPLACE TRIGGER ALBUM_VIEW_DELETE_TRIGGER INSTEAD OF DELETE ON ALBUM_VIEW FOR EACH ROW
BEGIN
DELETE FROM Albums WHERE AlbumID = :OLD.AlbumID;
DELETE FROM Recordings WHERE AlbumID = :OLD.AlbumID;
DELETE FROM Artist_Album WHERE Album_AlbumID = :OLD.AlbumID;
DELETE FROM Album_Recordings WHERE Album_AlbumID = :OLD.AlbumID;
END;
/

-- End of File