::---------------------------------------------------
:: Admin Yetki kodu BAŞI
@echo off
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)
:: Admin Yetki kodu SONU

@echo off & setlocal enableextensions
title Reset AnyDesk
reg query HKEY_USERS\S-1-5-19 >NUL || (echo Please Run as administrator.& pause >NUL&exit)

::chcp 1252
chcp 65001
cls
:: Dosya yolları
set APPDATA_ANYDESK=%APPDATA%\AnyDesk
set ALLUSERSPROFILE_ANYDESK=%ProgramData%\AnyDesk
::%ALLUSERSPROFILE%\AnyDesk\ ile %ProgramData%\AnyDesk\ aynı.

:: Kontrol işlemleri ve installedversion ayarlama
if exist "%ALLUSERSPROFILE_ANYDESK%\system.conf" if exist "%ALLUSERSPROFILE_ANYDESK%\service.conf" (
    set installedversion=installed
    echo Yüklenmiş sürüm bulundu.
) else (
    set installedversion=
    echo Portable sürüm bulundu.
)

:: installedversion değişkenini kontrol ediyoruz
echo Yüklenmiş sürüm: %installedversion%

:: Eğer service.conf ve system.conf her iki yolda da yoksa, işlem bitirilsin
::if not exist "%ALLUSERSPROFILE_ANYDESK%\service.conf" if not exist "%APPDATA_ANYDESK%\service.conf" if not exist "%ALLUSERSPROFILE_ANYDESK%\system.conf" if not exist "%APPDATA_ANYDESK%\system.conf" (
::    echo Hiçbir dosya bulunamadı, işlem sonlandırılıyor.
::    goto :eof
::)

:: Eğer service.conf ve system.conf dosyaları aynı yolda birlikte yoksa, işlem bitirilsin
if not exist "%ALLUSERSPROFILE_ANYDESK%\service.conf" if not exist "%ALLUSERSPROFILE_ANYDESK%\system.conf" (
    if not exist "%APPDATA_ANYDESK%\service.conf" if not exist "%APPDATA_ANYDESK%\system.conf" (
        echo Hiçbir dosya bulunamadı, işlem sonlandırılıyor.
		pause
        goto :eof
    )
)

:: Eğer sadece bir dosya varsa, mevcut olanı sil
if exist "%ALLUSERSPROFILE_ANYDESK%\service.conf" if not exist "%ALLUSERSPROFILE_ANYDESK%\system.conf" (
    del /f "%ALLUSERSPROFILE_ANYDESK%\service.conf"
	echo Eksik dosyalar bulundu ve mevcut service.conf dosyası silindi.
)
if exist "%ALLUSERSPROFILE_ANYDESK%\system.conf" if not exist "%ALLUSERSPROFILE_ANYDESK%\service.conf" (
    del /f "%ALLUSERSPROFILE_ANYDESK%\system.conf"
	echo Eksik dosyalar bulundu ve mevcut system.conf dosyası silindi.
)
if exist "%APPDATA_ANYDESK%\service.conf" if not exist "%APPDATA_ANYDESK%\system.conf" (
    del /f "%APPDATA_ANYDESK%\service.conf"
	echo Eksik dosyalar bulundu ve mevcut service.conf dosyası silindi.
)
if exist "%APPDATA_ANYDESK%\system.conf" if not exist "%APPDATA_ANYDESK%\service.conf" (
    del /f "%APPDATA_ANYDESK%\system.conf"
	echo Eksik dosyalar bulundu ve mevcut system.conf dosyası silindi.
)


call :stop_any

echo İşlemler başlıyor...
:: AnyDesk'in tray'de kapatılması
::taskkill /f /im "AnyDesk.exe" 2>NUL
::for /f "tokens=1,2 delims= " %%A in ('tasklist /FI "IMAGENAME eq Anydesk.exe" /NH') do echo %%A=%%B &tskill %%B>nul
::for /f "tokens=1,2 delims= " %%A in ('tasklist /FI "IMAGENAME eq Anydesk.exe" /NH') do echo %%A=%%B &tskill %%B>nul
::for /f "tokens=1,2 delims= " %%A in ('tasklist /FI "IMAGENAME eq Anydesk.exe" /NH') do echo %%A=%%B &tskill %%B>nul


