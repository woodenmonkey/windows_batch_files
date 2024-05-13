@cd/d C:\Logs\Analog\
@qdns /G analog.cfg /Y 10.1.0.3
@analog
@copy/y Report\Report.dat ..\rmagic
@CD ..\rmagic
@del/a/q reports\*
@rmagic
@CD ..\analog
@start ..\rmagic\reports\index.html