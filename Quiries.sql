--Запрос 1
/*
1.	Получить отчет о состоянии библиотечного фонда за последний год. Каждая строка результата содержит: 
Информация об издании (автор, название, издательство, …); 
текущее количество в библиотеке; 
количество кафедр, заказывавших данное издание;  //join
суммарное количество заказанных изданий; //join
количество поставок данного издания; //
суммарное количество поставленных изданий; // один with
суммарное количество списанных изданий.// второй with/подзарос
*/
with 
pubs as (
   select pub.*,a_in_pub.author_id from publicat pub join author_in_publicat a_in_pub on isbn_equals(pub.isbn,a_in_pub.isbn)
),
proposals1 as (
    select p1.*,list1.isbn from pub_list_from_proposal list1 join proposal p1 on list1.proposal_counter = p1.proposal_counter and
	           		(select extract (year from p1.creating_date)) = (select extract(year from current_timestamp))
	                      												
),
order_list2 as(
    select list2.* from pub_in_order_list list2 join lit_order ord on list2.order_id = ord.order_id and 
	                       (select extract (year from ord.creating_date)) = (select extract(year from current_timestamp))
),
accept_act11 as (
  select act1.*,list3.isbn,list3.num from pub_list_for_accept list3 join acceptance_act act1 on list3.act_id = act1.act_id and 
                                 (select extract (year from act1.receipt_date)) = (select extract(year from current_timestamp))
),
debit_act22 as (
  select * from debit_act act2 where
		                  (select extract (year from act2.cancel_date)) = (select extract(year from current_timestamp))
),
pubs_props(isbn,val) as(
   select pubs.isbn,coalesce(count(distinct p1.caf_num),0) 
     from pubs left join proposals1 p1 on isbn_equals(p1.isbn,pubs.isbn)
     group by pubs.isbn, pubs.author_id
),
pubs_order_list2(isbn,val) as(
  select pubs.isbn,coalesce(sum(list2.num),0)
	from pubs left join order_list2 list2 on isbn_equals(list2.isbn,pubs.isbn)
	group by pubs.isbn, pubs.author_id
	
),
pubs_accept_act11(isbn,val) as(
  select pubs.isbn,coalesce(count(distinct act1.act_id),0)
	from pubs left join accept_act11 act1 on isbn_equals(act1.isbn,pubs.isbn)
	group by pubs.isbn, pubs.author_id
),
pubs_accept_act11_2(isbn,val) as(
  select pubs.isbn,coalesce(sum(act1.num),0)
	from pubs left join accept_act11 act1 on isbn_equals(act1.isbn,pubs.isbn)
	group by pubs.isbn, pubs.author_id
),
pubs_debit_act22(isbn,val) as(
  select pubs.isbn,coalesce(sum(act2.num),0)
	from pubs left join debit_act22 act2 on isbn_equals(act2.isbn,pubs.isbn)
	group by pubs.isbn, pubs.author_id
)
select distinct pubs.*,
       p1.val "Количество кафедр",
	   list2.val "Количество заказанных изданий",
	   act1.val "Количество поставок",
	   act1_2.val  "Суммарное кол-во пост. изданий",
	   act2.val "Суммарное кол-во списанных изданий"
from pubs
     join pubs_props p1 on isbn_equals(pubs.isbn,p1.isbn)
	 join pubs_order_list2 list2 on isbn_equals(pubs.isbn,list2.isbn)
	 join pubs_accept_act11 act1 on isbn_equals(pubs.isbn,act1.isbn)
	 join pubs_accept_act11_2 act1_2 on isbn_equals(pubs.isbn,act1_2.isbn)
	 join pubs_debit_act22 act2 on isbn_equals(pubs.isbn,act2.isbn);

