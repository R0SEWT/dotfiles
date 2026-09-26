# Windows VM

Paquete de `stow` para levantar una VM local de Windows sobre `qemu` + `KVM` + `swtpm` en Fedora.
La configuración de ejemplo está ajustada para Windows 10 con una máquina más modesta.

## Qué instala

- `~/.local/bin/windows-vm`
- `~/.config/windows-vm/windows-vm.env.example`

No versiona discos, ISOs ni estado de TPM. Todo eso vive fuera del repo, por defecto en `~/VMs/windows10`.

## Uso

1. Aplicar el paquete:

   ```bash
   cd ~/dotfiles
   stow windows-vm
   ```

2. Crear tu configuración local:

   ```bash
   mkdir -p ~/.config/windows-vm
   cp ~/.config/windows-vm/windows-vm.env.example ~/.config/windows-vm/windows-vm.env
   ```

3. Validar prerrequisitos:

   ```bash
   windows-vm doctor
   ```

4. Ajustar estas rutas en `~/.config/windows-vm/windows-vm.env`:

   - `WINDOWS_ISO`
   - `VIRTIO_ISO`
   - `VM_DIR` si no quieres usar `~/VMs/windows10`

   La configuración por defecto usa `DISK_BUS="sata"` y `NET_DEVICE="e1000e"` para que el instalador de Windows 10 vea mejor el disco y la red desde el primer arranque.

5. Crear disco y firmware escribible:

   ```bash
   windows-vm create
   ```

6. Primera instalación de Windows:

   ```bash
   windows-vm install
   ```

7. Arranques siguientes:

   ```bash
   windows-vm start
   ```

## Notas

- El script usa `OVMF` con Secure Boot y `swtpm`, así que también te deja margen si luego quieres migrar esta VM a Windows 11.
- Si el instalador no detecta disco o red, carga los drivers desde `virtio-win.iso`.
- Si `-enable-kvm` falla, revisa permisos de virtualización en la sesión real (`/dev/kvm`, grupo `kvm`, BIOS/UEFI con VT-x/AMD-V activo).
