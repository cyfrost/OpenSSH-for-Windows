Section $(SEC_SHARED) Shared
	SectionIn RO

	;Set the output to the bin directory
	SetOutPath $INSTDIR\bin

	StrCmp $X86FORCE 1 force2	
	${If} ${RunningX64}
		;Extract the files to the above directory
		File bin64\bash.exe ;which is switch.exe
		File bin64\chmod.exe
		File bin64\chown.exe
		File bin64\editrights.exe
		File bin64\junction.exe   ;from sysinternals
		File bin64\md5sum.exe
		File bin64\mkgroup.exe
		;File bin64\mkpasswd.c - use the real one
		File bin64\mkpasswd.exe
		File bin64\mv.exe
		File bin64\rsync.exe
		File bin64\sha1sum.exe
		File bin64\ssh-add.exe
		File bin64\ssh-agent.exe		
		File bin64\ssh-keygen.exe
		File bin64\ssh-keyscan.exe
		
		File bin64\cygattr-1.dll
		File bin64\cygcom_err-2.dll
		File bin64\cygcrypt-0.dll
		File bin64\cygcrypto-1.0.0.dll
		File bin64\cygedit-0.dll
		File bin64\cyggcc_s-seh-1.dll
		File bin64\cyggssapi_krb5-2.dll
		File bin64\cygiconv-2.dll
		File bin64\cygintl-8.dll
		File bin64\cygk5crypto-3.dll
		File bin64\cygkrb5-3.dll
		File bin64\cygkrb5support-0.dll
		File bin64\cygncursesw-10.dll
		File bin64\cygreadline7.dll
		File bin64\cygssp-0.dll
		File bin64\cygwin1.dll
		File bin64\cygz.dll
		
		File bin64\ssh-host-config
	${Else}
force2:
		;Extract the files to the above directory
		File bin32\bash.exe ;which is switch.exe
		File bin32\chmod.exe
		File bin32\chown.exe
		File bin32\editrights.exe
		File bin32\junction.exe   ;from sysinternals
		File bin32\md5sum.exe
		File bin32\mkgroup.exe
		; File bin32\mkpasswd.c - use the real one
		File bin32\mkpasswd.exe
		File bin32\mv.exe
		File bin32\rsync.exe
		File bin32\sha1sum.exe
		File bin32\ssh-add.exe
		File bin32\ssh-agent.exe
		File bin32\ssh-keygen.exe
		File bin32\ssh-keyscan.exe
		
		File bin32\cygattr-1.dll
		File bin32\cygcom_err-2.dll
		File bin32\cygcrypt-0.dll
		File bin32\cygcrypto-1.0.0.dll
		File bin32\cygedit-0.dll
		File bin32\cyggcc_s-1.dll
		File bin32\cyggssapi_krb5-2.dll
		File bin32\cygiconv-2.dll
		File bin32\cygintl-8.dll
		File bin32\cygk5crypto-3.dll
		File bin32\cygkrb5-3.dll
		File bin32\cygkrb5support-0.dll	
		File bin32\cygncursesw-10.dll
		File bin32\cygreadline7.dll
		File bin32\cygssp-0.dll
		File bin32\cygwin1.dll
		File bin32\cygz.dll

		File bin32\ssh-host-config		
	${EndIf}

	;Set the output to the docs directory
	SetOutPath $INSTDIR\docs

	;Extract the files to the above directory
	;File docs\changelog.txt
	;File docs\key_authentication.txt
	File docs\ssh-keygen-manual.htm
	File docs\ssh-keyscan-manual.htm
	File docs\ssh-agent-manual.htm
	;File docs\readme.txt
	;File docs\quickstart.txt
	File docs\ssh-keygen-manual.htm
	File docs\ssh-add-manual.htm
	File docs\cygwin-GPL.txt
	File docs\openssh-license.txt
	
	File docs\CREDITS
	File docs\LICENCE
	File docs\OVERVIEW
	File docs\PROTOCOL
	File docs\PROTOCOL.agent
	File docs\PROTOCOL.certkeys
	File docs\PROTOCOL.mux
	File docs\README
	File docs\README.dns
	File docs\README.platform
	File docs\README.privsep
	File docs\README.tun	

	;Create /tmp directory
	CreateDirectory $INSTDIR\tmp

	;Write the Registry Structure for CYGWIN
	WriteRegStr HKLM "Software\Cygnus Solutions\Cygwin\Program Options" "" ""

	; /
	WriteRegStr HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/" "native" "$INSTDIR"
	WriteRegDWORD HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/" "flags" "10"

	; /usr/bin
	WriteRegStr HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/usr/bin" "native" "$INSTDIR/bin"
	WriteRegDWORD HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/usr/bin" "flags" "10"

	; /home (The Profiles directory for the machine)

