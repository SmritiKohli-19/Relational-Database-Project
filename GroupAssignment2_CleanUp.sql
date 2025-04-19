-- =============================================
-- Cleanup Script for Vinyl Collection Database
-- Run as SYSDBA before recreating the database
-- =============================================

-- Connect as SYSDBA
CONNECT sys AS sysdba;

DROP PROCEDURE groupAssignment2_admin.sp_checkInvalidArtistName;
-- Drop the user and tablespace
DROP USER groupAssignment2_admin CASCADE;
DROP TABLESPACE cst2355_GroupAssignment2 INCLUDING CONTENTS AND DATAFILES;

COMMIT;
-- End of File