@for /f "tokens=1-16 delims=. " %%a in ('"ipconfig |find "IPv4 Address""') do set ip=%%d.%%e.%%f.%%g
route add 192.168.1.0 mask 255.255.255.0 %ip%
route add 192.168.2.0 mask 255.255.255.0 %ip%
route add 192.168.3.0 mask 255.255.255.0 %ip%
route add 10.0.6.0 mask 255.255.255.0 %ip%
route add 10.0.20.0 mask 255.255.255.0 %ip%
route add 10.0.22.0 mask 255.255.255.0 %ip%
route add 10.0.25.0 mask 255.255.255.0 %ip%
route add 10.0.0.0 mask 255.255.255.0 %ip%
route add 172.16.39.30 mask 255.255.255.255 %ip%
route add 172.16.159.3 mask 255.255.255.255 %ip%
route add 192.168.255.0 mask 255.255.255.0 %ip%
route add 10.20.1.0 mask 255.255.255.0 %ip%
route add 10.1.10.0 mask 255.255.255.0 %ip%
route add 10.110.1.0 mask 255.255.255.0 %ip%
@set ip=
cls
route print