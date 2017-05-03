CREATE ROLE CEO;
REVOKE ALL ON ALL TABLES TO CEO;
GRANT ALL ON ALL TO CEO;

CREATE ROLE CFO;
REVOKE ALL ON ALL TABLES TO CFO;
GRANT SELECT ON PaymentsPerQuarter TO CFO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Websites TO CFO;
GRANT SELECT ON Business TO CFO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Employees TO CFO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON RatesPerQuarter TO CFO;

CREATE ROLE CTO;
REVOKE ALL ON ALL TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Backups TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Hosting TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Servers TO CTO;
GRANT SELECT ON ActiveUsersPerQuarter TO CTO;
GRANT UPDATE, SELECT, ON Websites TO CTO;
GRANT SELECT ON Business TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Datacenters TO CTO;

CREATE ROLE CMO;
REVOKE ALL ON ALL TABLES TO CMO;
GRANT SELECT ON PaymentsPerQuarter TO CMO;
GRANT SELECT ON ActiveUsersPerQuarter TO CMO;
GRANT SELECT ON Websites TO CMO;
GRANT SELECT ON Business TO CMO;
GRANT SELECT ON Datacenters TO CMO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON RatesPerQuarter TO CMO;