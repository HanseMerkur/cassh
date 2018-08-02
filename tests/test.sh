#!/bin/bash

PUB_KEY_EXAMPLE='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZA5oaFXhrImv/uKCygPiTgYz3+qZMBLRUdVrI9BAMFkzn+OjcyfG6RCp6QLygXcw6JGHOyoOxcmIcd9ZoefLDK3MUgczTeeb5r2SiTUxziOiVgLnfYb5gUhOWzDJIkfAq7MpAJgweSElSwrpCrt5Xj3axlJDo8Qo/q9SrR+v5Pw3dB4izdcITPU6zarW/k596Va9/KYMg/082QpvG98bQnwOvkBPERUFyNHTduVE5oe6jdlIZZXC5YT9KnWyoTc//koOARRYsdQ8Ny92fLYKiT/2Dm+7p3XKznusRp6arbr84bbRnu9BpReVGj8RWOTZFDaTKvinV62G50Zm+m60hqG5RZUUwbaJwYwbAwoNpHTLh6v4SOUKIa1uqXB6f/6nrstFu7PCziH16eO0VQpI5I7ZsdioKA3JYwvanlC0h+8aNrUANFYGlC8cujWVWzc33laoulSu/uhFPxFofcwAA1lxjgPcSW2sAT/ZlgCAyh5ZIyq6ReHa1R9ZMors3TJiI4U/cMBtbft+GotEUJCEQE/p1Gy6JnQg37Tsz5m90KF/SVpJnHxIYfpbYleQj39sDIar7/YG8YSoi0zSjK5I8JS29JEJtboOv2Px7+A7dnizWTZyArqeTgG74umbv2oy74MpbDkEEk5n3naTyDrU4L3JE3QiVh/N+cGH3zJEn1w== exemple'
PUB_KEY_2_EXAMPLE='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN8R6msOkhrivOoS7UysmVK2ANGlLGguwQiUIQwW6KKazD8Rv1zQapfD+CMlH+AIIx4VYXeLVskFydFnfKdBmRVT/BY+YVVleiHRmVkHrAOdEZSAcUdMVR9NSp9JPgmKlpm3Rsof910SuKLRipe6i5fGW0pGYyNY01TT46eMlr0QbirQ/QEW18O8DGT8P585IGpx3KLJcPooltPKKsEHEYzWk6ZeMTWNzKlHD9j3eWvPofgqU+oDTiLHqM/xezd9Sph+DNEc8T41wTwIY/N4zEM77AJ56+Fxvha0FZeHsFp37BrAPC+ebXOpcHbhuZqmTXjxKDriSDbFssEeEs1dIZ exemple2'

