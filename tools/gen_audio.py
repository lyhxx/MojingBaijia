import wave, struct, math, random, os
SR = 22050
OUT = r"D:\code\test3\audio"
os.makedirs(OUT, exist_ok=True)

def save(name, samples):
    p = os.path.join(OUT, name)
    with wave.open(p, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(struct.pack("<" + "h" * len(samples), *[max(-32768, min(32767, int(s * 32767))) for s in samples]))
    print("wrote", p, len(samples))

def tone(f, dur, vol=0.4, slide=0.0, wave2="sine"):
    n = int(SR * dur); out = []
    ph = 0.0
    for i in range(n):
        t = i / SR
        ff = f * (1.0 + slide * t / max(dur, 1e-6))
        ph += 2 * math.pi * ff / SR
        v = math.sin(ph) if wave2 == "sine" else (math.sin(ph) + 0.4 * math.sin(2 * ph)) / 1.4
        env = min(1.0, i / (SR * 0.01)) * (1.0 - i / n)
        out.append(v * vol * env)
    return out

def noise(dur, vol=0.3, low=400.0):
    n = int(SR * dur); out = []; last = 0.0
    a = math.exp(-2 * math.pi * low / SR)
    for i in range(n):
        wht = random.uniform(-1, 1)
        last = last * a + wht * (1 - a)
        env = (1.0 - i / n)
        out.append(last * vol * 3.0 * env)
    return out

def mix(*tracks):
    L = max(len(t) for t in tracks)
    out = [0.0] * L
    for t in tracks:
        for i, v in enumerate(t):
            out[i] += v
    m = max(1e-6, max(abs(v) for v in out))
    return [v / m * 0.85 for v in out]

save("sword.wav", mix(noise(0.16, 0.5, 2500.0), tone(1400, 0.12, 0.15, -0.6)))
save("seal.wav", mix(tone(90, 0.35, 0.7, -0.3), noise(0.25, 0.35, 300.0)))
save("pickup.wav", tone(880, 0.09, 0.3, 0.5))
save("levelup.wav", mix(tone(523, 0.25, 0.35), tone(784, 0.3, 0.3)))
save("chest.wav", mix(tone(392, 0.2, 0.3), tone(523, 0.2, 0.3), tone(659, 0.35, 0.35)))
save("hit.wav", mix(noise(0.08, 0.4, 900.0), tone(200, 0.08, 0.3, -0.4)))
save("soul.wav", mix(tone(330, 0.3, 0.3, 0.8, "tri"), tone(495, 0.25, 0.2, 0.6, "tri")))
save("boss.wav", mix(tone(65, 0.8, 0.7, 0.2), noise(0.7, 0.3, 150.0)))
save("nuke.wav", mix(noise(0.6, 0.5, 500.0), tone(120, 0.6, 0.5, -0.7)))
# bgm: 24s pentatonic plucks + paper wash
random.seed(42)
penta = [220.0, 246.9, 277.2, 329.6, 370.0, 440.0, 493.9]
bgm = [0.0] * (SR * 24)
for k in range(28):
    f = random.choice(penta) / 2.0
    st = int(random.uniform(0, 22) * SR)
    nn = tone(f, 1.6, 0.22)
    for i, v in enumerate(nn):
        if st + i < len(bgm):
            bgm[st + i] += v
wash = noise(24.0, 0.05, 200.0)
save("bgm.wav", mix(bgm, wash))
print("AUDIO_DONE")
