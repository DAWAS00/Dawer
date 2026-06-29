-- Seed realistic demo data across every page/feature for the 4 fixed test users
-- (driver 1111..., supplier-individual 2222..., supplier-storeBusiness 3333..., recyclingCo 4444...)
-- so a tester can click through analytics, wallet, chat, marketplace, notifications, reports
-- without hitting empty states. Safe to re-run (idempotent inserts).

-- 1. Completed pickup orders spread across past days -> feeds analytics streak heatmap / cycle-time
insert into public.orders (id, type, status, supplier_id, driver_id, company_id, waste_types, waste_form,
  weight_category, estimated_weight_kg, actual_weight_kg, distance_km, reward_jd,
  pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
  created_at, accepted_at, arrived_at_pickup_at, in_transit_at, arrived_at_dropoff_at, completed_at)
values
  ('50000000-0000-0000-0000-000000000001','pickup','completed','22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   ARRAY['paper'],'solid','light',8,8,3.2,2.50, 31.9454,35.9284, 31.9000,35.8800,
   '2026-06-15 09:00:00+00','2026-06-15 09:05:00+00','2026-06-15 09:20:00+00','2026-06-15 09:25:00+00','2026-06-15 09:55:00+00','2026-06-15 10:00:00+00'),
  ('50000000-0000-0000-0000-000000000002','pickup','completed','33333333-3333-3333-3333-333333333333','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   ARRAY['organic'],'solid','medium',25,25,6.0,4.00, 31.9510,35.9180, 31.9000,35.8800,
   '2026-06-17 10:00:00+00','2026-06-17 10:05:00+00','2026-06-17 10:20:00+00','2026-06-17 10:25:00+00','2026-06-17 11:10:00+00','2026-06-17 11:15:00+00'),
  ('50000000-0000-0000-0000-000000000003','pickup','completed','22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   ARRAY['plastic'],'solid','light',6,6,2.0,2.00, 31.9454,35.9284, 31.9000,35.8800,
   '2026-06-19 11:00:00+00','2026-06-19 11:05:00+00','2026-06-19 11:15:00+00','2026-06-19 11:20:00+00','2026-06-19 11:45:00+00','2026-06-19 11:50:00+00'),
  ('50000000-0000-0000-0000-000000000004','pickup','completed','33333333-3333-3333-3333-333333333333','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   ARRAY['oil'],'liquid','medium',20,20,4.0,3.50, 31.9510,35.9180, 31.9000,35.8800,
   '2026-06-21 12:00:00+00','2026-06-21 12:05:00+00','2026-06-21 12:20:00+00','2026-06-21 12:25:00+00','2026-06-21 13:00:00+00','2026-06-21 13:05:00+00')
on conflict (id) do nothing;

-- 2. Collection job (company posts) + linked collectionSale (driver fulfils, supplier is the seller)
insert into public.orders (id, type, status, supplier_id, driver_id, company_id, waste_types, waste_form,
  weight_category, estimated_weight_kg, actual_weight_kg, distance_km, reward_jd,
  collection_delivery_method, collection_transaction_type,
  pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
  created_at, accepted_at, in_transit_at, completed_at)
values
  ('50000000-0000-0000-0000-000000000005','collection','completed',null,'11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   ARRAY['metal','electronics'],'solid','heavy',40,40,5.5,5.00,'assignRider','sell',
   31.9300,35.9100, 31.9000,35.8800,
   '2026-06-23 09:00:00+00','2026-06-23 09:10:00+00','2026-06-23 09:30:00+00','2026-06-23 11:00:00+00')
on conflict (id) do nothing;

insert into public.orders (id, type, status, supplier_id, driver_id, company_id, linked_job_id, waste_types, waste_form,
  weight_category, estimated_weight_kg, actual_weight_kg, distance_km, reward_jd, payment_model, price_per_kg,
  pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
  created_at, accepted_at, in_transit_at, completed_at)
values
  ('50000000-0000-0000-0000-000000000006','collectionSale','completed','33333333-3333-3333-3333-333333333333','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   '50000000-0000-0000-0000-000000000005',
   ARRAY['metal','electronics'],'solid','heavy',40,40,5.5,4.50,'perKg',0.15,
   31.9300,35.9100, 31.9000,35.8800,
   '2026-06-23 09:30:00+00','2026-06-23 09:35:00+00','2026-06-23 09:45:00+00','2026-06-23 11:00:00+00')
on conflict (id) do nothing;

-- 3. In-progress orders today -> exercise mid-flow driver states & wallet holds
insert into public.orders (id, type, status, supplier_id, driver_id, waste_types, waste_form,
  weight_category, estimated_weight_kg, distance_km, reward_jd,
  pickup_lat, pickup_lng,
  created_at, accepted_at, arrived_at_pickup_at)
