@echo off
start c:\debuggers\windbg.exe -z %1
rem start c:\debuggers\windbg.exe -z %1 -c ".load wow64exts;!findthebuild -s;.reload;!analyze -v;.load vext.dll;.load u2d.dll;!vulnerable;!exploitable"
