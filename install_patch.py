"""
ROB RUN Türkçe Yaması — Açık Kaynak Kurucu
Hazırlayan ve Düzenleyen: YAF
Oyun klasöründeki orijinal dosyaları değiştirmez (EAC güvenli).
"""
import os
import re
import sys
import shutil
import argparse
from pathlib import Path

RUNTIME = b'{UnityEngine.AddressableAssets.Addressables.RuntimePath}\\StandaloneWindows64\\'
OUR_DIR_NAME = "YAF_TRMod"
OUR_TOK = b'{UnityEngine.Application.persistentDataPath}/' + OUR_DIR_NAME.encode() + b'/'

REDIRECTS = [
    (
        'metin',
        b'localization-string-tables-english(unitedstates)(en-us)_assets_all.bundle',
        b'robrun-turkce-metin-tablosu-yaf-turkce-mod-1-staticstrings-realmnames-zamanbicimleri-v01.bundle',
        '00_localization-string-tables-english(unitedstates)(en-us)_assets_all.bundle'
    ),
    (
        'font',
        b'inbuild_assets_all.bundle',
        b'robrun-turkce-fontlar-tmpatlas-yaf-fontu.bundle',
        '01_inbuild_assets_all.bundle'
    )
]

MARKER = "turkce-yama-yaf.txt"
GAME_DATA = r"%USERPROFILE%\AppData\LocalLow\Kefir\ROB RUN"

MSG_DONE = "ROB RUN Türkçe Yama (YAF Sürümü) başarıyla kuruldu."
MSG_REMOVED = "ROB RUN Türkçe Yama başarıyla kaldırıldı."
MSG_NONE = "Kurulu Türkçe yama bulunamadı."
MSG_NO_GAME = "ROB RUN bulunamadı. Lütfen --game parametresi ile oyun klasörünü belirtin."
MSG_BAD_GAME = "Seçilen klasörde ROB RUN.exe bulunamadı."
MSG_GAME_FILES = "Oyun dosyaları eksik veya bulunamadı. Steam'den dosya bütünlüğünü doğrulayın."
MSG_VERSION = "Bu yama oyunun şu anki sürümüyle uyumlu değil."
MSG_BROKEN = "Yama veri paketleri eksik veya bozuk."

def game_data_dir() -> Path:
    return Path(os.path.expandvars(GAME_DATA))

def cache_dir() -> Path:
    return game_data_dir() / "com.unity.addressables"

def our_dir() -> Path:
    return game_data_dir() / OUR_DIR_NAME

