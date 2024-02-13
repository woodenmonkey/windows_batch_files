@echo off
Echo EHLO:
type %1 | find "%2" | find /c "EHLO"
Echo FROM:
type %1 | find "%2" | find /c "FROM:"
Echo DATA:
type %1 | find "%2" | find /c "DATA"
Echo QUIT:
type %1 | find "%2" | find /c "QUIT"
