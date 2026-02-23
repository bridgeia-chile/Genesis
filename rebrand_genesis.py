#!/usr/bin/env python3
"""
Script de rebranding masivo para Genesis.
Renombra archivos y reemplaza contenido de 'genesis' a 'genesis'.
Solo opera dentro del directorio especificado.
"""

import os
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

# Configuración
TARGET_DIR = Path("/home/convexai/Proyectos/genesis_base/genesis")
EXCLUDE_DIRS = {
    'node_modules', 'venv', '__pycache__', '.git', '.idea', '.vscode',
    '.next', '.nuxt', 'dist', 'build', 'coverage', '.cache', '.npm',
    '.yarn', 'tmp', 'temp', '.terraform', '.serverless'
}
EXCLUDE_FILES = {'.gitignore', '.gitattributes', '.env', '.env.local'}

# Patrones de búsqueda (case-insensitive)
PATTERNS = [
    (r'genesis', 'genesis'),      # lowercase
    (r'genesis', 'Genesis'),      # PascalCase
    (r'genesis', 'GENESIS'),      # UPPERCASE
    (r'genesis', 'Genesis'),      # Capitalized
]

# Archivos de texto a procesar
TEXT_EXTENSIONS = {
    '.md', '.txt', '.json', '.yaml', '.yml', '.toml',
    '.js', '.ts', '.jsx', '.tsx', '.py', '.java', '.cpp', '.c', '.h',
    '.html', '.css', '.scss', '.less', '.xml', '.sh', '.bash',
    '.php', '.rb', '.go', '.rs', '.swift', '.kt', '.dart',
    '.sql', '.graphql', '.gql', '.env', '.config', '.conf',
    '.ini', '.cfg', '.properties', '.lock', '.log'
}

# BINARY_EXTENSIONS para excluir
BINARY_EXTENSIONS = {
    '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.svg',
    '.mp3', '.mp4', '.wav', '.ogg', '.flac', '.avi', '.mov',
    '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
    '.zip', '.tar', '.gz', '.7z', '.rar', '.iso',
    '.exe', '.dll', '.so', '.dylib', '.bin'
}

def is_text_file(filepath):
    """Determina si un archivo es de texto basado en extensión y contenido."""
    ext = filepath.suffix.lower()
    
    # Excluir extensiones binarias conocidas
    if ext in BINARY_EXTENSIONS:
        return False
    
    # Incluir extensiones de texto conocidas
    if ext in TEXT_EXTENSIONS:
        return True
    
    # Para extensiones desconocidas, verificar contenido
    try:
        with open(filepath, 'rb') as f:
            chunk = f.read(1024)
            # Archivo binario si contiene null bytes
            if b'\x00' in chunk:
                return False
            # Verificar si es UTF-8 válido
            try:
                chunk.decode('utf-8')
                return True
            except UnicodeDecodeError:
                return False
    except Exception:
        return False

def should_exclude(path):
    """Determina si un path debe ser excluido."""
    # Excluir directorios específicos
    for part in path.parts:
        if part in EXCLUDE_DIRS:
            return True
    
    # Excluir archivos específicos
    if path.name in EXCLUDE_FILES:
        return True
    
    # Excluir archivos binarios
    if not is_text_file(path):
        return True
    
    return False

def rename_files_and_dirs(root_dir):
    """Renombra archivos y directorios que contienen 'genesis'."""
    changes = []
    
    # Primero renombrar directorios (profundidad primero)
    for dirpath, dirnames, filenames in os.walk(root_dir, topdown=False):
        dirpath = Path(dirpath)
        
        # Renombrar directorios
        for dirname in dirnames:
            old_path = dirpath / dirname
            if should_exclude(old_path):
                continue
            
            # Buscar 'genesis' en el nombre (case-insensitive)
            new_name = re.sub(r'genesis', 'genesis', dirname, flags=re.IGNORECASE)
            if new_name != dirname:
                new_path = dirpath / new_name
                try:
                    old_path.rename(new_path)
                    changes.append(('DIR', str(old_path), str(new_path)))
                except Exception as e:
                    print(f"Error renombrando directorio {old_path}: {e}")
    
    # Luego renombrar archivos
    for dirpath, dirnames, filenames in os.walk(root_dir):
        dirpath = Path(dirpath)
        
        for filename in filenames:
            old_path = dirpath / filename
            if should_exclude(old_path):
                continue
            
            # Buscar 'genesis' en el nombre (case-insensitive)
            new_name = re.sub(r'genesis', 'genesis', filename, flags=re.IGNORECASE)
            if new_name != filename:
                new_path = dirpath / new_name
                try:
                    old_path.rename(new_path)
                    changes.append(('FILE', str(old_path), str(new_path)))
                except Exception as e:
                    print(f"Error renombrando archivo {old_path}: {e}")
    
    return changes

