class ClaimUtils {
  ClaimUtils._();

  static String generateClaimNumber(
    int count,
  ) {
    return 'CLM-${(count + 1).toString().padLeft(3, '0')}';
  }
}
