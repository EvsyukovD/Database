CREATE FUNCTION isbn_equals(isbn1 ISBN,isbn2 ISBN) RETURNS bool AS $$
DECLARE
BEGIN
    return (isbn1).prefix = (isbn2).prefix and 
	(isbn1).reg_group_num = (isbn2).reg_group_num and
	(isbn1).reg_num = (isbn2).reg_num and
	(isbn1).pub_num = (isbn2).pub_num and
	(isbn1).control_num = (isbn2).control_num;
END;
$$ LANGUAGE 'plpgsql';



--Процедура списания изданий старше некоторого года
CREATE PROCEDURE debit_publication(public_year int,worker_id int,operator_id int)
language plpgsql    
as $$
declare
    tmp RECORD;
	worker RECORD;
	_operator RECORD;
	_role int;
	operator_code int := 2;
	i RECORD;
begin
    select * into worker from sys_user where (sys_user).user_id = worker_id;
	
	if not found then
	   raise notice 'Worker with id % does not exists!', worker_id;
	   return;
	end if;
	
	select role_code into _role from user_role where (user_role).user_id = worker_id;
	select * into _operator from user_role where (user_role).user_id = operator_id;
	
	if not found or _operator.role_code != operator_code then
	   raise notice 'Operator with id % does not exists!', operator_id;
	   return;
	end if;
	for i in select * from publicat where publicat.pub_year < public_year 
	and  publicat.lib_count > 0
	and	publicat.isbn in (select isbn from pub_list_from_proposal)
	loop
	    raise notice 'Publication in proposal: %', i.pub_name;
	end loop;
	
	for tmp in select * from publicat where publicat.pub_year < public_year 
	and  publicat.lib_count > 0
	and	publicat.isbn not in (select isbn from pub_list_from_proposal)
    loop
	    insert into debit_act(user_id,cancel_date,creating_date,
					  num,isbn,reason,first_name,second_name,
					  surname,role_code)
		values (operator_id,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,
				tmp.lib_count,tmp.isbn,'Cancellation',
				worker.first_name,worker.second_name,worker.surname,_role);
		raise notice 'Cancelled: % with num %', tmp.pub_name,tmp.lib_count;
	end loop;
	
	
end;$$;
--Структура автора
CREATE TYPE author_struct AS(
  author_id integer,
  second_name varchar(30),
  first_name varchar(30),
  surname varchar(30),
  biography varchar(80)
);

--Структура издательства
CREATE TYPE pub_house_struct AS(
  pub_id INT,
  pub_name VARCHAR(30),
  city VARCHAR(20),
  description VARCHAR(80)
);
--Структура издания
CREATE TYPE publication_struct AS(
  isbn ISBN,
  pub_id INTEGER,
  pub_name VARCHAR(80),
  pub_year INTEGER,
  pages_num INTEGER,
  annotation VARCHAR,
  lib_count INTEGER
);
--Добавление издания
CREATE PROCEDURE add_publication(pub publication_struct, 
								 house pub_house_struct, 
								 authors author_struct[])
language plpgsql    
as $$
declare
   tmp RECORD;
   len int := array_length(authors,1);
   last_author_id int;
   last_publicat_id int:= (house).pub_id;
begin
   select * into tmp from publicat where isbn_equals(publicat.isbn,(pub).isbn);
   if found then
      update publicat set lib_count = (tmp.lib_count + 1) where isbn_equals(publicat.isbn,(pub).isbn);
	  raise notice 'Amount of publication (%,%) is %',(pub).isbn,(pub).pub_name,(tmp.lib_count + 1);
	  return;
   end if;
   select * into tmp from pub_house where pub_house.pub_id = (house).pub_id;
   if not found then
      insert into pub_house(pub_name,city,description)
	  values ((house).pub_name,(house).city,(house).description) returning pub_id into last_publicat_id;
   end if;
   
   insert into publicat(isbn, pub_id, pub_name, pub_year, pages_num, annotation, lib_count)
   values ((pub).isbn,last_publicat_id,(pub).pub_name, (pub).pub_year, (pub).pages_num, (pub).annotation,0);
   
   for i in 1..len loop
       select * into tmp from author where (author).author_id = (authors[i]).author_id;
	   if not found then
	      insert into author(second_name,first_name,surname)
		  values ((authors[i]).second_name, (authors[i]).first_name, (authors[i]).surname) 
		  returning author_id into last_author_id;
	   else
	       last_author_id = (authors[i]).author_id;
	   end if;
	   insert into author_in_publicat(isbn,author_id)
	   values ((pub).isbn,last_author_id);
   end loop;
   raise notice 'Add publication (%,%) with authors %',(pub).isbn,(pub).pub_name,authors[:];
end;$$;
--Обработка заявок
CREATE PROCEDURE process_proposal(dep_id int,user_id int)
language plpgsql    
as $$
declare
   last_order_id int;
   i RECORD;
   tmp RECORD;
begin
	 select p1.*
	 into tmp
	 from pub_list_from_proposal p1,pub_in_order_list
	 where exists(
			select p2.isbn from pub_list_from_proposal p2
			where p2.isbn in(
			      select isbn
				  from pub_list_from_sales_dep
				  where department_id = dep_id
			 ) 
			 and p2.proposal_counter = p1.proposal_counter
	 ) 
	 and p1.proposal_counter != pub_in_order_list.proposal_counter;
     if not found then
	    raise notice 'Respective proposals do not exists';
		return;
	 end if;
	insert into lit_order(creating_date, pay_date, user_id, department_id)
	values(CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,user_id,dep_id) 
	returning order_id into last_order_id;
    with 
	full_proposals as (
    	select proposal_counter 
		from pub_list_from_proposal p1
		where not exists(
			 select isbn from pub_list_from_proposal p2
			 where isbn not in(
			      select isbn
				  from pub_list_from_sales_dep
				  where department_id = dep_id
			 ) 
			 and p2.proposal_counter = p1.proposal_counter
		)
	), -- заявки, в которых все издания продаются в отделе с номером dep_id
	_open as (
	     select pub_list_from_proposal.proposal_counter 
		 from pub_list_from_proposal,pub_in_order_list
		 where pub_list_from_proposal.proposal_counter != pub_in_order_list.proposal_counter
	),--все необработанные заявки
	open_and_full as(
	    select proposal_counter 
		from _open
		where proposal_counter in (select * from full_proposals)
	),
	S as (
	  select * 
			  from  pub_list_from_proposal
			  where proposal_counter in (select proposal_counter from open_and_full)
	)
	insert into pub_in_order_list(order_id,isbn,proposal_counter,num)
	(select last_order_id, S.isbn,S.proposal_counter,S.num from S);
end;$$;