def find_game_dir(explicit: str | None = None) -> Path:
    if explicit:
        p = Path(explicit)
        if (p / "ROB RUN.exe").exists():
            return p
        sys.exit(MSG_BAD_GAME)

    roots: list[Path] = []
    try:
        import winreg
        for hive, key, val in [
            (winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam", "SteamPath"),
            (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Valve\Steam", "InstallPath")
        ]:
            try:
                with winreg.OpenKey(hive, key) as k:
                    v, _ = winreg.QueryValueEx(k, val)
                    roots.append(Path(v))
            except OSError:
                pass
    except ImportError:
        pass

    roots.extend([
        Path(r"C:\Program Files (x86)\Steam"),
        Path(r"C:\Program Files\Steam"),
        Path(r"D:\Steam"),
        Path(r"D:\SteamLibrary"),
        Path(r"E:\SteamLibrary")
    ])

    libs: list[Path] = []
    for r in roots:
        if not r.exists():
            continue
        libs.append(r)
        vdf = r / "steamapps" / "libraryfolders.vdf"
        if vdf.exists():
            try:
                content = vdf.read_text(encoding="utf-8", errors="ignore")
                for m in re.findall(r'"path"\s+"([^"]+)"', content):
                    libs.append(Path(m.replace(r'\\', r'\\')))
            except Exception:
                pass

    libs = list(dict.fromkeys(libs))
    for lib in libs:
        cand = lib / "steamapps" / "common" / "Rob Run"
        if (cand / "ROB RUN.exe").exists():
            return cand

    sys.exit(MSG_NO_GAME)

def catalog_in(aa: Path) -> Path:
    sw = aa / "StandaloneWindows64"
    bins = sorted(sw.glob("catalog_*.bin"))
    if bins:
        return bins[-1]
    legacy = aa / "catalog.bin"
    if legacy.exists():
        return legacy
    sys.exit(MSG_GAME_FILES)

def redirect_catalog(cat_bytes: bytearray) -> int:
    done = 0
    for _, old_name, new_name, _ in REDIRECTS:
        old = RUNTIME + old_name
        new = OUR_TOK + new_name
        if len(old) != len(new):
            sys.exit(MSG_BROKEN)
        n = cat_bytes.count(old)
        if n == 0 or n != 1:
            sys.exit(MSG_VERSION)
        idx = cat_bytes.find(old)
        cat_bytes[idx : idx + len(old)] = new
        done += 1
    return done

def remove_legacy() -> bool:
    try:
        cache = cache_dir()
        marker = cache / ".bizim-yama-rob-run"
        if marker.exists():
            marker.unlink(missing_ok=True)
        for old_name in ["BizimYama", "RobRun_TR"]:
            old_dir = game_data_dir() / old_name
            if old_dir.exists():
                shutil.rmtree(old_dir, ignore_errors=True)
    except Exception:
        pass
    return True

def install(game: str | None = None, data_dir: Path | None = None) -> int:
    if data_dir is None:
        data_dir = Path(__file__).resolve().parent / "Yama_Dosyalari"

    root = find_game_dir(game)
    print(f"Oyun dizini tespit edildi: {root}")

    aa = root / "ROB RUN_Data" / "StreamingAssets" / "aa"
    if not aa.exists():
        sys.exit(MSG_GAME_FILES)

    for _, _, _, our_file in REDIRECTS:
        if not (data_dir / our_file).exists():
            sys.exit(f"Hata: {our_file} bulunamadı!")

    cat = catalog_in(aa)
    hash_src = cat.with_suffix(".hash")
    if not hash_src.exists():
        sys.exit(MSG_GAME_FILES)

    print(f"Katalog dosyası işleniyor: {cat.name}")
    cat_bytes = bytearray(cat.read_bytes())
    redirect_catalog(cat_bytes)

    remove_legacy()

    ours = our_dir()
    if ours.exists():
        shutil.rmtree(ours, ignore_errors=True)
    ours.mkdir(parents=True, exist_ok=True)

    for _, _, new_name, our_file in REDIRECTS:
        shutil.copy2(data_dir / our_file, ours / new_name.decode())

    marker_file = ours / MARKER
    marker_file.write_text(
        "ROB RUN Türkçe Yama — YAF\n"
        "Bu klasör Türkçe metin ve font paketlerini tutar.\n",
        encoding="utf-8"
    )

    cache = cache_dir()
    cache.mkdir(parents=True, exist_ok=True)

    (cache / cat.name).write_bytes(cat_bytes)
    shutil.copy2(hash_src, cache / hash_src.name)

    print(MSG_DONE)
    return 0

def uninstall() -> int:
    remove_legacy()
    removed = 0
    cache = cache_dir()
    if cache.exists():
        for cat in cache.glob("catalog_*.bin"):
            try:
                b = cat.read_bytes()
                if OUR_TOK in b or b"BizimYama" in b or b"RobRun_TR" in b:
                    cat.unlink(missing_ok=True)
                    cat.with_suffix(".hash").unlink(missing_ok=True)
                    removed += 1
            except Exception:
                pass

    ours = our_dir()
    if ours.exists():
        shutil.rmtree(ours, ignore_errors=True)
        removed += 1

    if removed > 0:
        print(MSG_REMOVED)
    else:
        print(MSG_NONE)
    return 0

def main():
    parser = argparse.ArgumentParser(description="ROB RUN Türkçe Yama Kurucu — YAF")
    parser.add_argument("--game", help="ROB RUN klasörü (içinde ROB RUN.exe)", default=None)
    parser.add_argument("--data", help="Türkçe paketlerin bulunduğu klasör", default=None)
    parser.add_argument("--kaldir", action="store_true", help="Yamayı kaldır")
    args = parser.parse_args()

    data_path = Path(args.data) if args.data else (Path(__file__).resolve().parent / "Yama_Dosyalari")

    if args.kaldir:
        return uninstall()
    else:
        return install(args.game, data_path)

if __name__ == "__main__":
    sys.exit(main() or 0)
