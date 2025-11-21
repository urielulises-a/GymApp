# Deployment Guide — Flutter Web (UI-only)

## Build
```bash
flutter build web --release --web-renderer skwasm
```

## Hosting
- **GitHub Pages / Netlify / Vercel**: publicar `build/web/`.
- **Nginx/Apache/S3**: servir `build/web/` con fallback a `index.html`.

## Consideraciones
- Comprimir estáticos (gzip/brotli).
- `Cache-Control` largo para assets, corto para `index.html`.
- Si se hospeda en subruta, ajustar `<base href>` en `web/index.html`.
