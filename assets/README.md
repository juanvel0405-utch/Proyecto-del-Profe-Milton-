# Archivos necesarios para el reproductor de audio

Esta carpeta debe contener los siguientes archivos para que la aplicación funcione correctamente:

## Archivos de audio (MP3):
- `allthat.mp3` - Canción "All that" por Mayelo
- `love.mp3` - Canción "Love" por Diego  
- `thejazzpiano.mp3` - Canción "Jazz Piano" por Jazira

## Archivos de imagen (JPG):
- `allthat_colored.jpg` - Portada para "All that"
- `love_colored.jpg` - Portada para "Love"
- `thejazzpiano_colored.jpg` - Portada para "Jazz Piano"

## Nota:
Los archivos de audio deben estar directamente en la carpeta `assets/`.
Las imágenes también deben estar en la carpeta `assets/`.

Para agregar más canciones, edita el archivo `lib/views/player.dart` y agrega nuevos objetos `AudioItem` a la lista `canciones`.

