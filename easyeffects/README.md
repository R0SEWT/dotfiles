# EasyEffects Pipeline & Diagnostics

Presets orientados al diagnóstico, estabilización y compensación de sistemas de audio usando EasyEffects en Linux (PipeWire).

## Pipeline Estándar
1. **Equalizer** (Ajuste frecuencial)
2. **Multiband Compressor** (Control dinámico por bandas)
3. **Limiter** (Techo de seguridad)

## Flujo de Trabajo (Diagnóstico)
```text
[Base Balanceado] → [Test experimental] → [Diagnóstico] → [Ajuste fino] → [Preset final]
```

## Presets de Diagnóstico
1. **Balanceado** (Baseline)
2. **Crossover**: Crucial para sistemas mixtos o con interferencia de drivers.
3. **Mid-focus**: Revela pérdida de claridad por enmascaramiento.
4. **V-shape**: Diagnostica sistemas mid-heavy.
5. **Bass stress**: Chequeo de sub-graves sueltos.

### Interpretación de Zonas Críticas:
* **120-300 Hz**: Problema principal de sonido a "caja" o "mud". Cortar antes de subir.
* **1-3 kHz**: Rango de claridad vocal.
* **60-100 Hz**: Impacto.
* **6-10 kHz**: Brillo y detalle. Bajar si hay fatiga auditiva.

*Regla:* Primero cortar (cut), luego potenciar (boost). Mueve una sola variable a la vez. Siempre usar Limiter. Evitar boosts mayores a +3 dB.

---

## Troubleshooting Rápido

### Stack de Audio
* Verificar servidor: `pactl info` debe listar PipeWire.
* Todo activo: `systemctl --user status pipewire wireplumber pipewire-pulse`
* Output device: `pactl list sinks` (asegurar que es el correcto, ej. `analog-stereo`, evitar HDMI si no es el destino).

### Reglas Físicas y Configuraciones
* **Volumen General**: <= 100%. Usar el pre-gain de EasyEffects en negativo (-1 a -3 dB).
* **Sample Rate**: Fijo en 48kHz (si es 44.1kHz, hay resampling).
* **Latencia/Glitches**: Revisar `pw-top`. Si hay XRUNS, ajustar el quantum.
* **Sanity Check de Setup**: Si cambias a un preset extremo y el sonido **no** cambia, EasyEffects no está aplicando al target adecuado.

### Instalación (GNU Stow)
```bash
git clone <url-del-repo> ~/dotfiles
cd ~/dotfiles
stow easyeffects
```