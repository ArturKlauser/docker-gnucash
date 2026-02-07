#!/usr/bin/bash

# shellcheck disable=SC2016
CONTAINER_COM_DIR='$$CONTAINER_COM_DIR$$'
log="${CONTAINER_COM_DIR}/log"

: > "${log}" # Start appready debugging log.
echo "waiting for gnucash pid" >> "${log}"
# Give app run script some time to exec the gnucash process.
for countdown in {10..0}; do
  # Only care about gnucash child process of PID 1 (init),
  # not other random gnucash invocations from parallel tests.
  gnucash_pid=$(pgrep -P 1 gnucash)
  echo "waiting ${countdown}; pid=${gnucash_pid}" >> "${log}"
  [[ -n "${gnucash_pid}" ]] && break
  sleep 1
done

if [[ ${countdown} -eq 0 ]]; then
  echo "Docker gnucash app startup wait timeout." >> "${log}"
  echo "Docker gnucash app startup wait timeout." \
    > "${CONTAINER_COM_DIR}/appenv"
else
  ls -la "/proc" >> "${log}"
  ls -la "/proc/${gnucash_pid}" >> "${log}"
  # Capture the running app's environment, \n delimited.
  # shellcheck disable=SC2312
  tr '\0' '\n' < "/proc/${gnucash_pid}/environ" 2>&1 \
    | sed -e '/^$/d' \
    > "${CONTAINER_COM_DIR}/appenv"
fi

# Create a shell script that sets the environment like the app has it. Make
# sure this correctly handles embedded white space by quoting env values.
echo "env -i" > "${CONTAINER_COM_DIR}/appenv.sh"
sed -e 's/^/export "/;s/$/"/' "${CONTAINER_COM_DIR}/appenv" \
  >> "${CONTAINER_COM_DIR}/appenv.sh"
touch "${CONTAINER_COM_DIR}/appready"
