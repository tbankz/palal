import netlifyIdentity from 'https://esm.sh/@netlify/identity@1.2.0';

export function initNetlifyIdentity() {
  if (typeof window !== 'undefined' && typeof netlifyIdentity?.init === 'function') {
    netlifyIdentity.init();
  }
}

export function loginWithProvider(provider) {
  if (typeof window !== 'undefined' && typeof netlifyIdentity?.login === 'function') {
    return netlifyIdentity.login({ provider });
  }
  return null;
}