values
  ('50000000-0000-0000-0000-000000000007','pickup','arrivedAtPickup','22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111',
   ARRAY['paper','plastic'],'solid','light',7,2.8,2.20, 31.9454,35.9284,
   '2026-06-29 08:30:00+00','2026-06-29 08:35:00+00','2026-06-29 08:50:00+00')
on conflict (id) do nothing;

insert into public.orders (id, type, status, supplier_id, driver_id, company_id, waste_types, waste_form,
  weight_category, estimated_weight_kg, distance_km, reward_jd,
  pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
  created_at, accepted_at, arrived_at_pickup_at, in_transit_at, arrived_at_dropoff_at)
values
  ('50000000-0000-0000-0000-000000000008','pickup','arrivedAtDropoff','33333333-3333-3333-3333-333333333333','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444',
   ARRAY['organic'],'solid','medium',22,5.1,3.00, 31.9510,35.9180, 31.9000,35.8800,
   '2026-06-29 09:00:00+00','2026-06-29 09:05:00+00','2026-06-29 09:20:00+00','2026-06-29 09:25:00+00','2026-06-29 09:55:00+00')
on conflict (id) do nothing;

-- 4. A cancelled order -> populates the cancelled tab
insert into public.orders (id, type, status, supplier_id, waste_types, waste_form, weight_category,
  estimated_weight_kg, reward_jd, cancelled_by, notes, created_at)
values
  ('50000000-0000-0000-0000-000000000009','pickup','cancelled','22222222-2222-2222-2222-222222222222',
   ARRAY['glass'],'solid','light',5,1.80,'supplier','تراجع المورد عن الطلب','2026-06-26 14:00:00+00')
on conflict (id) do nothing;

-- 5. A fresh open marketplace listing (restaurant supplier) + flag two existing pending orders as shared
insert into public.orders (id, type, status, supplier_id, waste_types, waste_form, weight_category,
  estimated_weight_kg, reward_jd, is_marketplace_shared, requires_rider, job_description,
  pickup_lat, pickup_lng, created_at)
values
  ('50000000-0000-0000-0000-00000000000a','pickup','pending','33333333-3333-3333-3333-333333333333',
   ARRAY['organic','oil'],'mixed','heavy',60,6.00,true,true,
   'فضلات مطعم قابلة للتحويل لسماد + زيت طهي مستخدم',
   31.9510,35.9180,'2026-06-29 07:00:00+00')
on conflict (id) do nothing;

-- 6. Transactions for the newly completed driver orders
insert into public.transactions (order_id, driver_id, base_fee_jd, distance_fee_jd, material_fee_jd, urgency_bonus_jd, status, created_at)
values
  ('50000000-0000-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',1.500,0.640,0.500,0.000,'paid','2026-06-15 10:00:00+00'),
  ('50000000-0000-0000-0000-000000000002','11111111-1111-1111-1111-111111111111',1.500,1.200,1.200,0.000,'paid','2026-06-17 11:15:00+00'),
  ('50000000-0000-0000-0000-000000000003','11111111-1111-1111-1111-111111111111',1.500,0.400,0.300,0.000,'paid','2026-06-19 11:50:00+00'),
  ('50000000-0000-0000-0000-000000000004','11111111-1111-1111-1111-111111111111',1.500,0.800,1.000,0.500,'paid','2026-06-21 13:05:00+00'),
  ('50000000-0000-0000-0000-000000000006','11111111-1111-1111-1111-111111111111',1.500,1.100,2.000,0.000,'paid','2026-06-23 11:00:00+00')
on conflict (order_id) do nothing;

-- 7. Driver wallet + a couple of hold/release entries (orders 7 & 8 are mid-flow -> held funds)
insert into public.driver_wallet (driver_id, balance, held_amount, updated_at)
values ('11111111-1111-1111-1111-111111111111', 14.30, 5.20, now())
on conflict (driver_id) do update set balance = excluded.balance, held_amount = excluded.held_amount, updated_at = now();

insert into public.wallet_transactions (driver_id, order_id, type, amount, note, created_at)
values
  ('11111111-1111-1111-1111-111111111111','50000000-0000-0000-0000-000000000007','hold',2.20,'تعليق أجرة الطلب قيد الاستلام','2026-06-29 08:35:00+00'),
  ('11111111-1111-1111-1111-111111111111','50000000-0000-0000-0000-000000000008','hold',3.00,'تعليق أجرة الطلب قيد التسليم','2026-06-29 09:05:00+00'),
  ('11111111-1111-1111-1111-111111111111','50000000-0000-0000-0000-000000000006','release',4.50,'تحرير دفعة طلب التجميع المكتمل','2026-06-23 11:05:00+00');

