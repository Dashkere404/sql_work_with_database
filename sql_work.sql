--Реализовать хранимую функцию/процедуру, возвращающую общее количество остатков заданного наименования товара в магазинах и на складах.
create or replace function get_remnants_of_goods (name_of_good TEXT)
returns INT 
as $$
declare 
	count_of_goods INT;
begin
	select 
		(select coalesce(sum(Good_Shop.count), 0) from Good join Good_Shop on Good.id=Good_Shop.id_good where name_of_good=Good.name)+
		(select coalesce(sum(Good_Warehouse.count), 0)  from Good join Good_Warehouse on Good.id=Good_warehouse.id_good where name_of_good=Good.name)
	into count_of_goods;
	return count_of_goods;
end;
$$language plpgsql;
select * from get_remnants_of_goods ('Apple iPhone 14');


--Реализовать хранимую функцию/процедуру, которая по наименованию товара и возрасту покупателя выводит сообщение о возможности приобретения данного товара данным покупателем.
create or replace function get_message_possibility(name_of_good TEXT, age_buyer INT)
returns TEXT
as $$
declare 
	message_possibility TEXT;
	min_age INT;
	good_exists BOOLEAN;
begin 
	select exists (select 1 from Good where name=name_of_good)
	into good_exists;
	if not good_exists then 
		raise info 'Данный товар не найден.';
	end if;
	select GoodCategory.ageMin
	into min_age 
	from Good 
	join GoodCategory ON Good.id_goodCategory = GoodCategory.id 
	where Good.name=name_of_good;
	if min_age is null then
        message_possibility:='Вы можете купить данный товар';
	else
		if age_buyer<min_age then 
			message_possibility:='Вы не можете купить данный товар';
		else 
			message_possibility:='Вы можете купить данный товар';
			end if;
	end if;
	return message_possibility;

end;
$$language plpgsql;
select*from get_message_possibility('Apple iPhone 14', 4);



--Реализовать хранимую функцию/процедуру, которая оценивает возможность покупки заданного количества товара в магазине (название магазина и товара задаются пользователем). При этом необходимо также проверить возрастные ограничения покупателя (используя функцию из п.2).
create or replace function possibility_to_buy_count_of_good (
	name_of_good TEXT, 
	count_of_good INT, 
	age_buyer INT, 
	name_of_shop TEXT
)
returns void
as $$
declare
	available_count INT;
	shop_exist BOOLEAN;
begin
	select exists (select 1 from Shop where name=name_of_shop)
	into shop_exist;
	if not shop_exist then 
		raise info 'Данный магазин не найден.';
		return;
	end if;
	select Good_Shop.count into available_count from Good_Shop
	join Good on (Good.id=Good_Shop.id_good)
	join Shop on (Shop.id=Good_Shop.id_shop)
	where Shop.name=name_of_shop and Good.name=name_of_good;
	if get_message_possibility(name_of_good, age_buyer)='Вы можете купить данный товар' and available_count>=count_of_good then
		raise info 'Вы можете купить % %', count_of_good, name_of_good;
	else 
		raise info 'Вы не можете купить % %', count_of_good, name_of_good;
	end if;
end;
$$language plpgsql;
select*from possibility_to_buy_count_of_good('Apple iPhone', 6, 18, 'МВидео');







