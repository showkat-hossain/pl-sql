CREATE OR REPLACE PROCEDURE APPS.XX_CREATE_ITEM_PROC (
   P_INVENTORY_ITEM_ID   IN NUMBER,
   P_ITEM_STATUS            VARCHAR2)
IS
   V_ITEM_DESCRIPTION     VARCHAR2 (240);
   V_PRIMARY_UOM_CODE     VARCHAR2 (240);
   V_INVENTORY_ITEM_ID    NUMBER;
   -- P_INVENTORY_ITEM_ID    NUMBER;
   V_ORGANIZATION_ID      NUMBER;
   P_ORGANIZATION_ID      NUMBER;
   V_TEMPLATE_ID          NUMBER;
   V_NEW_ITEM_CODE        VARCHAR2 (250);
   V_SEGMENT1             VARCHAR2 (250);
   V_SEGMENT2             VARCHAR2 (250);
   V_SEGMENT3             VARCHAR2 (250);
   V_SEGMENT4             VARCHAR2 (250);
   V_SEGMENT5             VARCHAR2 (250);
   V_SEGMENT6             VARCHAR2 (250);
   V_ITEM_ATTR_CATG       VARCHAR2 (250);
   V_ITEM_ATTR1           VARCHAR2 (250);
   V_ITEM_ATTR2           VARCHAR2 (250);
   V_ITEM_ATTR3           VARCHAR2 (250);
   V_ITEM_ATTR4           VARCHAR2 (250);
   V_ITEM_ATTR5           VARCHAR2 (250);
   V_ITEM_ATTR6           VARCHAR2 (250);
   V_ITEM_ATTR7           VARCHAR2 (250);
   V_ITEM_ATTR8           VARCHAR2 (250);
   V_ITEM_ATTR9           VARCHAR2 (250);
   V_ITEM_ATTR10          VARCHAR2 (250);
   V_ITEM_ATTR11          VARCHAR2 (250);
   V_ITEM_ATTR12          VARCHAR2 (250);
   V_ITEM_ATTR13          VARCHAR2 (250);
   V_ITEM_ATTR14          VARCHAR2 (250);
   V_ITEM_ATTR15          VARCHAR2 (250);
   V_ITEM_ATTR16          VARCHAR2 (250);
   V_ITEM_ATTR17          VARCHAR2 (250);
   V_ITEM_ATTR18          VARCHAR2 (250);
   V_ITEM_ATTR19          VARCHAR2 (250);
   V_ITEM_ATTR20          VARCHAR2 (250);
   V_ITEM_ATTR21          VARCHAR2 (250);
   V_ITEM_ATTR22          VARCHAR2 (250);
   V_ITEM_ATTR23          VARCHAR2 (250);
   V_ITEM_ATTR24          VARCHAR2 (250);
   V_ITEM_ATTR25          VARCHAR2 (250);
   V_ITEM_ATTR26          VARCHAR2 (250);
   V_GRADE                VARCHAR2 (250);


   V_RETURN_STATUS        VARCHAR2 (1);
   V_MSG_COUNT            NUMBER;
   V_MSG_DATA             VARCHAR2 (4000);
   X_MESSAGE_LIST         ERROR_HANDLER.ERROR_TBL_TYPE;
   l_user_id              NUMBER;
   l_resp_id              NUMBER;
   l_resp_appl_id         NUMBER;
   L_ITEM_ORG_TBL         EGO_ITEM_PUB.ITEM_TBL_TYPE;
   X_ITEM_ORG_TBL         EGO_ITEM_PUB.ITEM_TBL_TYPE;
   L_ORG_API_VERSION      NUMBER := 1.0;
   L_ORG_INIT_MSG_LIST    VARCHAR2 (2) := FND_API.G_TRUE;
   L_ORG_COMMIT           VARCHAR2 (2) := FND_API.G_FALSE;
   L_ROLE_GRANT_TBL       EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE;
   L_ORG_ROLE_GRANT_TBL   EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE;
   X_ORG_MESSAGE_LIST     ERROR_HANDLER.ERROR_TBL_TYPE;
   X_ORG_RETURN_STATUS    VARCHAR2 (2);
   X_ORG_MSG_COUNT        NUMBER := 0;
   X_MSG_DATA             VARCHAR2 (4000);
