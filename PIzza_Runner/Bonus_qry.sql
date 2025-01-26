#E. Bonus Questions
#If Danny wants to expand his range of pizzas - 
#how would this impact the existing data design?
# Write an INSERT statement to demonstrate what would happen 
# if a new Supreme pizza with all the toppings was 
#added to the Pizza Runner menu?


create table pizza_names_new as
 (select * from pizza_names);

create table pizza_recipes_new as
 (select * from pizza_recipes);
 
insert into pizza_names_new values(3,'Supreme Pizza');
insert into pizza_recipes_new values (3,'1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

select * from pizza_recipes_new;
select * from pizza_names_new;
