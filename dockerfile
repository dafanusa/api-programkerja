# Gunakan image Dart resmi
FROM dart:stable AS build

# Salin semua file proyek ke container
WORKDIR /app
COPY . .

# Get dependencies
RUN dart pub get

# Jalankan aplikasi
CMD ["dart", "run", "bin/api_programkerja.dart"]