RESP=$(curl -s http://localhost:8080/ping)
if [ "${RESP}" == 'pong' ]; then
    echo "[OK] Test ping"
else
    echo "[FAIL] Test ping : ${RESP}"
fi

curl -s http://localhost:8080/health | jq .name >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[OK] Test health"
else
    echo "[FAIL] Test health"
fi

RESP=$(curl -s http://localhost:8080/client?realname=test.user@domain.fr)
if [ "${RESP}" == 'None' ]; then
    echo "[OK] Test status unknown user"
else
    echo "[FAIL] Test status unknown user : ${RESP}"
fi

RESP=$(curl -s -X PUT http://localhost:8080/client)
if [ "${RESP}" == 'Error: No username option given.' ]; then
    echo "[OK] Test add user without username"
else
    echo "[FAIL] Test add user without username : ${RESP}"
fi

RESP=$(curl -s -X PUT http://localhost:8080/client?username=test_user)
if [ "${RESP}" == "Error: Username test_user doesn't match pattern ^([a-z]+)$" ]; then
    echo "[OK] Test add user with bad username"
else
    echo "[FAIL] Test add user with bad username : ${RESP}"
fi

RESP=$(curl -s -X PUT http://localhost:8080/client?username=testuser)
if [ "${RESP}" == 'Error: No realname option given.' ]; then
    echo "[OK] Test add user without realname"
else
    echo "[FAIL] Test add user without realname : ${RESP}"
fi

RESP=$(curl -s -X PUT http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Error : Public key unprocessable' ]; then
    echo "[OK] Test add user with no pubkey"
else
    echo "[FAIL] Test add user with no pubkey : ${RESP}"
fi

RESP=$(curl -s -X PUT -d "toto" http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Error : Public key unprocessable' ]; then
    echo "[OK] Test add user with bad pubkey"
else
    echo "[FAIL] Test add user with bad pubkey : ${RESP}"
fi

RESP=$(curl -s -X PUT -d "${PUB_KEY_EXAMPLE}" http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Create user=testuser. Pending request.' ]; then
    echo "[OK] Test add user"
else
    echo "[FAIL] Test add user : ${RESP}"
fi

RESP=$(curl -s -X PUT -d "${PUB_KEY_EXAMPLE}" http://localhost:8080/client?username=all\&realname=test.user@domain.fr)
if [ "${RESP}" == "Error: Username all doesn't match pattern ^([a-z]+)$" ]; then
    echo "[OK] Test add user named 'all' (should fail)"
else
    echo "[FAIL] Test add user named 'all' (should fail): ${RESP}"
fi

RESP=$(curl -s "http://localhost:8080/client?realname=test.user@domain.fr" | jq .status 2>/dev/null)
if [ "${RESP}" == '"PENDING"' ]; then
    echo "[OK] Test status pending user"
else
    echo "[FAIL] Test status pending user : ${RESP}"
fi

RESP=$(curl -s -X PUT -d "${PUB_KEY_2_EXAMPLE}" http://localhost:8080/client?username=toto\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Create user=toto. Pending request.' ]; then
    echo "[OK] Test add user with same realname (which is possible)"
else
    echo "[FAIL] Test add user with same realname (which is possible): ${RESP}"
fi

RESP=$(curl -s -X PUT -d "${PUB_KEY_2_EXAMPLE}" http://localhost:8080/client?username=toto\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Update user=toto. Pending request.' ]; then
    echo "[OK] Test updating user"
else
    echo "[FAIL] Test updating user: ${RESP}"
fi

RESP=$(curl -s -X PUT -d "${PUB_KEY_EXAMPLE}" http://localhost:8080/client?username=testuser\&realname=toto123@domain.fr)
if [ "${RESP}" == 'Error : (username, realname) couple mismatch.' ]; then
    echo "[OK] Test add user with same username (should fail)"
else
    echo "[FAIL] Test add user with same username (should fail): ${RESP}"
fi

RESP=$(curl -s -X POST http://localhost:8080/client)
if [ "${RESP}" == 'Error: No username option given. Update your CASSH >= 1.3.0' ]; then
    echo "[OK] Test signing key without username"
else
    echo "[FAIL] Test signing key without username: ${RESP}"
fi

RESP=$(curl -s -X POST http://localhost:8080/client?username=testuser)
if [ "${RESP}" == 'Error: No realname option given.' ]; then
    echo "[OK] Test signing key without realname"
else
    echo "[FAIL] Test signing key without realname: ${RESP}"
fi

RESP=$(curl -s -X POST http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Error : Public key unprocessable' ]; then
    echo "[OK] Test signing key with no pubkey"
else
    echo "[FAIL] Test signing key with no pubkey : ${RESP}"
fi

RESP=$(curl -s -X POST -d "toto" http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Error : Public key unprocessable' ]; then
    echo "[OK] Test signing key with bad pubkey"
else
    echo "[FAIL] Test signing key with bad pubkey : ${RESP}"
fi

RESP=$(curl -s -X POST -d "${PUB_KEY_2_EXAMPLE}" http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Error : User or Key absent, add your key again.' ]; then
    echo "[OK] Test signing key when wrong public key"
else
    echo "[FAIL] Test signing key when wrong public key : ${RESP}"
fi

RESP=$(curl -s -X POST -d "${PUB_KEY_EXAMPLE}" http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Status: PENDING' ]; then
    echo "[OK] Test signing key when PENDING status"
else
    echo "[FAIL] Test signing key when PENDING status : ${RESP}"
fi

RESP=$(curl -s http://localhost:8080/admin/toto?revoke=true)
if [ "${RESP}" == 'Revoke user=toto.' ]; then
    echo "[OK] Test admin revoke 'toto'"
else
    echo "[FAIL] Test admin revoke 'toto' : ${RESP}"
fi

RESP=$(curl -s http://localhost:8080/admin/toto?status=true | jq .status 2>/dev/null)
if [ "${RESP}" == '"REVOKED"' ]; then
    echo "[OK] Test admin verify 'toto' status"
else
    echo "[FAIL] Test admin verify 'toto' status : ${RESP}"
fi

RESP=$(curl -s -X POST -d "${PUB_KEY_2_EXAMPLE}" http://localhost:8080/client?username=toto\&realname=test.user@domain.fr)
if [ "${RESP}" == 'Status: REVOKED' ]; then
    echo "[OK] Test signing key when revoked"
else
    echo "[FAIL] Test signing key when revoked: ${RESP}"
fi

RESP=$(curl -s -X DELETE http://localhost:8080/admin/toto)
if [ "${RESP}" == 'OK' ]; then
    echo "[OK] Test delete 'toto'"
else
    echo "[FAIL] Test delete 'toto': ${RESP}"
fi

RESP=$(curl -s http://localhost:8080/admin/toto)
if [ "${RESP}" == "User 'toto' does not exists." ]; then
    echo "[OK] Test admin active unknown user"
else
    echo "[FAIL] Test admin active unknown user : ${RESP}"
fi

RESP=$(curl -s http://localhost:8080/admin/testuser?status=true | jq .status 2>/dev/null)
if [ "${RESP}" == '"PENDING"' ]; then
    echo "[OK] Test admin verify 'testuser' status"
else
    echo "[FAIL] Test admin verify 'testuser' status : ${RESP}"
fi

RESP=$(curl -s http://localhost:8080/admin/testuser)
if [ "${RESP}" == "Active user=testuser. SSH Key active but need to be signed." ]; then
    echo "[OK] Test admin active testuser"
else
    echo "[FAIL] Test admin active testuser : ${RESP}"
fi

RESP=$(curl -s http://localhost:8080/admin/testuser)
if [ "${RESP}" == "user=testuser already active. Nothing done." ]; then
    echo "[OK] Test admin re-active testuser"
else
    echo "[FAIL] Test admin re-active testuser : ${RESP}"
fi

RESP=$(curl -s -X POST -d "${PUB_KEY_EXAMPLE}" http://localhost:8080/client?username=testuser\&realname=test.user@domain.fr)
echo $RESP > /tmp/test-cert
if ssh-keygen -L -f /tmp/test-cert >/dev/null 2>&1; then
    echo "[OK] Test signing key"
else
    echo "[FAIL] Test signing key : ${RESP}"
fi
rm -f /tmp/test-cert

RESP=$(curl -s -X DELETE http://localhost:8080/admin/testuser)
if [ "${RESP}" == 'OK' ]; then
    echo "[OK] Test delete 'testuser'"
else
    echo "[FAIL] Test delete 'testuser': ${RESP}"
fi
