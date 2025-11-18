
--Zabbix 5.0. Do not work on 6.0. Set guest the same as super admin
UPDATE users SET type=(
SELECT type FROM users WHERE alias='Admin'
) WHERE alias='guest';

--Zabbix 6.0
UPDATE users SET roleid=(
    SELECT roleid FROM role WHERE name='Super admin role'
    ) WHERE roleid=(
        SELECT roleid FROM role WHERE name='Guest role'
        );

--Zabbix 5.0/6.0. Replace associated 'Disabled' group with 'Zabbix administrators'
UPDATE users_groups SET usrgrpid=(
    SELECT usrgrpid FROM usrgrp WHERE name='Zabbix administrators'
    ) WHERE usrgrpid=(
        SELECT usrgrpid FROM usrgrp WHERE name='Disabled'
        );


--Zabbix 6.0. Set guest the same as super admin
UPDATE users SET type=(
SELECT type FROM users WHERE username='Admin'
) WHERE username='guest';

--Zabbix 6.0
UPDATE users SET rows_per_page=2000 WHERE rows_per_page=50;
