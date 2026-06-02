import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright Configuration for MG-0002 Cat Alchemy Workshop
 *
 * Optimized for Flutter Web E2E testing with extended timeouts
 * for Flutter app initialization.
 */

export default defineConfig({
  // Test directory
  testDir: './',
  testMatch: '**/e2e_web.spec.ts',

  // Extended timeout for Flutter app initialization
  timeout: 60 * 1000,
  expect: {
    timeout: 15 * 1000,
  },

  // Run tests in parallel for faster execution
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : 4,

  // Reporters
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['list'],
  ],

  // Shared settings for all tests
  use: {
    // Base URL for tests - can be overridden by TEST_URL env var
    baseURL: process.env.TEST_URL || 'http://localhost:8081',

    // Collect trace on first retry for debugging
    trace: 'on-first-retry',

    // Capture screenshot on failure
    screenshot: 'only-on-failure',

    // Record video on failure
    video: 'retain-on-failure',

    // Wait for network to be idle before considering navigation complete
    navigationTimeout: 30000,
  },

  // Test projects targeting different browsers/viewport
  projects: [
    {
      name: 'chromium-desktop',
      use: {
        ...devices['Desktop Chrome'],
        viewport: { width: 1280, height: 720 },
      },
    },

    {
      name: 'chromium-mobile',
      use: {
        ...devices['Pixel 5'],
      },
    },

    {
      name: 'firefox-desktop',
      use: {
        ...devices['Desktop Firefox'],
        viewport: { width: 1280, height: 720 },
      },
    },

    {
      name: 'webkit-desktop',
      use: {
        ...devices['Desktop Safari'],
        viewport: { width: 1280, height: 720 },
      },
    },
  ],

  // Local development server
  webServer: {
    command: 'python -m http.server 8081 --directory build/web',
    port: 8081,
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