select * from pub_in_order_list;
select * from pub_list_for_accept;
--Запрос 2
/*
2.	Получить информацию об отделах продаж, 
количество оформленных заказов в которые превышает среднее количество заказов по всем отделам продаж. 
Отчет представить в виде:
Информация об отделе продаж; 
общее количество оформленных заказов; 
среднее количество оформленных заказов по всем отделам продаж; 
превышение среднего значения в процентах.
*/
  with 
    average(val) as(
	   select count(order_id) / count(distinct department_id) from lit_order
  ),
  orders(department_id,val) as(
   select dep.department_id,coalesce(count(distinct ord.order_id),0)
	  from sales_department dep left join lit_order ord on ord.department_id = dep.department_id
	  group by dep.department_id
  ),
  delta(avg_val,department_id,val) as (
   select average.val,dep.department_id, (coalesce(count(order_id),0) - average.val) * 100 / average.val 
	  from sales_department dep left join lit_order ord on ord.department_id = dep.department_id,
	  (select count(order_id) / count(distinct department_id) from lit_order) as average(val)
	  group by dep.department_id,average.val
  )
  select dep.*,
         ord.val "Общее количество заказов",
		 d.avg_val "Среднее количество заказов",
		 d.val "Превышение %"
   from sales_department dep
     join orders ord on ord.department_id = dep.department_id
	 join delta d on d.department_id = dep.department_id
	 ;
 
select * from lit_order;

--Запрос 3
/*
3.	Получить статистику о работе отдела в зависимости от месяца 2022 года. Результаты вывести в виде:
Название месяца, 
количество полученных изданий в этом месяце, 
количество заказанных, 
число заказов кафедр, 
количество кафедр, которые делали заказ,
количество списанных изданий. 
Если в месяце каких-то данных не было – вывести 0.
*/
select act.*, l.* from acceptance_act act join pub_list_for_accept l on act.act_id = l.act_id;
/*with months(i,_name) as (
    select unnest(array[1,2,3,4,5,6,7,8,9,10,11,12]),
	       unnest(array['Январь','Февраль','Март','Апрель',
						'Май','Июнь','Июль','Август','Сентябрь',
						'Октябрь','Ноябрь','Декабрь'])
)
select months._name "Месяц",
       (select coalesce(sum(p1.num),0) from pub_list_for_accept p1, acceptance_act act
		where (select extract (month from act.receipt_date)) = months.i and
	    (select extract (year from act.receipt_date)) = 2023 and
	    act.act_id = p1.act_id) "Число поступивших изд",--with/подзапрос
	   (select coalesce(sum(p1.num),0) 
		from pub_in_order_list p1, lit_order ord1
		where p1.order_id = ord1.order_id and
		      (select extract (month from ord1.creating_date)) = months.i and
	          (select extract (year from ord1.creating_date)) = 2023) "Заказанные издания",--join
	    (select coalesce(count(order_id),0) 
		 from lit_order 
		 where (select extract (month from creating_date)) = months.i and
		        (select extract (year from creating_date)) = 2023) "Число заказов",--join
		(select coalesce(count(distinct p1.caf_num),0) 
		 from proposal p1, pub_in_order_list p2, lit_order l1
		 where p1.proposal_counter = p2.proposal_counter and
		       l1.order_id = p2.order_id and 
		       (select extract (month from l1.creating_date)) = months.i and
		       (select extract (year from l1.creating_date)) = 2023) "Число кафедр",--join
	     (select coalesce(sum(act1.num),0) 
		  from debit_act act1
		  where (select extract (month from act1.cancel_date)) = months.i and
		         (select extract (year from act1.cancel_date)) = 2023) "Число списанных изданий"
from months;*/


