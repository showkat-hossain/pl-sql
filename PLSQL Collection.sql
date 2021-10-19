DECLARE 
   type valueArray IS VARRAY(10) OF VARCHAR2(200);
   so_pp_array valueArray := valueArray('Kavita', 'Pritam', 'Ayan', 'Rishav', 'Aziz'); 
BEGIN 

/*
to select from some table have to use BULK COLLECT

select first_name BULK COLLECT into so_pp_array from employees;
*/  

   FOR i in 1 .. so_pp_array.count LOOP 
      dbms_output.put_line('Value: ' ||i ||' is '|| so_pp_array(i)); 
   END LOOP; 
   
END; 
/