;	;Profile directories usually only reside on NT machines. This will set /home to the profiles directory only on NT. If on 9x, it will use $INSTDIR/bin
;	ReadEnvStr $7 "OS"
;	;If the OS environment variable is Windows_NT, this will goto IsOK, if not, it goes to SkipServer
;	StrCmp $7 "Windows_NT" 0 Win9xHome
;
;	;Find the profiles directory
;	;Find the user's personal directory by getting the directory below their startmenu directory
;	Push $STARTMENU
;	Call GetParent
;	Pop $R0
;
;	;Find the directory that holds the user's profile. This will hold the profiles of other users.
;	Push $R0
;	Call GetParent
;	Pop $R0

	;do this differently so we point to where we put the junction
	ExpandEnvStrings $2 %USERPROFILE%

	;setup the users home directory for both client and server access
	;effectively mklink /d "c:\program files\opensshd\home" "\users\" [Vista+]
	;            mklink /d "c:\program files\opensshd\home" "\Documents and Settings\" [XP]
	nsExec::Exec `$INSTDIR\bin\junction.exe /accepteula "$INSTDIR\home" "$2\.."`
	
	;WriteRegStr HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/home" "native" "$R0"
	WriteRegStr HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/home" "native" "$2\.."
	WriteRegDWORD HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/home" "flags" "10"

	Goto EndNT
;Win9xHome: ;StrCmp for Win9xHome not used any more
	;WriteRegStr HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/home" "native" "$INSTDIR/bin"
	;WriteRegDWORD HKLM "Software\Cygnus Solutions\Cygwin\mounts v2\/home" "flags" "10"
EndNT:
	;Write the CYGWIN environment variable
	WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "CYGWIN" "mintty"

	;Check if directory is in path
	ReadRegStr $1 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "PATH"
	Push $1

	;Add the installation directory to the path
	Push "$INSTDIR\bin"
	Call StrStr
	Pop $1
	IntCmp $1 -1 0 0 There
	;Add the installation directory to the path
	Push "$INSTDIR\bin"
	Call AddToPath
There:
SectionEnd

Section $(SEC_CLIENT) Client
	;bail immediately if we are server only
	StrCmp $SSHSERVERONLY "1" ServerOnly 

	;Set the output to the bin directory
	SetOutPath $INSTDIR\bin

	;Extract the files to the above directory
	StrCmp $X86FORCE 1 force3
	${If} ${RunningX64}
		File bin64\ssh.exe
		File bin64\sftp.exe
		File bin64\scp.exe
	${Else}
force3:
		File bin32\ssh.exe
		File bin32\sftp.exe
		File bin32\scp.exe
	${EndIf}
	
	;Set the output to the docs directory
	SetOutPath $INSTDIR\docs

	;Extract the files to the above directory
	File docs\scp-manual.htm
	File docs\sftp-manual.htm
	File docs\ssh-manual.htm

	;Set the output to the usr\share\terminfo\c directory
	SetOutPath $INSTDIR\usr\share\terminfo\c

	;Extract the files to the above directory
	File usr\share\terminfo\c\cygwin
ServerOnly:
SectionEnd

Section $(SEC_SERVER) Server
	;bail immediately if we are client only
	StrCmp $SSHCLIENTONLY "1" ClientOnly

	;The Server can only be installed on NT, check the OS.
	ReadEnvStr $7 "OS"
	;If the OS environment variable is Windows_NT, this will goto IsOK, if not, it goes to SkipServer
	StrCmp $7 "Windows_NT" 0 SkipServer

	;Backup the old configuration and keys

	;Create backup directorys to hold the files
	CreateDirectory "$TEMP\etc.bak"
	;Copy the files to the backup folders
	CopyFiles /SILENT "$INSTDIR\etc\*.*" "$TEMP\etc.bak"     ;The Configuration and keys

	;Remove the backed-up files
	Delete "$INSTDIR\etc\*.*"

	;Copy the Server Files

	;Set the output to the bin directory
	SetOutPath $INSTDIR\bin

	;Extract the files to the above directory
	StrCmp $X86FORCE 1 force4
	${If} ${RunningX64}
		File bin64\cygrunsrv.exe
		File bin64\false.exe
		File bin64\last.exe
		File bin64\ls.exe
		File bin64\mkdir.exe
		File bin64\quietcmd.bat
		File bin64\rm.exe
		File bin64\sh.exe
		File bin64\switch.c
		File bin64\switch.exe	
		File bin64\true.exe
	${Else}
