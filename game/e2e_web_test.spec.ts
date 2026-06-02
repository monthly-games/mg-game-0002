import { test, expect } from '@playwright/test';

const BASE_URL = 'https://mg-games-dev.web.app';

test.describe('MG-0002 Cat Alchemy Workshop - E2E Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(BASE_URL);
    // Wait for app to load completely
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);
    // Wait for Flutter app to initialize
    await page.waitForSelector('body', { timeout: 10000 });
  });

  test('Main menu loads correctly', async ({ page }) => {
    // Verify game ID and title
    await expect(page.locator('text=MG-0002')).toBeVisible();
    await expect(page.locator('text=Cat Alchemy Workshop')).toBeVisible();

    // Verify core fun loop is displayed
    await expect(page.locator('text=Core Fun')).toBeVisible();

    // Verify main menu buttons
    await expect(page.getByRole('button', { name: /Start Game/i })).toBeVisible();
    await expect(page.getByRole('button', { name: /Level Roadmap/i })).toBeVisible();
  });

  test('Start game and verify gameplay loop', async ({ page }) => {
    // Click Start Game
    await page.getByRole('button', { name: /Start Game/i }).click();
    await page.waitForTimeout(1000);

    // Verify game screen is loaded
    await expect(page.locator('text=Live Run')).toBeVisible();
    await expect(page.locator('text=Level 1')).toBeVisible();

    // Verify Complete Action button
    const completeButton = page.getByRole('button', { name: /Complete Action/i });
    await expect(completeButton).toBeVisible();

    // Complete first action
    await completeButton.click();
    await page.waitForTimeout(500);

    // Verify progression to Level 2
    await expect(page.locator('text=Level 2')).toBeVisible();
  });

  test('Multi-level progression', async ({ page }) => {
    await page.getByRole('button', { name: /Start Game/i }).click();
    await page.waitForTimeout(1000);

    const completeButton = page.getByRole('button', { name: /Complete Action/i });

    // Complete 5 actions
    for (let i = 0; i < 5; i++) {
      await completeButton.click();
      await page.waitForTimeout(300);
    }

    // Verify reached Level 6
    await expect(page.locator('text=Level 6')).toBeVisible();
  });

  test('Level roadmap navigation', async ({ page }) => {
    await page.getByRole('button', { name: /Level Roadmap/i }).click();
    await page.waitForTimeout(1000);

    // Verify roadmap screen
    await expect(page.locator('text=Level Roadmap')).toBeVisible();

    // Verify level list exists
    await expect(page.locator('text=Level 1')).toBeVisible();
    await expect(page.locator('text=Level 10')).toBeVisible();
  });

  test('Daily quests screen', async ({ page }) => {
    await page.getByRole('button', { name: /Daily/i }).click();
    await page.waitForTimeout(1000);

    await expect(page.locator('text=Daily Quests')).toBeVisible();
  });

  test('Tournament screen', async ({ page }) => {
    await page.getByRole('button', { name: /Tournament/i }).click();
    await page.waitForTimeout(1000);

    await expect(page.locator('text=Tournament')).toBeVisible();
  });

  test('Guild War screen', async ({ page }) => {
    await page.getByRole('button', { name: /Guild/i }).click();
    await page.waitForTimeout(1000);

    await expect(page.locator('text=Guild War')).toBeVisible();
  });

  test('Seasonal Event screen', async ({ page }) => {
    await page.getByRole('button', { name: /Event/i }).click();
    await page.waitForTimeout(1000);

    await expect(page.locator('text=Seasonal Event')).toBeVisible();
  });

  test('Rewards screen', async ({ page }) => {
    await page.getByRole('button', { name: /Rewards/i }).click();
    await page.waitForTimeout(1000);

    await expect(page.locator('text=Progression loop')).toBeVisible();
  });

  test('Engine loop screen', async ({ page }) => {
    await page.getByRole('button', { name: /Engine/i }).click();
    await page.waitForTimeout(1000);

    await expect(page.locator('text=GameWidget frame loop')).toBeVisible();
  });

  test('Full game loop stress test', async ({ page }) => {
    await page.getByRole('button', { name: /Start Game/i }).click();
    await page.waitForTimeout(1000);

    const completeButton = page.getByRole('button', { name: /Complete Action/i });

    // Complete 10 actions rapidly
    for (let i = 0; i < 10; i++) {
      await completeButton.click();
      await page.waitForTimeout(200);
    }

    // Verify app still responsive
    await expect(completeButton).toBeVisible();
  });

  test('Navigation flow test', async ({ page }) => {
    const routes = [
      { button: /Start Game/i, verify: /Live Run/i },
      { button: /Level Roadmap/i, verify: /Level Roadmap/i },
      { button: /Daily/i, verify: /Daily Quests/i },
      { button: /Rewards/i, verify: /Progression loop/i },
      { button: /Tournament/i, verify: /Tournament/i },
      { button: /Guild/i, verify: /Guild War/i },
      { button: /Event/i, verify: /Seasonal Event/i },
      { button: /Engine/i, verify: /GameWidget frame loop/i },
    ];

    for (const route of routes) {
      await page.getByRole('button', { name: route.button }).click();
      await page.waitForTimeout(500);
      await expect(page.locator(`text=${route.verify}`)).toBeVisible();

      // Navigate back
      await page.goBack();
      await page.waitForTimeout(500);
    }

    // Verify returned to main menu
    await expect(page.locator('text=MG-0002')).toBeVisible();
  });

  test('Reward accumulation test', async ({ page }) => {
    await page.getByRole('button', { name: /Start Game/i }).click();
    await page.waitForTimeout(1000);

    const completeButton = page.getByRole('button', { name: /Complete Action/i });

    // Complete 3 actions
    for (let i = 0; i < 3; i++) {
      await completeButton.click();
      await page.waitForTimeout(300);
    }

    // Verify reward indicators are visible
    await expect(page.locator('text=gold')).toBeVisible();
    await expect(page.locator('text=xp')).toBeVisible();
  });

  test('Responsive design test', async ({ page }) => {
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.reload();
    await page.waitForTimeout(2000);

    await expect(page.locator('text=MG-0002')).toBeVisible();

    // Test tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.reload();
    await page.waitForTimeout(2000);

    await expect(page.locator('text=MG-0002')).toBeVisible();

    // Test desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.reload();
    await page.waitForTimeout(2000);

    await expect(page.locator('text=MG-0002')).toBeVisible();
  });
});
