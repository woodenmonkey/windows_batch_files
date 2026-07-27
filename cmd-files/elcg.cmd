@echo off
Echo EHLO:
type %1 | find /v "10.110.3.137" | find /v "10.110.62.103" | find /v "10.110.1.10" | find /v "10.110.50.51" | find /c "EHLO"
Echo FROM:
type %1 | find /v "10.110.3.137" | find /v "10.110.62.103" | find /v "10.110.1.10" | find /v "10.110.50.51" | find /c "FROM"
Echo DATA:
type %1 | find /v "10.110.3.137" | find /v "10.110.62.103" | find /v "10.110.1.10" | find /v "10.110.50.51" | find /c "DATA"
Echo QUIT:
type %1 | find /v "10.110.3.137" | find /v "10.110.62.103" | find /v "10.110.1.10" | find /v "10.110.50.51" | find /c "QUIT"
