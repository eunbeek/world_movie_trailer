{{flutter_js}}
{{flutter_build_config}}

function showStartupError(error) {
  console.error('Flutter failed to start:', error);
  const loading = document.getElementById('app-loading');
  if (loading) {
    loading.innerHTML = '<div style="text-align:center;padding:24px">' +
      '<div>앱을 불러오지 못했습니다.</div>' +
      '<button onclick="location.reload()">새로고침</button></div>';
  }
}

function removeLegacyFlutterCache() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(function (registrations) {
      registrations.forEach(function (registration) {
        registration.unregister();
      });
    }).catch(function (error) {
      console.warn('Could not remove old service worker:', error);
    });
  }

  if ('caches' in window) {
    caches.keys().then(function (cacheNames) {
      cacheNames.forEach(function (cacheName) {
        caches.delete(cacheName);
      });
    }).catch(function (error) {
      console.warn('Could not clear old Flutter cache:', error);
    });
  }
}

async function startFlutter() {
  const timeout = setTimeout(function () {
    showStartupError(new Error('Flutter first frame timed out'));
  }, 20000);

  window.addEventListener('flutter-first-frame', function () {
    clearTimeout(timeout);
    const loading = document.getElementById('app-loading');
    if (loading) loading.remove();
  }, { once: true });

  // iOS WebViews can leave Cache API promises pending indefinitely. Cleanup
  // must never block Flutter startup.
  removeLegacyFlutterCache();
  await _flutter.loader.load({ serviceWorkerSettings: null });
}

startFlutter().catch(showStartupError);
