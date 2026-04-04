import wave
import math
import struct
import os

sample_rate = 44100
duration = 0.8
file_path = "alert.wav"

with wave.open(file_path, 'w') as obj:
    obj.setnchannels(1)
    obj.setsampwidth(2)
    obj.setframerate(sample_rate)
    
    for i in range(int(duration * sample_rate)):
        t = i / float(sample_rate)
        
        # Exponential decay envelope for a "ding"
        envelope = math.exp(-6 * t)
        
        # Fundamental frequency (e.g., 1046.50 Hz - C6)
        freq = 1046.50
        
        # Combine sine waves for a "glass/chime" effect
        v1 = math.sin(freq * math.pi * 2 * t)
        v2 = 0.6 * math.sin(freq * 2.76 * math.pi * 2 * t)
        v3 = 0.4 * math.sin(freq * 5.4 * math.pi * 2 * t)
        
        # Arpeggio effect: add a higher note slightly delayed (E6)
        v4 = 0
        if t > 0.08:
            env2 = math.exp(-7 * (t - 0.08))
            v4 = env2 * math.sin(1318.51 * math.pi * 2 * (t - 0.08))
            
        value = (v1 + v2 + v3) * envelope * 0.4 + (v4 * 0.5)
        
        # Convert to 16-bit PCM
        pcm_val = int(32767.0 * max(-1.0, min(1.0, value)))
        data = struct.pack('<h', pcm_val)
        obj.writeframesraw(data)
