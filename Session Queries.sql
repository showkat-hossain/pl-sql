/* Formatted on 11/8/2021 8:49:07 PM (QP5 v5.227.12220.39754) */
/*  
            Session Queries
    For Oracle Apps & Oracle Database
    
*/

SELECT DISTINCT
       fu.user_name User_Name,
       fr.RESPONSIBILITY_KEY Responsibility,
       (SELECT user_function_name
          FROM fnd_form_functions_vl fffv
         WHERE (fffv.function_id = ic.function_id))
          Current_Function,
       TO_CHAR (ic.first_connect, 'dd-mm-yyyy hh24:mi:ss') first_connect,
       TO_CHAR (ic.last_connect, 'dd-mm-yyyy hh24:mi:ss') last_connect,
       ppx.full_name,
       fu.email_address,
       ppx.employee_number,
       pbg.name Business_Group
  FROM fnd_user fu,
       fnd_responsibility fr,
       icx_sessions ic,
       per_people_x ppx,
       per_business_groups pbg
 WHERE     fu.user_id = ic.user_id
       AND fr.responsibility_id = ic.responsibility_id
       AND ic.responsibility_id IS NOT NULL
       AND fu.employee_id = ppx.person_id(+)
       AND ppx.business_group_id = pbg.business_group_id(+);



SELECT sid,
       serial#,
       osuser,
       machine,
       program,
       module
  FROM v$session;

SELECT a.username us,
       a.osuser os,
       a.sid,
       a.serial#
  FROM v$session a, v$locked_object b, dba_objects c
 WHERE     UPPER (c.object_name) = UPPER ('&tbl_name')
       AND b.object_id = c.object_id
       AND a.sid = b.session_id;

ALTER SYSTEM KILL SESSION 'sid,serial#';