:: İlk önce service.conf.bak dosyasını kontrol et ve varsa sil
if exist "%ALLUSERSPROFILE_ANYDESK%\service.conf.bak" (
    del /f "%ALLUSERSPROFILE_ANYDESK%\service.conf.bak"
	echo Eski service.conf.bak yedeği silindi.
)
timeout 1
:: Eğer service.conf dosyası varsa yedekle
if exist "%ALLUSERSPROFILE_ANYDESK%\service.conf" (
    rename "%ALLUSERSPROFILE_ANYDESK%\service.conf" "service.conf.bak" 2>NUL
	echo service.conf dosyası service.conf.bak olarak yeniden adlandırılıp yedeklendi.
)
timeout 1
:: Aynı işlemi system.conf için yap
if exist "%ALLUSERSPROFILE_ANYDESK%\system.conf.bak" (
    del /f "%ALLUSERSPROFILE_ANYDESK%\system.conf.bak"
	echo Eski system.conf.bak yedeği silindi.
)
timeout 1
if exist "%ALLUSERSPROFILE_ANYDESK%\system.conf" (
    rename "%ALLUSERSPROFILE_ANYDESK%\system.conf" "system.conf.bak" 2>NUL
	echo system.conf dosyası system.conf.bak olarak yeniden adlandırılıp yedeklendi.
)
timeout 1
:: Aynı işlemleri APPDATA yolunda tekrar uygula
if exist "%APPDATA_ANYDESK%\service.conf.bak" (
    del /f "%APPDATA_ANYDESK%\service.conf.bak"
	echo Eski service.conf.bak yedeği silindi.
)
timeout 1
if exist "%APPDATA_ANYDESK%\service.conf" (
    rename "%APPDATA_ANYDESK%\service.conf" "service.conf.bak" 2>NUL
	echo service.conf dosyası service.conf.bak olarak yeniden adlandırılıp yedeklendi.
)
timeout 1
if exist "%APPDATA_ANYDESK%\system.conf.bak" (
    del /f "%APPDATA_ANYDESK%\system.conf.bak"
	echo Eski system.conf.bak yedeği silindi.
)
timeout 1
if exist "%APPDATA_ANYDESK%\system.conf" (
    rename "%APPDATA_ANYDESK%\system.conf" "system.conf.bak" 2>NUL
	echo system.conf dosyası system.conf.bak olarak yeniden adlandırılıp yedeklendi.
)
timeout 1
:: Geri yükleme işlemleri
call :start_any

:SonGiris
goto :Son

:start_any
echo Başlangıç kısmı çalıştırılıyor...

:: Eğer kurulu bir sürüm varsa
if "%installedversion%"=="installed" (
    echo Yüklenmiş sürüm bulundu, Anydesk servisi başlatılıyor...
    call :start_installed_any
) else (
    echo Taşınabilir sürüm bulundu. Anydesk programını el ile çalıştırın.
	call :start_portable_any
)
goto :eof

:start_portable_any
echo AnyDesk programını çalıştırın ve devam edin.
echo AnyDesk programını çalıştırın ve devam edin.
echo AnyDesk programını çalıştırın ve devam edin.
echo AnyDesk programını çalıştırın ve devam edin.
echo AnyDesk programını çalıştırın ve devam edin.

timeout /t 10 /nobreak >NUL
pause
::goto :lic
goto :eof

:start_installed_any
echo Anydesk servisi başlatılmaya çalışılıyor...

:: Hizmetin çalışıp çalışmadığını kontrol et
sc query AnyDesk | find "STATE" | find "RUNNING" >NUL
if %errorlevel% neq 0 (
    echo AnyDesk servisi başlatılıyor...
    sc start AnyDesk
    timeout /t 10 /nobreak >NUL
    sc query AnyDesk | find "STATE" | find "RUNNING" >NUL
    if %errorlevel% neq 0 (
        echo Servis başlatılamadı. Tekrar deneniyor...
        call :start_installed_any
    ) else (
        echo AnyDesk servisi başarıyla başlatıldı.
    )
) else (
    echo AnyDesk servisi zaten çalışıyor.
    echo Anydesk.exe başlatılacak.
    call :start_any_exe
)

goto :eof


:start_any_exe
set "AnyDesk1=%SystemDrive%\Program Files (x86)\AnyDesk\AnyDesk.exe"
set "AnyDesk2=%SystemDrive%\Program Files\AnyDesk\AnyDesk.exe"
if exist "%AnyDesk1%" start "" "%AnyDesk1%"
if exist "%AnyDesk2%" start "" "%AnyDesk2%"
echo 10 saniye beklediğiniz halde AnyDesk açılmamışsa açılmasını bekledikten sonra devam edin.
timeout /t 10 /nobreak >NUL
pause
::call :lic

goto :Son
		
:::start_any_exe_yedek
::if exist "c:\Program Files (x86)" (set ostype=64) else (set ostype=32)
::if %ostype%==32 (set pdir="C:\Program Files\AnyDesk\") else (set pdir="C:\Program Files (x86)\AnyDesk\")
::c:
::cd\
::cd %pdir%
::start Anydesk.exe

::goto :Son


:stop_any
echo stop any

:: Hizmetin durumunu kontrol et
sc query AnyDesk | find "STATE" | find "RUNNING" >NUL
if %errorlevel% equ 0 (
    :: Hizmet çalışıyorsa durdurmayı dene
    echo Anydesk servisi durduruluyor...
    sc stop AnyDesk
    :: Hizmetin durmasını bekleyin
    timeout /t 5 /nobreak >NUL
    :: Hizmetin durup durmadığını kontrol et
    sc query AnyDesk | find "STATE" | find "STOPPED" >NUL
    if %errorlevel% neq 0 (
        :: Hizmet hala durmadıysa hata mesajı ver
        echo Servis durdurulamadı. Manuel olarak kontrol edin.
    ) else (
        echo AnyDesk servisi başarıyla durduruldu.
    )
) else (
    echo AnyDesk servisi zaten çalışmıyor.
)

:: AnyDesk işlemlerini kapat
taskkill /f /im "AnyDesk.exe" 2>NUL

goto :eof



:Son
echo *********
echo *********
echo *********
echo *********
echo *********
echo AnyDesk ID Reset işlemi başarıyla tamamlandı.
timeout /t 10 /nobreak >NUL
pause
exit /b