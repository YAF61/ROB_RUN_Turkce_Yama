@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex (Get-Content -LiteralPath '%~f0' -Encoding utf8 | Select-Object -Skip 4 | Out-String)"
exit /b
$Host.UI.RawUI.WindowTitle = "ROB RUN Turkce Yama Kaldirici - YAF"

$DIR_NAME = "YAF_TRMod"
$BUNDLE_TEXT_NEW = "robrun-turkce-metin-tablosu-yaf-turkce-mod-1-staticstrings-realmnames-zamanbicimleri-v01.bundle"
$BUNDLE_FONT_NEW = "robrun-turkce-fontlar-tmpatlas-yaf-fontu.bundle"

$appDataLow = [System.IO.Path]::Combine($env:USERPROFILE, "AppData\LocalLow\Kefir\ROB RUN")
$ourDir = [System.IO.Path]::Combine($appDataLow, $DIR_NAME)
$cacheDir = [System.IO.Path]::Combine($appDataLow, "com.unity.addressables")

function Find-ByteSequence($source, $pattern) {
    if ($source.Length -lt $pattern.Length) { return -1 }
    for ($i = 0; $i -le ($source.Length - $pattern.Length); $i++) {
        $match = $true
        for ($j = 0; $j -lt $pattern.Length; $j++) {
            if ($source[$i + $j] -ne $pattern[$j]) {
                $match = $false
                break
            }
        }
        if ($match) { return $i }
    }
    return -1
}

function Remove-Legacy() {
    try {
        $oldMarker = [System.IO.Path]::Combine($cacheDir, ".bizim-yama-rob-run")
        if (Test-Path $oldMarker) { Remove-Item $oldMarker -Force -ErrorAction SilentlyContinue }
        
        foreach ($legacyName in @("BizimYama", "RobRun_TR")) {
            $p = [System.IO.Path]::Combine($appDataLow, $legacyName)
            if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
        }
    } catch {}
}

function Uninstall-Patch() {
    Write-Host "[*] Turkce yama kaldiriliyor..." -ForegroundColor Cyan
    Remove-Legacy
    $removed = 0

    if (Test-Path $cacheDir) {
        $cats = Get-ChildItem -Path $cacheDir -Filter "catalog_*.bin" -File
        $persistTok = [System.Text.Encoding]::UTF8.GetBytes("{UnityEngine.Application.persistentDataPath}/$DIR_NAME/")
        $oldTok1 = [System.Text.Encoding]::UTF8.GetBytes("BizimYama")
        $oldTok2 = [System.Text.Encoding]::UTF8.GetBytes("RobRun_TR")
        foreach ($c in $cats) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($c.FullName)
                if ((Find-ByteSequence $bytes $persistTok) -ne -1 -or 
                    (Find-ByteSequence $bytes $oldTok1) -ne -1 -or 
                    (Find-ByteSequence $bytes $oldTok2) -ne -1) {
                    Remove-Item $c.FullName -Force -ErrorAction SilentlyContinue
                    $h = [System.IO.Path]::ChangeExtension($c.FullName, ".hash")
                    if (Test-Path $h) { Remove-Item $h -Force -ErrorAction SilentlyContinue }
                    $removed++
                }
            } catch {}
        }
    }

    if (Test-Path $ourDir) {
        Remove-Item $ourDir -Recurse -Force -ErrorAction SilentlyContinue
        $removed++
    }

    if ($removed -gt 0) {
        Write-Host "`n[+] Turkce yama basariyla kaldirildi. Oyun orijinal haline donduruldu." -ForegroundColor Green
    } else {
        Write-Host "`n[!] Kurulu Turkce yama bulunamadi." -ForegroundColor Yellow
    }
}

