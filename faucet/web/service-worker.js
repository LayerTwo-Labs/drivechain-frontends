const CACHE_NAME = "faucet-cache-v1";
const TIMESTAMP = new Date().getTime();

// Add files you want to cache
const urlsToCache = [
  "/",
  "/index.html",
  "/main.dart.js",
  "/flutter.js",
  "/flutter_bootstrap.js",
  "/favicon.png",
  "/manifest.json",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      // Add timestamp to URLs to bust cache
      const urlsWithTimestamp = urlsToCache.map((url) =>
        url.includes("?") ? `${url}&v=${TIMESTAMP}` : `${url}?v=${TIMESTAMP}`
      );
      return cache.addAll(urlsWithTimestamp);
    })
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      // Always try to fetch new version from network first
      return fetch(event.request)
        .then((networkResponse) => {
          // Update cache with new version
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, networkResponse.clone());
          });
          return networkResponse;
        })
        .catch(() => {
          // If network fetch fails, return from cache
          return response;
        });
    })
  );
});
