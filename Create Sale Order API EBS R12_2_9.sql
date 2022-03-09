CREATE OR REPLACE PROCEDURE APPS.XX_SO_CREATE_PROC (
   P_ORDER_HEADER_ID       NUMBER,
   X_SO_NUMBER         OUT VARCHAR2,
   X_SO_HEADER_ID      OUT NUMBER,
   X_API_MESSAGE       OUT VARCHAR2)
AS
   l_return_status                VARCHAR2 (2000);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2 (2000);
   -- PARAMETERS
   l_debug_level                  NUMBER := 5;       -- OM DEBUG LEVEL (MAX 5)
   l_org                          VARCHAR2 (20); -- OPERATING UNIT -- Nice Denim Mills Limited
   l_no_orders                    NUMBER := 1;                 -- NO OF ORDERS
   -- INPUT VARIABLES FOR PROCESS_ORDER API
   l_header_rec                   oe_order_pub.header_rec_type;
   l_line_tbl                     oe_order_pub.line_tbl_type;
   l_action_request_tbl           oe_order_pub.request_tbl_type;
   -- OUT VARIABLES FOR PROCESS_ORDER API
   l_header_rec_out               oe_order_pub.header_rec_type;
   l_header_val_rec_out           oe_order_pub.header_val_rec_type;
   l_header_adj_tbl_out           oe_order_pub.header_adj_tbl_type;
   l_header_adj_val_tbl_out       oe_order_pub.header_adj_val_tbl_type;
   l_header_price_att_tbl_out     oe_order_pub.header_price_att_tbl_type;
   l_header_adj_att_tbl_out       oe_order_pub.header_adj_att_tbl_type;
   l_header_adj_assoc_tbl_out     oe_order_pub.header_adj_assoc_tbl_type;
   l_header_scredit_tbl_out       oe_order_pub.header_scredit_tbl_type;
   l_header_scredit_val_tbl_out   oe_order_pub.header_scredit_val_tbl_type;
   l_line_tbl_out                 oe_order_pub.line_tbl_type;
   l_line_val_tbl_out             oe_order_pub.line_val_tbl_type;
   l_line_adj_tbl_out             oe_order_pub.line_adj_tbl_type;
   l_line_adj_val_tbl_out         oe_order_pub.line_adj_val_tbl_type;
   l_line_price_att_tbl_out       oe_order_pub.line_price_att_tbl_type;
   l_line_adj_att_tbl_out         oe_order_pub.line_adj_att_tbl_type;
   l_line_adj_assoc_tbl_out       oe_order_pub.line_adj_assoc_tbl_type;
   l_line_scredit_tbl_out         oe_order_pub.line_scredit_tbl_type;
   l_line_scredit_val_tbl_out     oe_order_pub.line_scredit_val_tbl_type;
   l_lot_serial_tbl_out           oe_order_pub.lot_serial_tbl_type;
   l_lot_serial_val_tbl_out       oe_order_pub.lot_serial_val_tbl_type;
   l_action_request_tbl_out       oe_order_pub.request_tbl_type;
   -- l_msg_index                    NUMBER;
   -- l_data                         VARCHAR2 (2000);
   -- V_API_MESSAGE                  VARCHAR2 (2000);
   l_loop_count                   NUMBER;
   l_debug_file                   VARCHAR2 (200);
   l_user_id                      NUMBER;
   l_resp_id                      NUMBER;
   l_resp_appl_id                 NUMBER;
   V_SHIP_FROM_INV_ORG_ID         NUMBER;
   V_PARENT_PI_HEADER_ID          NUMBER;
   V_CUSTOMER_ACCOUNT_ID          NUMBER;
   V_ORDER_TYPE_ID                NUMBER;
   V_LINE_NO                      NUMBER;
   V_CURRENCY                     VARCHAR2 (100);
   l_msg_index_out                NUMBER (10);
   V_ORDER_DATE                   DATE;
