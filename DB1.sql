--Роль пользователя
CREATE TABLE IF NOT EXISTS user_role(
  user_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
  role_code INT NOT NULL CHECK(role_code >= 0 and role_code <= 3),
  role_name VARCHAR(30) NOT NULL
);
TRUNCATE TABLE user_role RESTART IDENTITY;
--Пользователь
CREATE TABLE IF NOT EXISTS sys_user(
  user_id INTEGER PRIMARY KEY,
  login VARCHAR(80) NOT NULL UNIQUE,
  passwrd_hash VARCHAR(40) NOT NULL,
  caf_num INT NOT NULL CHECK(caf_num > 0),
  phone_num CHAR(11) NOT NULL,
  first_name VARCHAR(30) NOT NULL,
  second_name VARCHAR(30) NOT NULL,
  surname VARCHAR(30) NULL,
  FOREIGN KEY(user_id) REFERENCES user_role,
  CHECK(phone_num ~ '[0-9]{11}')
);
--Издательство
CREATE TABLE IF NOT EXISTS pub_house(
  pub_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
  pub_name VARCHAR(30) NOT NULL,
  city VARCHAR(20) NOT NULL,
  description VARCHAR(80) NULL
);
TRUNCATE TABLE pub_house RESTART IDENTITY;
--Автор
CREATE TABLE IF NOT EXISTS author(
  author_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
  second_name VARCHAR(30) NOT NULL,
  first_name VARCHAR(30) NOT NULL,
  surname VARCHAR(30) NULL,
  biography VARCHAR(80) NULL
);
TRUNCATE TABLE author RESTART IDENTITY;
--Отдел продаж
CREATE TABLE IF NOT EXISTS sales_department(
  department_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
  department_name VARCHAR(30) NOT NULL,
  address VARCHAR(40) NOT NULL,
  phone_num CHAR(11) NOT NULL,
  first_name VARCHAR(30) NOT NULL,
  second_name VARCHAR(30) NOT NULL,
  surname VARCHAR(30) NULL,
  CHECK(phone_num ~ '[0-9]{11}')
);
TRUNCATE TABLE sales_department RESTART IDENTITY;
--Кафедра
CREATE TABLE IF NOT EXISTS cafedra(
  caf_num INTEGER PRIMARY KEY CHECK(caf_num > 0),
  caf_name VARCHAR(30) NOT NULL UNIQUE,
  spec_num INTEGER NOT NULL CHECK(spec_num > 0),
  spec_name VARCHAR(30) NOT NULL
);
--Работник на кафедре
CREATE TABLE IF NOT EXISTS cafedra_worker(
  caf_num INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY(caf_num) REFERENCES cafedra,
  FOREIGN KEY(user_id) REFERENCES sys_user,
  PRIMARY KEY(caf_num, user_id)
);
CREATE TYPE ISBN AS(
  prefix INTEGER,
  reg_group_num INTEGER,
  reg_num INTEGER,
  pub_num INTEGER,
  control_num INTEGER
);
--Заявка
CREATE TABLE IF NOT EXISTS proposal(
  proposal_counter INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
  caf_num INTEGER NOT NULL,
  creating_date TIMESTAMP NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY(caf_num, user_id) REFERENCES cafedra_worker
);
TRUNCATE TABLE proposal RESTART IDENTITY;
--Заказ на приобретение лит-ры
CREATE TABLE IF NOT EXISTS lit_order(
  order_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
  creating_date TIMESTAMP NOT NULL,
  pay_date TIMESTAMP NOT NULL,
  user_id INTEGER NOT NULL,
  department_id INTEGER NOT NULL,
  CHECK(creating_date >= pay_date),
  FOREIGN KEY(user_id) REFERENCES sys_user,
  FOREIGN KEY(department_id) REFERENCES sales_department
);
TRUNCATE TABLE lit_order RESTART IDENTITY;
--Издание
CREATE TABLE IF NOT EXISTS publicat(
  isbn ISBN PRIMARY KEY,
  pub_id INTEGER NOT NULL,
  pub_name VARCHAR(80) NOT NULL,
  pub_year INTEGER NOT NULL CHECK(pub_year > 0),
  pages_num INTEGER NOT NULL CHECK(pages_num > 0),
  annotation VARCHAR(100) NULL,
  lib_count INTEGER NOT NULL CHECK(lib_count >= 0),
  CHECK((isbn).prefix >= 0),
  CHECK((isbn).reg_group_num >= 0),
  CHECK((isbn).reg_num >= 0),
  CHECK((isbn).pub_num >= 0),
  CHECK((isbn).control_num >= 0),
  FOREIGN KEY(pub_id) REFERENCES pub_house
);
--Акт списания
CREATE TABLE IF NOT EXISTS debit_act(
  act_counter INT GENERATED ALWAYS AS IDENTITY (START WITH 1),
  user_id INTEGER NOT NULL,
  cancel_date TIMESTAMP NOT NULL,
  creating_date TIMESTAMP NOT NULL,
  num INTEGER NOT NULL CHECK(num > 0),
  isbn ISBN NOT NULL,
  reason VARCHAR(100) NOT NULL,
  first_name VARCHAR(30) NOT NULL,
  second_name VARCHAR(30) NOT NULL,
  surname VARCHAR(30) NULL,
  role_code INTEGER NOT NULL CHECK(role_code >= 0 and role_code <= 4),
  CHECK((isbn).prefix >= 0),
  CHECK((isbn).reg_group_num >= 0),
  CHECK((isbn).reg_num >= 0),
  CHECK((isbn).pub_num >= 0),
  CHECK((isbn).control_num >= 0),
  CHECK(creating_date <= cancel_date),
  PRIMARY KEY(act_counter, user_id),
  FOREIGN KEY(user_id) REFERENCES sys_user,
  FOREIGN KEY(isbn) REFERENCES publicat
);
TRUNCATE TABLE debit_act RESTART IDENTITY;
--Автор в издании
CREATE TABLE IF NOT EXISTS author_in_publicat(
  isbn ISBN NOT NULL,
  author_id INTEGER NOT NULL,
  PRIMARY KEY(isbn,author_id),
  FOREIGN KEY(isbn) REFERENCES publicat,
  FOREIGN KEY(author_id) REFERENCES author
);
--Список изданий в продаже
CREATE TABLE IF NOT EXISTS pub_list_from_sales_dep(
	isbn ISBN NOT NULL,
	department_id INTEGER NOT NULL,
	price NUMERIC(3,2) NOT NULL CHECK(price > 0),
	PRIMARY KEY(isbn, department_id),
	FOREIGN KEY(isbn) REFERENCES publicat,
	FOREIGN KEY(department_id) REFERENCES sales_department
);
--Список изданий в заявке
CREATE TABLE IF NOT EXISTS pub_list_from_proposal(
    proposal_counter INTEGER NOT NULL,
	isbn ISBN NOT NULL,
	num INTEGER NOT NULL CHECK(num > 0),
	PRIMARY KEY(proposal_counter, isbn),
	FOREIGN KEY(proposal_counter) REFERENCES proposal,
	FOREIGN KEY(isbn) REFERENCES publicat
);

