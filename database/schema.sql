-- =========================================================================
-- ระบบฐานข้อมูล: BRT Laos Application (Bus Rapid Transit System)
-- DBMS: Microsoft SQL Server (T-SQL)
-- =========================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BRT_Bus_DB')
BEGIN
    CREATE DATABASE BRT_Bus_DB;
END
GO

USE BRT_Bus_DB;
GO

-- =========================================================================
-- ส่วนที่ 1: ระบบผู้ใช้งานและการชำระเงินที่บันทึกไว้ (User & Profile Module)
-- =========================================================================

IF OBJECT_ID(N'dbo.UserPaymentMethods', N'U') IS NOT NULL DROP TABLE dbo.UserPaymentMethods;
IF OBJECT_ID(N'dbo.TicketScans', N'U') IS NOT NULL DROP TABLE dbo.TicketScans;
IF OBJECT_ID(N'dbo.Transactions', N'U') IS NOT NULL DROP TABLE dbo.Transactions;
IF OBJECT_ID(N'dbo.Tickets', N'U') IS NOT NULL DROP TABLE dbo.Tickets;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;

CREATE TABLE Users (
    user_id             NVARCHAR(50)    NOT NULL PRIMARY KEY, -- เช่น UID จาก Firebase
    email               NVARCHAR(100)   NOT NULL UNIQUE,
    full_name           NVARCHAR(150)   NOT NULL,
    phone               NVARCHAR(25)    NULL,
    gender              NVARCHAR(10)    NULL CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth       DATE            NULL,
    profile_image_url   NVARCHAR(500)   NULL,
    role                NVARCHAR(20)    NOT NULL DEFAULT 'passenger' CHECK (role IN ('passenger', 'driver', 'staff', 'admin')),
    is_active           BIT             NOT NULL DEFAULT 1,
    created_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    updated_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE UserPaymentMethods (
    payment_method_id   INT IDENTITY(1,1) PRIMARY KEY,
    user_id             NVARCHAR(50)    NOT NULL,
    provider            NVARCHAR(50)    NOT NULL, -- เช่น 'BCEL One / OnePay', 'LDB Bank', 'Visa/Master'
    account_name        NVARCHAR(150)   NOT NULL,
    account_number      NVARCHAR(50)    NOT NULL, -- เช่น '***-***-8921'
    is_default          BIT             NOT NULL DEFAULT 0,
    created_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_UserPayment_User FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
GO

-- =========================================================================
-- ส่วนที่ 2: ระบบสถานี เส้นทาง และรถเมล์ (Bus, Route & Station Module)
-- =========================================================================

IF OBJECT_ID(N'dbo.Schedules', N'U') IS NOT NULL DROP TABLE dbo.Schedules;
IF OBJECT_ID(N'dbo.Buses', N'U') IS NOT NULL DROP TABLE dbo.Buses;
IF OBJECT_ID(N'dbo.RouteStations', N'U') IS NOT NULL DROP TABLE dbo.RouteStations;
IF OBJECT_ID(N'dbo.Routes', N'U') IS NOT NULL DROP TABLE dbo.Routes;
IF OBJECT_ID(N'dbo.Stations', N'U') IS NOT NULL DROP TABLE dbo.Stations;

CREATE TABLE Stations (
    station_id          NVARCHAR(50)    NOT NULL PRIMARY KEY, -- เช่น 'ST_TALATXAO', 'ST_DONGDOK'
    name_la             NVARCHAR(100)   NOT NULL,             -- ຕະຫຼາດເຊົ້າ
    name_en             NVARCHAR(100)   NOT NULL,             -- Talat Sao
    latitude            DECIMAL(9, 6)   NULL,
    longitude           DECIMAL(9, 6)   NULL,
    is_active           BIT             NOT NULL DEFAULT 1,
    created_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Routes (
    route_id            NVARCHAR(50)    NOT NULL PRIMARY KEY, -- เช่น 'RT-01'
    route_name          NVARCHAR(150)   NOT NULL,
    origin_station_id   NVARCHAR(50)    NULL,
    dest_station_id     NVARCHAR(50)    NULL,
    base_price          INT             NOT NULL DEFAULT 7000, -- สกุลเงินกีบ (LAK)
    estimated_duration  NVARCHAR(50)    NULL,
    is_active           BIT             NOT NULL DEFAULT 1,
    CONSTRAINT FK_Route_Origin FOREIGN KEY (origin_station_id) REFERENCES Stations(station_id),
    CONSTRAINT FK_Route_Dest FOREIGN KEY (dest_station_id) REFERENCES Stations(station_id)
);
GO

CREATE TABLE RouteStations (
    route_station_id    INT IDENTITY(1,1) PRIMARY KEY,
    route_id            NVARCHAR(50)    NOT NULL,
    station_id          NVARCHAR(50)    NOT NULL,
    stop_order          INT             NOT NULL,
    CONSTRAINT FK_RS_Route FOREIGN KEY (route_id) REFERENCES Routes(route_id) ON DELETE CASCADE,
    CONSTRAINT FK_RS_Station FOREIGN KEY (station_id) REFERENCES Stations(station_id),
    CONSTRAINT UQ_Route_StopOrder UNIQUE (route_id, stop_order)
);
GO

CREATE TABLE Buses (
    bus_id              INT IDENTITY(1,1) PRIMARY KEY,
    bus_code            NVARCHAR(50)    NOT NULL UNIQUE, -- เช่น 'BRT-01'
    bus_name            NVARCHAR(100)   NOT NULL,        -- เช่น 'BRT Express 01'
    license_plate       NVARCHAR(30)    NULL,
    driver_name         NVARCHAR(100)   NULL,            -- เช่น 'ສົມພອນ (Somphone)'
    current_route_id    NVARCHAR(50)    NULL,
    status              NVARCHAR(20)    NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'on_route', 'maintenance')),
    created_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Bus_Route FOREIGN KEY (current_route_id) REFERENCES Routes(route_id)
);
GO

CREATE TABLE Schedules (
    schedule_id         INT IDENTITY(1,1) PRIMARY KEY,
    bus_id              INT             NULL,
    route_id            NVARCHAR(50)    NOT NULL,
    departure_time      TIME            NOT NULL,
    arrival_time        TIME            NULL,
    frequency_text      NVARCHAR(50)    NULL,
    operating_days      NVARCHAR(50)    NOT NULL DEFAULT 'Everyday',
    CONSTRAINT FK_Sched_Bus FOREIGN KEY (bus_id) REFERENCES Buses(bus_id),
    CONSTRAINT FK_Sched_Route FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);
GO

-- =========================================================================
-- ส่วนที่ 3: ระบบการออกตั๋ว และการสแกน (Ticketing & Booking Module)
-- =========================================================================

CREATE TABLE Tickets (
    ticket_id           NVARCHAR(50)    NOT NULL PRIMARY KEY, -- เช่น 'BRT-2610-8934'
    user_id             NVARCHAR(50)    NOT NULL,
    user_email          NVARCHAR(100)   NOT NULL,
    origin_station      NVARCHAR(100)   NOT NULL,
    destination_station NVARCHAR(100)   NOT NULL,
    route_id            NVARCHAR(50)    NULL,
    quantity            INT             NOT NULL DEFAULT 1,
    price_per_ticket    INT             NOT NULL DEFAULT 7000,
    total_amount        INT             NOT NULL,
    currency            NVARCHAR(10)    NOT NULL DEFAULT 'LAK',
    status              NVARCHAR(20)    NOT NULL DEFAULT 'paid' CHECK (status IN ('paid', 'used', 'expired', 'cancelled')),
    payment_method      NVARCHAR(50)    NOT NULL DEFAULT 'BCEL OnePay',
    transaction_id      NVARCHAR(100)   NULL,
    qr_payload          NVARCHAR(MAX)   NOT NULL,
    created_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    expires_at          DATETIME2       NOT NULL,
    used_at             DATETIME2       NULL,
    CONSTRAINT FK_Ticket_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Ticket_Route FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);
GO

CREATE TABLE TicketScans (
    scan_id             INT IDENTITY(1,1) PRIMARY KEY,
    ticket_id           NVARCHAR(50)    NOT NULL,
    scanned_by_staff_id NVARCHAR(50)    NULL,
    station_id          NVARCHAR(50)    NULL,
    bus_id              INT             NULL,
    scan_result         NVARCHAR(30)    NOT NULL CHECK (scan_result IN ('SUCCESS', 'ALREADY_USED', 'EXPIRED', 'INVALID')),
    scanned_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Scan_Ticket FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id),
    CONSTRAINT FK_Scan_Station FOREIGN KEY (station_id) REFERENCES Stations(station_id),
    CONSTRAINT FK_Scan_Bus FOREIGN KEY (bus_id) REFERENCES Buses(bus_id)
);
GO