def replace_content_in_files(root_dir):
    """Reemplaza contenido en archivos de texto."""
    changes = []
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        dirpath = Path(dirpath)
        
        # Excluir directorios
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        
        for filename in filenames:
            filepath = dirpath / filename
            if should_exclude(filepath):
                continue
            
            try:
                # Leer contenido
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                original_content = content
                
                # Aplicar todos los reemplazos
                for pattern, replacement in PATTERNS:
                    content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
                
                # Si hubo cambios, escribir de vuelta
                if content != original_content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    # Contar cambios
                    changes_count = 0
                    for pattern, replacement in PATTERNS:
                        # Contar ocurrencias reemplazadas
                        old_matches = len(re.findall(pattern, original_content, flags=re.IGNORECASE))
                        new_matches = len(re.findall(pattern, content, flags=re.IGNORECASE))
                        changes_count += (old_matches - new_matches)
                    
                    changes.append((str(filepath), changes_count))
                    
            except Exception as e:
                print(f"Error procesando {filepath}: {e}")
    
    return changes

def create_backup(root_dir):
    """Crea una copia de seguridad del directorio."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = root_dir.parent / f"backup_genesis_{timestamp}"
    
    print(f"Creando copia de seguridad en: {backup_dir}")
    
    try:
        # Copiar directorio excluyendo algunos archivos grandes/dinámicos
        shutil.copytree(
            root_dir,
            backup_dir,
            ignore=shutil.ignore_patterns(
                'node_modules', 'venv', '__pycache__', '.git',
                '*.log', '*.tmp', '*.temp', '.cache', 'dist', 'build'
            ),
            dirs_exist_ok=True
        )
        print(f"✓ Backup creado exitosamente")
        return backup_dir
    except Exception as e:
        print(f"✗ Error creando backup: {e}")
        return None

def main():
    """Función principal."""
    print("=" * 60)
    print("SCRIPT DE REBRANDING GENESIS")
    print("=" * 60)
    print(f"Directorio objetivo: {TARGET_DIR}")
    print(f"Excluyendo: {', '.join(sorted(EXCLUDE_DIRS))}")
    print()
    
    # Verificar que estamos en el directorio correcto
    if not TARGET_DIR.exists():
        print(f"✗ Error: El directorio {TARGET_DIR} no existe.")
        sys.exit(1)
    
    # Crear backup
    print("1. Creando copia de seguridad...")
    backup_dir = create_backup(TARGET_DIR)
    if not backup_dir:
        print("¿Continuar sin backup? (s/n): ", end='')
        if input().lower() != 's':
            print("Operación cancelada.")
            sys.exit(1)
    
    # Renombrar archivos y directorios
    print("\n2. Renombrando archivos y directorios...")
    rename_changes = rename_files_and_dirs(TARGET_DIR)
    print(f"✓ Renombrados: {len(rename_changes)} elementos")
    
    # Reemplazar contenido
    print("\n3. Reemplazando contenido en archivos...")
    content_changes = replace_content_in_files(TARGET_DIR)
    print(f"✓ Modificados: {len(content_changes)} archivos")
    
    # Mostrar resumen
    print("\n" + "=" * 60)
    print("RESUMEN DE CAMBIOS")
    print("=" * 60)
    
    if rename_changes:
        print("\nArchivos/Directorios renombrados:")
        for change_type, old_path, new_path in rename_changes[:10]:  # Mostrar primeros 10
            print(f"  {change_type}: {old_path} → {new_path}")
        if len(rename_changes) > 10:
            print(f"  ... y {len(rename_changes) - 10} más")
    
    if content_changes:
        total_replacements = sum(count for _, count in content_changes)
        print(f"\nReemplazos de contenido: {total_replacements} en {len(content_changes)} archivos")
        for filepath, count in content_changes[:10]:  # Mostrar primeros 10
            print(f"  {filepath}: {count} reemplazos")
        if len(content_changes) > 10:
            print(f"  ... y {len(content_changes) - 10} archivos más")
    
    print(f"\n✓ Proceso completado exitosamente")
    if backup_dir:
        print(f"✓ Backup disponible en: {backup_dir}")
    print("=" * 60)

if __name__ == "__main__":
    main()