--Издания в заказе
CREATE TABLE IF NOT EXISTS pub_in_order_list(
    record_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
	order_id INTEGER NOT NULL,
	isbn ISBN NOT NULL,
	proposal_counter INTEGER NOT NULL,
	num INTEGER NOT NULL CHECK(num > 0),
	FOREIGN KEY(order_id) REFERENCES lit_order,
	FOREIGN KEY(proposal_counter, isbn) REFERENCES pub_list_from_proposal
);
TRUNCATE TABLE pub_in_order_list RESTART IDENTITY;
--Акт приёма
CREATE TABLE IF NOT EXISTS acceptance_act(
    act_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1) PRIMARY KEY,
	order_id INTEGER NOT NULL,
	receipt_date TIMESTAMP NOT NULL,
	user_id INTEGER NOT NULL,
	FOREIGN KEY(order_id) REFERENCES lit_order,
	FOREIGN KEY(user_id) REFERENCES sys_user
);
TRUNCATE TABLE acceptance_act RESTART IDENTITY;
--Список изданий на приём
CREATE TABLE IF NOT EXISTS pub_list_for_accept(
    act_id INT GENERATED ALWAYS AS IDENTITY  (START WITH 1) NOT NULL,
	isbn ISBN NOT NULL,
	num INTEGER NOT NULL CHECK(num > 0),
	PRIMARY KEY(act_id, isbn),
	FOREIGN KEY(act_id) REFERENCES acceptance_act,
	FOREIGN KEY(isbn) REFERENCES publicat
);
TRUNCATE TABLE pub_list_for_accept RESTART IDENTITY;