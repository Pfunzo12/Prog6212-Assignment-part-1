CREATE DATABASE  RaceDayDB;
USE RaceDayDB;

CREATE TABLE Users (
                   user_id   INT IDENTITY PRIMARY KEY,
                   full_name VARCHAR(100) NOT NULL, 
                   email VARCHAR(255) NOT NULL,
                   password_hash VARCHAR(255) NOT NULL,
                   role VARCHAR(20) NOT NULL DEFAULT 'participant',
                   phone VARCHAR(20) NULL,
                   created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
               CONSTRAINT UQ_Users_Email UNIQUE (email),
               CONSTRAINT CK_Users_Role CHECK (role IN
               ('organiser', 'participant')));
CREATE TABLE Events ( 
                    event_id INT IDENTITY PRIMARY KEY, 
                    organiser_id INT NOT NULL, 
                    name VARCHAR(150) NOT NULL,
                    description TEXT NULL,
                    event_date DATE NOT NULL, 
                    location VARCHAR(150) NOT NULL,
                    event_type VARCHAR(20) NOT NULL,
                    status VARCHAR(20) NOT NULL DEFAULT 'upcoming',
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
              CONSTRAINT FK_Events_Organiser FOREIGN KEY (organiser_id) REFERENCES Users (user_id),
              CONSTRAINT CK_Events_Type CHECK (event_type IN ('running', 'walking', 'cycling')),
              CONSTRAINT CK_Events_Status CHECK (status IN ('upcoming', 'completed', 'cancelled')) );

CREATE TABLE Categories ( 
                        category_id INT IDENTITY PRIMARY KEY,
                        event_id INT NOT NULL, name VARCHAR(50) NOT NULL,
                        distance_km DECIMAL(5,2) NOT NULL,
                        price DECIMAL(8,2) NOT NULL DEFAULT 0,
                        max_participants INT NOT NULL DEFAULT 0,
              CONSTRAINT FK_Categories_Event FOREIGN KEY (event_id) REFERENCES Events (event_id),
              CONSTRAINT UQ_Categories_EventName UNIQUE (event_id, name), 
              CONSTRAINT CK_Categories_Distance CHECK (distance_km > 0),
              CONSTRAINT CK_Categories_MaxParticipants CHECK (max_participants >= 0) );

CREATE TABLE Entries (
                     entry_id INT IDENTITY PRIMARY KEY,
                     category_id INT NOT NULL,
                     participant_id INT NOT NULL, 
                     bib_number VARCHAR(10) NULL,
                     entry_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                     status VARCHAR(20) NOT NULL DEFAULT 'pending',
             CONSTRAINT FK_Entries_Category FOREIGN KEY (category_id) REFERENCES Categories (category_id),
             CONSTRAINT FK_Entries_Participant FOREIGN KEY (participant_id) REFERENCES Users (user_id),
             CONSTRAINT UQ_Entries_CategoryParticipant UNIQUE (category_id, participant_id), 
             CONSTRAINT CK_Entries_Status CHECK (status IN ('pending', 'confirmed', 'cancelled')) );

CREATE TABLE Results ( 
                     result_id INT IDENTITY PRIMARY KEY,
                     entry_id INT NOT NULL, 
                     finish_time TIME NULL, 
                     position_overall INT NULL,
                     position_category INT NULL,
                     pace_per_km TIME NULL,
                     recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
             CONSTRAINT FK_Results_Entry FOREIGN KEY (entry_id) REFERENCES Entries (entry_id),
             CONSTRAINT UQ_Results_Entry UNIQUE (entry_id) ) ;

CREATE TABLE Weather_Forecasts (
                               weather_id INT IDENTITY PRIMARY KEY,
                               event_id INT NOT NULL, 
                               forecast_datetime DATETIME NOT NULL,
                               temperature_c DECIMAL(4,1) NULL, 
                               condition_text VARCHAR(50) NULL,
                               wind_speed_kmh DECIMAL(5,1) NULL,
                               humidity_pct INT NULL,
              CONSTRAINT FK_Weather_Event FOREIGN KEY (event_id) REFERENCES Events (event_id),
              CONSTRAINT CK_Weather_Humidity CHECK (humidity_pct IS NULL OR humidity_pct BETWEEN 0 AND 100) );

INSERT INTO Users (
                  full_name, email, password_hash, role, phone) 
                  VALUES ('Thandiwe Nkosi',  'thandiwe.nkosi@raceday.co.za', 'hashed_pw_001', 'organiser', '0721234567'),
                  ('Pieter van Wyk','pieter.vanwyk@raceday.co.za', 'hashed_pw_002','organiser', '0839876543'),
                  ('Lindiwe Dube', 'lindiwe.dube@example.com', 'hashed_pw_003','participant', '0731122334'),
                  ('Sipho Mahlangu', 'sipho.mahlangu@example.com', 'hashed_pw_004', 'participant', '0665544332');

INSERT INTO Events (
                   organiser_id, name, description, event_date, location, event_type, status) 
                   VALUES (1, 'Comrades Marathon', 'Iconic ultramarathon between Pietermaritzburg and Durban.', '2027-06-13', 'Pietermaritzburg, KZN', 'running', 'upcoming'),
                   (1, 'Soweto Marathon', 'Community road race through the streets of Soweto.', '2027-02-14', 'Soweto, Gauteng', 'running', 'upcoming'), 
                   (2, 'Cape Town Cycle Tour', 'One of the worlds largest timed cycling events.', '2027-03-08', 'Cape Town, Western Cape','cycling', 'upcoming');

INSERT INTO Categories (
                       event_id, name, distance_km, price, max_participants)
                       VALUES (1, '90km Ultra', 90.00, 950.00, 20000), 
                       (1, 'Novice 56km', 56.00, 950.00, 5000),
                       (2, '10km', 10.00, 180.00, 3000), 
                       (2, '21km', 21.10, 250.00, 3000),
                       (3, '109km Full Tour', 109.00, 650.00, 35000),
                       (3, '56km Half Tour', 56.00, 450.00, 10000);

INSERT INTO Weather_Forecasts (
                              event_id, forecast_datetime, temperature_c, condition_text, wind_speed_kmh, humidity_pct)
                              VALUES (1, '2027-06-13 05:30:00', 9.5, 'Clear', 10.0, 55),
                              (3, '2027-03-08 06:00:00', 18.0, 'Partly cloudy', 22.5, 68);

INSERT INTO Entries (
                    category_id, participant_id, bib_number, status)
                    VALUES (1, 3, '10045', 'confirmed'); -- Lindiwe entered Comrades 90km Ultra (3, 3, '20871', 'confirmed'); -- Lindiwe also entered Soweto 10km (4, 4, '20872', 'pending'), -- Sipho entered Soweto 21km (5, 4, '30456', 'confirmed'); -- Sipho entered Cape Town Cycle Tour 109km

INSERT INTO Results (
                    entry_id, finish_time, position_overall, position_category, pace_per_km)
                    VALUES (2, '00:48:32', 154, 12, '00:04:51'); -- Lindiwe's Soweto 10km result (4, '02:52:10', 890, 340, '00:04:53'); -- Sipho's Cape Town Cycle Tour

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Entries;
SELECT * FROM Results;
SELECT * FROM Weather_Forecasts;
