@echo off
Echo Ehlo:
type %1 | find "%2" | find /i "ehlo"
Echo From:
type %1 | find "%2" | find /i "from:"
Echo Data:
type %1 | find "%2" | find /i "data"
Echo Quit:
type %1 | find "%2" | find /i "quit"
