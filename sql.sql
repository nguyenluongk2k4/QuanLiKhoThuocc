-- supabase_medicine_app_int_logtype.sql
-- Quản lý thuốc đông y: log nhập/xuất dùng int (1=IN, 2=OUT)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1) Users
CREATE TABLE IF NOT EXISTS app_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE,
  full_name text,
  role text DEFAULT 'user',
  created_at timestamptz DEFAULT now()
);

-- 2) Products
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,      -- mã sản phẩm
  name text NOT NULL,
  traditional_name text,
  description text,
  qr_image_url text,              -- link ảnh QR trong Supabase Storage (nếu có)
  created_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- 3) Nhật ký nhập / xuất (log_type dùng int)
CREATE TABLE IF NOT EXISTS inventory_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  log_type int NOT NULL CHECK (log_type IN (1,2)), -- 1 = Nhập, 2 = Xuất
  log_date date NOT NULL DEFAULT current_date,
  reference text,
  note text,
  processed_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- 4) Seed data
INSERT INTO app_users (id, email, full_name, role)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@example.com', 'Admin', 'admin')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (code, name, traditional_name, description, created_by)
VALUES
  ('TY-001','Đinh lăng khô','Đinh lăng','Rễ đinh lăng khô bồi bổ sức khỏe', '00000000-0000-0000-0000-000000000001'),
  ('TY-002','Tam thất bột','Tam thất','Bột tam thất cầm máu và bổ máu', '00000000-0000-0000-0000-000000000001')
ON CONFLICT (code) DO NOTHING;

INSERT INTO inventory_logs (product_id, log_type, log_date, reference, note, processed_by)
SELECT id, 1, current_date, 'init', 'Nhập kho ban đầu', '00000000-0000-0000-0000-000000000001'
FROM products
WHERE code IN ('TY-001','TY-002')
ON CONFLICT DO NOTHING;
