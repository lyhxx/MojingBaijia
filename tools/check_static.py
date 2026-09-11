import os, re
root = r"D:\code\test3"
errs = []
for dp, dn, fns in os.walk(os.path.join(root, "scripts")):
    for fn in fns:
        if not fn.endswith(".gd"):
            continue
        p = os.path.join(dp, fn)
        txt = open(p, encoding="utf-8").read()
        for m in re.finditer(r'preload\("res://([^"]+)"\)', txt):
            rel = m.group(1).replace("/", os.sep)
            if not os.path.exists(os.path.join(root, rel)):
                errs.append("MISSING_PRELOAD " + fn + ": res://" + m.group(1))
for sc in ["scenes/main.tscn", "scenes/menu.tscn"]:
    txt = open(os.path.join(root, sc), encoding="utf-8").read()
    for m in re.finditer(r'path="res://([^"]+)"', txt):
        rel = m.group(1).replace("/", os.sep)
        if not os.path.exists(os.path.join(root, rel)):
            errs.append("MISSING_SCENE_RES " + sc + ": " + m.group(1))
main = open(os.path.join(root, "scripts/main.gd"), encoding="utf-8").read()
hud = open(os.path.join(root, "scripts/hud.gd"), encoding="utf-8").read()
for meth in ["toggle_pause","restart_run","to_menu","reroll_choices","cast_nuke","fire_swords","fire_seals","fire_soul","deal_aoe","spawn_splash","spawn_dmgnum","open_chest","apply_upgrade","show_end","show_boss","hide_boss","show_choices","refresh_items","show_pause"]:
    if ("func " + meth) not in main and ("func " + meth) not in hud:
        errs.append("MISSING_METHOD " + meth)
checks = [("MojingPlayer","scripts/player.gd"),("MojingEnemy","scripts/enemy.gd"),("MojingGolem","scripts/golem.gd"),("InkCrow","scripts/crow.gd"),("InkJudge","scripts/boss.gd"),("FlyingSword","scripts/sword.gd"),("FallingSeal","scripts/seal.gd"),("SoulChainFx","scripts/soul.gd"),("OrbitInk","scripts/orbit.gd"),("XPGem","scripts/gem.gd"),("TreasureChest","scripts/chest.gd"),("InkBullet","scripts/ebullet.gd"),("MojingHUD","scripts/hud.gd"),("MojingMain","scripts/main.gd"),("PaperBG","scripts/paper_bg.gd"),("GroundInk","scripts/ground_ink.gd"),("InkSplash","scripts/splash.gd"),("DmgNum","scripts/dmgnum.gd")]
for cls, path in checks:
    txt = open(os.path.join(root, path), encoding="utf-8").read()
    if ("class_name " + cls) not in txt:
        errs.append("MISSING_CLASS " + cls + " in " + path)
print("ERRORS:" if errs else "STATIC_OK")
for e in errs:
    print(" - " + e)
