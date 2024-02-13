@Echo off
for /f "skip=3 tokens=1-4" %%a in ('netsh int show int') do netsh int set int name= "%%d" admin=disable & echo Interface "%%d" disabled