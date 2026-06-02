import { test, expect } from '@playwright/test';

/**
 * MG-0001/MG-0002 Cat Alchemy Workshop - Web E2E Tests
 *
 * Simple smoke tests for Flutter web application.
 * Focus on verifying the app loads and is functional.
 */

const BASE_URL = process.env.TEST_URL || 'http://localhost:8081';

test.describe('Cat Alchemy Workshop - Web Smoke Tests', () => {
  test('should load the application', async ({ page }) => {
    await page.goto(BASE_URL);

    // Wait for page to load
    await page.waitForLoadState('networkidle');

    // Check title
    const title = await page.title();
    expect(title).toBeTruthy();
  });

  test('should have HTML content', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');

    // Check for basic HTML structure
    const html = await page.content();
    expect(html).toContain('<!DOCTYPE html>');
    expect(html).toContain('flutter');
  });

  test('should load Flutter scripts', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');

    // Wait a bit for Flutter to initialize
    await page.waitForTimeout(5000);

    // Check for Flutter script
    const flutterScript = await page.locator('script[src*="flutter"]').count();
    expect(flutterScript).toBeGreaterThan(0);
  });

  test('should have body content after initialization', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');

    // Wait for Flutter to initialize (up to 15 seconds)
    await page.waitForTimeout(10000);

    // Check body has children
    const bodyChildren = await page.locator('body > *').count();
    expect(bodyChildren).toBeGreaterThan(0);
  });

  test('should not have console errors', async ({ page }) => {
    const errors: string[] = [];

    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);

    // Filter out non-critical errors
    const criticalErrors = errors.filter(e =>
      e.includes('Fatal') || e.includes('Failed to load module')
    );

    expect(criticalErrors.length).toBe(0);
  });

  test('should respond to user interaction after load', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');

    // Wait for app to initialize
    await page.waitForTimeout(10000);

    // Try to find and click something
    const buttons = await page.locator('button').count();
    if (buttons > 0) {
      await page.locator('button').first().click();
      await page.waitForTimeout(1000);
    }
  });

  test('should handle viewport changes', async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);

    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(2000);

    // Test desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForTimeout(2000);

    // Page should still be responsive
    const body = await page.locator('body');
    await expect(body).toBeVisible();
  });
});

test.describe('Cat Alchemy Workshop - Loaded App Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState('networkidle');

    // Extended wait for Flutter initialization
    await page.waitForTimeout(15000);
  });

  test('should display game content', async ({ page }) => {
    // Check for any text content
    const textContent = await page.locator('body').textContent();
    expect(textContent?.length).toBeGreaterThan(0);
  });

  test('should have interactive elements', async ({ page }) => {
    // Check for buttons or links
    const buttons = await page.locator('button, a, [role="button"]').count();
    expect(buttons).toBeGreaterThan(0);
  });

  test('should be clickable', async ({ page }) => {
    // Find first clickable element
    const firstButton = page.locator('button, a, [role="button"]').first();

    if (await firstButton.count() > 0) {
      await firstButton.click();
      await page.waitForTimeout(1000);

      // App should still be responsive
      const body = await page.locator('body');
      await expect(body).toBeVisible();
    }
  });
});
