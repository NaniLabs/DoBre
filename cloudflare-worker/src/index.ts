import { appConfig } from './config';

const jsonHeaders = {
  'content-type': 'application/json; charset=utf-8',
  'cache-control': 'public, max-age=300, s-maxage=300',
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, OPTIONS',
  'access-control-allow-headers': 'content-type',
  'x-content-type-options': 'nosniff',
} as const;

function jsonResponse(body: unknown, init?: ResponseInit): Response {
  return new Response(JSON.stringify(body, null, 2), {
    ...init,
    headers: {
      ...jsonHeaders,
      ...(init?.headers ?? {}),
    },
  });
}

export default {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: jsonHeaders,
      });
    }

    if (request.method !== 'GET') {
      return jsonResponse(
        {
          error: 'Method Not Allowed',
          allowedMethods: ['GET', 'OPTIONS'],
        },
        { status: 405 },
      );
    }

    if (url.pathname === '/config') {
      // Endpoint principal consumido por Flutter.
      // Debe mantenerse 100% compatible con AppConfig.
      return jsonResponse(appConfig, { status: 200 });
    }

    if (url.pathname === '/' || url.pathname === '/health') {
      return jsonResponse(
        {
          service: 'dobre-config-worker',
          status: 'ok',
          configEndpoint: '/config',
          version: appConfig.version,
        },
        { status: 200 },
      );
    }

    return jsonResponse(
      {
        error: 'Not Found',
        availableEndpoints: ['/', '/health', '/config'],
      },
      { status: 404 },
    );
  },
};
