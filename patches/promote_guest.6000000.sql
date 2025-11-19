UPDATE users SET roleid=(
    SELECT roleid FROM role WHERE name='Super admin role'
    ) WHERE roleid=(
        SELECT roleid FROM role WHERE name='Guest role'
        );