force4:
		File bin32\cygrunsrv.exe
		File bin32\false.exe
		File bin32\last.exe
		File bin32\ls.exe
		File bin32\mkdir.exe
		File bin32\quietcmd.bat
		File bin32\rm.exe
		File bin32\sh.exe
		File bin32\switch.c
		File bin32\switch.exe
		File bin32\true.exe	
	${EndIf}

	;Set the output to the ssh directory
	SetOutPath $INSTDIR\usr\sbin

	;Extract the files to the above directory
	StrCmp $X86FORCE 1 force5
	${If} ${RunningX64}
		File usr\sbin64\sftp-server.exe
		File usr\sbin64\sshd.exe
		File usr\sbin64\ssh-keysign.exe
	${Else}
force5:
		File usr\sbin32\sftp-server.exe
		File usr\sbin32\sshd.exe
		File usr\sbin32\ssh-keysign.exe
	${EndIf}	

	;Set the output to the docs directory
	SetOutPath $INSTDIR\docs

	;Extract the files to the above directory
	File docs\sshd-manual.htm
	File docs\sshd-config-manual.htm
	File docs\sftp-server-manual.htm
	File docs\last-copyright.txt

	;Set the output to the etc directory
	SetOutPath $INSTDIR\etc

	;Extract the files to the above directory
	File etc\banner.txt
	;IfFileExists \etc\sshd_config +2 0      ;if the user has re-installed, don't whack their config settings
	;File etc\sshd_config
	IfFileExists \etc\ssh_config +2 0     ;if the user has re-installed, don't whack their config settings
	File etc\ssh_config
	File etc\moduli

	;Create /var/empty directory
	SetOutPath $INSTDIR\var\empty

	;Set the output to the var\log directory
	SetOutPath $INSTDIR\var\log

	;Extract the files to the above directory
	File var\log\lastlog
	File var\log\wtmp

	;Set the output to the var\run directory
	SetOutPath $INSTDIR\var\run

	;Extract the files to the above directory
	File var\run\utmp

	;Move the backup files into their normal locations
	;CopyFiles /SILENT "$INSTDIR\etc\backup\*.*" "$INSTDIR\etc"
	;Remove the backup folders, as they are no longer needed
	;RMDir /r "$INSTDIR\etc\backup"

	;Look for existing keys, if not found, generate keys
	;IfFileExists $INSTDIR\etc\*host* EndSection

	;MessageBox MB_OK|MB_ICONINFORMATION "SSHDDOMAIN= $SSHDDOMAIN"
	;make the passwd/group files
	;this drove me nuts, found the fix (IF 1==1) at http://forums.winamp.com/showthread.php?t=118246
	ExpandEnvStrings $0 %COMSPEC% 
	IntCmp $SSHDDOMAIN 1 domain

	;ExecWait `"$0" /C "$\"$INSTDIR\bin\mkgroup.exe"$\" -l >> ..\..\etc\group`		;create local group file
	;ExecWait `"$0" /C "$\"$INSTDIR\bin\mkpasswd.exe"$\" -l >> ..\..\etc\passwd`		;create local passwd file
	nsExec::Exec `"$0" /C IF 1==1 "$INSTDIR\bin\mkgroup.exe" -l > "$INSTDIR\etc\group"`		;create local group file
	nsExec::Exec `"$0" /C IF 1==1 "$INSTDIR\bin\mkpasswd.exe" -l > "$INSTDIR\etc\passwd"`	;create local passwd file
	goto nodomain
domain:
	;ExecWait `"$0" /C "$\"$INSTDIR\bin\mkgroup.exe"$\" -d >> ..\..\etc\group`		;create local group file
	;ExecWait `"$0" /C "$\"$INSTDIR\bin\mkpasswd.exe"$\" -d >> ..\..\etc\passwd`		;create local passwd file
	nsExec::Exec `"$0" /C IF 1==1 "$INSTDIR\bin\mkgroup.exe" -d > "$INSTDIR\etc\group"`		;create local group file
	nsExec::Exec `"$0" /C IF 1==1 "$INSTDIR\bin\mkpasswd.exe" -d > "$INSTDIR\etc\passwd"`	;create local passwd file
