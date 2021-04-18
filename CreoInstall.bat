@echo off

setlocal

color 0C


REM *********************************************************************
REM Determine local server.
REM *********************************************************************
    set deployServer=
    set min=99999999
    set serverList= "server42" "server7" "server30" "server110"

    REM Enumerate the hosts to check.
    for %%a in ( %serverList% ) do (

        REM Ping the host and retrieve the average roundtrip.
        for /f "tokens=6 delims== " %%r in ('
            ping -n 1 "%%~a" ^| findstr /r /c:"^  .*ms$"
        ') do for /f "delims=ms" %%t in ("%%r") do (
            set /a "1/(min/(%%t+1))" && (
                set "deployServer=%%~a"
                set "min=%%t"
            )
        )
    ) 2>nul
	

REM *********************************************************************
REM Environment customization begins here. Modify variables below.
REM *********************************************************************

	REM Set LogLocation to a central directory to collect log files.
	set logLocation="\\server110\Share\GPOs\GPO Logs\Creo\6-0-3-0"

	REM Set Setup file location to a network-accessible location containing the source files.
	set netFrameVersion=4.7.2
	set creoVersion=6.0.3.0
	set netFrameSetup=C:\CreoInstall\ptcsh0\NDP472-KB4054530-x86-x64-AllOS-ENU.exe
	set creoSetup=C:\CreoInstall\setup.exe
	set thumbSetup=C:\CreoInstall\install\addon\Thumbviewer_32_64.msi
	set viewSetup=C:\CreoInstall\install\addon\pvx32_64\CreoSetup.exe
	set xml=C:\CreoInstall\xml
	set source=\\%deployServer%\Software$\Creo\6-0-3-0
	set dest=C:\CreoInstall
	set miscSource=C:\CreoInstall\install\addon\misc
	set miscDest="%PROGRAMFILES%\PTC\Creo %creoVersion%\Parametric\bin"


REM *********************************************************************
REM Deployment code begins here. Do not modify anything below this line.
REM *********************************************************************

	REM Check to see if Creo is installed.
	cls
	echo.
	echo.
	echo Checking if Creo %creoVersion% is installed...
	echo %date% %time% Checking if Creo %creoVersion% is installed...>> %LogLocation%\%computername%.txt
	echo.
	echo.
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\PTC\PTC Creo Common Files\%creoVersion%" /v Release
	if %errorlevel%==0 reg query "HKEY_LOCAL_MACHINE\SOFTWARE\PTC\PTC Creo Layout\%creoVersion%" /v Release
	if %errorlevel%==0 reg query "HKEY_LOCAL_MACHINE\SOFTWARE\PTC\PTC Creo Simulate\%creoVersion%" /v Release
	if %errorlevel%==0 reg query "HKEY_LOCAL_MACHINE\SOFTWARE\PTC\PTC Creo Parametric\%creoVersion%" /v Release
	if %errorlevel%==0 echo %date% %time% Creo %creoVersion% is already installed. Cancelling deployment.>> %LogLocation%\%computername%.txt
	if %errorlevel%==0 goto Exit
	if %errorlevel%==1 echo %date% %time% Creo %creoVersion% is not installed. Proceeding with deployment.>> %LogLocation%\%computername%.txt
	echo Creo %creoVersion% is not installed. Proceeding with deployment.

	REM Copy source files to local computer.
	echo %date% %time% Copying source files from %deployServer% to local computer.>> %LogLocation%\%computername%.txt
	robocopy %source% %dest% *.* /E /LOG+:%LogLocation%\%computername%.txt /TEE /NP

	REM Check to see if Net Framework is installed.
	cls
	echo.
	echo.
	echo %date% %time% Checking if .Net Framework %netFrameVersion% is installed...>> %LogLocation%\%computername%.txt
	echo.
	echo.
	for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release') do (set /a release = %%a)
	if %release% GEQ 461808 echo %date% %time% .Net Framework %netFrameVersion% is already installed.>> %LogLocation%\%computername%.txt
	if %release% GEQ 461808 goto Install
	if %release% LSS 461808 echo %date% %time% .Net Framework %netFrameVersion% is not installed. Proceeding with deployment.>> %LogLocation%\%computername%.txt

	:Install
	REM Begin installation.
	echo.
	echo.
	echo.
	echo.
	echo.
	echo Creo %creoVersion% is installing... DO NOT CLOSE THIS WINDOW.
	echo.
	echo.
	echo Creo %creoVersion% is installing... DO NOT CLOSE THIS WINDOW.
	echo.
	echo.
	echo Creo %creoVersion% is installing... DO NOT CLOSE THIS WINDOW.
	if %release% LSS 461808 goto NetFramework
	goto Creo

	:NetFramework
	REM Install .Net Framework.
	echo %date% %time% Installing .Net Framework %netFrameVersion%...>> %LogLocation%\%computername%.txt
	start "" /wait %netFrameSetup% /q /norestart
	echo %date% %time% Setup ended with error code %errorlevel%.>> %LogLocation%\%computername%.txt
	if %errorlevel%==0 echo %date% %time% .Net Framework has been installed successfully.>> %LogLocation%\%computername%.txt

	:Creo
	REM Install Creo.
	echo %date% %time% Installing Creo %creoVersion%...>> %LogLocation%\%computername%.txt
	start "" /wait %creoSetup% -xmlall %xml%
	echo %date% %time% Setup ended with error code %errorlevel%.>> %LogLocation%\%computername%.txt
	if %errorlevel%==0 echo %date% %time% Creo has been installed successfully.>> %LogLocation%\%computername%.txt

	REM Copy miscellanous config files.
	if %errorlevel%==0 echo %date% %time% Copying Creo %creoVersion% miscellaneous files...>> %LogLocation%\%computername%.txt
	if %errorlevel%==0 robocopy %miscSource% %miscDest% *.* /IS /LOG+:%LogLocation%\%computername%.txt /TEE /NP

	REM Install Thumbnail Viewer.
	echo %date% %time% Installing Thumbnail Viewer...>> %LogLocation%\%computername%.txt
	start "" /wait %thumbSetup% /passive
	echo %date% %time% Setup ended with error code %errorlevel%.>> %LogLocation%\%computername%.txt
	if %errorlevel%==0 echo %date% %time% Thumbnail Viewer has been installed successfully.>> %LogLocation%\%computername%.txt

	REM Install Creo View Express. (Currently disabled)
	REM echo Installing Creo View Express...>> %LogLocation%\%computername%.txt
	REM start "" /wait %viewSetup% /vADDLOCAL="ALL" /qn
	REM echo %date% %time% Setup ended with error code %errorlevel%.>> %LogLocation%\%computername%.txt
	REM if %errorlevel%==0 echo Creo View Express has been installed successfully.>> %LogLocation%\%computername%.txt


	:Exit
	REM Finish installation.
	cls
	echo.
	if %errorlevel%==0 echo %date% %time% Cleaning up any installation files...>> %LogLocation%\%computername%.txt
	if %errorlevel%==0 rmdir /s /q %dest%>> %LogLocation%\%computername%.txt
	echo Deployment complete.
	echo %date% %time% Deployment complete.>> %LogLocation%\%computername%.txt
	timeout /t 5 /nobreak

endlocal

exit