declare
    l_unit varchar2(200);
    l_unit_id number;
    l_query clob;
    cursor unit_cur is select ORGANIZATION_ID, SHORT_CODE from hr_operating_units;
    cursor dept_cur(p_unit_id number) is select distinct CLASS_CODE from XXPWC.ICT_DB_WIP_DEPT_PRODUCTION where OPERATING_UNIT = p_unit_id;
begin
    for i in unit_cur loop
        l_unit := i.short_code;
        l_unit_id := i.ORGANIZATION_ID;
        dbms_output.put_line('---------------------------------');
        dbms_output.put_line(l_unit);
        dbms_output.put_line('---------------------------------');
        dbms_output.put_line(chr(10));
        
        for j in dept_cur(l_unit_id) loop
            l_query := 'SELECT TO_CHAR(PROD_DATE,''DD'') LABEL, PROD_QUANTITY VALUE,  ''#bc08d2'' COLOR 
                        FROM XXPWC.ICT_DB_WIP_DEPT_PRODUCTION@PROD_LINK
                        WHERE     ou_short_code = '''||l_unit||'''
                        AND TO_DATE (TO_CHAR (PROD_DATE, ''dd-Mon-YYYY''), ''dd-Mon-YYYY'') BETWEEN
                        TRUNC ((SYSDATE),''month'')AND TO_DATE (TO_CHAR (SYSDATE,''dd-Mon-YYYY''),''dd-Mon-YYYY'')
                        AND CLASS_CODE = '''||j.class_code||'''
                        ORDER BY PROD_DATE ASC;'||chr(10);
                        dbms_output.put_line(l_query);
        end loop;
    end loop;
end;