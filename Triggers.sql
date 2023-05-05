DROP FUNCTION IF EXISTS
	trigger_debit_act_before_insert,
	trigger_pub_in_order_list_before_insert;
--Проверка возможности списания литературы
CREATE FUNCTION trigger_debit_act_before_insert() RETURNS trigger AS $$
DECLARE
	tmp INTEGER := -1;
BEGIN
    SELECT * INTO tmp FROM user_role WHERE user_role.user_id = NEW.user_id AND user_role.role_code = 2;
	IF NOT FOUND THEN
	   raise NOTICE 'Operator with user id % does not exist', NEW.user_id;
	   return NULL;
	end IF;
	SELECT lib_count INTO tmp FROM publicat WHERE (publicat.isbn).prefix = (NEW.isbn).prefix and 
	(publicat.isbn).reg_group_num = (NEW.isbn).reg_group_num and
	(publicat.isbn).reg_num = (NEW.isbn).reg_num and
	(publicat.isbn).pub_num = (NEW.isbn).pub_num and
	(publicat.isbn).control_num = (NEW.isbn).control_num LIMIT 1;
	IF NOT FOUND THEN
	    raise NOTICE 'Publication with given isbn % does not exist',NEW.isbn;
    	RETURN NULL;
	END IF;
	IF (tmp < NEW.num) THEN
	    raise NOTICE 'Amount of publication with isbn % must be less or equal %',NEW.isbn,tmp;
    	RETURN NULL;
	END IF;
	UPDATE publicat SET lib_count = (tmp - NEW.num) WHERE (publicat.isbn).prefix = (NEW.isbn).prefix and 
		(publicat.isbn).reg_group_num = (NEW.isbn).reg_group_num and
		(publicat.isbn).reg_num = (NEW.isbn).reg_num and
		(publicat.isbn).pub_num = (NEW.isbn).pub_num and
		(publicat.isbn).control_num = (NEW.isbn).control_num;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';
CREATE OR REPLACE TRIGGER debitActInsert 
BEFORE INSERT ON debit_act
FOR EACH ROW
EXECUTE PROCEDURE trigger_debit_act_before_insert();

--Проверка существования издания в отделе продаж
CREATE OR REPLACE FUNCTION trigger_pub_in_order_list_before_insert() RETURNS trigger AS
$$
DECLARE
   dep_id INTEGER := -1;
   res RECORD;
BEGIN
	SELECT department_id INTO dep_id FROM lit_order WHERE order_id = NEW.order_id;
	IF NOT FOUND THEN
	   RETURN NULL;
	END IF;
	SELECT * INTO res FROM pub_list_from_sales_dep WHERE department_id = dep_id AND (pub_list_from_sales_dep.isbn).prefix = (NEW.isbn).prefix and 
		(pub_list_from_sales_dep.isbn).reg_group_num = (NEW.isbn).reg_group_num and
		(pub_list_from_sales_dep.isbn).reg_num = (NEW.isbn).reg_num and
		(pub_list_from_sales_dep.isbn).pub_num = (NEW.isbn).pub_num and
		(pub_list_from_sales_dep.isbn).control_num = (NEW.isbn).control_num;
	IF NOT FOUND THEN
		 SELECT department_id INTO dep_id FROM pub_list_from_sales_dep WHERE (pub_list_from_sales_dep.isbn).prefix = (NEW.isbn).prefix and 
				(pub_list_from_sales_dep.isbn).reg_group_num = (NEW.isbn).reg_group_num and
				(pub_list_from_sales_dep.isbn).reg_num = (NEW.isbn).reg_num and
				(pub_list_from_sales_dep.isbn).pub_num = (NEW.isbn).pub_num and
				(pub_list_from_sales_dep.isbn).control_num = (NEW.isbn).control_num;
		 raise NOTICE 'Insert is impossible. You can buy publication in department: %', dep_id;
		 RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';
CREATE OR REPLACE TRIGGER litOrderInsert 
BEFORE INSERT ON pub_in_order_list
FOR EACH ROW
EXECUTE PROCEDURE trigger_pub_in_order_list_before_insert();