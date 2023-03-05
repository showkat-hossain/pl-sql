--DROP TABLE XXERP.XX_ITEM_UPDATE_STAGING PURGE;
CREATE TABLE XXERP.XX_ITEM_UPDATE_STAGING
(
    ORG_ID                      NUMBER,
    ORG_CODE                    VARCHAR2 (20),
    ITEM_ID                     NUMBER,
    ITEM_TYPE                   VARCHAR2 (10),
    ITEM_GROUP                  VARCHAR2 (10),
    ITEM_SUBGROUP               VARCHAR2 (10),
    ITEM_SEQUENCE               VARCHAR2 (10),
    ITEM_CODE                   VARCHAR2 (100),
    ITEM_FIN_CAT                VARCHAR2 (100),
    OLD_EXPENSE_ACCOUNT_ID      NUMBER,
    OLD_EXPENSE_ACCOUNT_CODE    VARCHAR2 (100),
    NEW_EXPENSE_ACCOUNT_ID      NUMBER,
    NEW_EXPENSE_ACCOUNT_CODE    VARCHAR2 (100)
);

UPDATE XXERP.XX_ITEM_UPDATE_STAGING
   SET NEW_EXPENSE_ACCOUNT_ID =
           (SELECT CODE_COMBINATION_ID
              FROM GL_CODE_COMBINATIONS_KFV
             WHERE CONCATENATED_SEGMENTS =
                   XXERP.XX_ITEM_UPDATE_STAGING.NEW_EXPENSE_ACCOUNT_CODE);



DECLARE
    v_item_count       NUMBER :=0;
    v_org_id           NUMBER;
    v_return_status    VARCHAR2 (300);
    v_status           VARCHAR2 (300);
    v_msg_count        NUMBER;
    v_msg_data         apps.error_handler.error_tbl_type;
    v_return_message   VARCHAR2 (4000);
    l_item_rec         inv_item_grp.item_rec_type;
    x_item_rec         inv_item_grp.item_rec_type;
    typ_error_tbl      inv_item_grp.error_tbl_type;

CURSOR c1 IS select * from XXERP.XX_ITEM_UPDATE_STAGING --WHERE ORG_CODE = :P_ORG_CODE
;
BEGIN
    FOR i IN C1
    LOOP
        l_item_rec.inventory_item_id := i.ITEM_ID;
        l_item_rec.EXPENSE_ACCOUNT := i.NEW_EXPENSE_ACCOUNT_ID;
        l_item_rec.organization_id := i.ORG_ID;
        
        fnd_global.apps_initialize (6123, 50763, 401);
        
        inv_item_grp.update_item (
            p_commit             => fnd_api.g_false,
            p_lock_rows          => fnd_api.g_false,
            p_validation_level   => fnd_api.g_valid_level_full,
            p_item_rec           => l_item_rec,
            x_item_rec           => x_item_rec,
            x_return_status      => v_return_status,
            x_error_tbl          => typ_error_tbl);
    IF v_return_status = fnd_api.g_ret_sts_success THEN
        v_item_count := v_item_count+1;
    ELSE
        DBMS_OUTPUT.PUT_LINE(i.ITEM_ID||' update failed');
        END IF;
    END LOOP;
    DBMS_OUTPUT.put_line (v_item_count||' row updated');
EXCEPTION
    WHEN OTHERS
    THEN DBMS_OUTPUT.put_line (SQLERRM);
END;


SELECT MP.ORGANIZATION_CODE,
       itm.CONCATENATED_SEGMENTS ITEM_CODE,
       gcc.CODE_COMBINATION_ID EXPENSE_ACCOUNT_ID,
       fnd_flex_ext.get_segs('SQLGL', 'GL#', 101, itm.EXPENSE_ACCOUNT) EXPENSE_ACCOUNT_CODE
       --53526 TARGET_EXPENSE_ID,
       --fnd_flex_ext.get_segs('SQLGL', 'GL#', 101, 53526) TARGET_EXPENSE_ACCOUNT
  FROM MTL_SYSTEM_ITEMS_VL itm,MTL_PARAMETERS       MP, gl_code_combinations_kfv gcc
 WHERE     1 = 1
       AND MP.ORGANIZATION_ID = itm.ORGANIZATION_ID
       AND itm.EXPENSE_ACCOUNT = gcc.CODE_COMBINATION_ID
       AND MP.ORGANIZATION_CODE IN('TRA','TRB','TRD','TRH')
       --AND itm.segment1 IN ('SP','FL')
       --AND itm.EXPENSE_ACCOUNT != 1134183
       AND itm.segment1 != 'FA';



delete from XXERP.XX_ITEM_UPDATE_STAGING;