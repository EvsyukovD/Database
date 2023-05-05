DROP TABLE IF EXISTS 
	pub_list_for_accept,
	acceptance_act,
	pub_in_order_list,
	pub_list_from_proposal,
	pub_list_from_sales_dep,
	author_in_publicat,
	publicat,
	debit_act,
	lit_order,
	proposal;
DROP TABLE IF EXISTS
	cafedra_worker,
	cafedra,
	sales_department,
	author,
	pub_house,
	sys_user,
	user_role;
DROP PROCEDURE IF EXISTS
	 debit_publication,
	 add_publication;
DROP PROCEDURE IF EXISTS
	 process_proposal;
DROP FUNCTION IF EXISTS
     isbn_equals;
DROP TYPE IF EXISTS
	author_struct,
	pub_house_struct,
	publication_struct,
	isbn;