------------------------С join -----------------------------
with months(i,_name) as (
    select unnest(array[1,2,3,4,5,6,7,8,9,10,11,12]),
	       unnest(array['Январь','Февраль','Март','Апрель',
						'Май','Июнь','Июль','Август','Сентябрь',
						'Октябрь','Ноябрь','Декабрь'])
),
acceptance(act_id,receipt_date,isbn,num) as (
    select act.act_id,act.receipt_date, p1.isbn, p1.num 
	from pub_list_for_accept p1 join acceptance_act act on p1.act_id = act.act_id
),
isbn_num_months(i,val) as(
   select months.i, coalesce(sum(act.num),0)
   from  months left join acceptance act on (select extract (month from act.receipt_date)) = months.i
   and (select extract (year from act.receipt_date)) = 2023
   group by months.i
), --число поступивших изданий
orders(order_id,creating_date,isbn,num) as(
   select ord1.order_id, ord1.creating_date,p1.isbn,p1.num
	from pub_in_order_list p1 join lit_order ord1 on p1.order_id = ord1.order_id
),
isbn_orders_months_nums(i,val) as(
  select months.i,coalesce(sum(ord.num),0) 
		from months left join orders ord on (select extract (month from ord.creating_date)) = months.i
		and (select extract (year from ord.creating_date)) = 2023
	    group by months.i
),
isbn_orders_months_count(i,val) as(
  select months.i,coalesce(count(ord.order_id),0) 
		from months left join lit_order ord on (select extract (month from ord.creating_date)) = months.i
		and (select extract (year from ord.creating_date)) = 2023
	    group by months.i
),
cafedra_orders_and_props(caf_num,creating_date) as (
  select p1.caf_num,l1.creating_date
	from proposal p1 join pub_in_order_list p2 on p1.proposal_counter = p2.proposal_counter 
	join lit_order l1 on l1.order_id = p2.order_id
),
cafedra_orders_and_props_months(i,val) as (
   select months.i,coalesce(count(distinct cafs.caf_num),0)
   from months left join cafedra_orders_and_props cafs on (select extract (month from cafs.creating_date)) = months.i
   and (select extract (year from cafs.creating_date)) = 2023
   group by months.i
),
debit_isbns(i,val) as(
   select months.i,coalesce(sum(act1.num),0) 
		  from months left join debit_act act1 on (select extract (month from act1.cancel_date)) = months.i and
	                                                (select extract (year from act1.cancel_date)) = 2023
		  group by months.i
)
select
  months._name "Месяц",
  isbn_num_months.val "Кол-во изд. в месяце",
  isbn_orders_months_nums.val "Кол-во заказанных изд.",
  isbn_orders_months_count.val "Кол-во заказов",
  cafedra_orders_and_props_months.val "Кол-во кафедр",
  debit_isbns.val "Кол-во списанных изд."
 from months join isbn_num_months on isbn_num_months.i = months.i
 join isbn_orders_months_nums on isbn_orders_months_nums.i = months.i
 join isbn_orders_months_count on isbn_orders_months_count.i = months.i
 join cafedra_orders_and_props_months on cafedra_orders_and_props_months.i = months.i
 join debit_isbns on debit_isbns.i = months.i;

