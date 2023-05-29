INSERT INTO author(second_name,first_name,surname)
VALUES
('Morgan','Nik',NULL), --1
('Pushkin','Alexander','Sergeevich'), --2
('Duma','Alexander',NULL), --3
('Second name 1','First name 1',NULL), --4
('Second name 2','First name 2',NULL), --5
('Second name 3','First name 3',NULL), --6
('Second name 4','First name 4',NULL); --7

INSERT INTO pub_house(pub_name,city,description)
VALUES
('Alpha','Moscow',NULL), --1
('Beta','St-Petersburg',NULL), --2
('1','St-Petersburg',NULL), --3
('2','St-Petersburg',NULL); --4
select * from pub_house;
INSERT INTO publicat(isbn,pub_id,pub_name,pub_year,pages_num,annotation,lib_count)
VALUES
(ROW(978,5,100,295,6),1,'JavaScript for kids',2006,290,NULL,10),
(ROW(978,5,100,575,454),2,'Captains daughter',2023,500,NULL,10),
(ROW(978,5,100,546,2382),2,'Graph Monte-Kristo',2023,1000,NULL,20),
(ROW(978,10,100,546,2382),2,'BOOK 1',2000,565,NULL,20),
(ROW(978,11,100,546,2382),2,'BOOK 2',2003,1000,NULL,20),
(ROW(978,12,100,546,2382),2,'BOOK 3',2003,1000,NULL,20),
(ROW(978,13,100,546,2382),2,'BOOK 4',2003,1000,NULL,20);

INSERT INTO author_in_publicat(isbn,author_id)
VALUES
(ROW(978,5,100,295,6),1),
(ROW(978,5,100,575,454),2),
(ROW(978,5,100,546,2382),3),
(ROW(978,10,100,546,2382),4),
(ROW(978,11,100,546,2382),5),
(ROW(978,12,100,546,2382),6),
(ROW(978,13,100,546,2382),7);

INSERT INTO user_role(role_code,role_name)
VALUES
(0,'worker'), --1
(1,'manager'), --2
(2,'operator'), --3
(3,'director'), --4
(0,'worker'), --5
(0,'worker'), --6
(0,'worker'), --7
(0,'worker'), --8 1
(0,'worker'), --9
(0,'worker'),--10
(0,'worker'),--11
(0,'worker');--12
INSERT INTO cafedra(caf_num,caf_name,spec_num,spec_name)
VALUES
(12,'CST',90301,'engineer'),
(41,'CSofCS',10001,'engineer'),
(42,'IS',10004,'engineer'),
(43,'Name 1',1,'spec_name 1'),
(44,'Name 2',2,'spec_name 2'),
(45,'Name 3',3,'spec_name 3'),
(46,'Name 4',4,'spec_name 4'),
(47,'Name 5',5,'spec_name 5');

INSERT INTO sys_user(user_id,login,passwrd_hash,caf_num,phone_num,first_name,second_name,surname)
VALUES
(1,'login1','hash1',12,'77777777777','Ivan','Ivanov','Ivanovich'),
(2,'login2','hash2',41,'85667756934','Alex','Alexov','Alexandrovich'),
(3,'login3','hash3',42,'85567756934','Felix','Felixov',NULL),
(4,'login4','hash4',12,'85667677934','Dmitry','Dmitriev','Dmitrievich'),
(5,'login5','hash5',12,'85623678934','Dmitry','Dmitriev','Dmitrievich'),
(6,'login6','hash6',41,'85667689934','Sergei','Sergeev','Sergeevich'),
(7,'login7','hash7',42,'83467677934','John','Doe',NULL),
(8,'login8','hash8',43,'83478677934','Name 8','Sec name 8',NULL),
(9,'login9','hash9',44,'83478645934','Name 9','Sec name 9',NULL),
(10,'login10','hash10',45,'83478645734','Name 10','Sec name 10',NULL),
(11,'login11','hash11',46,'84578645734','Name 11','Sec name 11',NULL),
(12,'login12','hash12',47,'85678645734','Name 12','Sec name 12',NULL);
INSERT INTO cafedra_worker(caf_num,user_id)
VALUES
(12,1),
(41,2),
(42,3),
(12,4),
(12,5),
(41,6),
(42,7),
(43,8),
(44,9),
(45,10),
(46,11),
(47,12);
INSERT INTO debit_act(user_id,cancel_date,creating_date,
					  num,isbn,reason,first_name,second_name,
					  surname,role_code)