-- =========================================================================
-- ส่วนที่ 4: ระบบการเงินและโปรโมชั่น (Payment & Promotion Module)
-- =========================================================================

IF OBJECT_ID(N'dbo.Promotions', N'U') IS NOT NULL DROP TABLE dbo.Promotions;

CREATE TABLE Promotions (
    promo_id            INT IDENTITY(1,1) PRIMARY KEY,
    promo_code          NVARCHAR(30)    NOT NULL UNIQUE,
    title               NVARCHAR(100)   NULL,
    discount_type       NVARCHAR(20)    NOT NULL DEFAULT 'fixed' CHECK (discount_type IN ('fixed', 'percent')),
    discount_value      INT             NOT NULL,
    min_spend           INT             NOT NULL DEFAULT 0,
    max_uses            INT             NOT NULL DEFAULT 100,
    used_count          INT             NOT NULL DEFAULT 0,
    valid_from          DATETIME2       NOT NULL,
    valid_until         DATETIME2       NOT NULL,
    is_active           BIT             NOT NULL DEFAULT 1
);
GO

CREATE TABLE Transactions (
    transaction_id      NVARCHAR(100)   NOT NULL PRIMARY KEY, -- เช่น 'TXN-202610-xxxx'
    ticket_id           NVARCHAR(50)    NULL,
    user_id             NVARCHAR(50)    NOT NULL,
    payment_method      NVARCHAR(50)    NOT NULL,
    amount              INT             NOT NULL,
    currency            NVARCHAR(10)    NOT NULL DEFAULT 'LAK',
    status              NVARCHAR(20)    NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'refunded')),
    gateway_ref_id      NVARCHAR(100)   NULL,
    created_at          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    completed_at        DATETIME2       NULL,
    CONSTRAINT FK_Txn_Ticket FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id),
    CONSTRAINT FK_Txn_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO

