(for /f %%a in ('type %1') do start cmd /c "creatfil %2\%%a.fil 4000000") & (for /f %%a in ('type %1') do start cmd /c "creatfil %3\%%a.fil 4000000")
