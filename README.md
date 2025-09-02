# ASM Builder

A simple Bash tool to assemble, compile, and run **x86_64 Assembly programs** easily using NASM + GCC.

## 🚀 Features
- Build & run `.asm` files in one command
- Dependency check (nasm, gcc, curl)
- Show help & version
- Auto-update from GitHub (`--update`)
- Error handling for missing files & dependencies

## 📦 Requirements
- `nasm`
- `gcc`
- `curl`

Install them on Ubuntu/Debian:
```bash
sudo apt install nasm gcc curl -y
````

## 🛠 Usage

```bash
./asmbuild.sh [options] <file.asm>
```

### Options

* `-h, --help` → Show help
* `-v, --version` → Show version
* `--update` → Update script to latest version

### Example

```bash
./asmbuild.sh hello.asm
```

## 🔄 Update

Check & update to latest version:

```bash
./asmbuild.sh --update
```

---

Made with ❤️ by **UzairDeveloper223**