-- Indexes
CREATE INDEX IX_Tickets_UserStatus ON Tickets (user_id, status);
CREATE INDEX IX_Tickets_ExpiresAt ON Tickets (expires_at);
CREATE INDEX IX_Transactions_UserId ON Transactions (user_id);
CREATE INDEX IX_RouteStations_RouteId ON RouteStations (route_id, stop_order);
GO

-- =========================================================================
-- ข้อมูลตัวอย่างเริ่มต้น (Initial Seed Data)
-- =========================================================================

-- เพิ่มข้อมูลสถานี
INSERT INTO Stations (station_id, name_la, name_en, latitude, longitude) VALUES
('station_talatxao',  N'ຕະຫຼາດເຊົ້າ',             'Talat Sao Central Station', 17.9645, 102.6133),
('station_dongdok',   N'ມະຫາວິທະຍາໄລແຫ່ງຊາດ (ດົງໂດກ)', 'National University (Dongdok)', 18.0345, 102.6341),
('station_thatluang', N'ທາດຫຼວງ',                 'Pha That Luang', 17.9767, 102.6375),
('station_southern',  N'ຄິວລົດສາຍໃຕ້',             'Southern Bus Terminal', 18.0123, 102.6645),
('station_northern',  N'ຄິວລົດສາຍເໜືອ',            'Northern Bus Terminal', 18.0456, 102.5891),
('station_airport',   N'ສະໜາມບິນວັດໄຕ',             'Wattay International Airport', 17.9883, 102.5633),
('station_itecc',     N'ໄອເຕັກ ມໍລ໌',               'ITECC Mall', 17.9542, 102.6450),
('station_sihom',     N'ສີຫອມ',                   'Sihom Station', 17.9678, 102.6050),
('station_sikeut',    N'ສີເກີດ',                   'Sikeut Junction', 18.0678, 102.5512);

-- เพิ่มข้อมูลเส้นทาง
INSERT INTO Routes (route_id, route_name, origin_station_id, dest_station_id, base_price, estimated_duration) VALUES
('RT-01', N'Dongdok -> Talat Sao', 'station_dongdok', 'station_talatxao', 7000, N'30 ນາທີ'),
('RT-02', N'Talat Sao -> Wattay Airport', 'station_talatxao', 'station_airport', 7000, N'25 ນາທີ'),
('RT-03', N'Talat Sao -> ITECC Mall', 'station_talatxao', 'station_itecc', 10000, N'35 ນາທີ');

-- เพิ่มข้อมูลรถเมล์
INSERT INTO Buses (bus_code, bus_name, driver_name, current_route_id, status) VALUES
('BRT-01', N'BRT Express 01', N'ສົມພອນ (Somphone)', 'RT-01', 'active'),
('BRT-02', N'BRT City Line 02', N'ບຸນມີ (Bounmy)', 'RT-02', 'active'),
('BRT-03', N'BRT Shuttle 03', N'ຄຳຫຼ້າ (Khamla)', 'RT-03', 'active'),
('BRT-04', N'BRT Express 04', N'ສົມສັກ (Somsack)', 'RT-01', 'active');

-- เพิ่มโปรโมชั่นตัวอย่าง
INSERT INTO Promotions (promo_code, title, discount_type, discount_value, min_spend, max_uses, valid_from, valid_until) VALUES
('BRTNEW', N'ส่วนลดต้อนรับสมาชิกใหม่', 'fixed', 2000, 7000, 500, SYSDATETIME(), DATEADD(month, 3, SYSDATETIME())),
('BRT10', N'ลด 10% สำหรับการเดินทาง', 'percent', 10, 14000, 200, SYSDATETIME(), DATEADD(month, 1, SYSDATETIME()));
GO
