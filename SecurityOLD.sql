REVOKE ALL Backups TO CEO;
REVOKE ALL Hosting TO CEO;
REVOKE ALL PaymentsPerQuarter TO CEO;
REVOKE ALL Servers TO CEO;
REVOKE ALL ActiveUsersPerQuarter TO CEO;
REVOKE ALL Websites TO CEO;
REVOKE ALL Business TO CEO;
REVOKE ALL Employees TO CEO;
REVOKE ALL Datacenters TO CEO;
REVOKE ALL Address TO CEO;
REVOKE ALL ZipTO CEO;
REVOKE ALL Quarters TO CEO;
REVOKE ALL RatesPerQuarter TO CEO;

GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Backups TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Hosting TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON PaymentsPerQuarter TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Servers TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON ActiveUsersPerQuarter TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Websites TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Business TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Employees TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Datacenters TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Address TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON ZipTO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Quarters TO CEO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON RatesPerQuarter TO CEO;

REVOKE ALL Backups TO CFO;
REVOKE ALL Hosting TO CFO;
REVOKE ALL PaymentsPerQuarter TO CFO;
REVOKE ALL Servers TO CFO;
REVOKE ALL ActiveUsersPerQuarter TO CFO;
REVOKE ALL Websites TO CFO;
REVOKE ALL Business TO CFO;
REVOKE ALL Employees TO CFO;
REVOKE ALL Datacenters TO CFO;
REVOKE ALL Address TO CFO;
REVOKE ALL ZipTO CFO;
REVOKE ALL Quarters TO CFO;
REVOKE ALL RatesPerQuarter TO CFO;

GRANT SELECT ON PaymentsPerQuarter TO CFO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Websites TO CFO;
GRANT SELECT ON Business TO CFO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Employees TO CFO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON RatesPerQuarter TO CFO;

REVOKE ALL Backups TO CTO;
REVOKE ALL Hosting TO CTO;
REVOKE ALL PaymentsPerQuarter TO CTO;
REVOKE ALL Servers TO CTO;
REVOKE ALL ActiveUsersPerQuarter TO CTO;
REVOKE ALL Websites TO CTO;
REVOKE ALL Business TO CTO;
REVOKE ALL Employees TO CTO;
REVOKE ALL Datacenters TO CTO;
REVOKE ALL Address TO CTO;
REVOKE ALL ZipTO CTO;
REVOKE ALL Quarters TO CTO;
REVOKE ALL RatesPerQuarter TO CTO;

GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Backups TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Hosting TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Servers TO CTO;
GRANT SELECT ON ActiveUsersPerQuarter TO CTO;
GRANT UPDATE, SELECT, ON Websites TO CTO;
GRANT SELECT ON Business TO CTO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON Datacenters TO CTO;

REVOKE ALL Backups TO CMO;
REVOKE ALL Hosting TO CMO;
REVOKE ALL PaymentsPerQuarter TO CMO;
REVOKE ALL Servers TO CMO;
REVOKE ALL ActiveUsersPerQuarter TO CMO;
REVOKE ALL Websites TO CMO;
REVOKE ALL Business TO CMO;
REVOKE ALL Employees TO CMO;
REVOKE ALL Datacenters TO CMO;
REVOKE ALL Address TO CMO;
REVOKE ALL ZipTO CMO;
REVOKE ALL Quarters TO CMO;
REVOKE ALL RatesPerQuarter TO CMO;

GRANT SELECT ON PaymentsPerQuarter TO CMO;
GRANT SELECT ON ActiveUsersPerQuarter TO CMO;
GRANT SELECT ON Websites TO CMO;
GRANT SELECT ON Business TO CMO;
GRANT SELECT ON Datacenters TO CMO;
GRANT INSERT, UPDATE, DELETE, SELECT, ALTER ON RatesPerQuarter TO CMO;

COMMIT;