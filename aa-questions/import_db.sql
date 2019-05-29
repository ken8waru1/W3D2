PRAGMA foreign_keys = ON; 

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  body TEXT,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id), 
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes (
  -- id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions (id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Frankie','Siino'),
  ('Ken','Ha'),
  ('Ian','Ellison'),
  ('Phil','Krasnick');

INSERT INTO
  questions (title,body,user_id)
VALUES
  ('How do I close a browser window?',
    'I am working on a project and I have 100 windows open. My computer is starting to freeze. How do I close 99 of them?',(SELECT id FROM users WHERE fname = 'Ian' AND lname = 'Ellison'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  (1, 3);

INSERT INTO
  question_follows
  (question_id, user_id)
VALUES
  (1, 4);

INSERT INTO
  replies (question_id, body, parent_id, user_id)
VALUES
  (
    1, 
    'Hi, Ian, I suggest you google your problem. Have a great day.',
    NULL, 
    2
  );

INSERT INTO
  replies (question_id, body, parent_id, user_id)
VALUES
  (
    1,'Hi Ken. I suggest you stop being rude to Ian. Have a nice day.',
    1,
    1
  );

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (4, 1);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (3, 1);
