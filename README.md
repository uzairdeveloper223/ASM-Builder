# ASM Builder for Linux

A powerful, cross-platform assembly language build and run tool that simplifies the process of compiling and executing assembly programs. Supports multiple architectures, syntaxes, and provides advanced features like auto-dependency installation, watch mode, benchmarking, and more.

## Features

- 🚀 **Easy Assembly Building**: Compile and run assembly programs with a single command
- 🔧 **Multi-Platform Support**: Works on Linux, macOS, and Windows (via WSL/Cygwin)
- 🏗️ **Multiple Architectures**: Support for 32-bit, 64-bit, and ARM64 architectures
- 📝 **Syntax Flexibility**: Intel and AT&T assembly syntax support
- ⚡ **Optimization Levels**: Configurable optimization levels (O0-O3)
- 🔄 **Watch Mode**: Automatically rebuild when source files change
- 📊 **Benchmarking**: Measure execution performance of compiled programs
- 🐛 **Debug Support**: Built-in debugging with GDB-compatible output
- 📦 **Auto-Dependency Installation**: Automatically install required tools (NASM, GCC, etc.)
- 🔄 **Self-Updating**: Check for and install updates automatically
- 🧹 **Clean Builds**: Remove build artifacts with ease
- 📋 **Comprehensive Logging**: Detailed logs for troubleshooting
- 🎨 **Colorful Output**: Enhanced terminal output with colors and progress indicators

## Installation

### Quick Install (Recommended)

```bash
# Download and run the installer
curl -sL https://raw.githubusercontent.com/uzairdeveloper223/ASM-Runner-For-Linux/main/installer.sh | bash
```

### Manual Installation

1. Download the `asmbuilder` script:
```bash
wget https://raw.githubusercontent.com/uzairdeveloper223/ASM-Runner-For-Linux/main/asmbuilder
```

2. Make it executable:
```bash
chmod +x asmbuilder
```

3. Move to a directory in your PATH:
```bash
sudo mv asmbuilder /usr/local/bin/
```

### Dependencies

The installer will automatically install required dependencies. Manual installation requires:

- **NASM**: Netwide Assembler
- **GCC**: GNU Compiler Collection
- **make**: Build automation tool
- **curl**: For updates and downloads

## Usage

### Basic Usage

```bash
# Build and run an assembly program
asmbuilder hello.asm

# Specify output filename
asmbuilder -o myprogram hello.asm

# Build with optimization
asmbuilder -O2 -o optimized hello.asm
```

### Advanced Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-v, --version` | Show version information |
| `-u, --update` | Check for updates |
| `-r, --repair` | Repair installation |
| `-c, --clean` | Clean build artifacts |
| `-d, --debug` | Enable debug mode |
| `-o, --output <name>` | Specify output filename |
| `-O, --optimize <level>` | Set optimization level (0-3) |
| `-A, --arch <arch>` | Target architecture (32/64/arm64) |
| `-S, --syntax <syntax>` | Assembly syntax (intel/att) |
| `-l, --link <libs>` | Link with libraries |
| `-w, --watch` | Watch file for changes |
| `-b, --benchmark` | Benchmark the program |
| `-p, --profile` | Generate profiling data |
| `--install-deps` | Auto-install dependencies |
| `--show-log` | Display log file |
| `--clear-cache` | Clear cache directory |
| `--config` | Open configuration file |
| `--static` | Build static binary |
| `--strip` | Strip symbols |
| `--pie` | Build position-independent executable |

## Examples

### Basic Hello World

Create a file `hello.asm`:

```nasm
section .data
    hello db 'Hello, World!', 0xA
    hello_len equ $ - hello

section .text
    global _start

_start:
    ; Write hello to stdout
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, hello      ; message
    mov rdx, hello_len  ; length
    syscall

    ; Exit
    mov rax, 60         ; syscall: exit
    mov rdi, 0          ; exit code
    syscall
```

Build and run:
```bash
asmbuilder hello.asm
```

### 64-bit Program with Libraries

```bash
# Build with math library
asmbuilder -l m -o calculator calc.asm

# Build static binary
asmbuilder --static -o static_calc calc.asm
```

### Watch Mode for Development

```bash
# Automatically rebuild when file changes
asmbuilder -w program.asm
```

### Benchmarking Performance

```bash
# Benchmark your program
asmbuilder -b program.asm
```

### Cross-Architecture Building

```bash
# Build for 32-bit
asmbuilder -A 32 -o program32 program.asm

# Build for ARM64 (if supported)
asmbuilder -A arm64 -o program_arm program.asm
```

## Configuration

Configuration files are stored in `~/.config/asmbuilder/`:

- `config.conf`: Main configuration
- `asmbuilder.log`: Operation logs

## Troubleshooting

### Common Issues

1. **Permission Denied**: Make sure the script is executable
   ```bash
   chmod +x asmbuilder
   ```

2. **Dependencies Missing**: Run auto-install
   ```bash
   asmbuilder --install-deps
   ```

3. **PATH Issues**: Ensure installation directory is in PATH
   ```bash
   export PATH="$PATH:/usr/local/bin"
   ```

4. **Architecture Mismatch**: Specify correct architecture
   ```bash
   asmbuilder -A 64 program.asm
   ```

### Getting Help

```bash
# Show detailed help
asmbuilder --help

# Show version and system info
asmbuilder --version

# View logs
asmbuilder --show-log
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**UzairDeveloper223**
- Email: contact@uzair.is-a.dev
- Website: https://uzair.is-a.dev
- GitHub: [@uzairdeveloper223](https://github.com/uzairdeveloper223)

## Version

Current Version: 1.0.1

---

**Happy Assembling! 🏗️**
