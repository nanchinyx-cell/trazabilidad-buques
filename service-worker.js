const CACHE_NAME = 'v1_trazabilidad_buques';
const ASSETS = [
  './index.html',
  'https://unpkg.com/leaflet/dist/leaflet.css',
  'https://unpkg.com/leaflet/dist/leaflet.js'
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS).catch(() => console.log('Algunos recursos no pudieron cachearse'));
    })
  );
});

self.addEventListener('fetch', (e) => {
  e.respondWith(
    fetch(e.request)
      .then(response => {
        const clonedResponse = response.clone();
        caches.open(CACHE_NAME).then(cache => {
          cache.put(e.request, clonedResponse);
        });
        return response;
      })
      .catch(() => caches.match(e.request))
  );
});