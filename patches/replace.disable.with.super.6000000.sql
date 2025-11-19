--Zabbix 5.0/6.0. Replace associated 'Disabled' group with 'Zabbix administrators'
UPDATE users_groups SET usrgrpid=(
    SELECT usrgrpid FROM usrgrp WHERE name='Zabbix administrators'
    ) WHERE usrgrpid=(
        SELECT usrgrpid FROM usrgrp WHERE name='Disabled'
        );