nodomain:

	;to debug
	;MessageBox MB_OK|MB_ICONINFORMATION "port=$SSHDPORT  pass=$SSHDPASS"

	;handle privsep (prior to calling write sshd_config
	ExpandEnvStrings $0 %COMSPEC% 
	ExpandEnvStrings $1 %TEMP%
	nsExec::Exec `"$0" /C net user sshd /add /fullname:$\"sshd privsep$\" /homedir:"$INSTDIR\var\empty" /active:no`		;create local group file
	nsExec::Exec `"$0" /C wmic useraccount where "Name='sshd'" SET PasswordExpires=FALSE`		;never expires
	;ExecWait `"$0" /C "$\"$INSTDIR\bin\mkpasswd.exe"$\" -l -u sshd >> ..\..\etc\passwd`		;create local passwd file
	nsExec::Exec `"$0" /C IF 1==1 "$INSTDIR\bin\mkpasswd.exe" -l -u sshd >> "$INSTDIR\etc\passwd"`		;create local passwd file

	;Set the output to the bin\cyglsa directory
	SetOutPath $INSTDIR\bin\cyglsa

	;Extract the files to the above directory
	StrCmp $X86FORCE 1 force6
	${If} ${RunningX64}
		File bin64\cyglsa\cyglsa64.dll
	${Else}
force6:
		File bin32\cyglsa\cyglsa.dll
	${EndIf}
	
;for now, disabling the actual install of this technique
;files will be put in place, but registry not modified
;need to figure out how to handle reboots of this
goto noprivsep	

	;read the registry entries
	${registry::Read} "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" "Authentication Packages" $R0 $R1
	;r0 = msv1_0
	;r1 = REG_MULTI_SZ
	
	;rem there is always at lest one - msv1_0
	StrCpy $1 0
	${StrTok} "$R5" "$R0" "$\n" $1 1
	;rem if we find cyglsa already there, then leave it alone and move on
	StrCmp "$R5" "$INSTDIR\bin\cyglsa\cyglsa" noprivsep install_loop
install_loop:
	IntOp $1 $1 + 1
	${StrTok} "$R5" "$R0" "$\n" $1 1
	;rem if we find cyglsa already there, then leave it alone and move on
	StrCmp "$R5" "$INSTDIR\bin\cyglsa\cyglsa" noprivsep +1
	StrCmp "$R5" "" +1 install_loop
	
	${registry::Read} "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" "Authentication Packages" $R0 $R1
	StrCpy $R2 "$R0$\n$INSTDIR\bin\cyglsa\cyglsa"
	StrCpy $R0 $R2
	${registry::Write} "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" "Authentication Packages" "$R0" "$R1" $R2
	
noprivsep:

	;port was already set (default or via cmd line)
	;now that we know about privsep, can write sshd_config
	call WriteSshdConfig

	;bug fix for 6.1p1 - had to make the keys (ssh-keygen) in the /, then mv them into /etc
	;even using the trick with IF 1==1 we still got this error
	;Generating public/private dsa key pair.
	;     10 [main] ssh-keygen 1904 exception::handle: Exception: STATUS_ACCESS_VIOLATION
	;    702 [main] ssh-keygen 1904 open_stackdumpfile: Dumping stack trace to ssh-keygen.exe.stackdump
	;  61429 [main] ssh-keygen 1904 exception::handle: Exception: STATUS_ACCESS_VIOLATION
	;  70699 [main] ssh-keygen 1904 exception::handle: Error while dumping state (probably corrupted stack)
	nsExec::Exec `$INSTDIR\bin\ssh-keygen.exe -b 1024 -t dsa -f /ssh_host_dsa_key -N ""` ;Creates a SSH2 DSA key (max 1024)
	nsExec::Exec `$INSTDIR\bin\mv /ssh_host_dsa_key* /etc`
	nsExec::Exec `$INSTDIR\bin\ssh-keygen.exe -b $KEYSIZE -t rsa1 -f /ssh_host_key -N ""`    ;Creates a SSH1 RSA key
	nsExec::Exec `$INSTDIR\bin\mv /ssh_host_key* /etc/`
	nsExec::Exec `$INSTDIR\bin\ssh-keygen.exe -b $KEYSIZE -t rsa -f /ssh_host_rsa_key -N ""` ;Creates a SSH2 RSA key
	nsExec::Exec `$INSTDIR\bin\mv /ssh_host_rsa_key* /etc/`
	nsExec::Exec `$INSTDIR\bin\ssh-keygen.exe -b 521 -t ecdsa -f /ssh_host_ecdsa_key -N ""` ;Creates a SSH2 ECDSA key (max 521)
	nsExec::Exec `$INSTDIR\bin\mv /ssh_host_ecdsa_key* /etc/`
	nsExec::Exec `$INSTDIR\bin\ssh-keygen.exe -b $KEYSIZE -t ed25519 -f /ssh_host_ed25519_key -N ""` ;Creates a SSH2 ed25519 key
	nsExec::Exec `$INSTDIR\bin\mv /ssh_host_ed25519_key* /etc/`	

	;If no keys were generated, this section is called. It is also called after keys have been generated
	;This section displays a notice about configuring the passwd file for server access
	;EndSection:
	;Install the OpenSSHd Service

	;The ACLs need change to let cygrunsrv properly work with the service
	; chmod is still not working - need to use cacls until this can be worked out
	;nsExec::Exec  'chmod -R 755 "$INSTDIR"'
	;nsExec::Exec  'chmod -R 644 "$INSTDIR\etc"'

	;Get the current username and domain for ACL changes
	ReadEnvStr $2 "USERDOMAIN"
	ReadEnvStr $3 "USERNAME"

	;Add correct permissions
	nsExec::Exec 'cacls "$INSTDIR" /E /T /G $2\$3:F'
UserMgr::GetLocalizedStdAccountName ${SG_NTAUTHORITY_SYSTEM}
Pop $5
;MessageBox MB_OK|MB_ICONINFORMATION "username = $5"
	;nsExec::Exec 'cacls "$INSTDIR" /E /T /G SYSTEM:F'
	nsExec::Exec 'cacls "$INSTDIR" /E /T /G "$5":F'

	;configure firewall
	WriteRegDWORD HKLM "Software\OpenSSH for Windows" sshd_port $SSHDPORT
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
	StrCpy $R1 $R0 1
	StrCmp $R1 '5' xp_2k3 vista_plus
xp_2k3:
	nsExec::Exec `"$0" /C netsh firewall add portopening name="OpenSSH" protocol=TCP port=$SSHDPORT mode=ENABLE`
	goto fw_done
vista_plus:
	nsExec::Exec `"$0" /C netsh advfirewall firewall add rule name="OpenSSH" dir=in action=allow service=OpenSSHd enable=yes`
	nsExec::Exec `"$0" /C netsh advfirewall firewall add rule name="OpenSSH" dir=in action=allow program="$INSTDIR\usr\sbin\sshd.exe" enable=yes`
	nsExec::Exec `"$0" /C netsh advfirewall firewall add rule name="OpenSSH" dir=in action=allow protocol=TCP localport=$SSHDPORT`
fw_done:
	
	;setup for sshd to run as sshd_server (priviledge seperation)
	ExpandEnvStrings $0 %COMSPEC%
	ExpandEnvStrings $1 %TEMP% 
	nsExec::Exec `"$0" /C net user sshd_server "$SSHDPASS" /add /fullname:"sshd server account" /y /homedir:"$INSTDIR\var\empty"`		;create local group file
	nsExec::Exec `"$0" /C wmic useraccount where "Name='sshd_server'" SET PasswordExpires=FALSE`		;never expires
	UserMgr::GetUserNameFromSID "S-1-5-32-544"
	Pop $1
	${StrTok} $2 $1 '\' 'L' 1
	;MessageBox MB_OK|MB_ICONINFORMATION "group = $1, split string=$2"
	nsExec::Exec `"$0" /C net localgroup $2 sshd_server /add`
	
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeAssignPrimaryTokenPrivilege -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeCreateTokenPrivilege -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeTcbPrivilege -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeDenyInteractiveLogonRight -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeDenyNetworkLogonRight -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeDenyRemoteInteractiveLogonRight -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeIncreaseQuotaPrivilege -u sshd_server`
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\editrights.exe"$\" -a SeServiceLogonRight -u sshd_server`

	;ExecWait `"$0" /C "$\"$INSTDIR\bin\mkgroup.exe"$\" -l >> ..\..\etc\group`		;create local group file
	nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\mkpasswd.exe"$\" -l -u sshd_server >> ..\..\etc\passwd`		;create local passwd file
	;set privsep permissions on folder correctly for w2k3 and above

; sequence is remove inheritance, then grant sshd_server
; at this point, the folder is owned by a wonky sid, so set owner to sshd-server
; if do an ls -l should see drwx------ 1 sshd_server None   empty
; and then net start opensshd should work!	
;C:\Program Files\OpenSSH\var>icacls empty
;empty win7\sshd_server:(R,W,D,WDAC,WO)
;      win7\None:(Rc,S,RA)
;      Everyone:(Rc,S,RA)
;      win7\sshd_server:(OI)(CI)(IO)(F)
; is the ACLs we expect to see
; uninstall/re-install and re-verify should always be the case and listener on 22 should be active
;
;for XP:
;C:\Program Files\OpenSSH\var\empty WINXPSP0A\sshd_server:(special access:)
;                                                         STANDARD_RIGHTS_ALL
;                                                         DELETE
;														  ...
;                                                         FILE_READ_ATTRIBUTES
;                                                         FILE_WRITE_ATTRIBUTES
;
;                                   WINXPSP0A\None:(special access:)
;                                                  READ_CONTROL
;                                                  SYNCHRONIZE
;                                                  FILE_READ_ATTRIBUTES
;
;                                   Everyone:(special access:)
;                                            READ_CONTROL
;                                            SYNCHRONIZE
;                                            FILE_READ_ATTRIBUTES
;
;                                   BUILTIN\Users:R
;                                   BUILTIN\Users:(OI)(CI)(IO)(special access:)
;                                                             GENERIC_READ
;                                                             GENERIC_EXECUTE
;
	
UserMgr::GetLocalizedStdAccountName ${SG_EVERYONE}
Pop $4
;MessageBox MB_OK|MB_ICONINFORMATION "SG_EVERYONE = $4"
nsExec::Exec `"$0" /C cacls "$INSTDIR\var\empty" /E /R "$4"`
UserMgr::GetLocalizedStdAccountName ${SG_POWERUSERS}
Pop $4
;MessageBox MB_OK|MB_ICONINFORMATION "SG_POWERUSERS = $4"
nsExec::Exec `"$0" /C cacls "$INSTDIR\var\empty" /E /R "$4"`
UserMgr::GetLocalizedStdAccountName ${SG_NTAUTHORITY_SYSTEM}
Pop $4
;MessageBox MB_OK|MB_ICONINFORMATION "SG_NTAUTHORITY_SYSTEM = $4"
nsExec::Exec `"$0" /C cacls "$INSTDIR\var\empty" /E /R "$4"`
UserMgr::GetLocalizedStdAccountName ${SG_CREATOROWNER}
Pop $4
;MessageBox MB_OK|MB_ICONINFORMATION "SG_CREATOROWNER = $4"
nsExec::Exec `"$0" /C cacls "$INSTDIR\var\empty" /E /R "$4"`
UserMgr::GetLocalizedStdAccountName ${SG_ADMINISTRATORS}
Pop $4
;MessageBox MB_OK|MB_ICONINFORMATION "SG_ADMINISTRATORS = $4"
nsExec::Exec `"$0" /C cacls "$INSTDIR\var\empty" /E /R "$4"`


nsExec::Exec `"$0" /C icacls "$INSTDIR\var\empty" /reset /c /T`	
nsExec::Exec `"$0" /C icacls "$INSTDIR\var\empty" /inheritance:r /c /T`		
UserMgr::GetCurrentUserName
Pop $3
;;MessageBox MB_OK|MB_ICONINFORMATION "username = $3"
nsExec::Exec `"$0" /C icacls "$INSTDIR\var\empty" /inheritance:d /remove:g $3 /grant:r sshd_server:(OI)(CI)F /c /T`	
nsExec::Exec `"$0" /C icacls "$INSTDIR\var\empty" /setowner sshd_server /c /t`

nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\chown.exe"$\" sshd_server /var/empty`
nsExec::Exec `"$0" /C "$\"$INSTDIR\bin\chmod.exe"$\" 600 /var/empty`

	
	;nsExec::Exec 'icacls "$INSTDIR\var\empty" /c /t /setowner sshd_server'
	;ExecWait `"$0" /C IF 1==1 "$INSTDIR\bin\chown.exe" sshd_server ..\empty`
;around:

	;now setup the users home directory for sshd_server
	;effectively mklink /d "c:\program files\opensshd\home" "\users\" [Vista+]
	;            mklink /d "c:\program files\opensshd\home" "\Documents and Settings\" [XP]
	;ExpandEnvStrings $2 %USERPROFILE%
	;nsExec::Exec `$INSTDIR\bin\junction.exe /accepteula "$INSTDIR\home" "$2\.."`

	IntCmp $SSHDSERVER 1 +3
	nsExec::Exec `$INSTDIR\bin\cygrunsrv --install OpenSSHd --path /usr/sbin/sshd --args "-D -r" --dep "Tcpip" --stderr "/var/log/OpenSSHd.log" --env "CYGWIN=binmode ntsec" --disp "OpenSSH Server"`
	goto skipDisplayPassword
	IfSilent skipDisplayPassword ;skip the msgbox if silent
	MessageBox MB_OK|MB_ICONINFORMATION "Password for sshd_server account: $SSHDPASS"
skipDisplayPassword:
	nsExec::Exec `$INSTDIR\bin\cygrunsrv --install OpenSSHd --path /usr/sbin/sshd --args "-D -r" -u sshd_server -w "$SSHDPASS" --dep "Tcpip" --stderr "/var/log/OpenSSHd.log" --env "CYGWIN=binmode ntsec" --disp "OpenSSH Server"`	

	;Copy the files from the backup folders - overwrite what we just created if the user already had the information written
	CopyFiles /SILENT "$TEMP\etc.bak\*.*"  "$INSTDIR\etc\"    ;The Configuration and keys	
	;Remove the backed-up files
	RMDIR /r "$TEMP\etc.bak\*.*"
	Return

SkipServer:
	MessageBox MB_OK|MB_ICONEXCLAMATION "You cannot install the server unless you're running Windows XP+.  The server installation will be skipped."
ClientOnly:
SectionEnd

Section $(SEC_SHORTCUTS) Shortcuts
	;By default, this section runs will all install types
	SectionIn 1 2 3

	;Set the context to all users
	SetShellVarContext all
	;These Entries below create shortcuts to the documentation for the program
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application

	;Create shortcuts
	CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
	;CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Key Based Authentication.lnk" "$INSTDIR\docs\key_authentication.txt"
	;CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Readme.lnk" "$INSTDIR\docs\readme.txt"
	;CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Quick Start Guide.lnk" "$INSTDIR\docs\quickstart.txt"
	WriteIniStr "$INSTDIR\openssh.url" "InternetShortcut" "URL" "http://www.mls-software.com/opensshd.html"
	CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\OpenSSH for Windows Web Site.lnk" "$INSTDIR\openssh.url"
	CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Remove OpenSSH for Windows.lnk" "$INSTDIR\uninstall.exe" "/x86=$X86FORCE"

	;Write shortcut location to the registry (for Uninstaller)
	;WriteRegStr HKLM "Software\${PRODUCT}" "Start Menu Folder" "$STARTMENU_FOLDER"

	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "-PostInstall"
	;This section is required
	SectionIn RO

	;This command creates an uninstall program
	WriteUninstaller $INSTDIR\uninstall.exe

	;Set the context to all users
	SetShellVarContext all

	;Add a shortcut to the startmenu/programs for uninstallation
	;CreateShortCut "$SMPROGRAMS\OpenSSH\Remove OpenSSH for Windows.lnk" "$INSTDIR\uninstall.exe" "/x86=$X86FORCE"

	;Add a link to the Add/Remove Programs Control Panel Applet
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "DisplayName" "OpenSSH for Windows ${_VERSION_NAME} (remove only)"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "UninstallString" "$\"$INSTDIR\uninstall.exe$\" /x86=$X86FORCE"
	;$INSTDIR will strip out a colon that is not the second character of a straight path, so can't quote it
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "InstallPath" "$INSTDIR"
	
	;Add Support Information to Add/Remove Control Panel Applet
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "Contact" 'admin@mls-software.com'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "DisplayIcon" '"$INSTDIR\uninstall.exe",0'
	;WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "DisplayVersion" '${VERSION}'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "HelpLink" "http://www.mls-software.com/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "Publisher" 'Mark Saeger/Original Author: Michael Johnson'
	;WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "Readme" '$INSTDIR\docs\readme.txt'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "URLInfoAbout" "http://www.mls-software.com/opensshd"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenSSH" "URLUpdateInfo" "http://www.mls-software.com/"
SectionEnd