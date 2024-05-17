if [%1]==[] (
	goto next
) else (
goto more
)
:next
@for /f %%a in ('type %systemroot%\ServiceList.txt') do sc query %%a | find /i "running" && net stop %%a
tasklist | find /i "ccmsetup.exe" && taskkill /im ccmsetup.exe /f
tasklist | find /i "Ccm32BitLauncher.exe" && taskkill /im Ccm32BitLauncher.exe /f
tasklist | find /i "ccmdump.exe" && taskkill /im ccmdump.exe /f
tasklist | find /i "CcmEval.exe" && taskkill /im CcmEval.exe /f
tasklist | find /i "CcmExec.exe" && taskkill /im CcmExec.exe /f
tasklist | find /i "ccmrepair.exe" && taskkill /im ccmrepair.exe /f
tasklist | find /i "CcmRestart.exe" && taskkill /im CcmRestart.exe /f
tasklist | find /i "CMHttpsReadiness.exe" && taskkill /im CMHttpsReadiness.exe /f
tasklist | find /i "OSDBitLocker.exe" && taskkill /im OSDBitLocker.exe /f
tasklist | find /i "OSDBitLocker_wtg.exe" && taskkill /im OSDBitLocker_wtg.exe /f
tasklist | find /i "OSDDiskPart.exe" && taskkill /im OSDDiskPart.exe /f
tasklist | find /i "OSDJoin.exe" && taskkill /im OSDJoin.exe /f
tasklist | find /i "OsdMigrateUserState.exe" && taskkill /im OsdMigrateUserState.exe /f
tasklist | find /i "OSDNetSettings.exe" && taskkill /im OSDNetSettings.exe /f
tasklist | find /i "OSDPrepareOS.exe" && taskkill /im OSDPrepareOS.exe /f
tasklist | find /i "OSDPrepareSmsClient.exe" && taskkill /im OSDPrepareSmsClient.exe /f
tasklist | find /i "OSDPrestartCheck.exe" && taskkill /im OSDPrestartCheck.exe /f
tasklist | find /i "OSDRunPowerShellScript.exe" && taskkill /im OSDRunPowerShellScript.exe /f
tasklist | find /i "OSDSetDynamicVariables.exe" && taskkill /im OSDSetDynamicVariables.exe /f
tasklist | find /i "OSDSetupWindows.exe" && taskkill /im OSDSetupWindows.exe /f
tasklist | find /i "OSDSmpClient.exe" && taskkill /im OSDSmpClient.exe /f
tasklist | find /i "OSDWinSettings.exe" && taskkill /im OSDWinSettings.exe /f
tasklist | find /i "SCClient.exe" && taskkill /im SCClient.exe /f
tasklist | find /i "SCNotification.exe" && taskkill /im SCNotification.exe /f
tasklist | find /i "SCToastNotification.exe" && taskkill /im SCToastNotification.exe /f
tasklist | find /i "ShellExecuteMSStore.exe" && taskkill /im ShellExecuteMSStore.exe /f
tasklist | find /i "smsappinstall.exe" && taskkill /im smsappinstall.exe /f
tasklist | find /i "smsboot.exe" && taskkill /im smsboot.exe /f
tasklist | find /i "smsnetuse.exe" && taskkill /im smsnetuse.exe /f
tasklist | find /i "smsswd.exe" && taskkill /im smsswd.exe /f
tasklist | find /i "tsenv.exe" && taskkill /im tsenv.exe /f
tasklist | find /i "TSInstallSWUpdate.exe" && taskkill /im TSInstallSWUpdate.exe /f
tasklist | find /i "TSManager.exe" && taskkill /im TSManager.exe /f
tasklist | find /i "TSMBootstrap.exe" && taskkill /im TSMBootstrap.exe /f
tasklist | find /i "TsProgressUI.exe" && taskkill /im TsProgressUI.exe /f
tasklist | find /i "UpdateTrustedSites.exe" && taskkill /im UpdateTrustedSites.exe /f
tasklist | find /i "VAppCollector.exe" && taskkill /im VAppCollector.exe /f
tasklist | find /i "VAppLauncher.exe" && taskkill /im VAppLauncher.exe /f
sc delete ccmsetup
sc delete CcmExec
sc delete CmRcService
sc delete smstsmgr
goto end
:more
@for /f %%a in ('type %systemroot%\thoseservices.txt') do sc query %%a | find /i "running" && net stop %%a
:end