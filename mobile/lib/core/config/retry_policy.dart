/// Riverpod 3 retries a failed provider on its own, and while it retries
/// the page shows its skeleton for many seconds. Every page here has its
/// own "Try again" button, so a failure is shown at once instead.
Duration? noAutoRetry(int retryCount, Object error) => null;