-- 8. Driver live location (used by supplier/company tracking screens)
insert into public.driver_locations (driver_id, order_id, lat, lng, updated_at)
values ('11111111-1111-1111-1111-111111111111','50000000-0000-0000-0000-000000000007', 31.9460, 35.9290, now())
on conflict (driver_id) do update set order_id = excluded.order_id, lat = excluded.lat, lng = excluded.lng, updated_at = now();

-- 9. Chat messages on an active order room
insert into public.chat_messages (room_id, sender_id, sender_name, sender_role, content, sent_at, is_read, kind)
values
  ('50000000-0000-0000-0000-000000000007','22222222-2222-2222-2222-222222222222','ليلى ناصر أبو حمد','supplier','وصلت لعندي؟','2026-06-29 08:48:00+00',true,'text'),
  ('50000000-0000-0000-0000-000000000007','11111111-1111-1111-1111-111111111111','محمد عمر خليل','driver','نعم وصلت، بكم كيس؟','2026-06-29 08:49:00+00',true,'text'),
  ('50000000-0000-0000-0000-000000000007','22222222-2222-2222-2222-222222222222','ليلى ناصر أبو حمد','supplier','كيسين، بلاستيك وورق','2026-06-29 08:50:00+00',false,'text'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc','11111111-1111-1111-1111-111111111111','محمد عمر خليل','driver','في الطريق إليك، حوالي ٥ دقائق','2026-06-27 15:48:00+00',true,'text'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc','22222222-2222-2222-2222-222222222222','ليلى ناصر أبو حمد','supplier','تمام، بانتظارك','2026-06-27 15:49:00+00',false,'text');

-- 10. Extra notifications covering types not yet represented for these 4 users
insert into public.notifications (recipient_id, type, title, body, order_id, is_read, created_at)
values
  ('11111111-1111-1111-1111-111111111111','pointsEarned','حصلت على نقاط جديدة','أضفنا 35 نقطة خُضَر لحسابك بعد إكمال طلب الزيت','50000000-0000-0000-0000-000000000004',true,'2026-06-21 13:05:00+00'),
  ('33333333-3333-3333-3333-333333333333','accountVerified','تم توثيق حسابك','تهانينا، تم توثيق حساب مطعم الزيتونة بنجاح',null,true,'2026-06-10 09:00:00+00'),
  ('11111111-1111-1111-1111-111111111111','collectionJobPosted','مهمة تجميع جديدة من الشركة','شركة الخضراء نشرت مهمة تجميع معادن وإلكترونيات','50000000-0000-0000-0000-000000000005',true,'2026-06-23 09:00:00+00'),
  ('44444444-4444-4444-4444-444444444444','collectionJobAccepted','تم قبول مهمة التجميع','محمد عمر خليل قبل مهمة التجميع وأنهاها بنجاح','50000000-0000-0000-0000-000000000006',true,'2026-06-23 11:00:00+00'),
  ('11111111-1111-1111-1111-111111111111','systemBroadcast','تحديث على التطبيق','أضفنا تحسينات على شاشة التتبع المباشر',null,false,'2026-06-28 08:00:00+00'),
  ('22222222-2222-2222-2222-222222222222','systemBroadcast','تحديث على التطبيق','أضفنا تحسينات على شاشة التتبع المباشر',null,false,'2026-06-28 08:00:00+00'),
  ('33333333-3333-3333-3333-333333333333','systemBroadcast','تحديث على التطبيق','أضفنا تحسينات على شاشة التتبع المباشر',null,false,'2026-06-28 08:00:00+00'),
  ('44444444-4444-4444-4444-444444444444','systemBroadcast','تحديث على التطبيق','أضفنا تحسينات على شاشة التتبع المباشر',null,false,'2026-06-28 08:00:00+00');

-- 11. Report requests for the analytics/reports tab
insert into public.report_requests (user_id, template, status, period_start, period_end, requested_at)
values
  ('44444444-4444-4444-4444-444444444444','weeklySummary','ready','2026-06-22','2026-06-28','2026-06-28 09:00:00+00'),
  ('44444444-4444-4444-4444-444444444444','co2Certificate','processing','2026-01-01','2026-06-29','2026-06-29 08:00:00+00'),
  ('33333333-3333-3333-3333-333333333333','monthlyInvoice','ready','2026-05-01','2026-05-31','2026-06-01 09:00:00+00');
