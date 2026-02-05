# User Management App - Prueba Técnica

Aplicación móvil desarrollada en Flutter para la gestión de usuarios y direcciones, con persistencia local y arquitectura escalable.

---

##  Entorno de Desarrollo
*   **Flutter SDK**: 3.35.4
*   **Dart SDK**: 3.4.3

---

##  Decisiones Técnicas y Arquitectura

### Clean Architecture
El proyecto se ha estructurado en capas para garantizar el desacoplamiento y la facilidad de mantenimiento:
*   **Domain**: Entidades puras y contratos de repositorios. Contiene la lógica de negocio (validaciones de edad y formatos).
*   **Data**: Implementación de repositorios y modelos de datos de **Isar**. Mantiene la persistencia aislada del dominio.
*   **Presentation**: Capa de interfaz de usuario y gestión de estado mediante **Riverpod**.
*   **Core**: Manejo de errores personalizados (`Failures`) y configuración de temas.

### Gestión de Estado: Riverpod
Se seleccionó **Riverpod** por su robustez y seguridad en tiempo de compilación. El uso de `.autoDispose` permite una gestión eficiente de la memoria, garantizando que los estados de los formularios se reinicien al navegar.

### Persistencia: Isar Database
Se utilizó **Isar** por su alto rendimiento y manejo nativo de relaciones (`IsarLinks`), facilitando la gestión de múltiples direcciones por usuario de forma asíncrona y eficiente.

### Manejo de Errores
Se implementó el patrón **Result** mediante la librería `dartz` (`Either<Failure, T>`). Esto asegura que los errores sean tratados como datos y no como excepciones, facilitando el feedback visual (SnackBars) al usuario sin interrumpir la experiencia.

---

##  UI/UX y Diseño
*   **Material 3**: Soporte completo para temas claro y oscuro con switch dinámico en tiempo real.
*   **Diseño Moderno**: Inputs con etiquetas flotantes y bordes redondeados, siguiendo estándares de aplicaciones.
*   **Experiencia Móvil**: Uso de Modales (Bottom Sheets) para la gestión de direcciones secundarias, optimizando el espacio en pantalla.

---

##  Testing (Cobertura > 60%)
Suite de pruebas integrada para asegurar la calidad y estabilidad del código:
*   **Unit Tests**: Validación de lógica de negocio en entidades y manejo de estados en Notifiers.
*   **Widget Tests**: Verificación de renderizado y estados de carga/error en la interfaz principal.
*   **Mocks**: Uso de `mocktail` para desacoplar las pruebas de la persistencia real.

---

##  Instalación y Ejecución

1. **Obtener dependencias:**
   ```bash
   flutter pub get
   ```

2. **Generación de código:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Generar APK:**
   ```bash
   cd P:\flutter_user_management | P:\flutter_user_management\.fvm\flutter_sdk\bin\flutter.bat build apk --release
   ```

---
