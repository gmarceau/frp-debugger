
# compile test
cTest:
	mred -M errortrace -r demos/jdi-test3.ss

TEST_TARGET=demos/jdi-test-profile.ss
REMOTE_MACHINE=catacomb

# remote test
rTest:
	pkill -9 java; \
	java -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8001 Foobar 10 & \
	ssh ${REMOTE_MACHINE} 'pkill -9 mred; mred -M errortrace -u ~/mnt-canuk/projects/frp-debugger/${TEST_TARGET}'

# local test
lTest:
	pkill -9 java; \
	java -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8001 Foobar 10 & \
	mred -M errortrace -u ${TEST_TARGET}

tags:
	etags.ss base-gm.ss codec.ss jdi-symbol-table.ss jdi.ss jdwp.ss jdwp_constants.ss jdwp_spec3.ss 