BEGIN
   -- POPULATE REQUIRED ATTRIBUTES
   -- INITIALIZE HEADER RECORD
   l_header_rec := oe_order_pub.g_miss_header_rec;
   
   --l_header_rec.ship_from_org_id := 857545;

   BEGIN
      BEGIN
         SELECT TO_CHAR (OU_ID),CUST_PO_NUMBER,ORG_ID,CUSTOMER_ACCOUNT_ID,SALES_PERSON_ID,PAYMENT_TERM_ID,
                ORDER_TYPE_ID,ORDER_HEADER_ID,H_ATTRIBUTE1,H_ATTRIBUTE2,H_ATTRIBUTE3,H_ATTRIBUTE4,H_ATTRIBUTE5,
                H_ATTRIBUTE6,H_ATTRIBUTE7,H_ATTRIBUTE8,H_ATTRIBUTE9,H_ATTRIBUTE10,ORDER_DATE,ATTRIBUTE_ONTEXT
           INTO l_org,l_header_rec.cust_po_number,V_SHIP_FROM_INV_ORG_ID,V_CUSTOMER_ACCOUNT_ID,l_header_rec.salesrep_id,l_header_rec.PAYMENT_TERM_ID,
                V_ORDER_TYPE_ID,l_header_rec.order_source_id,l_header_rec.ATTRIBUTE1,l_header_rec.ATTRIBUTE2,l_header_rec.ATTRIBUTE3,l_header_rec.ATTRIBUTE4,l_header_rec.ATTRIBUTE5,
                l_header_rec.ATTRIBUTE6,l_header_rec.ATTRIBUTE7,l_header_rec.ATTRIBUTE8,l_header_rec.ATTRIBUTE9,l_header_rec.ATTRIBUTE10,V_ORDER_DATE,l_header_rec.CONTEXT
           FROM XXPWC.ICT_INTERFACE_SALE_HEADERS_ALL
          WHERE     ORDER_NUMBER IS NULL
                AND ORDER_HEADER_ID = P_ORDER_HEADER_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            X_API_MESSAGE := 'NO DATA FROM SALE ORDER CREATION';
            DBMS_OUTPUT.PUT_LINE (X_API_MESSAGE);

            RETURN;
      END;

      -- INITIALIZATION REQUIRED FOR R12
      mo_global.set_policy_context ('S', l_org);
      mo_global.init ('ONT');

      -- INITIALIZE DEBUG INFO
      IF (l_debug_level > 0)
      THEN
         l_debug_file := oe_debug_pub.set_debug_mode ('FILE');
         oe_debug_pub.initialize;
         oe_msg_pub.initialize;
         oe_debug_pub.setdebuglevel (l_debug_level);
      END IF;

      --    INITIALIZE ENVIRONMENT

      l_header_rec.ORDER_TYPE_ID := V_ORDER_TYPE_ID;
      l_header_rec.sold_to_org_id := V_CUSTOMER_ACCOUNT_ID;

      SELECT FND.USER_ID, FRESP.RESPONSIBILITY_ID, FRESP.APPLICATION_ID
        INTO L_USER_ID, L_RESP_ID, L_RESP_APPL_ID
        FROM FND_USER FND, FND_RESPONSIBILITY_TL FRESP
       WHERE     FND.USER_NAME = '8402'
             AND FRESP.RESPONSIBILITY_NAME = 'OM NDML PreCost';

      V_ORDER_DATE := SYSDATE;
      X_API_MESSAGE := NULL;
      fnd_global.apps_initialize (L_USER_ID, L_RESP_ID, L_RESP_APPL_ID);


      l_header_rec.operation := oe_globals.g_opr_create;
      l_header_rec.pricing_date := V_ORDER_DATE;

      l_header_rec.ordered_date := V_ORDER_DATE;
      l_header_rec.SHIP_FROM_ORG_ID := V_SHIP_FROM_INV_ORG_ID;
      l_header_rec.FLOW_STATUS_CODE := 'ENTERED';
      l_header_rec.OPERATION := OE_GLOBALS.G_OPR_CREATE;

      --  l_header_rec.CONTEXT := 'Denim Details';

      DBMS_OUTPUT.PUT_LINE ('V_ORDER_TYPE_ID : ' || V_ORDER_TYPE_ID);
      DBMS_OUTPUT.PUT_LINE ('V_CUSTOMER_ACCOUNT_ID : ' || V_CUSTOMER_ACCOUNT_ID);

      DBMS_OUTPUT.PUT_LINE ('CUS' || l_header_rec.sold_to_org_id);
      DBMS_OUTPUT.PUT_LINE ('l_header_rec.order_type_id : ' || l_header_rec.order_type_id);

      -------------------- PRICE LIST  ------------------------------------
      BEGIN
         SELECT PRICE_LIST_ID, CURRENCY_CODE
           INTO l_header_rec.price_list_id, V_CURRENCY
           FROM ICT_OM_ORDER_TYPE_PRICE_LIST_V
          WHERE TRANSACTION_TYPE_ID = V_ORDER_TYPE_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            X_API_MESSAGE := 'UNEXPECTED ERROR: PRICE LIST - ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE (X_API_MESSAGE);
            RETURN;
      END;
	  
      -------------------- SHIP_TO ------------------------------------
      DBMS_OUTPUT.PUT_LINE ('CUS' || l_header_rec.sold_to_org_id);

      BEGIN
         SELECT hzsuas.site_use_id ship_to_site_use_id
           INTO l_header_rec.ship_to_org_id
           FROM hz_parties hp,
                hz_cust_accounts hca,
                hz_cust_acct_sites_all hcasas,
                hz_cust_site_uses_all hzsuas,
                hz_party_sites hps
          WHERE hp.party_id = hca.party_id
                AND hca.CUST_ACCOUNT_ID = V_CUSTOMER_ACCOUNT_ID
                AND hcasas.cust_account_id = hca.cust_account_id
                AND hcasas.party_site_id = hps.party_site_id
                AND hcasas.cust_acct_site_id = hzsuas.cust_acct_site_id
                AND hzsuas.org_id = l_org
                AND hzsuas.SITE_USE_CODE = 'SHIP_TO'
                AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            X_API_MESSAGE := 'UNEXPECTED ERROR: SHIP_TO ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE (X_API_MESSAGE);
            UPDATE XXPWC.ICT_INTERFACE_SALE_HEADERS_ALL
               SET API_MESSEAGE = X_API_MESSAGE
             WHERE ORDER_HEADER_ID = P_ORDER_HEADER_ID;

            COMMIT;
            RETURN;
      END;

      ----------------------------------------------
      -------------------- BILL_TO ------------------------------------
      BEGIN
         SELECT hzsuas.site_use_id ship_to_site_use_id
           INTO l_header_rec.invoice_to_org_id
           FROM hz_parties hp,
                hz_cust_accounts hca,
                hz_cust_acct_sites_all hcasas,
                hz_cust_site_uses_all hzsuas,
                hz_party_sites hps
          WHERE     hp.party_id = hca.party_id
                AND hca.CUST_ACCOUNT_ID = V_CUSTOMER_ACCOUNT_ID         --2603
                AND hcasas.cust_account_id = hca.cust_account_id
                AND hcasas.party_site_id = hps.party_site_id
                AND hcasas.cust_acct_site_id = hzsuas.cust_acct_site_id
                AND hzsuas.org_id = l_org
                AND hzsuas.SITE_USE_CODE = 'BILL_TO'
                AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            X_API_MESSAGE := 'UNEXPECTED ERROR: BILL_TO' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE (X_API_MESSAGE);

            UPDATE XXPWC.ICT_INTERFACE_SALE_HEADERS_ALL
               SET API_MESSEAGE = X_API_MESSAGE
             WHERE ORDER_HEADER_ID = P_ORDER_HEADER_ID;

            RETURN;
      END;
      ----------------------------------------------
      V_LINE_NO := 1;

      -- INITIALIZE ACTION REQUEST RECORD
      BEGIN
         FOR rec_line
            IN (SELECT ORDER_HEADER_ID,ORDER_LINE_ID,INVENTORY_ITEM_ID,ITEM_CODE,ITEM_NAME,
                       UOM,QUANTITY,RATE,AMOUNT,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
                       LAST_UPDATE_DATE,LINE_CONTEXT,L_ATTRIBUTE1,L_ATTRIBUTE2,L_ATTRIBUTE3,
                       L_ATTRIBUTE4,L_ATTRIBUTE5,L_ATTRIBUTE6,L_ATTRIBUTE7,L_ATTRIBUTE8,
                       L_ATTRIBUTE9,L_ATTRIBUTE10,L_ATTRIBUTE11,L_ATTRIBUTE12,L_ATTRIBUTE13,
                       L_ATTRIBUTE14,L_ATTRIBUTE15
                  FROM XXPWC.ICT_INTERFACE_SALE_LINES_ALL L
                 WHERE ORDER_HEADER_ID = P_ORDER_HEADER_ID
                       AND QUANTITY > 0)
         LOOP
            BEGIN
               l_action_request_tbl (V_LINE_NO) :=
                  oe_order_pub.g_miss_request_rec;
               -- INITIALIZE LINE RECORD
               l_line_tbl (V_LINE_NO) := oe_order_pub.g_miss_line_rec;
               l_line_tbl (V_LINE_NO).operation := oe_globals.g_opr_create; -- Mandatory Operation to Pass
               l_line_tbl (V_LINE_NO).INVENTORY_ITEM_ID :=
                  rec_line.INVENTORY_ITEM_ID;
               l_line_tbl (V_LINE_NO).ordered_quantity := rec_line.QUANTITY;
               --  l_line_tbl (V_LINE_NO).UNIT_SELLING_PRICE :=2;
               -- rec_line.FINAL_PRICE;

               --  l_line_tbl (V_LINE_NO).order_quantity_uom := V_CURRENCY;
               l_line_tbl (V_LINE_NO).calculate_price_flag := 'N';
               l_line_tbl (V_LINE_NO).unit_selling_price := rec_line.RATE; --145;
               l_line_tbl (V_LINE_NO).unit_list_price := rec_line.RATE; --145;

               l_line_tbl (V_LINE_NO).ship_from_org_id := V_SHIP_FROM_INV_ORG_ID;
               l_line_tbl (V_LINE_NO).subinventory := NULL;
               l_line_tbl (V_LINE_NO).CONTEXT := rec_line.LINE_CONTEXT;
               l_line_tbl (V_LINE_NO).ATTRIBUTE1 := rec_line.L_ATTRIBUTE1;
               l_line_tbl (V_LINE_NO).ATTRIBUTE2 := rec_line.L_ATTRIBUTE2;
               l_line_tbl (V_LINE_NO).ATTRIBUTE3 := rec_line.L_ATTRIBUTE3;
               l_line_tbl (V_LINE_NO).ATTRIBUTE4 := rec_line.L_ATTRIBUTE4;
               l_line_tbl (V_LINE_NO).ATTRIBUTE5 := rec_line.L_ATTRIBUTE5;
               l_line_tbl (V_LINE_NO).ATTRIBUTE6 := rec_line.L_ATTRIBUTE6;
               l_line_tbl (V_LINE_NO).ATTRIBUTE7 := rec_line.L_ATTRIBUTE7;
               l_line_tbl (V_LINE_NO).ATTRIBUTE8 := rec_line.L_ATTRIBUTE8;
               l_line_tbl (V_LINE_NO).ATTRIBUTE9 := rec_line.L_ATTRIBUTE9;
               l_line_tbl (V_LINE_NO).ATTRIBUTE10 := rec_line.L_ATTRIBUTE10;
               l_line_tbl (V_LINE_NO).REQUEST_DATE := V_ORDER_DATE;
               l_line_tbl (V_LINE_NO).promise_date := V_ORDER_DATE; --SYSDATE ;
               l_line_tbl (V_LINE_NO).pricing_date := V_ORDER_DATE;
               l_line_tbl (V_LINE_NO).schedule_ship_date := V_ORDER_DATE; --SYSDATE ;
               V_LINE_NO := V_LINE_NO + 1;
            END;
         END LOOP;
      END;

      -- To BOOK the Sales Order
      l_action_request_tbl (1) := oe_order_pub.G_MISS_REQUEST_REC;
      l_action_request_tbl (1).request_type := oe_globals.g_book_order;
      l_action_request_tbl (1).entity_code := oe_globals.g_entity_header;

      DBMS_OUTPUT.PUT_LINE ('342');

      FOR i IN 1 .. l_no_orders
      LOOP
         -- BEGIN LOOP
         -- CALLTO PROCESS ORDER API
         oe_order_pub.process_order (
            p_org_id                   => l_org,
            --     p_operating_unit           => NULL,
            p_api_version_number       => 1.0,
            p_header_rec               => l_header_rec,
            p_line_tbl                 => l_line_tbl,
            p_action_request_tbl       => l_action_request_tbl,
            -- OUT variables
            x_header_rec               => l_header_rec_out,
            x_header_val_rec           => l_header_val_rec_out,
            x_header_adj_tbl           => l_header_adj_tbl_out,
            x_header_adj_val_tbl       => l_header_adj_val_tbl_out,
            x_header_price_att_tbl     => l_header_price_att_tbl_out,
            x_header_adj_att_tbl       => l_header_adj_att_tbl_out,
            x_header_adj_assoc_tbl     => l_header_adj_assoc_tbl_out,
            x_header_scredit_tbl       => l_header_scredit_tbl_out,
            x_header_scredit_val_tbl   => l_header_scredit_val_tbl_out,
            x_line_tbl                 => l_line_tbl_out,
            x_line_val_tbl             => l_line_val_tbl_out,
            x_line_adj_tbl             => l_line_adj_tbl_out,
            x_line_adj_val_tbl         => l_line_adj_val_tbl_out,
            x_line_price_att_tbl       => l_line_price_att_tbl_out,
            x_line_adj_att_tbl         => l_line_adj_att_tbl_out,
            x_line_adj_assoc_tbl       => l_line_adj_assoc_tbl_out,
            x_line_scredit_tbl         => l_line_scredit_tbl_out,
            x_line_scredit_val_tbl     => l_line_scredit_val_tbl_out,
            x_lot_serial_tbl           => l_lot_serial_tbl_out,
            x_lot_serial_val_tbl       => l_lot_serial_val_tbl_out,
            x_action_request_tbl       => l_action_request_tbl_out,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

         -- CHECK RETURN STATUS
         IF l_return_status = fnd_api.g_ret_sts_success
         THEN
            IF (l_debug_level > 0)
            THEN
               DBMS_OUTPUT.put_line ('Sales Order Successfully Created');
               DBMS_OUTPUT.put_line ('Sales Order is Created And Order Number Is : '|| l_header_rec_out.order_number);
               DBMS_OUTPUT.PUT_LINE ('header.flow_status_code IS: '|| l_header_rec_out.flow_status_code);
               DBMS_OUTPUT.PUT_LINE ('HEADER_ID IS: ' || l_header_rec_out.header_id);

               DBMS_OUTPUT.PUT_LINE ('process ORDER ret status IS: ' || l_return_status);
               X_SO_NUMBER := l_header_rec_out.order_number;
               X_SO_HEADER_ID := l_header_rec_out.header_id;

               UPDATE XXPWC.ICT_INTERFACE_SALE_HEADERS_ALL
                  SET SO_HEADER_ID = X_SO_HEADER_ID,
                      ORDER_NUMBER = X_SO_NUMBER
                WHERE ORDER_HEADER_ID = P_ORDER_HEADER_ID;

               DBMS_OUTPUT.PUT_LINE (P_ORDER_HEADER_ID || 'SO CREATED');
            END IF;
			
COMMIT;
         ELSE
            IF (l_debug_level > 0)
            THEN
               FOR i IN 1 .. l_msg_count
               LOOP
                  Oe_Msg_Pub.get (p_msg_index       => i,
                                  p_encoded         => Fnd_Api.G_FALSE,
                                  p_data            => l_msg_data,
                                  p_msg_index_out   => l_msg_index_out);
                  DBMS_OUTPUT.PUT_LINE ('message : ' || l_msg_data);
                  DBMS_OUTPUT.PUT_LINE (
                     'message index : ' || l_msg_index_out);
               END LOOP;

               DBMS_OUTPUT.put_line ('Failed to Create Sales Order');
               DBMS_OUTPUT.put_line (l_msg_count);
               DBMS_OUTPUT.put_line (l_msg_data);
            END IF;
            ROLLBACK;
         END IF;
      END LOOP;
   END;
END;
/