select * from pub_list_for_accept;
--Запрос 4
/*
4.	Получить информацию о соавторстве авторов. 
Результат имеет N строк и N+1 столбец, где один столбец – имя автора, 
а остальные содержат в себе число, сколько раз автор из строки был в соавторстве с автором из столбца. 
Для вывода в таком виде гуглить “sql transpose table”, “sql crosstab”, “sql piv-ot”.
*/
--Зачли
create extension tablefunc;
select * from crosstab(
   $$select (a1.second_name || ' ' || a1.first_name || ' ' || coalesce(a1.surname,'')) as name1,
	        (a2.second_name || ' ' || a2.first_name || ' ' || coalesce(a2.surname,'')) as name2,
	       (select coalesce(count(distinct a3.isbn),0) from author_in_publicat a3 
			where row(a3.isbn,a1.author_id) in (select * from author_in_publicat) and
		          row(a3.isbn,a2.author_id) in (select * from author_in_publicat)) as name3
   from author a1,author a2
   where (a1.author_id != a2.author_id);$$
) as ct(
 _name text,
"Morgan Nik" bigint, --1
"Pushkin Alexander Sergeevich" bigint, --2
"Duma Alexander" bigint, --3
"Second name 1 First name 1" bigint, --4
"Second name 2 First name 2" bigint, --5
"Second name 3 First name 3" bigint, --6
"Second name 4 First name 4" bigint
);
select * from publicat;
select a1.*, a2.* from author a1, author_in_publicat a2;
--Запрос 5
/*
5.	Получить статистику по запросам кафедр за некоторый период. Отчет представить в виде:
Номер, 
название, 
специальность кафедры, 
номер и дата первой заявки за заданный период, 
номер и дата последней заявки за заданный период, 
число разных изданий во всех заявках кафедры, 
общее количество изданий во всех заявках за период, 
максимальное и минимальное количество изданий в заявке за период, 
среднее количество изданий в заявке.
*/
explain analyze select caf.caf_num,
       caf.caf_name,
	   caf.spec_name,
	   (select row(p1.proposal_counter,p1.creating_date) from proposal p1 
	    group by p1.proposal_counter
	    having p1.creating_date = (select min(p2.creating_date) from proposal p2 
		                           where p2.caf_num = caf.caf_num and
	                                     p2.creating_date > timestamp'2023-01-01' and 
								         p2.creating_date < timestamp'2023-12-12') limit 1) "Первая заявка(номер,дата)",-- объединить с последней , distinct on/join
	    (select row(p1.proposal_counter,p1.creating_date) from proposal p1 
	    group by p1.proposal_counter
	    having p1.creating_date = (select max(p2.creating_date) from proposal p2 
		                           where p2.caf_num = caf.caf_num and
	                                     p2.creating_date > timestamp'2023-01-01' and 
								         p2.creating_date < timestamp'2023-12-12') limit 1) "Последняя заявка(номер,дата)",--
	   (select count(distinct p2.isbn) from proposal p1, pub_list_from_proposal p2
		where p1.caf_num = caf.caf_num and
		      p1.proposal_counter = p2.proposal_counter  and
	          p1.creating_date > timestamp'2023-01-01' and p1.creating_date < timestamp'2023-12-12') "Число разных изд",
       (select coalesce(sum(p2.num),0) from proposal p1, pub_list_from_proposal p2
		where p1.caf_num = caf.caf_num and
		      p1.proposal_counter = p2.proposal_counter and
	          p1.creating_date > timestamp'2023-01-01' and p1.creating_date < timestamp'2023-12-12') "Общее количество изд",
	   (select coalesce(max(p2.num),0) from proposal p1, pub_list_from_proposal p2
	   where p1.proposal_counter = p2.proposal_counter and
		     p1.caf_num = caf.caf_num and
	         p1.creating_date > timestamp'2023-01-01' and p1.creating_date < timestamp'2023-12-12') "Макс. число изд",
		(select coalesce(min(p2.num),0) from proposal p1, pub_list_from_proposal p2
	   where p1.proposal_counter = p2.proposal_counter and
		     p1.caf_num = caf.caf_num and
	         p1.creating_date > timestamp'2023-01-01' and p1.creating_date < timestamp'2023-12-12') "Мин. число изд", 
	   (select count(p2.isbn)/count(distinct p1.proposal_counter) from proposal p1,pub_list_from_proposal p2
	   where p1.proposal_counter = p2.proposal_counter and 
	         p1.caf_num = caf.caf_num and
	         p1.creating_date > timestamp'2023-01-01' and p1.creating_date < timestamp'2023-12-12') "Среднее число изд"
from cafedra caf;
--уменьшить число подзапросов
--сделать 5 через join(как план запроса, сделать 2 версию)
--Запорлнить бд

