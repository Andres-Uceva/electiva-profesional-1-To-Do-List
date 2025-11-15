# Todo List - Aplicación Flutter con Arquitectura Offline-First

Una aplicación de lista de tareas desarrollada en Flutter que implementa una arquitectura limpia con soporte offline-first y sincronización automática.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)
![Provider](https://img.shields.io/badge/State%20Management-Provider-green.svg)
![SQLite](https://img.shields.io/badge/Database-SQLite-orange.svg)

## Arquitectura

La aplicación sigue los principios de **Clean Architecture** con una estrategia **Offline-First**:

### Flujo Offline-First

1. **Lectura**: Siempre se leen datos locales primero (respuesta inmediata)
2. **Escritura**: Se guarda localmente y se encola para sincronización
3. **Sincronización**: Cuando hay conexión, las operaciones pendientes se envían al servidor
4. **Resolución de conflictos**: Last-Write-Wins (LWW) basado en `updatedAt`

## Tecnologías Utilizadas

### Frontend (Flutter)
- **Flutter 3.x**: Framework de desarrollo móvil
- **Dart 3.x**: Lenguaje de programación
- **Provider**: Gestión de estado
- **sqflite**: Base de datos SQLite local
- **http**: Cliente HTTP para llamadas REST
- **connectivity_plus**: Detección de conectividad
- **uuid**: Generación de IDs únicos

### Backend (Mock API)
- **json-server**: Servidor REST mock para desarrollo

## Estructura del Proyecto
```
lib/
├── core/                           # Utilidades y configuración compartida
│   ├── constants/
│   │   └── api_constants.dart      # URLs, endpoints, timeouts
│   ├── exceptions/
│   │   └── api_exception.dart      # Excepciones personalizadas
│   ├── utils/
│   │   └── connectivity_helper.dart # Helper de conectividad
│   └── di/
│       └── dependency_injection.dart # Inyección de dependencias
│
├── domain/                         # Capa de dominio (lógica de negocio)
│   ├── entities/
│   │   └── task.dart               # Entidad Task
│   └── repositories/
│       └── task_repository.dart    # Interfaz del repositorio
│
├── data/                           # Capa de datos
│   ├── local/                      # Persistencia local
│   │   ├── database/
│   │   │   ├── database_helper.dart
│   │   │   ├── task_local_data_source.dart
│   │   │   └── queue_operation_local_data_source.dart
│   │   └── models/
│   │       ├── task_local_model.dart
│   │       └── queue_operation_model.dart
│   │
│   ├── remote/                     # API REST
│   │   ├── api/
│   │   │   ├── api_client.dart
│   │   │   └── task_remote_data_source.dart
│   │   └── models/
│   │       └── task_remote_model.dart
│   │
│   └── repositories/               # Implementación de repositorios
│       └── task_repository_impl.dart
│
├── presentation/                   # Capa de presentación
│   ├── providers/
│   │   ├── task_provider.dart      # Estado de tareas
│   │   └── connectivity_provider.dart # Estado de conectividad
│   ├── screens/
│   │   └── home_screen.dart        # Pantalla principal
│   └── widgets/
│       ├── task_list.dart
│       ├── task_item.dart
│       ├── task_input_dialog.dart
│       ├── task_edit_dialog.dart
│       └── connectivity_banner.dart
│
└── main.dart                       # Punto de entrada de la aplicación
```

### Explicación de Capas

#### **Domain Layer** (Dominio)
- **Responsabilidad**: Define las entidades de negocio y contratos (interfaces)
- **Independencia**: No depende de ninguna otra capa
- **Ejemplo**: `Task` entity, `TaskRepository` interface

#### **Data Layer** (Datos)
- **Responsabilidad**: Implementa el acceso a datos (local y remoto)
- **Componentes**:
  - **Local**: SQLite para persistencia offline
  - **Remote**: Cliente HTTP para API REST
  - **Repositories**: Coordina entre local y remoto
- **Ejemplo**: `TaskRepositoryImpl` decide si leer de local o remoto

#### **Presentation Layer** (Presentación)
- **Responsabilidad**: UI y gestión de estado
- **Componentes**:
  - **Providers**: Estado reactivo con Provider
  - **Screens**: Páginas de la aplicación
  - **Widgets**: Componentes reutilizables
- **Ejemplo**: `TaskProvider` expone métodos y estado a la UI

## Instalación

### Prerrequisitos

- Flutter SDK 3.x o superior
- Dart SDK 3.x o superior
- Node.js (para json-server)
- Android Studio / Xcode (para emuladores)

### Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd electiva-profesional-1-To-Do-List
```

### Instalar dependencias de Flutter
```bash
flutter pub get
```

## Configuración del Mock API

### 1. Instalar json-server
```bash
npm install -g json-server
```

### 2. Crear el archivo de datos mock

En una carpeta separada, crea `db.json`:
```json
{
  "tasks": [
    {
      "id": "1",
      "title": "Comprar leche",
      "completed": false,
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    {
      "id": "2",
      "title": "Estudiar Flutter",
      "completed": true,
      "updatedAt": "2025-11-14T09:30:00.000Z"
    }
  ]
}
```

### 3. Iniciar el servidor
```bash
json-server --watch db.json --port 3000
```

El servidor estará disponible en `http://localhost:3000`

### 4. Configurar la URL en la app

Edita `lib/core/constants/api_constants.dart`:
```dart
// Para Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// Para iOS Simulator
static const String baseUrl = 'http://localhost:3000';

// Para dispositivo físico (usa tu IP local)
static const String baseUrl = 'http://192.168.1.100:3000';
```

Para obtener tu IP local:
- **Windows**: `ipconfig`
- **Mac/Linux**: `ifconfig` o `ip addr`

## ▶Ejecutar la Aplicación

### En modo debug
```bash
flutter run
```

### En modo release
```bash
flutter run --release
```

### Seleccionar dispositivo específico
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en un dispositivo específico
flutter run -d <device-id>
```

## Probar Modo Offline

### Crear tarea sin conexión

1. **Activar modo avión** en tu dispositivo/emulador
2. Deberías ver un **banner naranja** indicando "Sin conexión"
3. **Crear una nueva tarea**:
   - Presiona el botón `+`
   - Escribe el título
   - Presiona "Crear"
4. La tarea se guarda **localmente** en SQLite
5. **Verificar persistencia**:
   - Cierra la app completamente
   - Vuelve a abrirla
   - La tarea debería seguir ahí

### Sincronización automática

1. Con tareas creadas offline, **desactiva el modo avión**
2. Deberías ver un **banner verde** indicando "Conexión restablecida. Sincronizando..."
3. La app sincroniza automáticamente las operaciones pendientes
4. **Verificar en el servidor**:
```bash
   curl http://localhost:3000/tasks
```
5. Las tareas creadas offline ahora están en el servidor

### Editar/Eliminar offline

1. Activa modo avión
2. Edita una tarea existente
3. Elimina otra tarea
4. Todas las operaciones se **encolan** para sincronización
5. Al recuperar conexión, se sincronizan automáticamente

### Sincronización manual

1. Con conexión activa, presiona el botón de **sincronización** (⟳) en el AppBar
2. Fuerza la sincronización de operaciones pendientes
3. Verás un mensaje: "Sincronización completada"

## Generar APK

### APK de Release
```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Generar APK
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

### APK Split por ABI (menor tamaño)
```bash
flutter build apk --split-per-abi --release
```

Esto genera APKs separados para cada arquitectura:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit)
- `app-x86_64-release.apk` (x86 64-bit)

## Estrategia de Sincronización

### Operaciones

- **CREATE**: Crea la tarea en el servidor
- **UPDATE**: Actualiza la tarea en el servidor
- **DELETE**: Elimina la tarea del servidor

### Manejo de Reintentos

- Máximo **5 intentos** por operación
- Se registra el `attempt_count` y `last_error`
- Backoff exponencial entre reintentos

### Resolución de Conflictos

- **Last-Write-Wins (LWW)**: Se compara `updatedAt`
- La versión más reciente prevalece
