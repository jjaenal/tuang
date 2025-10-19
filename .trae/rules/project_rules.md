# Project Rules

## Linting

- jalankan `flutter analyze` setiap setelah melakukan perubahan untuk memeriksa linting
- Perbaiki semua linting warnings, deprecations, hint, etc.

## Testing

- Buat unit test untuk setiap fungsi yang dibuat untuk masing-masing file
- jalankan `flutter test` setiap setelah melakukan perubahan untuk memeriksa testing

## Development

Berikan komentar pada setiap blok kode yang diubah, termasuk penjelasan tentang fungsinya dan cara kerja

- Class comment:
  - Berikan komentar pada setiap class yang dibuat, termasuk parameter, return value, dan penjelasan tentang class dan cara kerja.
- Function comment:
  - Berikan komentar pada setiap fungsi yang dibuat, termasuk parameter, return value, dan penjelasan tentang fungsinya dan cara kerja.
- Block comment:
  - Berikan komentar pada setiap blok kode yang diubah, termasuk penjelasan tentang fungsinya dan cara kerja.

## Commit

- Buat branch baru untuk perubahan yang major, misalnya perubahan yang mengubah struktur kode, menambahkan fitur baru, atau memperbaiki bug yang tidak terduga.
- Jalankan `git commit -m "commit message"` setiap setelah melakukan perubahan minimal 1 file tunggal atau yang ada relasi ke file lain, commit message harus mengandung nama file yang diubah dan penjelasan singkat tentang perubahan tersebut:

- fitur baru `Add new feature`
- Fixed bug `Fix bug`
- Refactor code `Refactor code`
- Update documentation `Update documentation`

<!-- ## Pull Request

jalankan `git push origin <nama branch>` setiap setelah melakukan perubahan untuk memasukkan commit -->

## Documentation

- Update TODO.md setiap setelah selesai melakukan perubahan

- Update README.md setiap setelah selesai melakukan perubahan

README.md harus mengandung:

- Nama project
- Nama developer
- Nama file yang diubah
- Penjelasan singkat tentang perubahan tersebut