------------------------С join -----------------------------
select * from proposal;
explain analyze with
   min_date_prop(caf_num,val) as(
      select caf.caf_num,min(p2.creating_date) 
	   from cafedra caf left join proposal p2 on p2.caf_num = caf.caf_num
	   and p2.creating_date > timestamp'2023-01-01' and 
			 p2.creating_date < timestamp'2023-12-12'
	   group by caf.caf_num             
   ),
   max_date_prop(caf_num,val) as(
     select caf.caf_num,max(p2.creating_date) 
	   from cafedra caf left join proposal p2 on p2.caf_num = caf.caf_num
	   and p2.creating_date > timestamp'2023-01-01' and 
			 p2.creating_date < timestamp'2023-12-12'
	   group by caf.caf_num
   ),
   cafs_props as(
	   select caf.caf_num,p1.proposal_counter,p1.creating_date
	   from cafedra caf left join proposal p1 on caf.caf_num = p1.caf_num
   ),
   first_prop_2(caf_num,val) as(
        select p1.caf_num,row(p1.proposal_counter,p1.creating_date) 
	   from cafs_props p1 join  min_date_prop min_d on p1.caf_num = min_d.caf_num
	   and p1.proposal_counter = (select proposal_counter from proposal where creating_date = min_d.val 
								  and caf_num = min_d.caf_num limit 1)
   ),
   last_prop_2(caf_num,val) as (
      select p1.caf_num,row(p1.proposal_counter,p1.creating_date) 
	   from cafs_props p1 join  max_date_prop max_d on p1.caf_num = max_d.caf_num
	   where p1.proposal_counter = (select proposal_counter from proposal where creating_date = max_d.val 
									and caf_num = max_d.caf_num limit 1)
   ),
   proposals(proposal_counter,isbn,num,caf_num,creating_date) as(
     select p1.proposal_counter,p2.isbn,p2.num,p1.caf_num,p1.creating_date from proposal p1 join pub_list_from_proposal p2 on p1.proposal_counter = p2.proposal_counter
   ),
   num_of_isbn(caf_num,val) as (
       select caf.caf_num,coalesce(count(distinct p1.isbn),0) 
	   from cafedra caf left join proposals p1 on p1.caf_num = caf.caf_num  
	   and p1.creating_date > timestamp'2023-01-01' and p1.creating_date < timestamp'2023-12-12'
	   group by caf.caf_num
   ),
   common_num(caf_num,val) as (
       select caf.caf_num,coalesce(sum(p2.num),0) 
	   from cafedra caf left join proposals p2 on p2.caf_num = caf.caf_num
		and p2.creating_date > timestamp'2023-01-01' and p2.creating_date < timestamp'2023-12-12'
	    group by caf.caf_num
   ),--общее число изданий во всех заявках
   max_isbn(caf_num,val) as (
       select caf.caf_num,coalesce(max(p2.num),0) 
	   from cafedra caf left join proposals p2 on p2.caf_num = caf.caf_num
	   and p2.creating_date > timestamp'2023-01-01' and p2.creating_date < timestamp'2023-12-12'
	   group by caf.caf_num
   ),--максимальное количество изданий в заявке за период
   min_isbn(caf_num,val) as(
       select caf.caf_num,coalesce(min(p2.num),0) 
	   from cafedra caf left join proposals p2 on p2.caf_num = caf.caf_num
	   and p2.creating_date > timestamp'2023-01-01' and p2.creating_date < timestamp'2023-12-12'
	   group by caf.caf_num
   ),
   avg_isbn(caf_num,val) as (
       select caf.caf_num,count(p2.isbn)/count(distinct p2.proposal_counter) 
	   from cafedra caf left join proposals p2 on p2.caf_num = caf.caf_num
	   and p2.creating_date > timestamp'2023-01-01' and p2.creating_date < timestamp'2023-12-12'
	   group by caf.caf_num
   )
   select caf.caf_num,
       caf.caf_name,
	   caf.spec_name,
	   fprop.val "Первая заявка(номер,дата)",
	   lprop.val "Послед. заявка(номер,дата)",
	   num.val "Число разных изд",
	   cnum.val "Общее количество изд",
	   max_isbn.val "Макс. число изд",
	   min_isbn.val "Мин. число изд",
	   avg_isbn.val "Среднее число изд"
   from cafedra caf
   join first_prop_2 fprop on fprop.caf_num = caf.caf_num
   join last_prop_2 lprop on lprop.caf_num = caf.caf_num
   join num_of_isbn num on num.caf_num = caf.caf_num
   join common_num cnum on cnum.caf_num = caf.caf_num
   join max_isbn on max_isbn.caf_num = caf.caf_num
   join min_isbn on min_isbn.caf_num = caf.caf_num
   join avg_isbn on avg_isbn.caf_num = caf.caf_num;





