
;Handle silent parameters
!include "FileFunc.nsh"
!insertmacro GetParameters
!insertmacro GetOptions

Function un.onInit
	;default settings for variables/parameters
	StrCpy $X86FORCE 0

	;handle cmd line parameters
	;/x86=X [0|1] set 1 to enable forced x86 install
	${GetParameters} $R0
	ClearErrors
	${GetOptions} $R0 /x86= $0
	
	StrCmp $0 "" +2
	StrCpy $X86FORCE $0
	
	;debug
	;MessageBox MB_OK|MB_ICONINFORMATION "x86=$X86FORCE"
	
FunctionEnd	
	
Section "Uninstall"

	;debug
	;MessageBox MB_OK|MB_ICONINFORMATION "x86=$X86FORCE"

	StrCmp $X86FORCE 1 force7
	${If} ${RunningX64}
		SetRegView 64
		;read the install path from the registy
		ReadRegStr $INSTDIR HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "InstallPath"
	${Endif}
	Goto force7a
force7:
	;if we are in x64 and the user requested x86, force it to be x64
	${If} ${RunningX64}
		SetRegView 32
		${EnableX64FSRedirection}
		;read the install path from the registy
		ReadRegStr $INSTDIR HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "InstallPath"
	${Endif}
force7a:
	
	;Find out if the OpenSSHd Service is installed
	Push 'OpenSSHd'
	Services::IsServiceInstalled
	Pop $0
	; $0 now contains either 'Yes', 'No' or an error description
	StrCmp $0 'Yes' RemoveServices SkipRemoval

	;This will stop and remove the OpenSSHd service if it is running.
RemoveServices:
	push 'OpenSSHd'
	push 'Stop'
	Services::SendServiceCommand

	push 'OpenSSHd'
	push 'Delete'
	Services::SendServiceCommand
	Pop $0
	StrCmp $0 'Ok' Success
	MessageBox MB_OK|MB_ICONSTOP 'The installer found the OpenSSH on Windows service, but was unable to remove it. Please stop it and manually remove it. Then try the Uninstall again. Reason: $0'
	Abort

Success:

SkipRemoval:

	ExpandEnvStrings $0 %COMSPEC%
	nsExec::Exec `"$0" /C "net user sshd /delete"` ;remote created users
	nsExec::Exec `"$0" /C "net user sshd_server /delete"` ;remote created users

;for now, disabling the actual install of this technique
;files will be put in place, but registry not modified
;need to figure out how to handle reboots of this
goto aroundlsa		
	
	;put the LSA configuration back, without cyglsa being present
	;rem there is always at lest one - msv1_0
	StrCpy $1 0
	${registry::Read} "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" "Authentication Packages" $R2 $R1
	${unStrTok} "$R5" "$R2" "$\n" $1 1
	StrCmp "$R5" "$INSTDIR\bin\cyglsa\cyglsa" loop +1
	;MessageBox MB_OK|MB_ICONINFORMATION "r5=$R5"
	StrCpy $R0 "$R5"
	;MessageBox MB_OK|MB_ICONINFORMATION "r0=$R0"
loop:
	IntOp $1 $1 + 1
	${unStrTok} "$R5" "$R2" "$\n" $1 1
	StrCmp "$R5" "" doneloop
	StrCmp "$R5" "$INSTDIR\bin\cyglsa\cyglsa" +2 +1
	StrCpy $R0 "$R0$\n$R5"
	;MessageBox MB_OK|MB_ICONINFORMATION "temp: r0=$R0 r5=$R5"
	StrCmp "$R5" "" +1 loop
doneloop:
	;MessageBox MB_OK|MB_ICONINFORMATION "example cleaned value: r0=$R0"
	${registry::Write} "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" "Authentication Packages" "$R0" "REG_MULTI_SZ" $R2

aroundlsa:	
	;now delete the users home directory for sshd_server
	;we must remove the home directory itself before whacking the reference to home
	;but we have to have deleted the user first
	RMDIR /r "$INSTDIR\home\sshd_server"
	nsExec::Exec `$INSTDIR\bin\junction.exe /accepteula -d "$INSTDIR\home"`

	;Remove the directory from the path
	Push ";$INSTDIR\bin"
	Call un.RemoveFromPath

	;Remove the installed directory - note that this does NOT backup any config or keys in /etc/
	Delete "$INSTDIR\uninstall.exe"
	;DANGEROUS! WHACKED MY APPDATA ONE TIME! RMDir /r "$INSTDIR"

	;Create backup directorys to hold the files
	CreateDirectory "$TEMP\etc.bak"	
	;Copy the /etc folder to a temporary place	
	CopyFiles /SILENT "$INSTDIR\etc\*.*" "$TEMP\etc.bak\"	

	RMDIR /r "$INSTDIR\bin"
	RMDIR /r "$INSTDIR\docs"
	RMDIR /r "$INSTDIR\etc"
	RMDIR /r "$INSTDIR\tmp"
	RMDIR /r "$INSTDIR\usr"
	RMDIR /r "$INSTDIR\var"
	RMDIR "$INSTDIR"

	;Get the Start Menu Folder that the icons were installed in
	!insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP

	;Set the context to all users
	SetShellVarContext all

	;Delete empty start menu parent diretories
	;StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"
	RMDIR /r "$SMPROGRAMS\OpenSSH for Windows"
	;RMDir /r $MUI_TEMP

	;Delete registry entries specific to the product
	ReadRegDWORD $R2 HKLM "Software\OpenSSH for Windows" sshd_port
	DeleteRegKey HKLM "Software\OpenSSH for Windows"  ;Product Registry Entries - Holds Start Menu Info
	DeleteRegKey HKLM "SOFTWARE\Cygnus Solutions"  ;Holds mounts
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH"  ;The Add/Remove Programs Entry

	;configure firewall
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
	StrCpy $R1 $R0 1
	StrCmp $R1 '5' xp_2k3 vista_plus
xp_2k3:
	nsExec::Exec `"$0" /C netsh firewall delete portopening protocol=TCP port=$R2`
	goto fw_done
vista_plus:
	nsExec::Exec `"$0" /C netsh advfirewall firewall delete rule name="OpenSSH"`
fw_done:	
SectionEnd
