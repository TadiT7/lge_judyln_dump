PRESSLOG_PID=`getprop sys.lge.presslog.pid`
if [ "$PRESSLOG_PID" != "" ]; then
	kill -10 $PRESSLOG_PID
fi