BEGIN
   BEGIN
      P_ORGANIZATION_ID := 91;
      V_ITEM_ATTR_CATG := 'Processed Fabric Item Details';
	  
      SELECT SEGMENT1,
             SEGMENT2,
             SEGMENT3,
             SEGMENT4,
             SEGMENT5,
             SEGMENT6,
             PRIMARY_UOM_CODE,
             DESCRIPTION,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             ATTRIBUTE16,
             ATTRIBUTE17,
             ATTRIBUTE18,
             ATTRIBUTE19,
             ATTRIBUTE20,
             ATTRIBUTE21,
             ATTRIBUTE22,
             ATTRIBUTE23,
             ATTRIBUTE24
        INTO V_SEGMENT1,
             V_SEGMENT2,
             V_SEGMENT3,
             V_SEGMENT4,
             V_SEGMENT5,
             V_SEGMENT6,
             V_PRIMARY_UOM_CODE,
             V_ITEM_DESCRIPTION,
             V_ITEM_ATTR_CATG,
             V_ITEM_ATTR1,
             V_ITEM_ATTR2,
             V_ITEM_ATTR3,
             V_ITEM_ATTR4,
             V_ITEM_ATTR5,
             V_ITEM_ATTR6,
             V_ITEM_ATTR7,
             V_ITEM_ATTR8,
             V_ITEM_ATTR9,
             V_ITEM_ATTR10,
             V_ITEM_ATTR11,
             V_ITEM_ATTR12,
             V_ITEM_ATTR13,
             V_ITEM_ATTR14,
             V_ITEM_ATTR15,
             V_ITEM_ATTR16,
             V_ITEM_ATTR17,
             V_ITEM_ATTR18,
             V_ITEM_ATTR19,
             V_ITEM_ATTR20,
             V_ITEM_ATTR21,
             V_ITEM_ATTR22,
             V_ITEM_ATTR23,
             V_ITEM_ATTR24
        FROM APPS.MTL_SYSTEM_ITEMS_B_KFV
       WHERE     INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
             AND ORGANIZATION_ID = P_ORGANIZATION_ID;

      V_SEGMENT3 := P_ITEM_STATUS;

      IF P_ITEM_STATUS = '1042'
      THEN
         V_GRADE := 'B';
         V_PRIMARY_UOM_CODE := 'YDS';
      ELSIF P_ITEM_STATUS = '1043'
      THEN
         V_GRADE := 'C';
         V_PRIMARY_UOM_CODE := 'YDS';
      ELSIF P_ITEM_STATUS = '1047'
      THEN
         V_GRADE := 'UNGRADED';
         V_PRIMARY_UOM_CODE := 'MRT';
      ELSE
         V_GRADE := P_ITEM_STATUS;
         V_PRIMARY_UOM_CODE := 'YDS';
      END IF;

      V_ITEM_DESCRIPTION := V_ITEM_DESCRIPTION || ' Grade : ' || V_GRADE;

      SELECT TEMPLATE_ID
        INTO V_TEMPLATE_ID
        FROM APPS.MTL_ITEM_TEMPLATES
       WHERE TEMPLATE_NAME = '@FabricFG';

      DBMS_OUTPUT.PUT_LINE (V_TEMPLATE_ID);
      V_NEW_ITEM_CODE := V_SEGMENT1|| '.'|| V_SEGMENT2|| '.'|| V_SEGMENT3|| '.'|| V_SEGMENT4|| '.'|| V_SEGMENT5|| '.'|| V_SEGMENT6;
	  
      DBMS_OUTPUT.PUT_LINE ('V_NEW_ITEM_CODE :' || V_NEW_ITEM_CODE);
      DBMS_OUTPUT.PUT_LINE ('V_ORGANIZATION_ID ' || P_ORGANIZATION_ID);
	  
      V_INVENTORY_ITEM_ID := 0;
	  
      BEGIN
         SELECT INVENTORY_ITEM_ID
           INTO V_INVENTORY_ITEM_ID
           FROM APPS.MTL_SYSTEM_ITEMS_B_KFV
          WHERE     CONCATENATED_SEGMENTS = V_NEW_ITEM_CODE
                AND ORGANIZATION_ID = 91;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('UNEXPECTED ERROR: ' || SQLERRM);
            V_INVENTORY_ITEM_ID := 0;
      END;
      DBMS_OUTPUT.PUT_LINE ('Inventory Item Id-  ' || V_INVENTORY_ITEM_ID);

      SELECT FND.USER_ID, FRESP.RESPONSIBILITY_ID, FRESP.APPLICATION_ID
        INTO L_USER_ID, L_RESP_ID, L_RESP_APPL_ID
        FROM APPS.FND_USER FND, APPS.FND_RESPONSIBILITY_TL FRESP
       WHERE     FND.USER_NAME = 'API_EBS'
             AND FRESP.RESPONSIBILITY_NAME = 'WIP NDSD';

      APPS.FND_GLOBAL.APPS_INITIALIZE (L_USER_ID, L_RESP_ID, L_RESP_APPL_ID);

      IF V_INVENTORY_ITEM_ID = 0
      THEN
         APPS.EGO_ITEM_PUB.PROCESS_ITEM (
            P_API_VERSION                  => 1.0,
            P_INIT_MSG_LIST                => 'T',
            P_COMMIT                       => 'T',
            P_TRANSACTION_TYPE             => 'CREATE',
            P_SEGMENT1                     => V_SEGMENT1,
            P_SEGMENT2                     => V_SEGMENT2,
            P_SEGMENT3                     => V_SEGMENT3,
            P_SEGMENT4                     => V_SEGMENT4,
            P_SEGMENT5                     => V_SEGMENT5,
            P_SEGMENT6                     => V_SEGMENT6,
            P_DESCRIPTION                  => V_ITEM_DESCRIPTION,
            P_ORGANIZATION_ID              => P_ORGANIZATION_ID,
            P_PRIMARY_UOM_CODE             => V_PRIMARY_UOM_CODE,
            P_ATTRIBUTE_CATEGORY           => V_ITEM_ATTR_CATG,
            P_ATTRIBUTE1                   => V_ITEM_ATTR1,
            P_ATTRIBUTE2                   => V_ITEM_ATTR2,
            P_ATTRIBUTE3                   => V_ITEM_ATTR3,
            P_ATTRIBUTE4                   => V_ITEM_ATTR4,
            P_ATTRIBUTE5                   => V_ITEM_ATTR5,
            P_ATTRIBUTE6                   => V_ITEM_ATTR6,
            P_ATTRIBUTE7                   => V_ITEM_ATTR7,
            P_ATTRIBUTE8                   => V_ITEM_ATTR8,
            P_ATTRIBUTE9                   => V_ITEM_ATTR9,
            P_ATTRIBUTE10                  => V_ITEM_ATTR10,
            P_ATTRIBUTE11                  => V_ITEM_ATTR11,
            P_ATTRIBUTE12                  => V_ITEM_ATTR12,
            P_ATTRIBUTE13                  => V_ITEM_ATTR13,
            P_ATTRIBUTE14                  => V_ITEM_ATTR14,
            P_ATTRIBUTE15                  => V_ITEM_ATTR15,
            P_ATTRIBUTE16                  => V_ITEM_ATTR16,
            P_ATTRIBUTE17                  => V_ITEM_ATTR17,
            P_ATTRIBUTE18                  => V_ITEM_ATTR18,
            P_ATTRIBUTE19                  => V_ITEM_ATTR19,
            P_ATTRIBUTE20                  => V_ITEM_ATTR20,
            P_ATTRIBUTE21                  => V_ITEM_ATTR21,
            P_ATTRIBUTE22                  => V_ITEM_ATTR22,
            P_ATTRIBUTE23                  => V_ITEM_ATTR23,
            P_ATTRIBUTE24                  => V_ITEM_ATTR24,
            P_ATTRIBUTE25                  => V_ITEM_ATTR25,
            P_ATTRIBUTE26                  => V_ITEM_ATTR26,
            P_TEMPLATE_ID                  => V_TEMPLATE_ID,
            P_INVENTORY_ITEM_STATUS_CODE   => 'Active',
            P_APPROVAL_STATUS              => 'A',
            X_INVENTORY_ITEM_ID            => V_INVENTORY_ITEM_ID,
            X_ORGANIZATION_ID              => V_ORGANIZATION_ID,
            X_RETURN_STATUS                => V_RETURN_STATUS,
            X_MSG_COUNT                    => V_MSG_COUNT,
            X_MSG_DATA                     => V_MSG_DATA);

         IF V_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  'ITEM CREATED SUCCESSFULLY, ITEM ID: '
               || V_INVENTORY_ITEM_ID
               || ' ,ORGANIZATION ID: '
               || V_ORGANIZATION_ID);
         /*Org Assignment*/
         ELSE
            DBMS_OUTPUT.PUT_LINE (
               'CPS ITEM CREATION FAILED DUE TO  ' || V_RETURN_STATUS);
            DBMS_OUTPUT.PUT_LINE ('V_MSG_DATA  ' || V_MSG_DATA);

            ROLLBACK;

            ERROR_HANDLER.GET_MESSAGE_LIST (X_MESSAGE_LIST => X_MESSAGE_LIST);

            FOR I IN 1 .. X_MESSAGE_LIST.COUNT
            LOOP
               DBMS_OUTPUT.PUT_LINE (X_MESSAGE_LIST (I).MESSAGE_TEXT);
            END LOOP;
         END IF;
      END IF;

      ----*******************************************************************------

      IF V_INVENTORY_ITEM_ID > 0
      THEN
         FOR ORG_ASSIGN_REC
            IN (SELECT HOU.ORGANIZATION_ID
                  FROM APPS.MTL_PARAMETERS MP, APPS.HR_ORGANIZATION_UNITS HOU
                 WHERE     MP.ORGANIZATION_ID = HOU.ORGANIZATION_ID
                       AND NVL (MP.EAM_ENABLED_FLAG, 'N') = 'N'
                       AND NVL (MP.ATTRIBUTE14, 'NO') = 'NO'
                       AND UPPER (MP.ATTRIBUTE15) IN ('PROCESSING')
                       AND HOU.ORGANIZATION_ID NOT IN
                              (SELECT DISTINCT ORGANIZATION_ID
                                 FROM MTL_SYSTEM_ITEMS_KFV
                                WHERE INVENTORY_ITEM_ID = V_INVENTORY_ITEM_ID))
         LOOP
            L_ITEM_ORG_TBL (1).TRANSACTION_TYPE := 'CREATE';
            L_ITEM_ORG_TBL (1).INVENTORY_ITEM_ID := V_INVENTORY_ITEM_ID;
            L_ITEM_ORG_TBL (1).ORGANIZATION_ID :=
               ORG_ASSIGN_REC.ORGANIZATION_ID;
            L_ITEM_ORG_TBL (1).INVENTORY_ITEM_STATUS_CODE := 'Active';

            BEGIN
               APPS.EGO_ITEM_PUB.PROCESS_ITEMS (
                  P_API_VERSION      => L_ORG_API_VERSION,
                  P_INIT_MSG_LIST    => L_ORG_INIT_MSG_LIST,
                  P_COMMIT           => L_ORG_COMMIT,
                  P_ITEM_TBL         => L_ITEM_ORG_TBL,
                  P_ROLE_GRANT_TBL   => L_ORG_ROLE_GRANT_TBL,
                  X_ITEM_TBL         => X_ITEM_ORG_TBL,
                  X_RETURN_STATUS    => X_ORG_RETURN_STATUS,
                  X_MSG_COUNT        => X_ORG_MSG_COUNT);

               IF (X_ORG_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS)
               THEN
                  COMMIT;

                  FOR I IN 1 .. X_ITEM_ORG_TBL.COUNT
                  LOOP
                     DBMS_OUTPUT.PUT_LINE (
                           'Org Inventory Item Id :'
                        || TO_CHAR (X_ITEM_ORG_TBL (I).INVENTORY_ITEM_ID));
                     DBMS_OUTPUT.PUT_LINE (
                           'Org Organization Id   :'
                        || TO_CHAR (X_ITEM_ORG_TBL (I).ORGANIZATION_ID));
                  END LOOP;
               ELSE
                  DBMS_OUTPUT.PUT_LINE ('Org Assignment Error Messages :');
                  ERROR_HANDLER.GET_MESSAGE_LIST (
                     X_MESSAGE_LIST => X_ORG_MESSAGE_LIST);

                  FOR I IN 1 .. X_ORG_MESSAGE_LIST.COUNT
                  LOOP
                     DBMS_OUTPUT.PUT_LINE (
                        X_ORG_MESSAGE_LIST (I).MESSAGE_TEXT);
                  END LOOP;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('UNEXPECTED ERROR: ' || SQLERRM);
   END;
END;
/