function Find-RobRunDir() {
    $roots = New-Object System.Collections.Generic.List[string]
    try {
        $k = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Valve\Steam")
        if ($k) { $val = $k.GetValue("SteamPath"); if ($val) { $roots.Add($val) } }
    } catch {}
    try {
        $k2 = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\WOW6432Node\Valve\Steam")
        if ($k2) { $val2 = $k2.GetValue("InstallPath"); if ($val2) { $roots.Add($val2) } }
    } catch {}

    $roots.Add("C:\Program Files (x86)\Steam")
    $roots.Add("C:\Program Files\Steam")
    $roots.Add("D:\Steam")
    $roots.Add("D:\SteamLibrary")
    $roots.Add("E:\SteamLibrary")

    $libs = New-Object System.Collections.Generic.HashSet[string]
    foreach ($r in $roots) {
        if (Test-Path $r) {
            [void]$libs.Add($r)
            $vdf = Join-Path $r "steamapps\libraryfolders.vdf"
            if (Test-Path $vdf) {
                try {
                    $content = Get-Content $vdf -Raw
                    $matches = [regex]::Matches($content, '"path"\s+"([^"]+)"')
                    foreach ($m in $matches) {
                        $p = $m.Groups[1].Value.Replace("\\", "\")
                        if (Test-Path $p) { [void]$libs.Add($p) }
                    }
                } catch {}
            }
        }
    }

    foreach ($lib in $libs) {
        $cand = Join-Path $lib "steamapps\common\Rob Run"
        if (Test-Path (Join-Path $cand "ROB RUN.exe")) {
            return $cand
        }
    }
    return $null
}

function Install-Patch() {
    Write-Host "[*] ROB RUN kurulumu araniyor..." -ForegroundColor Cyan
    $gDir = Find-RobRunDir

    if (-not $gDir) {
        Write-Host "[!] Oyun Steam klasorunde otomatik tespit edilemedi." -ForegroundColor Yellow
        $gDir = Read-Host "Lutfen ROB RUN.exe dosyasinin bulundugu klasoru yapistirin"
        if ($gDir) { $gDir = $gDir.Trim().Trim('"') }
        if (-not $gDir -or -not (Test-Path (Join-Path $gDir "ROB RUN.exe"))) {
            Write-Host "[HATA] Belirtilen konumda ROB RUN.exe bulunamadi!" -ForegroundColor Red
            return
        }
    }

    Write-Host "[+] Oyun klasoru bulundu: $gDir" -ForegroundColor Green

    $aaDir = Join-Path $gDir "ROB RUN_Data\StreamingAssets\aa"
    $swDir = Join-Path $aaDir "StandaloneWindows64"
    $catFile = $null
    if (Test-Path $swDir) {
        $bins = Get-ChildItem -Path $swDir -Filter "catalog_*.bin" -File | Sort-Object Name
        if ($bins.Count -gt 0) {
            $catFile = $bins[-1].FullName
        }
    }
    if (-not $catFile) {
        $legacyCat = Join-Path $aaDir "catalog.bin"
        if (Test-Path $legacyCat) { $catFile = $legacyCat }
    }

    if (-not $catFile) {
        Write-Host "[HATA] Oyunun katalog dosyasi (catalog_*.bin) bulunamadi!" -ForegroundColor Red
        return
    }

    $hashFile = [System.IO.Path]::ChangeExtension($catFile, ".hash")
    if (-not (Test-Path $hashFile)) {
        Write-Host "[HATA] Oyunun .hash dosyasi bulunamadi!" -ForegroundColor Red
        return
    }

    $scriptDir = (Get-Location).Path
    $yamaDir = Join-Path $scriptDir "Yama_Dosyalari"
    $bundle0 = Join-Path $yamaDir "00_localization-string-tables-english(unitedstates)(en-us)_assets_all.bundle"
    $bundle1 = Join-Path $yamaDir "01_inbuild_assets_all.bundle"

    if (-not (Test-Path $bundle0) -or -not (Test-Path $bundle1)) {
        Write-Host "[HATA] Yama_Dosyalari klasorundeki dosyalar eksik!" -ForegroundColor Red
        return
    }

    Write-Host "[*] Oyun katalogu isleniyor: $([System.IO.Path]::GetFileName($catFile))"
    $catBytes = [System.IO.File]::ReadAllBytes($catFile)

    $oldText = [System.Text.Encoding]::UTF8.GetBytes("{UnityEngine.AddressableAssets.Addressables.RuntimePath}\StandaloneWindows64\localization-string-tables-english(unitedstates)(en-us)_assets_all.bundle")
    $newText = [System.Text.Encoding]::UTF8.GetBytes("{UnityEngine.Application.persistentDataPath}/$DIR_NAME/$BUNDLE_TEXT_NEW")

    $oldFont = [System.Text.Encoding]::UTF8.GetBytes("{UnityEngine.AddressableAssets.Addressables.RuntimePath}\StandaloneWindows64\inbuild_assets_all.bundle")
    $newFont = [System.Text.Encoding]::UTF8.GetBytes("{UnityEngine.Application.persistentDataPath}/$DIR_NAME/$BUNDLE_FONT_NEW")

    $idx1 = Find-ByteSequence $catBytes $oldText
    if ($idx1 -eq -1) {
        Write-Host "[HATA] Oyun surumu katalog ile eslesmedi (metin girdisi bulunamadi)." -ForegroundColor Red
        return
    }

    $idx2 = Find-ByteSequence $catBytes $oldFont
    if ($idx2 -eq -1) {
        Write-Host "[HATA] Oyun surumu katalog ile eslesmedi (font girdisi bulunamadi)." -ForegroundColor Red
        return
    }

    [System.Array]::Copy($newText, 0, $catBytes, $idx1, $newText.Length)
    [System.Array]::Copy($newFont, 0, $catBytes, $idx2, $newFont.Length)

    Remove-Legacy

    if (Test-Path $ourDir) { Remove-Item $ourDir -Recurse -Force -ErrorAction SilentlyContinue }
    [System.IO.Directory]::CreateDirectory($ourDir) | Out-Null

    Copy-Item $bundle0 (Join-Path $ourDir $BUNDLE_TEXT_NEW) -Force
    Copy-Item $bundle1 (Join-Path $ourDir $BUNDLE_FONT_NEW) -Force

    $marker = Join-Path $ourDir "turkce-yama-yaf.txt"
    [System.IO.File]::WriteAllText($marker, "ROB RUN Turkce Yama - YAF`r`nBu klasor oyunun Turkce cevirisini icerir.`r`n", [System.Text.Encoding]::UTF8)

    if (-not (Test-Path $cacheDir)) { [System.IO.Directory]::CreateDirectory($cacheDir) | Out-Null }

    $destCat = Join-Path $cacheDir ([System.IO.Path]::GetFileName($catFile))
    $destHash = Join-Path $cacheDir ([System.IO.Path]::GetFileName($hashFile))

    [System.IO.File]::WriteAllBytes($destCat, $catBytes)
    Copy-Item $hashFile $destHash -Force

    Write-Host "`n[TEBRIKLER] ROB RUN Turkce Yama (YAF Surumu) basariyla kuruldu!" -ForegroundColor Green
    Write-Host "Oyununuzu Steam uzerinden dogrudan baslatabilirsiniz.`n" -ForegroundColor Green
}


Uninstall-Patch
try { [void][System.Console]::ReadKey($true) } catch { Read-Host "Devam etmek icin Enter'a basin" }