VALUES
(3,('2023-01-01 15:20:00'),('2023-01-01 15:20:00'),1,ROW(978,5,100,295,6),'Lost','Felix','Felixov',NULL,3),
(3,('2023-01-01 15:20:00'),('2023-01-01 15:20:00'),1,ROW(978,5,100,295,6),'Lost','Felix','Felixov',NULL,3),
(3,('2023-01-01 15:20:00'),('2023-01-01 15:20:00'),1,ROW(978,5,100,295,6),'Lost','Felix','Felixov',NULL,3),
(3,('2023-01-01 15:20:00'),('2023-01-01 15:20:00'),20,ROW(978,5,100,295,6),'Lost','Felix','Felixov',NULL,3);

INSERT INTO sales_department(department_name,address,phone_num,first_name,second_name,surname)
VALUES
('Sales department 1','Address 1','12345678912','John','Doe',NULL), --1
('Sales department 2','Address 2','12253678912','Elon','Mask',NULL), --2
('Sales department 3','Address 3','12254678912','Bill','Gates',NULL), --3
('Sales department 4','Address 4','12254674912','Name 1','Sec name 2',NULL), --4
('Sales department 5','Address 5','13254678912','Name 2','Sec name 2',NULL), --5
('Sales department 6','Address 6','12254674512','Name 3','Sec name 3',NULL); --6

INSERT INTO pub_list_from_sales_dep(isbn,department_id,price)
VALUES
(ROW(978,5,100,546,2382),1,5),
(ROW(978,5,100,295,6),1,5),
(ROW(978,5,100,575,454),1,5),
(ROW(978,10,100,546,2382),3,5),
(ROW(978,11,100,546,2382),3,5),
(ROW(978,12,100,546,2382),3,5),
(ROW(978,13,100,546,2382),3,5),
(ROW(978,13,100,546,2382),4,5),
(ROW(978,5,100,575,454),4,5),
(ROW(978,13,100,546,2382),5,5),
(ROW(978,5,100,575,454),5,5),
(ROW(978,13,100,546,2382),6,5),
(ROW(978,5,100,575,454),6,5);

INSERT INTO proposal(caf_num,creating_date,user_id)
VALUES
(12,('2023-01-01 15:20:00'),1), --1
(12,('2023-02-01 15:20:00'),1), --2
(12,('2023-03-01 15:20:00'),1), --3
(41,('2023-04-01 15:20:00'),6), --4
(41,('2023-05-01 15:20:00'),6), --5
(41,('2023-05-01 15:20:00'),6), --6
(42,('2023-05-01 15:20:00'),7), --7
(42,('2023-05-01 15:20:00'),7); --8

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES
(1,ROW(978,5,100,546,2382),100),
(2,ROW(978,5,100,546,2382),100),
(2,ROW(978,10,100,546,2382),100),
(2,ROW(978,11,100,546,2382),100),
(3,ROW(978,10,100,546,2382),100),
(3,ROW(978,11,100,546,2382),100),
(3,ROW(978,12,100,546,2382),100),
(3,ROW(978,13,100,546,2382),100);

call process_proposal(3,2);
call process_proposal(1,2);

 INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES
 (5,ROW(978,5,100,546,2382),100),
 (5,ROW(978,5,100,295,6),100),
 (5,ROW(978,5,100,575,454),100),
 (5,ROW(978,10,100,546,2382),100),
 (5,ROW(978,11,100,546,2382),100),
 (5,ROW(978,12,100,546,2382),100),
 (5,ROW(978,13,100,546,2382),100),
 
 (6,ROW(978,5,100,546,2382),100),
 (6,ROW(978,5,100,295,6),100),
 (6,ROW(978,5,100,575,454),100),
 
 (7,ROW(978,10,100,546,2382),100),
 (7,ROW(978,11,100,546,2382),100),
 (7,ROW(978,12,100,546,2382),100),
 (7,ROW(978,13,100,546,2382),100),

 (8,ROW(978,5,100,546,2382),100),
 (8,ROW(978,5,100,295,6),100),
 (8,ROW(978,5,100,575,454),100),
 (8,ROW(978,10,100,546,2382),100),
 (8,ROW(978,11,100,546,2382),100),
 (8,ROW(978,12,100,546,2382),100),
 (8,ROW(978,13,100,546,2382),100);

call process_proposal(3,2);
call process_proposal(1,2);

INSERT INTO proposal(caf_num,creating_date,user_id)
VALUES
(12,('2023-05-14 15:20:00'),1); --9

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES
 (9,ROW(978,10,100,546,2382),100),
 (9,ROW(978,11,100,546,2382),100),
 (9,ROW(978,12,100,546,2382),100),
 (9,ROW(978,13,100,546,2382),100);

call process_proposal(3,2);

INSERT INTO proposal(caf_num,creating_date,user_id)
VALUES
(12,('2022-05-14 15:20:00'),1), --10
(41,('2022-05-14 15:20:00'),6), --11
(42,('2022-05-14 15:20:00'),7); --12


INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES
 (10,ROW(978,10,100,546,2382),100),
 (10,ROW(978,11,100,546,2382),100),
 (10,ROW(978,12,100,546,2382),100),
 (10,ROW(978,13,100,546,2382),100),
 
 (11,ROW(978,5,100,546,2382),100),
 (11,ROW(978,5,100,295,6),100),
 (11,ROW(978,5,100,575,454),100);

 
INSERT INTO pub_list_from_sales_dep(isbn,department_id,price)
VALUES
(ROW(978,5,100,546,2382),2,5),
(ROW(978,5,100,295,6),2,5),
(ROW(978,5,100,575,454),2,5);
 
INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (12,ROW(978,5,100,546,2382),100),
 (12,ROW(978,5,100,295,6),100),
 (12,ROW(978,5,100,575,454),100);
 
 call process_proposal(2,2);
 
INSERT INTO acceptance_act(order_id,receipt_date,user_id)
VALUES 
 (1,('2023-09-10 15:20:00'),3), --1
 (2,('2023-09-10 15:20:00'),3), --2
 (3,('2023-09-10 15:20:00'),3), --3
 (4,('2023-09-10 15:20:00'),3), --4
 (5,('2023-09-10 15:20:00'),3), --5
 (6,('2023-09-10 15:20:00'),3); --6
select * from acceptance_act;
select * from pub_list_for_accept;
INSERT INTO pub_list_for_accept(act_id,isbn,num)
(select distinct act.order_id, pub.isbn, (select sum(p1.num) from pub_in_order_list p1 where isbn_equals(p1.isbn,pub.isbn) and pub.order_id = p1.order_id)
from acceptance_act act,pub_in_order_list pub
     where act.order_id = pub.order_id
order by act.order_id);
select * from pub_in_order_list;
INSERT INTO proposal(caf_num,creating_date,user_id)
VALUES
(41,('2023-10-14 15:20:00'),6); --13

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (13,ROW(978,5,100,546,2382),100),
 (13,ROW(978,5,100,295,6),100),
 (13,ROW(978,5,100,575,454),100);

call process_proposal_2(1,2,('2023-10-14 15:20:00'),('2023-10-14 15:20:00'));

INSERT INTO acceptance_act(order_id,receipt_date,user_id)
VALUES 
 (7,('2023-10-14 15:20:00'),3); --7

INSERT INTO pub_list_for_accept(act_id,isbn,num)
(select act.act_id, pub.isbn,pub.num
from acceptance_act act,pub_in_order_list pub
where act.order_id = 7 and pub.order_id = act.order_id
group by act.act_id,pub.isbn,pub.num);

INSERT INTO author_in_publicat(isbn,author_id)
VALUES
(ROW(978,5,100,295,6),2),
(ROW(978,5,100,295,6),3);

INSERT INTO author_in_publicat(isbn,author_id)
VALUES
(ROW(978,5,100,575,454),1);
-----------------------------------------------------------------------New data
INSERT INTO proposal(caf_num,creating_date,user_id)
VALUES
(43,('2023-10-15 15:20:00'),8), --14
(43,('2023-10-15 15:30:00'),8), --15
(44,('2023-10-15 15:20:00'),9), --16
(44,('2023-10-16 15:20:00'),9), --17
(45,('2023-10-15 15:20:00'),10), --18
(46,('2023-10-15 15:20:00'),11), --19
(46,('2023-11-15 15:20:00'),11), --20
(47,('2023-11-15 15:20:00'),12); --21

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (14,ROW(978,13,100,546,2382),1000),
 (14,ROW(978,5,100,575,454),1000);
 
call process_proposal_2(4,2,('2023-10-16 15:20:00'),('2023-10-16 15:20:00'));

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (15,ROW(978,13,100,546,2382),1000),
 (15,ROW(978,5,100,575,454),1000);
 
call process_proposal_2(5,2,('2023-10-16 15:20:00'),('2023-10-16 15:20:00'));

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (16,ROW(978,13,100,546,2382),1000),
 (16,ROW(978,5,100,575,454),1000);
 
call process_proposal_2(6,2,('2023-10-16 15:20:00'),('2023-10-16 15:20:00'));

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (17,ROW(978,13,100,546,2382),1000),
 (17,ROW(978,5,100,575,454),1000);
 
call process_proposal_2(4,2,('2023-10-16 15:20:00'),('2023-10-16 15:20:00'));

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (18,ROW(978,13,100,546,2382),1000),
 (19,ROW(978,5,100,575,454),1000);

call process_proposal_2(5,2,('2023-10-16 15:20:00'),('2023-10-16 15:20:00'));

INSERT INTO pub_list_from_proposal(proposal_counter,isbn,num)
VALUES 
 (20,ROW(978,13,100,546,2382),1000),
 (21,ROW(978,5,100,575,454),1000);
 
call process_proposal_2(5,2,('2023-11-30 15:20:00'),('2023-11-30 15:20:00'));
 